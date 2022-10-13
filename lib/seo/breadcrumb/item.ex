defmodule SEO.Breadcrumb.Item do
  @moduledoc """
  The referenced item in a `SEO.Breadcrumb.ListItem`
  """

  defstruct [
    :name,
    :"@id"
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          "@id": String.t()
        }

  @doc """
  Build an item in a `SEO.Breadcrumb.List`
  """
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  @doc false
  def to_map(%__MODULE__{} = item) do
    item |> Map.from_struct()
  end
end
