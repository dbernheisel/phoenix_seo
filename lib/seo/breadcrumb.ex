defmodule SEO.Breadcrumb do
  @moduledoc """
  This is SEO for Google to display breadcrumbs in the search results.
  This allows the search result to search as multiple links.

  https://developers.google.com/search/docs/data-types/breadcrumbs
  https://json-ld.org/

  tester: https://search.google.com/test/rich-results
  tester: https://search.google.com/structured-data/testing-tool
  """

  use Phoenix.Component
  alias SEO.Breadcrumb.List

  defstruct []

  attr(:item, :any, required: true)
  attr(:default, SEO.Breadcrumb, required: true)

  def meta(assigns) do
    ~H"""
    <script type="application/ld+json">
      <%= Phoenix.HTML.raw(@default[:json_library].encode!(to_map(@item))) %>
    </script>
    """
  end

  defp to_map(%List{} = list), do: List.to_map(list)
end
