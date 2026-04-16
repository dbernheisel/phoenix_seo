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
    assigns = assign(assigns, :item, sanitize(assigns[:item]))

    ~H"""
    <script :if={@item} type="application/ld+json">
      <%= Phoenix.HTML.raw(@json_library.encode!(@item)) %>
    </script>
    """
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
