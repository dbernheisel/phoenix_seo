defprotocol SEO.OpenGraph.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/2` which receives your item and conn and returns a `SEO.OpenGraph.t` or `nil`
  """

  @spec build(term, Plug.Conn.t()) :: SEO.OpenGraph.t() | nil
  def build(item, conn)
end

defimpl SEO.OpenGraph.Build, for: Any do
  def build(item, _conn), do: SEO.OpenGraph.build(item)
end
