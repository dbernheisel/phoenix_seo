defmodule SEO.Breadcrumb.ListItem do
  @moduledoc """
  One item in a `SEO.Breadcrumb.List`
  """

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

  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  @doc false
  def to_map(%__MODULE__{} = list_item) do
    list_item |> Map.from_struct()
  end
end
