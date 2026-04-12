defmodule SampleApp.Blog do
  @moduledoc false

  @articles [
    %MyApp.Article{
      id: "genserver-guide",
      title: "Understanding GenServer",
      description: "GenServer is one of the most important OTP abstractions",
      author: "José Valim"
    },
    %MyApp.Article{
      id: "pubsub-deep-dive",
      title: "Phoenix PubSub Deep Dive",
      description: "Phoenix PubSub powers real-time features in LiveView"
    }
  ]

  def list_published, do: @articles
  def get_article_by_slug!("genserver-guide"), do: Enum.at(@articles, 0)
  def get_article_by_slug!("pubsub-deep-dive"), do: Enum.at(@articles, 1)
end

defmodule SampleApp.ArticleMD do
  @moduledoc false
  @behaviour SEO.LLMs
  alias SEO.LLMs.Entry

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
  def entry(article) do
    Entry.build(
      section: "Articles",
      title: article.title,
      url: "/articles/#{article.id}",
      description: article.description
    )
  end
end

defmodule SampleApp.PageMD do
  @moduledoc false
  @behaviour SEO.LLMs
  alias SEO.LLMs.Entry
  import MDEx.Sigil

  def show(%{page: :about} = _assigns) do
    ~MD"""
    # About This Site

    A weekly newsletter about Elixir, Phoenix, and OTP.

    ## Topics

    - Language features
    - Phoenix and LiveView
    - OTP design
    """MD
  end

  @impl SEO.LLMs
  def entry(:about) do
    Entry.build(
      section: "Docs",
      title: "About",
      url: "/about",
      description: "What this site covers"
    )
  end

  def entry(:subscribe) do
    Entry.build(
      section: "Optional",
      title: "Subscribe",
      url: "/subscribe",
      description: "Sign up for the newsletter"
    )
  end
end

defmodule SampleApp.LLMsProvider do
  @moduledoc false
  @behaviour SEO.LLMs.Provider

  alias SEO.LLMs.Entry

  @impl true
  def sections do
    static = [SampleApp.PageMD.entry(:about)]

    articles =
      SampleApp.Blog.list_published()
      |> Enum.map(&SampleApp.ArticleMD.entry/1)

    optional = [SampleApp.PageMD.entry(:subscribe)]

    all = static ++ articles ++ optional
    Entry.group_by_section(all)
  end
end
