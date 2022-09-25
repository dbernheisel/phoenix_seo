defmodule SEO.Breadcrumb.ListItem do
  @moduledoc ""

  defstruct [
    :position,
    :item,
    "@context": "https://schema.org",
    "@type": "ListItem"
  ]

  @type t :: %__MODULE__{
          position: pos_integer(),
          "@context": String.t(),
          "@type": String.t(),
          item: SEO.Breadcrumb.Item.t()
        }

  def serialize(%__MODULE__{} = list_item) do
    list_item |> Map.from_struct() |> SEO.json_library().encode!()
  end

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
