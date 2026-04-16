defmodule SEO.LLMs.IntegrationTest do
  use ExUnit.Case, async: true

  import Plug.Test

  alias SEO.LLMs.Entry

  defmodule Blog do
    @articles [
      %MyApp.Article{
        id: "genserver-guide",
        title: "Understanding GenServer",
        description: "GenServer is one of the most important OTP abstractions"
      },
      %MyApp.Article{
        id: "pubsub-deep-dive",
        title: "Phoenix PubSub Deep Dive",
        description: "Phoenix PubSub powers real-time features in LiveView"
      }
    ]

    def list_published, do: @articles
    def get_article!("genserver-guide"), do: Enum.at(@articles, 0)
    def get_article!("pubsub-deep-dive"), do: Enum.at(@articles, 1)
  end

  defmodule SampleArticleMD do
    @behaviour SEO.LLMs

    def show(%{article: article}) do
      """
      # #{article.title}

      #{article.description}

      Written by #{article.author || "Staff"}
      """
    end

    def index(%{articles: articles}) do
      header = "# All Articles\n\n"
      list = Enum.map_join(articles, "\n", fn a -> "- [#{a.title}](/articles/#{a.id})" end)
      header <> list
    end

    @impl SEO.LLMs
    def entry(article, _conn) do
      Entry.build(
        section: "Articles",
        title: article.title,
        url: "/articles/#{article.id}",
        description: article.description
      )
    end
  end

  defmodule SamplePageMD do
    @behaviour SEO.LLMs

    def show(%{page: :about}) do
      """
      # About This Site

      A weekly newsletter about Elixir, Phoenix, and OTP.
      """
    end

    def show(%{page: :contributing}) do
      """
      # Contributing

      We welcome guest posts on any Elixir topic.
      """
    end

    @impl SEO.LLMs
    def entry(:about, _conn) do
      Entry.build(
        section: "Docs",
        title: "About",
        url: "/about",
        description: "What this site covers"
      )
    end

    def entry(:contributing, _conn) do
      Entry.build(
        section: "Docs",
        title: "Contributing",
        url: "/contributing",
        description: "How to submit guest posts"
      )
    end

    def entry(:subscribe, _conn) do
      Entry.build(
        section: "Optional",
        title: "Subscribe",
        url: "/subscribe",
        description: "Sign up for the newsletter"
      )
    end
  end

  defmodule SampleProvider do
    @behaviour SEO.LLMs.Provider

    alias SEO.LLMs.IntegrationTest.{Blog, SampleArticleMD, SamplePageMD}

    @impl true
    def sections(conn) do
      static_pages = [
        SamplePageMD.entry(:about, conn),
        SamplePageMD.entry(:contributing, conn)
      ]

      articles =
        Blog.list_published()
        |> Enum.map(&SampleArticleMD.entry(&1, conn))

      optional = [SamplePageMD.entry(:subscribe, conn)]

      all_entries = static_pages ++ articles ++ optional
      Entry.group_by_section(all_entries)
    end
  end

  describe "ArticleMD behaviour" do
    test "show/1 renders markdown for an article" do
      article = Blog.get_article!("genserver-guide")
      content = SampleArticleMD.show(%{article: article})

      assert content =~ "# Understanding GenServer"
      assert content =~ "GenServer is one of the most important OTP abstractions"
      assert content =~ "Written by Staff"
    end

    test "index/1 renders a markdown list of articles" do
      articles = Blog.list_published()
      content = SampleArticleMD.index(%{articles: articles})

      assert content =~ "# All Articles"
      assert content =~ "- [Understanding GenServer](/articles/genserver-guide)"
      assert content =~ "- [Phoenix PubSub Deep Dive](/articles/pubsub-deep-dive)"
    end

    test "entry/2 returns an Entry struct" do
      article = Blog.get_article!("genserver-guide")
      entry = SampleArticleMD.entry(article, %Plug.Conn{})

      assert %Entry{
               section: "Articles",
               title: "Understanding GenServer",
               url: "/articles/genserver-guide",
               description: "GenServer is one of the most important OTP abstractions"
             } = entry
    end
  end

  describe "PageMD behaviour" do
    test "show/1 renders different pages via pattern matching" do
      assert SamplePageMD.show(%{page: :about}) =~ "# About This Site"
      assert SamplePageMD.show(%{page: :contributing}) =~ "# Contributing"
    end

    test "entry/2 returns entries for different pages" do
      about = SamplePageMD.entry(:about, %Plug.Conn{})
      assert about.section == "Docs"
      assert about.title == "About"

      subscribe = SamplePageMD.entry(:subscribe, %Plug.Conn{})
      assert subscribe.section == "Optional"
    end
  end

  describe "Provider assembles sections from MD modules" do
    test "sections/1 returns grouped sections in order" do
      sections = SampleProvider.sections(%Plug.Conn{})

      section_names = Enum.map(sections, &elem(&1, 0))

      assert "Docs" in section_names
      assert "Articles" in section_names
      assert "Optional" in section_names
    end

    test "Docs section has static pages" do
      sections = SampleProvider.sections(%Plug.Conn{})
      {_, docs} = List.keyfind(sections, "Docs", 0)

      assert {"About", "/about", "What this site covers"} in docs
      assert {"Contributing", "/contributing", "How to submit guest posts"} in docs
    end

    test "Articles section has dynamic entries" do
      sections = SampleProvider.sections(%Plug.Conn{})
      {_, articles} = List.keyfind(sections, "Articles", 0)

      assert {"Understanding GenServer", "/articles/genserver-guide",
              "GenServer is one of the most important OTP abstractions"} in articles

      assert {"Phoenix PubSub Deep Dive", "/articles/pubsub-deep-dive",
              "Phoenix PubSub powers real-time features in LiveView"} in articles
    end

    test "Optional section has low-priority entries" do
      sections = SampleProvider.sections(%Plug.Conn{})
      {_, optional} = List.keyfind(sections, "Optional", 0)

      assert {"Subscribe", "/subscribe", "Sign up for the newsletter"} in optional
    end
  end

  describe "full integration: provider → plug → llms.txt" do
    test "renders complete llms.txt with all sections" do
      opts =
        SEO.LLMs.init(
          config: MyAppWeb.SEO,
          provider: SEO.LLMs.IntegrationTest.SampleProvider
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      assert conn.status == 200
      assert {"content-type", "text/markdown; charset=utf-8"} in conn.resp_headers

      body = conn.resp_body

      # Title from SEO config (open_graph.site_name)
      assert body =~ "# David Bernheisel's Blog"

      # Description from SEO config (site.description)
      assert body =~ "> A blog about development"

      # Docs section
      assert body =~ "## Docs"
      assert body =~ "[About](/about): What this site covers"
      assert body =~ "[Contributing](/contributing): How to submit guest posts"

      # Articles section
      assert body =~ "## Articles"
      assert body =~ "[Understanding GenServer](/articles/genserver-guide)"
      assert body =~ "[Phoenix PubSub Deep Dive](/articles/pubsub-deep-dive)"

      # Optional section
      assert body =~ "## Optional"
      assert body =~ "[Subscribe](/subscribe): Sign up for the newsletter"
    end

    test "title and description can be overridden" do
      opts =
        SEO.LLMs.init(
          config: MyAppWeb.SEO,
          title: "My Custom Title",
          description: "My custom description",
          provider: SEO.LLMs.IntegrationTest.SampleProvider
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      assert conn.resp_body =~ "# My Custom Title"
      assert conn.resp_body =~ "> My custom description"
      refute conn.resp_body =~ "David Bernheisel"
    end

    test "progressive structure: essential content comes before Optional" do
      opts =
        SEO.LLMs.init(
          config: MyAppWeb.SEO,
          provider: SEO.LLMs.IntegrationTest.SampleProvider
        )

      conn =
        conn(:get, "/llms.txt")
        |> SEO.LLMs.call(opts)

      body = conn.resp_body

      # Optional section should appear after other content
      {docs_pos, _} = :binary.match(body, "## Docs")
      {articles_pos, _} = :binary.match(body, "## Articles")
      {optional_pos, _} = :binary.match(body, "## Optional")

      assert docs_pos < optional_pos
      assert articles_pos < optional_pos
    end
  end

  describe "format negotiation simulation" do
    test "FooMD module is callable as a Phoenix view (show/1 with assigns map)" do
      article = Blog.get_article!("genserver-guide")
      result = SampleArticleMD.show(%{article: article})

      assert is_binary(result)
      assert result =~ "# Understanding GenServer"
    end

    test "same data produces both index entry and full content" do
      article = Blog.get_article!("pubsub-deep-dive")

      # For llms.txt index (via provider)
      entry = SampleArticleMD.entry(article, %Plug.Conn{})
      assert entry.title == "Phoenix PubSub Deep Dive"
      assert entry.url == "/articles/pubsub-deep-dive"

      # For markdown format response (via Phoenix view dispatch)
      content = SampleArticleMD.show(%{article: article})
      assert content =~ "# Phoenix PubSub Deep Dive"
      assert content =~ "Phoenix PubSub powers real-time features"
    end

    test "put_view + render dispatches to MD module for md format" do
      article = Blog.get_article!("genserver-guide")

      assigns = %{article: article}
      markdown = SampleArticleMD.show(assigns)

      conn =
        conn(:get, "/articles/genserver-guide")
        |> Plug.Conn.put_resp_content_type("text/markdown")
        |> Plug.Conn.send_resp(200, markdown)

      assert conn.status == 200
      assert {"content-type", "text/markdown; charset=utf-8"} in conn.resp_headers
      assert conn.resp_body =~ "# Understanding GenServer"
    end
  end

  describe "multiple MD modules contributing to one provider" do
    test "entries from different modules grouped by section" do
      conn = %Plug.Conn{}

      page_entries = [
        SamplePageMD.entry(:about, conn),
        SamplePageMD.entry(:contributing, conn),
        SamplePageMD.entry(:subscribe, conn)
      ]

      article_entries =
        Blog.list_published()
        |> Enum.map(&SampleArticleMD.entry(&1, conn))

      all = page_entries ++ article_entries
      sections = Entry.group_by_section(all)

      section_names = Enum.map(sections, &elem(&1, 0))
      assert "Docs" in section_names
      assert "Articles" in section_names
      assert "Optional" in section_names

      # Docs has 2 entries from PageMD
      {_, docs} = List.keyfind(sections, "Docs", 0)
      assert length(docs) == 2

      # Articles has 2 entries from ArticleMD
      {_, articles} = List.keyfind(sections, "Articles", 0)
      assert length(articles) == 2

      # Optional has 1 entry from PageMD
      {_, optional} = List.keyfind(sections, "Optional", 0)
      assert length(optional) == 1
    end
  end
end
