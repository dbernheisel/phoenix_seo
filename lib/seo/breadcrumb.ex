defmodule SEO.Breadcrumb do
  @moduledoc """
  This is SEO for Google to display breadcrumbs in the search results.
  This allows the search result to search as multiple links.

  https://developers.google.com/search/docs/data-types/breadcrumbs
  https://json-ld.org/

  tester: https://search.google.com/test/rich-results
  tester: https://search.google.com/structured-data/testing-tool
  """

  alias SEO.Breadcrumb.List

  def serialize(%List{} = list), do: List.serialize(list)
end
