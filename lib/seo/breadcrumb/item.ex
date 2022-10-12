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
  def build(attrs, _default \\ nil) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end

  @doc false
  def to_map(%__MODULE__{} = item) do
    item |> Map.from_struct()
  end
end
