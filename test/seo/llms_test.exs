defmodule SEO.LLMsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias SEO.LLMs.Entry

  defmodule StaticProvider do
    @behaviour SEO.LLMs.Provider

    @impl true
    def sections do
      [
        {"Docs",
         [
           {"API Reference", "https://example.com/docs/api.md", "Full REST API docs"},
           {"Guides", "https://example.com/docs/guides.md"}
         ]},
        {"Optional",
         [
           {"Changelog", "https://example.com/changelog.md"}
         ]}
      ]
    end
  end

  test "provider module returns sections" do
    sections = StaticProvider.sections()
    assert [{"Docs", docs}, {"Optional", optional}] = sections
    assert [{"API Reference", _, "Full REST API docs"}, {"Guides", _}] = docs
    assert [{"Changelog", _}] = optional
  end

  describe "render/1" do
    test "renders full llms.txt markdown with all sections" do
      opts = %{
        title: "My App",
        description: "A project management tool for teams",
        sections: [
          {"Docs",
           [
             {"API Reference", "https://example.com/docs/api.md", "Full REST API docs"},
             {"Guides", "https://example.com/docs/guides.md"}
           ]},
          {"Optional",
           [
             {"Changelog", "https://example.com/changelog.md"}
           ]}
        ]
      }

      result = SEO.LLMs.render(opts)

      assert result ==
               """
               # My App

               > A project management tool for teams

               ## Docs

               - [API Reference](https://example.com/docs/api.md): Full REST API docs
               - [Guides](https://example.com/docs/guides.md)

               ## Optional

               - [Changelog](https://example.com/changelog.md)
               """
               |> String.trim_leading()
               |> String.trim_trailing()
    end

    test "renders with body text" do
      opts = %{
        title: "My App",
        description: "A tool for teams",
        body: "Key things to know:\n- It uses Phoenix\n- It requires Elixir 1.14+",
        sections: []
      }

      result = SEO.LLMs.render(opts)

      assert result =~ "# My App"
      assert result =~ "> A tool for teams"
      assert result =~ "Key things to know:"
      assert result =~ "- It uses Phoenix"
    end

    test "renders without description" do
      opts = %{title: "My App", sections: []}

      result = SEO.LLMs.render(opts)

      assert result == "# My App"
    end

    test "renders without sections" do
      opts = %{title: "My App", description: "A tool", sections: []}

      result = SEO.LLMs.render(opts)

      assert result == "# My App\n\n> A tool"
    end
  end

  describe "render/1 with nested sub-sections" do
    test "renders H3 sub-sections within H2 sections" do
      opts = %{
        title: "My App",
        sections: [
          {"SDKs",
           [
             {"TypeScript",
              [
                {"Client SDK", "/sdk/ts", "TypeScript client"},
                {"Server SDK", "/sdk/ts-server"}
              ]},
             {"Python",
              [
                {"Client SDK", "/sdk/py", "Python client"}
              ]}
           ]}
        ]
      }

      result = SEO.LLMs.render(opts)

      assert result =~ "## SDKs"
      assert result =~ "### TypeScript"
      assert result =~ "- [Client SDK](/sdk/ts): TypeScript client"
      assert result =~ "- [Server SDK](/sdk/ts-server)"
      assert result =~ "### Python"
      assert result =~ "- [Client SDK](/sdk/py): Python client"
    end

    test "renders inline markdown strings in sections" do
      opts = %{
        title: "My App",
        sections: [
          {"Overview",
           [
             "Turso is a SQLite-compatible database built for modern applications.",
             {"Quick Start", "/docs/start", "Get running in 5 minutes"}
           ]}
        ]
      }

      result = SEO.LLMs.render(opts)

      assert result =~ "## Overview"
      assert result =~ "Turso is a SQLite-compatible database"
      assert result =~ "- [Quick Start](/docs/start): Get running in 5 minutes"
    end

    test "renders mixed content: strings, links, and sub-sections" do
      opts = %{
        title: "Docs",
        sections: [
          {"Guide",
           [
             "This guide covers the basics of the platform.",
             {"Getting Started", "/docs/start"},
             {"Installation", "/docs/install", "How to install"},
             {"Advanced",
              [
                {"Configuration", "/docs/config"},
                {"Deployment", "/docs/deploy"}
              ]}
           ]}
        ]
      }

      result = SEO.LLMs.render(opts)

      assert result =~ "## Guide"
      assert result =~ "This guide covers the basics"
      assert result =~ "- [Getting Started](/docs/start)"
      assert result =~ "- [Installation](/docs/install): How to install"
      assert result =~ "### Advanced"
      assert result =~ "- [Configuration](/docs/config)"
      assert result =~ "- [Deployment](/docs/deploy)"
    end

    test "consecutive links are separated by single newlines" do
      opts = %{
        title: "App",
        sections: [
          {"Docs",
           [
             {"One", "/one"},
             {"Two", "/two"},
             {"Three", "/three"}
           ]}
        ]
      }

      result = SEO.LLMs.render(opts)

      assert result =~ "- [One](/one)\n- [Two](/two)\n- [Three](/three)"
    end
  end

  describe "plug with static sections" do
    test "serves llms.txt with text/markdown content type" do
      opts =
        SEO.LLMs.init(
          title: "Test App",
          description: "A test application",
          sections: [
            {"Docs", [{"Guide", "https://example.com/guide.md"}]}
          ]
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      assert conn.status == 200
      assert {"content-type", "text/markdown; charset=utf-8"} in conn.resp_headers
      assert conn.resp_body =~ "# Test App"
      assert conn.resp_body =~ "> A test application"
      assert conn.resp_body =~ "[Guide](https://example.com/guide.md)"
    end

    test "serves llms.txt at root path" do
      opts = SEO.LLMs.init(title: "App", sections: [])

      conn =
        conn(:get, "/")
        |> SEO.LLMs.call(opts)

      assert conn.status == 200
      assert conn.resp_body =~ "# App"
    end
  end

  describe "plug with provider" do
    test "resolves sections from provider module" do
      opts =
        SEO.LLMs.init(
          title: "Provider App",
          provider: SEO.LLMsTest.StaticProvider
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      assert conn.status == 200
      assert conn.resp_body =~ "# Provider App"
      assert conn.resp_body =~ "## Docs"

      assert conn.resp_body =~
               "[API Reference](https://example.com/docs/api.md): Full REST API docs"

      assert conn.resp_body =~ "## Optional"
      assert conn.resp_body =~ "[Changelog](https://example.com/changelog.md)"
    end
  end

  describe "plug with SEO config" do
    test "derives title from open_graph.site_name and description from site.description" do
      opts =
        SEO.LLMs.init(
          config: MyAppWeb.SEO,
          sections: [
            {"Posts", [{"Latest", "https://example.com/posts.md"}]}
          ]
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      assert conn.status == 200
      assert conn.resp_body =~ "# David Bernheisel's Blog"
      assert conn.resp_body =~ "> A blog about development"
      assert conn.resp_body =~ "[Latest](https://example.com/posts.md)"
    end

    test "explicit title/description override config values" do
      opts =
        SEO.LLMs.init(
          config: MyAppWeb.SEO,
          title: "Override Title",
          description: "Override description",
          sections: []
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      assert conn.resp_body =~ "# Override Title"
      assert conn.resp_body =~ "> Override description"
      refute conn.resp_body =~ "David Bernheisel"
    end
  end

  describe "behaviour-based ArticleMD" do
    test "entry/1 returns an Entry for an article" do
      article = %MyApp.Article{id: "test", title: "Test Post", description: "A test post"}
      entry = MyAppWeb.ArticleMD.entry(article)

      assert %Entry{
               section: "Articles",
               title: "Test Post",
               url: "https://example.com/articles/test",
               description: "A test post"
             } = entry
    end

    test "show/1 renders markdown content" do
      article = %MyApp.Article{id: "test", title: "Test Post", description: "A test post"}
      content = MyAppWeb.ArticleMD.show(%{article: article})

      assert content == "# Test Post\n\nA test post"
    end
  end

  describe "behaviour-driven provider integration" do
    defmodule ArticleProvider do
      @behaviour SEO.LLMs.Provider

      @impl true
      def sections do
        articles = [
          %MyApp.Article{id: "first", title: "First Post", description: "The first post"},
          %MyApp.Article{id: "second", title: "Second Post", description: "The second post"}
        ]

        entries = Enum.map(articles, &MyAppWeb.ArticleMD.entry/1)
        dynamic = Entry.group_by_section(entries)

        static = [
          {"Docs", [{"Getting Started", "https://example.com/docs/start.md", "Setup guide"}]}
        ]

        static ++ dynamic
      end
    end

    test "full flow: behaviour → provider → plug renders index" do
      opts =
        SEO.LLMs.init(
          title: "My Blog",
          description: "A blog about Elixir",
          provider: SEO.LLMsTest.ArticleProvider
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      assert conn.status == 200
      assert conn.resp_body =~ "# My Blog"
      assert conn.resp_body =~ "> A blog about Elixir"

      # Static section
      assert conn.resp_body =~ "## Docs"
      assert conn.resp_body =~ "[Getting Started](https://example.com/docs/start.md): Setup guide"

      # Dynamic behaviour-derived section
      assert conn.resp_body =~ "## Articles"
      assert conn.resp_body =~ "[First Post](https://example.com/articles/first): The first post"

      assert conn.resp_body =~
               "[Second Post](https://example.com/articles/second): The second post"
    end
  end

  describe "Entry" do
    test "build/1 creates entry from keyword list" do
      entry =
        Entry.build(
          section: "Docs",
          title: "API",
          url: "/api",
          description: "API docs"
        )

      assert %Entry{
               section: "Docs",
               title: "API",
               url: "/api",
               description: "API docs"
             } = entry
    end

    test "build/2 merges with defaults" do
      defaults = Entry.build(section: "Docs")
      entry = Entry.build([title: "API", url: "/api"], defaults)

      assert entry.section == "Docs"
      assert entry.title == "API"
    end

    test "group_by_section/1 groups entries into section tuples" do
      entries = [
        Entry.build(section: "Docs", title: "API", url: "/api"),
        Entry.build(
          section: "Docs",
          title: "Guide",
          url: "/guide",
          description: "Getting started"
        ),
        Entry.build(section: "Optional", title: "FAQ", url: "/faq")
      ]

      sections = Entry.group_by_section(entries)

      assert {"Docs", docs} = List.keyfind(sections, "Docs", 0)
      assert {"API", "/api"} in docs
      assert {"Guide", "/guide", "Getting started"} in docs

      assert {"Optional", optional} = List.keyfind(sections, "Optional", 0)
      assert {"FAQ", "/faq"} in optional
    end

    test "group_by_section/1 filters out nils" do
      entries = [
        nil,
        Entry.build(section: "Docs", title: "API", url: "/api"),
        nil
      ]

      assert [{"Docs", [{"API", "/api"}]}] = Entry.group_by_section(entries)
    end
  end
end
