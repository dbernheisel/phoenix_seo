defmodule SEO.JSONLD.Breadcrumbs do
  @moduledoc """
  Convenience wrapper for building a Schema.org `m:SEO.JSONLD.BreadcrumbList`
  from a compact list of breadcrumb entries.

  Takes a flat list of `%{name: ..., item: ...}` maps (or keyword lists) and
  produces the full `BreadcrumbList` + `ListItem` hierarchy with sequential
  `position` values inferred from the list order (1-based).

  ## Example

  ```elixir
  SEO.JSONLD.Breadcrumbs.build([
    %{name: "Home", item: "https://example.com/"},
    %{name: "Blog", item: "https://example.com/blog/"},
    %{name: "This Post", item: "https://example.com/blog/post-1"}
  ])
  ```

  For full control (custom positions, extra `ListItem` fields like `image`),
  use `SEO.JSONLD.BreadcrumbList` and `SEO.JSONLD.ListItem` directly.
  """

  @doc """
  Build a `BreadcrumbList` JSON-LD map from a list of breadcrumb entries.

  Each entry should be a map or keyword list with:

  - `:name` - the breadcrumb label (required)
  - `:item` - the URL for the breadcrumb target, either a string or `URI.t()`
  """
  @spec build([map() | keyword()]) :: map()
  def build(items) when is_list(items) do
    SEO.JSONLD.BreadcrumbList.build(%{
      item_list_element: build_items(items)
    })
  end

  defp build_items(items) do
    items
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, position} ->
      entry = Enum.into(entry, %{})

      SEO.JSONLD.ListItem.build(%{
        position: position,
        name: entry[:name],
        item: entry[:item]
      })
    end)
  end
end
