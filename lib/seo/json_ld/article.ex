defmodule SEO.JsonLD.Article do
  @moduledoc """
  Helper for building a Schema.org [Article](https://schema.org/Article) JSON-LD structure.

  ## Example

      SEO.JsonLD.Article.build(
        headline: "My Post",
        description: "A post about things",
        datePublished: ~D[2024-01-15],
        author: %{"@type" => "Person", "name" => "Jane Doe"}
      )
  """

  @doc """
  Build an Article JSON-LD map.

  ## Fields

  - `:headline` - The headline of the article
  - `:description` - A short description
  - `:datePublished` - Date/DateTime/string when the article was published
  - `:dateModified` - Date/DateTime/string when the article was last modified
  - `:author` - A map or list of maps describing the author(s)
  - `:publisher` - A map describing the publisher
  - `:image` - URL string or list of URL strings for article images
  - `:mainEntityOfPage` - URL of the page this article is the main entity of
  """
  @spec build(Keyword.t() | map()) :: map()
  def build(attrs) do
    attrs
    |> Enum.into(%{})
    |> maybe_format_date(:datePublished)
    |> maybe_format_date(:dateModified)
    |> Map.merge(%{"@context" => "https://schema.org", "@type" => "Article"})
  end

  defp maybe_format_date(map, key) do
    case Map.get(map, key) do
      nil -> map
      date -> Map.put(map, key, SEO.Utils.to_iso8601(date))
    end
  end
end
