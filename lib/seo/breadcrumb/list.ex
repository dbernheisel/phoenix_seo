defmodule SEO.Breadcrumb.List do
  @moduledoc """
  A `SEO.Breadcrumb.List` is list of items consisting of a chain of linked Web pages, typically
  described using at least their URL and their name, and typically ending with the current page.

  The `:position` property is used to reconstruct the order of the items in a `SEO.Breadcrumb.List`.
  The convention is that a breadcrumb list has an `itemListOrder` of `ItemListOrderAscending`
  (lower values listed first), and that the first items in this list correspond to the "top"
  or beginning of the breadcrumb trail, e.g. with a site or section homepage. The specific values
  of 'position' are not assigned meaning for a BreadcrumbList, but they should be integers,
  e.g. beginning with '1' for the first item in the list.
  """

  alias SEO.Breadcrumb.Item
  alias SEO.Breadcrumb.ListItem

  defstruct "@context": "https://schema.org",
            "@type": "BreadcrumbList",
            itemListElement: []

  @type t :: %__MODULE__{
          "@context": String.t(),
          "@type": String.t(),
          itemListElement: list(ListItem.t())
        }

  @doc """
  Build a list of items that represent breadcrumbs for your item.

  You may build the list with `SEO.Breadcrumb.ListItem`, or
  `SEO.Breadcrumb.Item`, or with simply attributes that will build an item.
  The position will be inferred from the list provided. If you need to supply
  the position manually, you need to supply `SEO.Breadcrumb.ListItem`.

  For example:

  ```elixir
  SEO.Breadcrumb.List.build([
    %{name: "Posts", item: Routes.blog_url(@endpoint, :index)},
    %{name: "My Post", item: Routes.blog_url(@endpoint, :show, my_id)}
  ])
  ```
  """

  def build(attrs, _default \\ nil) when is_list(attrs) do
    %__MODULE__{itemListElement: format_items(attrs)}
  end

  @doc false
  def to_map(%__MODULE__{} = item) do
    %{
      item
      | itemListElement:
          Enum.map(item.itemListElement, fn list_item ->
            %{ListItem.to_map(list_item) | item: Item.to_map(list_item.item)}
          end)
    }
    |> Map.from_struct()
  end

  defp format_items(items) do
    items
    |> Enum.with_index()
    |> Enum.map(fn {item, i} ->
      i = i + 1

      case item do
        %ListItem{position: pos} = list_item ->
          %{list_item | position: pos || i}

        %Item{} = item ->
          ListItem.build(item: item, position: i)

        attrs when is_list(attrs) or is_map(attrs) ->
          ListItem.build(item: Item.build(attrs), position: i)
      end
    end)
  end
end
