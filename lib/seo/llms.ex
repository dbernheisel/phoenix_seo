defmodule SEO.LLMs do
  @moduledoc """
  Serve an `/llms.txt` file per the [llmstxt.org](https://llmstxt.org) spec.

  The llms.txt file provides LLM-friendly content about your site: a title,
  summary, and categorized links to key pages — structured progressively so
  LLMs can stop reading early and still have useful context.

  ## Quick start

  1. Add `"md"` to your router pipeline and forward `/llms.txt`:

          pipeline :browser do
            plug :accepts, ["html", "md"]
          end

          forward "/llms.txt", SEO.LLMs,
            config: MyAppWeb.SEO,
            provider: MyAppWeb.LLMsProvider

  2. Create markdown view modules (`FooMD`) that implement this behaviour:

          defmodule MyAppWeb.ArticleMD do
            @behaviour SEO.LLMs

            def show(%{article: article}) do
              \"""
              # \#{article.title}

              \#{article.body}
              \"""
            end

            @impl SEO.LLMs
            def entry(article) do
              SEO.LLMs.Entry.build(
                section: "Articles",
                title: article.title,
                url: "/articles/\#{article.slug}",
                description: article.summary
              )
            end
          end

  3. Register the markdown view in your controllers:

          defmodule MyAppWeb.ArticleController do
            use MyAppWeb, :controller

            plug :put_view, html: MyAppWeb.ArticleHTML, md: MyAppWeb.ArticleMD

            def show(conn, %{"slug" => slug}) do
              article = Blog.get_article_by_slug!(slug)
              render(conn, :show, article: article)
              # html → ArticleHTML.show/1
              # md   → ArticleMD.show/1
            end
          end

  4. Create a provider that assembles the llms.txt index:

          defmodule MyAppWeb.LLMsProvider do
            @behaviour SEO.LLMs.Provider

            @impl true
            def sections do
              articles = MyApp.Blog.list_published()

              entries = Enum.map(articles, &MyAppWeb.ArticleMD.entry/1)
              dynamic = SEO.LLMs.Entry.group_by_section(entries)

              static = [
                {"Docs", [
                  {"About", "/about", "What this site covers"}
                ]}
              ]

              static ++ dynamic
            end
          end

  ## How it works

  Phoenix resolves view modules by format: `ArticleHTML` for HTML, `ArticleJSON`
  for JSON, `ArticleMD` for markdown. A single `render(conn, :show, article: article)`
  call dispatches to the right view based on content negotiation.

  Your `FooMD` modules serve double duty:

  - **Phoenix view functions** (`show/1`, `index/1`, etc.) render full markdown
    content when the `"md"` format is requested
  - **The `entry/1` callback** provides metadata for the llms.txt index — section,
    title, URL, and description

  The provider collects entries from your MD modules and groups them into sections.
  The Plug renders the final llms.txt file, pulling the site title and description
  from your existing SEO config.

  ## Using MDEx with Phoenix

  [MDEx](https://hex.pm/packages/mdex) is a fast markdown library for Elixir that
  pairs naturally with `FooMD` view modules. It provides a `~MD` sigil for markdown
  templates — the markdown equivalent of HEEx's `~H` sigil for HTML.

  | Format | View module | Template engine | Sigil |
  |--------|------------|-----------------|-------|
  | HTML | `FooHTML` | HEEx | `~H` |
  | JSON | `FooJSON` | Plain maps | — |
  | Markdown | `FooMD` | MDEx | `~MD` |

  ### Setup

  Add MDEx to your dependencies:

      {:mdex, "~> 0.12"}

  ### The `~MD` sigil

  The `~MD` sigil with the `MD` modifier outputs CommonMark markdown (not HTML).
  It supports assigns (`{@var}`) and expressions (`<%= ... %>`), and is processed
  at compile time for performance:

      defmodule MyAppWeb.ArticleMD do
        @behaviour SEO.LLMs
        import MDEx.Sigil

        def show(assigns) do
          ~MD\"""
          # {@article.title}

          > Published {@article.date}

          {@article.body}

          ## Related

          <%= for tag <- @article.tags do %>
          - \#{tag}
          <% end %>
          \"""MD
        end

        @impl SEO.LLMs
        def entry(article) do
          SEO.LLMs.Entry.build(
            section: "Articles",
            title: article.title,
            url: "/articles/\#{article.slug}",
            description: article.summary
          )
        end
      end

  See `MDEx.Sigil` for the full list of modifiers and options.

  ### When to use the sigil vs string interpolation

  The `~MD` sigil processes templates at **compile time**, which makes it ideal for
  views with structured, known layouts — like documentation pages or about pages.
  For DB-backed content where the body is already markdown (like a blog post stored
  as markdown), plain string interpolation is simpler:

      # Compile-time template — good for structured pages
      def show(assigns) do
        ~MD\"""
        # {@page.title}

        {@page.body}
        \"""MD
      end

      # Runtime interpolation — good for DB-backed markdown content
      def show(%{article: article}) do
        \"""
        # \#{article.title}

        \#{article.body}
        \"""
      end

  ### Converting HTML content to markdown

  If your content is stored as HTML and you need to serve it as markdown,
  MDEx can parse and re-render it:

      def show(%{article: article}) do
        article.html_body
        |> MDEx.parse_document!()
        |> MDEx.to_markdown!()
      end

  ## Plug options

  - `:title` — H1 heading. Falls back to `open_graph.site_name` from config.
  - `:description` — Blockquote summary. Falls back to `site.description` from config.
  - `:body` — Optional prose between the summary and sections.
  - `:sections` — Static list of `{section_name, entries}` tuples.
  - `:provider` — Module implementing `SEO.LLMs.Provider` for dynamic sections.
  - `:config` — Your `use SEO` module or config map, used to derive title/description.

  ## Static sections (without a provider)

  For simple sites you can skip the provider and declare sections inline:

      forward "/llms.txt", SEO.LLMs,
        config: MyAppWeb.SEO,
        sections: [
          {"Docs", [
            {"API Reference", "/docs/api", "Full REST API docs"},
            {"Guides", "/docs/guides"}
          ]},
          {"Optional", [
            {"Changelog", "/changelog"}
          ]}
        ]
  """

  @doc """
  Callback for markdown view modules (`FooMD`) to provide llms.txt entries.

  Receives a resource and returns an `SEO.LLMs.Entry`, a list of entries, or `nil`.
  Used by `SEO.LLMs.Provider` implementations to build the llms.txt index from
  your view modules.
  """
  @callback entry(term()) :: SEO.LLMs.Entry.t() | [SEO.LLMs.Entry.t()] | nil

  @doc """
  Render the llms.txt markdown string from a map of options.

  Expects a map with:
  - `:title` (required) — the H1 heading
  - `:description` (optional) — the blockquote summary
  - `:body` (optional) — prose content between summary and sections
  - `:sections` — list of `{name, entries}` tuples
  """
  @spec render(map()) :: String.t()
  def render(opts) do
    parts =
      [
        render_title(opts[:title]),
        render_description(opts[:description]),
        render_body(opts[:body])
        | render_sections(opts[:sections] || [])
      ]

    parts
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
  end

  defp render_title(nil), do: nil
  defp render_title(title), do: "# #{title}"

  defp render_description(nil), do: nil
  defp render_description(desc), do: "> #{desc}"

  defp render_body(nil), do: nil
  defp render_body(""), do: nil
  defp render_body(body), do: body

  defp render_sections([]), do: []

  defp render_sections(sections) do
    Enum.map(sections, fn {name, entries} ->
      links =
        entries
        |> Enum.map(&render_entry/1)
        |> Enum.join("\n")

      "## #{name}\n\n#{links}"
    end)
  end

  defp render_entry({name, url}), do: "- [#{name}](#{url})"
  defp render_entry({name, url, desc}), do: "- [#{name}](#{url}): #{desc}"

  @behaviour Plug

  @impl Plug
  def init(opts) do
    opts = Map.new(opts)

    config = resolve_config(opts[:config])

    %{
      title: opts[:title] || get_in(config, [:open_graph, :site_name]),
      description: opts[:description] || get_in(config, [:site, :description]),
      body: opts[:body],
      sections: opts[:sections],
      provider: opts[:provider]
    }
  end

  @impl Plug
  def call(conn, opts) do
    sections = resolve_sections(opts)

    body =
      render(%{
        title: opts.title,
        description: opts.description,
        body: opts.body,
        sections: sections
      })

    conn
    |> Plug.Conn.put_resp_content_type("text/markdown")
    |> Plug.Conn.send_resp(200, body)
  end

  defp resolve_sections(%{provider: provider}) when is_atom(provider) and not is_nil(provider) do
    provider.sections()
  end

  defp resolve_sections(%{sections: sections}) when is_list(sections), do: sections
  defp resolve_sections(_), do: []

  defp resolve_config(nil), do: %{}

  defp resolve_config(mod) when is_atom(mod) do
    if Code.ensure_loaded?(mod) and function_exported?(mod, :config, 0) do
      config = mod.config()

      %{
        open_graph: to_map(config[:open_graph]),
        site: to_map(config[:site])
      }
    else
      %{}
    end
  end

  defp resolve_config(_), do: %{}

  defp to_map(nil), do: %{}
  defp to_map(x) when is_struct(x), do: Map.from_struct(x)
  defp to_map(x) when is_list(x), do: Map.new(x)
  defp to_map(x) when is_map(x), do: x
end
