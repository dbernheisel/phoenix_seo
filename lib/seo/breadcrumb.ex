defmodule SEO.Breadcrumb do
  @moduledoc """
  This is SEO for Google to display breadcrumbs in the search results.
  This allows the search result to search as multiple links.

  ![Breadcrumb Example](./assets/breadcrumb-example.png)

  ### Resources

  - https://developers.google.com/search/docs/data-types/breadcrumbs
  - https://json-ld.org/
  - https://search.google.com/test/rich-results
  - https://search.google.com/structured-data/testing-tool
  """

  use Phoenix.Component
  alias SEO.Breadcrumb.List

  defstruct []

  attr(:item, SEO.Breadcrumb.List, required: true)
  attr(:json_library, :atom, required: true)

  def meta(assigns) do
    ~H"""
    <script type="application/ld+json">
      <%= Phoenix.HTML.raw(@json_mod.encode!(List.to_map(@item))) %>
    </script>
    """
  end
end
