defmodule SEO.Breadcrumb.Item do
  @moduledoc ""

  defstruct [
    :name,
    :"@id"
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          "@id": String.t()
        }

  def to_map(%__MODULE__{} = item) do
    item |> Map.from_struct()
  end

  def build(attrs, _default \\ nil) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
