defprotocol SEO.Unfurl.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/2` which receives your item and conn and returns a `SEO.Unfurl.t` or `nil`
  """

  @spec build(term, Plug.Conn.t()) :: SEO.Unfurl.t() | nil
  def build(item, conn)
end

defimpl SEO.Unfurl.Build, for: Any do
  def build(item, _conn), do: SEO.Unfurl.build(item)
end
