defmodule SEO.Breadcrumb.ListItem do
  @moduledoc """
  One item in a `SEO.Breadcrumb.List`
  """

  defstruct [
    :position,
    :item,
    :name,
    "@type": "ListItem"
  ]

  @type t :: %__MODULE__{
          position: pos_integer(),
          "@type": String.t(),
          item: String.t() | URI.t()
        }

  @doc """
  One item within a breadcrumb list.

  The two required keys for every item are:

  - `:item` - The URL of the item, eg: "https://example.com/cats".
  - `:name` - The name of the item, eg: "Cats"

  You may optionally provide the position. If unset, then one will be generated
  for you based on its position in the list. (1-based)

  - `:position` - The position in the breadcrumb list, eg: 1 (first)

  For example:

  ```elixir
  SEO.Breadcrumb.ListItem.build(%{
    name: "Posts",
    item: Routes.blog_url(@endpoint, :index)
  })
  ```
  """

  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  @doc false
  def to_map(%__MODULE__{} = list_item) do
    list_item |> Map.from_struct()
  end
end
