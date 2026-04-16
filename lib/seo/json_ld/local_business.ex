defmodule SEO.JsonLD.LocalBusiness do
  @moduledoc """
  Helper for building a Schema.org [LocalBusiness](https://schema.org/LocalBusiness) JSON-LD structure.

  ## Example

      SEO.JsonLD.LocalBusiness.build(
        name: "Joe's Pizza",
        address: %{"@type" => "PostalAddress", "streetAddress" => "123 Main St"},
        telephone: "+1-555-555-5555"
      )
  """

  @doc """
  Build a LocalBusiness JSON-LD map.

  ## Fields

  - `:name` - The name of the business
  - `:address` - A map describing the postal address
  - `:telephone` - Contact phone number
  - `:url` - The URL of the business's website
  - `:image` - URL or list of URLs for business images
  - `:priceRange` - The price range, e.g. "$$"
  - `:openingHoursSpecification` - A map or list of maps for opening hours
  - `:geo` - A map with latitude and longitude
  - `:sameAs` - List of URLs for social profiles
  """
  @spec build(Keyword.t() | map()) :: map()
  def build(attrs) do
    attrs
    |> Enum.into(%{})
    |> Map.merge(%{"@context" => "https://schema.org", "@type" => "LocalBusiness"})
  end
end
