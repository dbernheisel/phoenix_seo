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

  Rendered example inside a `<script type="application/ld+json">`:

  ```json
  {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    "itemListElement": [{
      "@type": "ListItem",
      "item": "https://bernheisel.com/blog",
      "name": "Posts",
      "position": 1
    },{
      "@type": "ListItem",
      "item": "https://bernheisel.com/blog/nostalgia-programming",
      "name": "Nostalgia, Fun, and Programming",
      "position": 2
    }]
  }
  ```

  """

  use Phoenix.Component
  alias SEO.Breadcrumb

  attr :item, Breadcrumb.List
  attr :json_library, :atom, required: true
  attr :config, :any, default: nil

  def meta(assigns) do
    assigns = assign(assigns, :item, Breadcrumb.List.build(assigns[:item], assigns[:config]))

    ~H"""
    <script :if={@item} type="application/ld+json">
      <%= Phoenix.HTML.raw(@json_library.encode!(Breadcrumb.List.to_map(@item))) %>
    </script>
    """
  end
end
