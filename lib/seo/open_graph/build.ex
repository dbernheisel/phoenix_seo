defprotocol SEO.OpenGraph.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/1` which receives your item and return a `SEO.OpenGraph.t` or `nil`
  """

  @spec build(term) :: SEO.OpenGraph.t() | nil
  def build(item)
end

defimpl SEO.OpenGraph.Build, for: Any do
  def build(item), do: SEO.OpenGraph.build(item)
end
