defmodule SEO.Breadcrumb.List do
  @moduledoc """
  A BreadcrumbList is an ItemList consisting of a chain of linked Web pages, typically described using at least their
  URL and their name, and typically ending with the current page.

  The `:position` property is used to reconstruct the order of the items in a BreadcrumbList The convention is that a
  breadcrumb list has an `itemListOrder` of `ItemListOrderAscending` (lower values listed first), and that the first
  items in this list correspond to the ""top" or beginning of the breadcrumb trail, e.g. with a site or section
  homepage. The specific values of 'position' are not assigned meaning for a BreadcrumbList, but they should be
  integers, e.g. beginning with '1' for the first item in the list.


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

  def serialize(%__MODULE__{} = item) do
    %{
      item
      | itemListElement:
          Enum.map(item.itemListElement, fn list_item ->
            %{ListItem.serialize(list_item) | item: Item.serialize(list_item.item)}
          end)
    }
    |> Map.from_struct()
    |> SEO.json_library().encode!()
  end

  def build(attrs) when is_list(attrs) do
    %__MODULE__{itemListElement: format_items(attrs)}
  end

  defp format_items(items) do
    Enum.with_index(items, fn item, i ->
      i = i + 1

      case item do
        %ListItem{position: pos} = list_item ->
          %{list_item | position: pos || i}

        %Item{} = item ->
          ListItem.build(item: item, position: i)

        attrs when is_list(attrs) or is_map(attrs) ->
          ListItem.build(
            item: Item.build(attrs),
            position: i
          )
      end
    end)
  end
end
