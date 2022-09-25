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

  def serialize(%__MODULE__{} = item) do
    item |> Map.from_struct() |> SEO.json_library().encode!()
  end

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
