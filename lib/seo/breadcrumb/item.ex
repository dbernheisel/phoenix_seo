defmodule SEO.Breadcrumb.Item do
  @moduledoc """
  The referenced item in a `SEO.Breadcrumb.ListItem`
  """

  defstruct [
    :name,
    :id
  ]

  @type t :: %__MODULE__{
          name: String.t(),
          id: String.t()
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
    item |> Map.from_struct() |> rename()
  end

  @rename %{id: "@id"}
  @doc false
  defp rename(attrs) do
    Enum.reduce(@rename, attrs, fn {from, to}, acc ->
      case Map.pop(acc, from) do
        {nil, popped} -> popped
        {value, popped} -> Map.put(popped, to, value)
      end
    end)
  end
end
