defmodule SEO.LLMs do
  @moduledoc """
  Serve an `/llms.txt` file per the [llmstxt.org](https://llmstxt.org) spec.

  The llms.txt file provides LLM-friendly content about your site: a title,
  summary, and categorized links to key pages — structured progressively so
  LLMs can stop reading early and still have useful context.

  ## As a Plug

      # In your router
      forward "/llms.txt", SEO.LLMs,
        config: MyAppWeb.SEO,
        sections: [
          {"Docs", [
            {"API Reference", "/docs/api.md", "Full REST API docs"}
          ]}
        ]

  ## With a provider module

      forward "/llms.txt", SEO.LLMs,
        config: MyAppWeb.SEO,
        provider: MyAppWeb.LLMsProvider

  ## Options

  - `:title` — H1 heading. Falls back to `open_graph.site_name` from config.
  - `:description` — Blockquote summary. Falls back to `site.description` from config.
  - `:body` — Optional prose between the summary and sections.
  - `:sections` — Static list of `{section_name, entries}` tuples.
  - `:provider` — Module implementing `SEO.LLMs.Provider` for dynamic sections.
  - `:config` — Your `use SEO` module or config map, used to derive title/description.

  ## Markdown view modules

  Phoenix resolves view modules by format: `ArticleHTML` for HTML, `ArticleJSON`
  for JSON, and `ArticleMD` for markdown. Your `FooMD` modules can implement the
  `SEO.LLMs` behaviour to provide entries for the llms.txt index:

      defmodule MyAppWeb.ArticleMD do
        @behaviour SEO.LLMs

        # Phoenix view function — called by render(conn, :show, article: article)
        def show(%{article: article}) do
          \"""
          # \#{article.title}

          \#{article.body}
          \"""
        end

        # llms.txt entry — called by your Provider
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

  Then register the format in your controller:

      use Phoenix.Controller, formats: [:html, :json, :md]

  And add `"md"` to your router pipeline:

      plug :accepts, ["html", "md"]
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
