defmodule SEO.JSONLD do
  @moduledoc """
  Renders JSON-LD structured data as `<script type="application/ld+json">` tags.

  JSON-LD (JavaScript Object Notation for Linked Data) allows you to provide
  structured data to search engines in a machine-readable format, enabling
  rich results in search listings.

  You can pass any map (or list of maps) with `@context` and `@type` keys:

      <SEO.JSONLD.meta
        item={%{"@context" => "https://schema.org", "@type" => "Organization", "name" => "Acme"}}
        json_library={Jason}
      />

  Or use one of the helper modules for common Schema.org types:

  - `SEO.JSONLD.Article`
  - `SEO.JSONLD.Organization`
  - `SEO.JSONLD.FAQ`
  - `SEO.JSONLD.Product`
  - `SEO.JSONLD.LocalBusiness`
  - `SEO.JSONLD.Event`

  ## Config defaults

  Site-wide defaults configured via `use SEO, json_ld: %{...}` are merged
  into each rendered JSON-LD payload as defaults — any key the item already
  supplies wins. The config map uses the string keys the renderer produces,
  so the cleanest way to author nested values is with one of the typed
  helpers:

      use SEO,
        json_ld: %{
          "inLanguage" => "en-US",
          "publisher" => SEO.JSONLD.Organization.build(%{name: "Acme"})
        }

  Top-level atom keys are accepted and stringified; nested values are left
  untouched, so build them with the typed helpers (or write raw
  string-keyed maps) so they match the JSON-LD output shape.

  ### Resources

  - https://json-ld.org/
  - https://schema.org/
  - https://developers.google.com/search/docs/appearance/structured-data
  - https://search.google.com/test/rich-results
  """

  use Phoenix.Component

  attr :item, :any
  attr :json_library, :atom, required: true
  attr :config, :any, default: nil

  def meta(assigns) do
    item =
      assigns[:item]
      |> merge_config_defaults(assigns[:config])
      |> sanitize()

    assigns = assign(assigns, :item, item)

    ~H"""
    <script :if={@item} type="application/ld+json">
      <%= Phoenix.HTML.raw(@json_library.encode!(@item)) %>
    </script>
    """
  end

  # Shallow-merges `config` into `item` as defaults — each top-level key
  # already on the item wins. `config` keys are coerced to strings so that a
  # user who wrote `%{publisher: ...}` in SEO.Config still merges against the
  # "publisher" key the generated modules emit. Nested values are opaque;
  # author them with the typed helpers if they need to match the output
  # shape.
  defp merge_config_defaults(item, nil), do: item
  defp merge_config_defaults(item, config) when config == %{}, do: item

  defp merge_config_defaults(items, config) when is_list(items) do
    Enum.map(items, &merge_config_defaults(&1, config))
  end

  defp merge_config_defaults(item, config) when is_map(item) and is_map(config) do
    Map.merge(stringify_keys(config), item)
  end

  defp merge_config_defaults(item, _config), do: item

  defp stringify_keys(map) do
    Map.new(map, fn
      {k, v} when is_atom(k) -> {Atom.to_string(k), v}
      {k, v} -> {k, v}
    end)
  end

  defp sanitize(nil), do: nil

  defp sanitize(items) when is_list(items) do
    cleaned = Enum.map(items, &drop_nils/1) |> Enum.reject(&empty?/1)

    case cleaned do
      [] -> nil
      [single] -> single
      multiple -> multiple
    end
  end

  defp sanitize(item) when is_struct(item) do
    item |> Map.from_struct() |> sanitize()
  end

  defp sanitize(item) when is_map(item) do
    cleaned = drop_nils(item)
    if empty?(cleaned), do: nil, else: cleaned
  end

  defp sanitize(_), do: nil

  defp drop_nils(map) when is_map(map) do
    for {k, v} <- map, v != nil, into: %{}, do: {k, v}
  end

  defp drop_nils(other), do: other

  defp empty?(map) when map_size(map) == 0, do: true
  defp empty?(_), do: false
end
