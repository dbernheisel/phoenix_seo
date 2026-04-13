defmodule SEO.LLMs.SampleAppTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Phoenix.ConnTest

  @endpoint SampleApp.Endpoint

  describe "format negotiation: markdown responses" do
    test "GET /articles/:slug with md format renders markdown from ArticleMD" do
      conn =
        build_conn()
        |> put_req_header("accept", "text/markdown")
        |> get("/articles/genserver-guide")

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") |> hd() =~ "text/markdown"
      assert conn.resp_body =~ "# Understanding GenServer"
      assert conn.resp_body =~ "GenServer is one of the most important OTP abstractions"
      assert conn.resp_body =~ "Written by José Valim"
    end

    test "GET /articles/:slug with md format uses fallback author" do
      conn =
        build_conn()
        |> put_req_header("accept", "text/markdown")
        |> get("/articles/pubsub-deep-dive")

      assert conn.status == 200
      assert conn.resp_body =~ "# Phoenix PubSub Deep Dive"
      assert conn.resp_body =~ "Written by Staff"
    end

    test "GET /about with md format renders markdown from PageMD" do
      conn =
        build_conn()
        |> put_req_header("accept", "text/markdown")
        |> get("/about")

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") |> hd() =~ "text/markdown"
      assert conn.resp_body =~ "# About This Site"
      assert conn.resp_body =~ "A weekly newsletter about Elixir, Phoenix, and OTP."
      assert conn.resp_body =~ "## Topics"
      assert conn.resp_body =~ "- Language features"
    end
  end

  describe "llms.txt endpoint" do
    test "GET /llms.txt serves the full index" do
      conn = build_conn() |> get("/llms.txt")

      assert conn.status == 200
      assert get_resp_header(conn, "content-type") |> hd() =~ "text/markdown"

      body = conn.resp_body

      # Title and description from MyAppWeb.SEO config
      assert body =~ "# David Bernheisel's Blog"
      assert body =~ "> A blog about development"

      # Docs section (from PageMD)
      assert body =~ "## Docs"
      assert body =~ "[About](/about): What this site covers"

      # Articles section (from ArticleMD via provider)
      assert body =~ "## Articles"
      assert body =~ "[Understanding GenServer](/articles/genserver-guide)"
      assert body =~ "[Phoenix PubSub Deep Dive](/articles/pubsub-deep-dive)"

      # Optional section
      assert body =~ "## Optional"
      assert body =~ "[Subscribe](/subscribe): Sign up for the newsletter"
    end

    test "llms.txt content is valid markdown structure" do
      conn = build_conn() |> get("/llms.txt")
      body = conn.resp_body

      lines = String.split(body, "\n")

      # First line is H1
      assert hd(lines) =~ ~r/^# /

      # Has blockquote
      assert Enum.any?(lines, &String.starts_with?(&1, "> "))

      # Has H2 sections
      h2s = Enum.filter(lines, &String.starts_with?(&1, "## "))
      assert length(h2s) >= 2

      # Has markdown links
      assert Enum.any?(lines, &(&1 =~ ~r/- \[.+\]\(.+\)/))
    end
  end

  describe "behaviour contract validation" do
    test "ArticleMD implements entry/1 callback" do
      article = SampleApp.Blog.get_article_by_slug!("genserver-guide")
      entry = SampleApp.ArticleMD.entry(article)

      assert %SEO.LLMs.Entry{} = entry
      assert entry.section == "Articles"
      assert entry.title == "Understanding GenServer"
      assert entry.url == "/articles/genserver-guide"
    end

    test "PageMD implements entry/1 callback for multiple resources" do
      about = SampleApp.PageMD.entry(:about)
      assert %SEO.LLMs.Entry{section: "Docs", title: "About"} = about

      subscribe = SampleApp.PageMD.entry(:subscribe)
      assert %SEO.LLMs.Entry{section: "Optional", title: "Subscribe"} = subscribe
    end

    test "ArticleMD show/1 follows Phoenix view convention (assigns map)" do
      article = SampleApp.Blog.get_article_by_slug!("genserver-guide")
      result = SampleApp.ArticleMD.show(%{article: article})

      assert is_binary(result)
      assert result =~ "# Understanding GenServer"
    end

    test "PageMD show/1 with MDEx sigil returns valid markdown" do
      result = SampleApp.PageMD.show(%{page: :about})

      assert is_binary(result)
      assert result =~ "About This Site"
      assert result =~ "Topics"
    end
  end

  describe "provider integration" do
    test "provider sections include all registered MD modules" do
      sections = SampleApp.LLMsProvider.sections()
      section_names = Enum.map(sections, &elem(&1, 0))

      assert "Docs" in section_names
      assert "Articles" in section_names
      assert "Optional" in section_names
    end

    test "entry metadata matches what appears in llms.txt" do
      sections = SampleApp.LLMsProvider.sections()
      {_, articles} = List.keyfind(sections, "Articles", 0)

      titles = Enum.map(articles, &elem(&1, 0))
      assert "Understanding GenServer" in titles
      assert "Phoenix PubSub Deep Dive" in titles
    end
  end

  describe "same resource: index entry matches full content" do
    test "article appears in llms.txt index and serves full markdown" do
      # Get the llms.txt index
      index_conn = build_conn() |> get("/llms.txt")
      assert index_conn.resp_body =~ "[Understanding GenServer](/articles/genserver-guide)"

      # Follow the link — get the full markdown
      content_conn =
        build_conn()
        |> put_req_header("accept", "text/markdown")
        |> get("/articles/genserver-guide")

      assert content_conn.resp_body =~ "# Understanding GenServer"
      assert content_conn.resp_body =~ "GenServer is one of the most important OTP abstractions"
    end
  end
end
