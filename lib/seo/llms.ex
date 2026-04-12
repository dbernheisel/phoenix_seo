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
  """

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
end
