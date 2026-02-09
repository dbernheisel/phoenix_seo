defmodule SEO.JsonLD.Product do
  @moduledoc """
  Helper for building a Schema.org [Product](https://schema.org/Product) JSON-LD structure.

  ## Example

      SEO.JsonLD.Product.build(
        name: "Widget",
        description: "A great widget",
        offers: %{"@type" => "Offer", "price" => "19.99", "priceCurrency" => "USD"}
      )
  """

  @doc """
  Build a Product JSON-LD map.

  ## Fields

  - `:name` - The name of the product
  - `:description` - A short description
  - `:image` - URL or list of URLs for product images
  - `:brand` - A map describing the brand
  - `:offers` - A map or list of maps describing offers/pricing
  - `:sku` - The Stock Keeping Unit
  - `:review` - A map or list of maps for reviews
  - `:aggregateRating` - A map describing the aggregate rating
  """
  @spec build(Keyword.t() | map()) :: map()
  def build(attrs) do
    attrs
    |> Enum.into(%{})
    |> Map.merge(%{"@context" => "https://schema.org", "@type" => "Product"})
  end
end
