defmodule SEO.JsonLD.Organization do
  @moduledoc """
  Helper for building a Schema.org [Organization](https://schema.org/Organization) JSON-LD structure.

  ## Example

      SEO.JsonLD.Organization.build(
        name: "Acme Corp",
        url: "https://acme.com",
        logo: "https://acme.com/logo.png"
      )
  """

  @doc """
  Build an Organization JSON-LD map.

  ## Fields

  - `:name` - The name of the organization
  - `:url` - The URL of the organization's website
  - `:logo` - URL of the organization's logo
  - `:sameAs` - List of URLs for the organization's social profiles
  - `:description` - A short description
  - `:email` - Contact email
  - `:telephone` - Contact phone number
  - `:address` - A map describing the postal address
  """
  @spec build(Keyword.t() | map()) :: map()
  def build(attrs) do
    attrs
    |> Enum.into(%{})
    |> Map.merge(%{"@context" => "https://schema.org", "@type" => "Organization"})
  end
end
