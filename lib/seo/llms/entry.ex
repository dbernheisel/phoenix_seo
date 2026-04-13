defmodule SEO.LLMs.Entry do
  @moduledoc """
  Represents a single resource entry in an llms.txt file.

  Each entry belongs to a section and has a title, URL, optional description,
  and optional markdown content (for serving the resource as markdown).

  ## Fields

  - `:section` — which H2 section this entry belongs to (e.g., `"Docs"`, `"Articles"`, `"Optional"`)
  - `:title` — the link text
  - `:url` — the link target URL
  - `:description` — optional text after the link in llms.txt
  - `:content` — optional markdown body for serving the page as markdown.
    Can be a string or a zero-arity function for lazy loading.
  """

  defstruct [:section, :title, :url, :description, :content]

  @type t :: %__MODULE__{
          section: String.t() | nil,
          title: String.t() | nil,
          url: String.t() | nil,
          description: String.t() | nil,
          content: String.t() | (-> String.t()) | nil
        }

  @doc """
  Build an Entry struct from attributes, optionally merging with defaults.
  """
  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  @doc """
  Group a list of entries by their `:section` field into the tuple format
  that `SEO.LLMs.render/1` expects.

  Returns a list of `{section_name, entries}` tuples where entries are
  `{title, url}` or `{title, url, description}` tuples.

  ## Example

      entries = [
        %SEO.LLMs.Entry{section: "Docs", title: "API", url: "/api"},
        %SEO.LLMs.Entry{section: "Docs", title: "Guide", url: "/guide", description: "Getting started"},
        %SEO.LLMs.Entry{section: "Optional", title: "FAQ", url: "/faq"}
      ]

      SEO.LLMs.Entry.group_by_section(entries)
      #=> [{"Docs", [{"API", "/api"}, {"Guide", "/guide", "Getting started"}]},
      #=>  {"Optional", [{"FAQ", "/faq"}]}]
  """
  @spec group_by_section([t()]) :: [SEO.LLMs.Provider.section()]
  def group_by_section(entries) do
    entries
    |> Enum.reject(&is_nil/1)
    |> Enum.group_by(& &1.section)
    |> Enum.map(fn {section, section_entries} ->
      {section, Enum.map(section_entries, &to_link/1)}
    end)
  end

  defp to_link(%{title: t, url: u, description: nil}), do: {t, u}
  defp to_link(%{title: t, url: u, description: d}), do: {t, u, d}
end
