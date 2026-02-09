defmodule SEO.JsonLD.Event do
  @moduledoc """
  Helper for building a Schema.org [Event](https://schema.org/Event) JSON-LD structure.

  ## Example

      SEO.JsonLD.Event.build(
        name: "ElixirConf 2024",
        startDate: ~D[2024-08-28],
        location: %{"@type" => "Place", "name" => "Gaylord Rockies"}
      )
  """

  @doc """
  Build an Event JSON-LD map.

  ## Fields

  - `:name` - The name of the event
  - `:startDate` - Date/DateTime/string when the event starts
  - `:endDate` - Date/DateTime/string when the event ends
  - `:location` - A map describing the location
  - `:description` - A short description
  - `:image` - URL or list of URLs for event images
  - `:organizer` - A map describing the organizer
  - `:performer` - A map or list of maps describing performers
  - `:offers` - A map or list of maps describing ticket offers
  - `:eventStatus` - Event status URL
  - `:eventAttendanceMode` - Attendance mode URL
  """
  @spec build(Keyword.t() | map()) :: map()
  def build(attrs) do
    attrs
    |> Enum.into(%{})
    |> maybe_format_date(:startDate)
    |> maybe_format_date(:endDate)
    |> Map.merge(%{"@context" => "https://schema.org", "@type" => "Event"})
  end

  defp maybe_format_date(map, key) do
    case Map.get(map, key) do
      nil -> map
      date -> Map.put(map, key, SEO.Utils.to_iso8601(date))
    end
  end
end
