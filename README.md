<!-- badges -->

[![Hex.pm Version](http://img.shields.io/hexpm/v/phoenix_seo.svg)](https://hex.pm/packages/phoenix_seo)
[![Hex docs](http://img.shields.io/badge/hex.pm-docs-blue.svg?style=flat)](https://hexdocs.pm/phoenix_seo)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE.md)

# SEO

![logo](./priv/logo.png)

You're reading the main branch's readme. Please visit
[hexdocs](https://hexdocs.pm/phoenix_seo) for the latest published documentation.

<!-- MDOC !-->

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
    {:phoenix_seo, "~> 0.3.0"}
  ]
end
```

Register the JSON-LD compiler in your `mix.exs` so `SEO.JSONLD.*` builder
modules are generated at compile time:

```elixir
def project do
  [
    # ...
    compilers: [:seo_jsonld] ++ Mix.compilers()
  ]
end
```

By default this emits the ~24 types Google has rich-result guides for,
along with the supporting types those guides reference (`Question`,
`Answer`, `ListItem`) and the closure of any types referenced through
field ranges and inheritance — about 200 modules in total.

If you need the full vocabulary (~820 typed builder modules) or a
different slice, override the default via application config — a single
entry or a list of entries:

```elixir
# config/config.exs
config :phoenix_seo, json_ld_types: :all
# or mix-and-match:
config :phoenix_seo, json_ld_types: [:google, SEO.JSONLD.SearchAction]
```

Available entries:

- `:google` — types Google has rich-result guides for plus their
  supporting types. **Default if `:json_ld_types` is not configured.**
- `:all` — every regular Schema.org class.
- Category atoms: `:medical`, `:place`, `:travel`, `:shopping`,
  `:creative_work`, `:action`, `:financial`, etc. See
  `Mix.Tasks.Compile.SeoJsonld.Generator.groups/0` for the full list.
- Module names like `SEO.JSONLD.Article`, or strings like `"Article"` /
  `"schema:Article"`.

Inheritance ancestors and referenced types are pulled into the emitted
set automatically — so the typespecs and module links always resolve.
Modules are written to your application's `_build` directory, not into
the dep tree.

## Usage

1. Define an SEO module for your web application and defaults

```elixir
defmodule MyAppWeb.SEO do
  use MyAppWeb, :verified_routes

  use SEO, [
    json_library: Jason,
    # a function reference will be called with a conn during render
    # arity 1 will be passed the conn, arity 0 is also supported.
    site: &__MODULE__.site_config/1,
    open_graph: SEO.OpenGraph.build(
      description: "A blog about development",
      site_name: "My Blog",
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

  # Or arity 0 is also supported, which can be great if you're using
  # Phoenix verified routes and don't need the conn to generate paths.
  def site_config(conn) do
    SEO.Site.build(
      default_title: "Default Title",
      description: "A blog about development",
      title_suffix: " · My App",
      theme_color: "#663399",
      windows_tile_color: "#663399",
      mask_icon_color: "#663399",
      mask_icon_url: static_url(conn, "/images/safari-pinned-tab.svg"),
      manifest_url: url(conn, ~p"/site.webmanifest")
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
  use MyAppWeb, :verified_routes

  def build(article, conn) do
    SEO.OpenGraph.build(
      detail:
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
      [:code.priv_dir(:my_app), "static", file]
      |> Path.join()
      |> File.exists?()

    if exists? do
      SEO.OpenGraph.Image.build(
        url: static_url(conn, file),
        alt: article.title
      )
    end
  end
end

defimpl SEO.Site.Build, for: MyApp.Article do
  use MyAppWeb, :verified_routes

  def build(article, conn) do
    # Because of `Phoenix.Param`, structs will assume the key of `:id` when
    # interpolating the struct into the verified route.
    SEO.Site.build(
      url: url(conn, ~p"/articles/#{article}"),
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

defimpl SEO.JSONLD.Build, for: MyApp.Article do
  use MyAppWeb, :verified_routes

  def build(article, conn) do
    # Because of `Phoenix.Param`, structs will assume the key of `:id` when
    # interpolating the struct into the verified route. Emit multiple JSON-LD
    # entities by returning a list — breadcrumbs sit alongside the article.
    [
      SEO.JSONLD.Article.build(%{
        headline: article.title,
        description: article.description,
        date_published: article.published_at,
        author: SEO.JSONLD.Person.build(%{name: article.author}),
        main_entity_of_page: url(conn, ~p"/articles/#{article}")
      }),
      SEO.JSONLD.Breadcrumbs.build([
        %{name: "Articles", item: url(conn, ~p"/articles")},
        %{name: article.title, item: url(conn, ~p"/articles/#{article}")}
      ])
    ]
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

## LLMs.txt

Serve an `/llms.txt` file per the [llmstxt.org](https://llmstxt.org) spec so
LLMs can discover and understand your site's content.

```elixir
# In your router
forward "/llms.txt", SEO.LLMs,
  config: MyAppWeb.SEO,
  provider: MyAppWeb.LLMsProvider
```

Create markdown view modules (`FooMD`) — the markdown equivalent of `FooHTML` —
that implement the `SEO.LLMs` behaviour:

```elixir
defmodule MyAppWeb.ArticleMD do
  @behaviour SEO.LLMs
  use MyAppWeb, :verified_routes

  # Phoenix view function — called when format is "md"
  def show(%{article: article}) do
    """
    # #{article.title}

    #{article.body}
    """
  end

  # llms.txt entry — called by your Provider with the current conn
  @impl SEO.LLMs
  def entry(article, conn) do
    SEO.LLMs.Entry.build(
      section: "Articles",
      title: article.title,
      url: url(conn, ~p"/articles/#{article}"),
      description: article.summary
    )
  end
end
```

Then register the `"md"` format in your pipeline and controller:

```elixir
pipeline :browser do
  plug :accepts, ["html", "md"]
end

defmodule MyAppWeb.ArticleController do
  use MyAppWeb, :controller
  plug :put_view, html: MyAppWeb.ArticleHTML, md: MyAppWeb.ArticleMD

  def show(conn, %{"slug" => slug}) do
    article = Blog.get_article_by_slug!(slug)
    render(conn, :show, article: article)
  end
end
```

See `SEO.LLMs` module docs for the full guide, including MDEx `~MD` sigil
integration, nested sub-sections, and inline markdown content.

## FAQ

> #### Question: What do I do for non-show routes, like for index routes? {: .info}
>
> You can pass maps or keyword lists for non-specific routes like index routes;
> however, since it's not an implementation of a struct, it's generic and will be
> passed to all SEO domains. In the case where an attribute is shared between
> domains, such as a Twitter title and an Site title and an OpenGraph title, then
> you won't be able to implement them differently. This is probably ok in most
> cases.
>
> Even better, you can define a struct on your controller or LiveView and pass
> that struct as the SEO item, then implement the struct per domain.
>
> For example:
>
> ```elixir
> defmodule MyAppWeb.PokemonController do
>   use MyAppWeb, :controller
>
>   defstruct [title: "Listing Pokemon"]
>
>   def index(conn, _params) do
>     # ... your usual index logic
>     SEO.assign(conn, %__MODULE__{})
>   end
>
> end
>
> defimpl SEO.OpenGraph.Build, for: MyAppWeb.PokemonController do
>   def build(index, conn) do
>     SEO.OpenGraph.build(title: index.title, ...)
>   end
> end
> ```

> #### Question: How do I serve markdown from a LiveView route? {: .info}
>
> LiveViews don't use the controller's `put_view` format dispatch, so you can't
> register a markdown view the same way you would for a controller. Instead,
> intercept the request in your router with a plug that checks the negotiated
> format and short-circuits with the markdown body before the LiveView mounts.
>
> ```elixir
> # In your router
> pipeline :browser do
>   plug :accepts, ["html", "md"]
>   # ...
>   plug :maybe_serve_lesson_markdown
> end
>
> scope "/", MyAppWeb do
>   pipe_through :browser
>   live "/learn/:slug", LessonLive
> end
>
> def maybe_serve_lesson_markdown(%Plug.Conn{path_info: ["learn", slug]} = conn, _opts) do
>   with "md" <- Phoenix.Controller.get_format(conn) do
>     lesson = MyApp.Lessons.get!(slug)
>     body = MyAppWeb.LessonMD.show(%{lesson: lesson})
>
>     conn
>     |> Plug.Conn.put_resp_content_type("text/markdown")
>     |> Plug.Conn.send_resp(200, body)
>     |> Plug.Conn.halt()
>   else
>     _ -> conn
>   end
> end
>
> def maybe_serve_lesson_markdown(conn, _opts), do: conn
> ```
>
> The `with "md" <- ...` pattern passes the conn through unchanged when the
> format is anything other than `"md"` (such as `"html"`), letting the LiveView
> render normally. When the client requests markdown — via an `Accept:
> text/markdown` header or `?_format=md` — the plug halts the pipeline and
> returns the rendered markdown directly from your `LessonMD` module, which
> is the same module you'd use with `SEO.LLMs` for `/llms.txt` entries.

> #### Question: Can I globally configure a JSON library? {: .info}
>
> Sure. Without configuration, SEO will choose the JSON library configured
> for Phoenix. If that's not configured and Jason is available, SEO will use Jason.
> If Jason is not available, but Poison is, then Poison will be used. In any case,
> you can specify the JSON library for SEO in your mix config:
>
> ```elixir
> import Config
> config :phoenix_seo, json_library: Jason
> ```
>
> This will be picked up when you `use SEO` so the config will have json_library
> available for the components to use later.

> #### Question: What's the difference between `SEO.OpenGraph.Build.build` and `SEO.OpenGraph.build`? {: .info}
>
> Elixir protocols are core to how this library works. Using OpenGraph as
> an example, protocols are defined in SEO domains such as `SEO.OpenGraph.Build`
> (big B) which are dispatched by Elixir to your implementation for the given struct. This
> is how polymorphism can work for Elixir! Whereas the function `SEO.OpenGraph.build`
> (little b) is building the `SEO.OpenGraph` struct based on the defaults for your
> domain and the result of your implementation. Again, shorter, `Build` (big b) is
> the protocol, and `build` (little b) is merging your implementation's result with
> defaults. Technically, your implementation doesn't have to return an
> `SEO.OpenGraph` struct, but it's very handy since documentation is present on the
> build function so your editor can quickly show you what is available. Knowing is
> half the battle!
