<!-- badges -->

[![Hex.pm Version](http://img.shields.io/hexpm/v/seo.svg)](https://hex.pm/packages/seo)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-blue.svg?style=flat)](https://hexdocs.pm/seo)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE.md)

# SEO

![logo](./priv/logo.png)

<!-- MDOC !-->

**WORK IN PROGRESS, DO NOT USE**

```
/ˈin(t)ərˌnet jo͞os/
noun: internet juice
```

SEO (Search Engine Optimization) provides a framework for Phoenix applications
to more-easily optimize your site for search engines and displaying rich results
when your URLs are shared across the internet. The better visibility your pages
have in search results, the more likely you are to have visitors.

## Installation

```elixir
def deps do
  [
    {:seo, "~> 0.1.0"}
  ]
end
```

## Usage

1. Define an SEO module for your web application and defaults

```elixir
defmodule MyAppWeb.SEO do
  use SEO, [
    {SEO.Site, SEO.Site.build(
      default_title: "Default Title",
      description: "A blog about development",
      title_suffix: " · My App"
    )},
    {SEO.OpenGraph, SEO.OpenGraph.build(
      description: "A blog about development",
      site_name: "David Bernheisel's Blog",
      type: "website",
      locale: "en_US"
    )},
    {SEO.Twitter, SEO.Twitter.build(
      site: "@bernheisel",
      site_id: "27704724",
      creator: "@bernheisel",
      creator_id: "27704724",
      card: :summary
    )},
    json_library: Jason
  ]

  # alternatively, you can put the config inside a `def config` if you want to define it at runtime 

  use Phoenix.Component

  attr(:item, :any, required: true)
  attr(:page_title, :string, default: nil)
  attr(:json_library, :atom, default: Jason)

  @doc "Provide SEO juice"
  def juice(assigns) do
    ~H"""
    <SEO.Site.meta item={SEO.Build.site(@item, config(SEO.Site))} page_title={@page_title} />
    <SEO.OpenGraph.meta item={SEO.Build.open_graph(@item, config(SEO.OpenGraph))} />
    <SEO.Twitter.meta item={SEO.Build.twitter(@item, config(SEO.Twitter))} />
    <SEO.Unfurl.meta item={SEO.Build.unfurl(@item, config(SEO.Unfurl))} /> 
    <%!-- <SEO.Facebook.meta item={SEO.Build.facebook(@item, config(SEO.Facebook))} /> --%>
    <SEO.Breadcrumb.meta
      item={SEO.Build.breadcrumb_list(@item, config(SEO.Breadcrumb))}
      json_library={@json_library}
    />
  """
end
```

2. Implement functions to build SEO information about your entities

```elixir
defmodule MyApp.Article do
  # This might be an Ecto schema, or just a plain struct
  defstruct [
      :id,
      :title,
      :short_description,
      :reading_time,
      :category,
      :author,
      :published_at,
      tags: []
    ]
end

defimpl MyApp.Article, for: SEO.Build do
  use SEO.Builder
  alias MyAppWeb.Router.Helpers, as: Routes
  @endpoint MyAppWeb.Endpoint

  def site(article, defaults) do
    SEO.Site.build([
      title: article.title,
      description: article.short_description
    ], defaults)
  end

  def unfurl(article, defaults) do
    SEO.Unfurl.build([
      label1: "Reading Time",
      data1: "#{article.reading_time} min",
      label2: "Category",
      data2: article.category
    ], defaults)
  end

  def twitter(article, defaults) do
    if creator = article.author.twitter_handle do
      SEO.Twitter.build([], defaults)
    else
      SEO.Twitter.build([creator: creator], defaults)
    end
  end

  def open_graph(article, defaults) do
    SEO.OpenGraph.build([
      title: article.title,
      type_detail: SEO.OpenGraph.Article.build(
        published_time: article.published_at,
        author: article.author.name,
        section: "Reviews",
        tag: article.tags
      ),
      image: image(article),
      url: Routes.blog_url(@endpoint, article.id),
      locale, "en_US",
      type: :article,
      description: article.short_description
    ], defaults)
  end

  def breadcrumb_list(article, _) do
    SEO.Breadcrumb.List.build([
      [name: "Posts", item: Routes.blog_url(@endpoint, :index)],
      [name: article.title, item: Routes.blog_url(@endpoint, :show, post.id)]
    ])
  end

  defp put_image(article) do
    file = "/images/blog/#{article.id}.png"

    exists? =
      [Application.app_dir(:my_app), "/priv/static", file]
      |> Path.join()
      |> File.exists?()

    if exists? do
      Routes.static_url(@endpoint, file), image_alt: article.title}
    else
      nil
    end
  end
end
```

3. Assign the item to your conns and/or sockets

```elixir
# In a plain Phoenix Controller
def show(conn, params) do
  article = load_article(params)

  conn
  |> SEO.assign(article)
  |> render("show.html")
end

def index(conn, params) do
  conn
  |> SEO.assign(%{title: "Listing Best Hugs"})
  |> render("show.html")
end

# In a Phoenix LiveView, make sure you handle with
# mount/3 or handle_params/3 so it's present on
# first static render.
def mount(params, _session, socket) do
  {:ok, socket}
end

def handle_params(params, _uri, socket) do
  {:noreply, SEO.assign(socket, load_article(params))}
end
```

4. Use your SEO module in your root layout

```heex
<head>
  <%# remove the Phoenix-generated <.live_title> component %>
  <%# and replace with MyAppWeb.SEO.juice component %>
  <MyAppWeb.SEO.juice item={assigns[:seo] || []} page_title={assigns[:page_title]} />
</head>
```
