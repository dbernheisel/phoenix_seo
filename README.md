<!-- badges -->

[![Hex.pm Version](http://img.shields.io/hexpm/v/phoenix_seo.svg)](https://hex.pm/packages/phoenix_seo)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-blue.svg?style=flat)](https://hexdocs.pm/phoenix_seo)
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
    {:phoenix_seo, "~> 0.1.6"}
  ]
end
```

## Usage

1. Define an SEO module for your web application and defaults

```elixir
defmodule MyAppWeb.SEO do
  alias MyAppWeb.Router.Helpers, as: Routes

  use SEO, [
    json_library: Jason,
    # a function reference will be called with a conn during render
    site: &__MODULE__.site_config/1,
    open_graph: SEO.OpenGraph.build(
      description: "A blog about development",
      site_name: "My Blog",
      type: :website,
      locale: "en_US"
    ),
    facebook: SEO.Facebook.build(app_id: "123"),
    twitter: SEO.Twitter.build(
      site: "@example",
      site_id: "27704724",
      creator: "@example",
      creator_id: "27704724",
      card: :summary
    )
  ]

  def site_config(conn) do
    SEO.Site.build(
      default_title: "Default Title",
      description: "A blog about development",
      title_suffix: " · My App",
      theme_color: "#663399",
      windows_tile_color: "#663399",
      mask_icon_color: "#663399",
      mask_icon_url: Routes.static_path(conn, "/images/safari-pinned-tab.svg"),
      manifest_url: Routes.robot_path(conn, :site_webmanifest)
    )
  end
end
```

2. Implement functions to build SEO information about your entities

```elixir
defmodule MyApp.Article do
  # This might be an Ecto schema or a plain struct
  defstruct [:id, :title, :description, :author, :reading, :published_at]
end

defimpl SEO.OpenGraph.Build, for: MyApp.Article do
  alias MyAppWeb.Router.Helpers, as: Routes

  def build(article, conn) do
    SEO.OpenGraph.build(
      type: :article,
      type_detail:
        SEO.OpenGraph.Article.build(
          published_time: article.published_at,
          author: article.author,
          section: "Tech"
        ),
      image: image(article, conn),
      title: article.title,
      description: article.description
    )
  end

  defp image(article, conn) do
    file = "/images/article/#{article.id}.png"

    exists? =
      [Application.app_dir(:my_app), "/priv/static", file]
      |> Path.join()
      |> File.exists?()

    if exists? do
      SEO.OpenGraph.Image.build(
        url: Routes.static_url(conn, file),
        secure_url: Routes.static_url(conn, file),
        alt: article.title
      )
    end
  end
end

defimpl SEO.Site.Build, for: MyApp.Article do
  alias MyAppWeb.Router.Helpers, as: Routes

  def build(article, conn) do
    SEO.Site.build(
      url: Routes.article_url(conn, :show, article.id),
      title: article.title,
      description: article.description
    )
  end
end

defimpl SEO.Twitter.Build, for: MyApp.Article do
  def build(article, _conn) do
    SEO.Twitter.build(description: article.description, title: article.title)
  end
end

defimpl SEO.Unfurl.Build, for: MyApp.Article do
  def build(article, _conn) do
    SEO.Unfurl.build(
      label1: "Reading Time",
      data1: "5 minutes",
      label2: "Published",
      data2: DateTime.to_iso8601(article.published_at)
    )
  end
end

defimpl SEO.Breadcrumb.Build, for: MyApp.Article do
  alias MyAppWeb.Router.Helpers, as: Routes

  def build(article, conn) do
    SEO.Breadcrumb.List.build([
      %{name: "Articles", item: Routes.article_url(conn, :index)},
      %{name: article.title, item: Routes.article_url(conn, :show, article.id)}
    ])
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
  # Note: it's better to implement a struct that represent a route like this,
  # so you can customize it per implementation. In this example below, the
  # `:title` attribute will be passed to all domains.
  conn
  |> SEO.assign(%{title: "Listing Best Hugs"})
  |> render("show.html")
end

# In a Phoenix LiveView, make sure you handle with
# mount/3 or handle_params/3 so it's present on
# first static render.
def mount(_params, _session, socket) do
  # You may mark it as temporary since it's only needed on the first render.
  {:ok, socket, temporary_assigns: [{SEO.key(), nil}]}
end

def handle_params(params, _uri, socket) do
  {:noreply, SEO.assign(socket, load_article(params))}
end
```

4. Juice up your root layout:

```heex
<head>
  <%# remove the Phoenix-generated <.live_title> component %>
  <%# and replace with SEO.juice component %>
  <SEO.juice
    conn={@conn}
    config={MyAppWeb.SEO.config()}
    page_title={assigns[:page_title]}
  />
</head>
```

Alternatively, you may selectively render components. For example:

```heex
<head>
  <%# With your SEO module's configuration %>
  <SEO.OpenGraph.meta
    config={MyAppWeb.SEO.config(:open_graph)}
    item={SEO.OpenGraph.Build.build(SEO.item(@conn))}
  />

  <%# Or with some other default configuration %>
  <SEO.OpenGraph.meta
    config={[default_title: "Foo Fighters"]}
    item={SEO.OpenGraph.Build.build(SEO.item(@conn))}
  />

  <%# Or without defaults %>
  <SEO.OpenGraph.meta item={SEO.OpenGraph.Build.build(SEO.item(@conn))} />
</head>
```

## FAQ

**Question: What do I do for non-show routes, like for index routes?**

Answer:

You can pass maps or keyword lists for non-specific routes like index routes;
however, since it's not an implementation of a struct, it's generic and will be
passed to all SEO domains. In the case where an attribute is shared between
domains, such as a Twitter title and an Site title and an OpenGraph title, then
you won't be able to implement them differently. This is probably ok in most
cases.

Even better, you can define a struct on your controller or LiveView and pass
that struct as the SEO item, then implement the struct per domain.

For example:

```elixir
defmodule MyAppWeb.PokemonController do
  use MyAppWeb, :controller

  defstruct [title: "Listing Pokemon"]

  def index(conn, _params) do
    # ... your usual index logic
    SEO.assign(conn, %__MODULE__{})
  end

end

defimpl SEO.OpenGraph.Build, for: MyAppWeb.PokemonController do
  def build(index, conn) do
    SEO.OpenGraph.build(title: index.title, ...)
  end
end
```

**Question: Can I globally configure a JSON library?**

Answer: Sure. Without configuration, SEO will choose the JSON library configured
for Phoenix. If that's not configured and Jason is available, SEO will use Jason.
If Jason is not available, but Poison is, then Poison will be used. In any case,
you can specify the JSON library for SEO in your mix config:

```elixir
import Config
config :seo_phoenix, json_library: Jason
```

This will be picked up when you `use SEO` so the config will have json_library
available for the components to use later.

**Question: What's the difference between `SEO.OpenGraph.Build.build` and `SEO.OpenGraph.build`?**

Answer: Elixir protocols are core to how this library works. Using OpenGraph as
an example, protocols are defined in SEO domains such as `SEO.OpenGraph.Build`
(big B) which are dispatched by Elixir to your implementation for the given struct. This
is how polymorphism can work for Elixir! Whereas the function `SEO.OpenGraph.build`
(little b) is building the `SEO.OpenGraph` struct based on the defaults for your
domain and the result of your implementation. Again, shorter, `Build` (big b) is
the protocol, and `build` (little b) is merging your implementation's result with
defaults. Technically, your implementation doesn't have to return an
`SEO.OpenGraph` struct, but it's very handy since documentation is present on the
build function so your editor can quickly show you what is available. Knowing is
half the battle!
