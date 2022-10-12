defmodule MyAppWeb.SEO do
  @moduledoc false

  use SEO, [
    {SEO.Site,
     %SEO.Site{
       default_title: "Default Title",
       description: "A blog about development",
       title_suffix: " · My App"
     }},
    {SEO.OpenGraph,
     %SEO.OpenGraph{
       description: "A blog about development",
       site_name: "David Bernheisel's Blog",
       type: "website",
       locale: "en_US"
     }},
    {SEO.Twitter,
     %SEO.Twitter{
       site: "@bernheisel",
       site_id: "27704724",
       creator: "@bernheisel",
       creator_id: "27704724",
       card: :summary
     }},
    json_library: Jason
  ]
end

defmodule MyApp.Article do
  @moduledoc false
  defstruct [:title, :description, :author, :reading]
end

defmodule MyApp.Article.Index do
  @moduledoc false
  defstruct title: "My Articles",
            description: "Articles that describe tech"
end

defimpl SEO.Build, for: MyApp.Article.Index do
  use SEO.Builder

  def site(index, _default) do
    SEO.Site.build(
      title: index.title,
      description: index.description
    )
  end

  def breadcrumb_list(_index, _default) do
    SEO.Breadcrumb.List.build([
      SEO.Breadcrumb.Item.build(
        position: 1,
        name: "Articles",
        item: "https://example.com/articles"
      )
    ])
  end
end

defimpl SEO.Build, for: MyApp.Article do
  use SEO.Builder

  def site(article) do
    SEO.Site.build(
      url: "https://example.com/#{article.id}",
      title: article.title,
      description: article.description
    )
  end

  def unfurl(article) do
    SEO.Unfurl.build(
      label1: "Title",
      data1: article.title,
      label2: "Reading Time",
      data2: article.reading
    )
  end

  def open_graph(article) do
    SEO.OpenGraph.build(
      type: :article,
      type_detail:
        SEO.OpenGraph.Article.build(
          author: article.author,
          section: "Tech"
        ),
      title: article.title,
      description: article.description,
      locale: "en_US"
    )
  end

  def breadcrumb_list(article) do
    SEO.Breadcrumb.List.build([
      SEO.Breadcrumb.Item.build(
        position: 1,
        name: "Articles",
        item: "https://example.com/articles"
      ),
      SEO.Breadcrumb.Item.build(
        position: 2,
        name: article.title,
        item: "https://example.com/articles/#{article.id}"
      )
    ])
  end
end
