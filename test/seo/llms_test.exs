defmodule SEO.LLMsTest do
  use ExUnit.Case, async: true
  use Plug.Test

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
end
