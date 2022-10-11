<!-- badges -->

<!-- MDOC !-->

# SEO

**WORK IN PROGRESS, DO NOT USE**

![logo](./assets/logo.svg)

`/ˈin(t)ərˌnet jo͞os/`

noun: **internet juice**

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

1. Define an SEO module for your web applications

```elixir
defmodule MyAppWeb.SEO do
  use SEO,
    json_library: Jason,
    default_title: "My App",
    site_name: "My App",
    title_suffix: " · My App",
    twitter: %{
      site: "@bernheisel",
      creator: "@bernheisel"
    }
end
```

2. Implement some functions to build SEO information about your entities

```elixir
defmodule MyAppWeb.SEO do
  # ...

  alias MyAppWeb.Router.Helpers, as: Routes
  @endpoint MyAppWeb.Endpoint

  def site(%MyApp.Article{} = article) do
    MyAppWeb.SEO.Site.build(
      title: article.title,
      description: article.short_description
    )
  end

  def unfurl(%MyApp.Article{} = article) do
    SEO.Unfurl.build(
      label1: "Reading Time",
      data1: "#{article.reading_time} min",
      label2: "Category",
      data2: article.category
    )
  end

  def twitter(%MyApp.Article{} = article) do
    if creator = article.author.twitter_handle do
      SEO.Twitter.build([])
    else
      SEO.Twitter.build(creator: creator)
    end
  end

  def open_graph(%MyApp.Article{} = article) do
    SEO.OpenGraph.build(
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
    )
  end

  def breadcrumb_list(%MyApp.Article{} = article) do
    SEO.Breadcrumb.List.build([
      SEO.Breadcrumb.Item.build(
        name: "Posts",
        item: Routes.blog_url(@endpoint, :index)
      ),
      SEO.Breadcrumb.Item.build(
        name: article.title,
        item: Routes.blog_url(@endpoint, :show, post.id)
      )
    ])
  end

  defp put_image(%MyApp.Article{} = article) do
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

3. Use your SEO module in your root layout

```heex
<head>
  <%# remove the Phoenix-generated <.live_title> function %>
  <%# and replace with MyApp.SEO.juice %>
  <MyAppWeb.SEO.juice item={MyAppWeb.SEO.Build.build(assigns[:seo])} />
</head>
```

4. Assign `seo: my_entity` to your conns and/or sockets

```elixir

# In a Phoenix Controller
def show(conn, params) do
  conn
  |> assign(:seo, load_article(params))
  |> render("show.html")
end

def index(conn, params) do
  conn
  |> assign(:seo, MyAppWeb.SEO.Generic.build(title: "Listing Best Hugs"))
  |> render("show.html")
end

# In a Phoenix LiveView
def mount(params, _session, socket) do
  article = load_article(params)
  {:ok, assign(socket, :seo, article)}
end
```

5.
