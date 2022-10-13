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

  attr(:item, SEO.Breadcrumb.List)
  attr(:json_library, :atom, required: true)

  def meta(assigns) do
    ~H"""
    <%= if @item != [] do %>
    <script type="application/ld+json">
      <%= Phoenix.HTML.raw(@json_library.encode!(List.to_map(@item))) %>
    </script>
    <% end %>
    """
  end
end
