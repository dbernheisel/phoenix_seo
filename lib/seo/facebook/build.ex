defprotocol SEO.Facebook.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/2` which receives your item and conn and returns a `SEO.Facebook.t` or `nil`
  """

  @spec build(term, Plug.Conn.t()) :: SEO.Facebook.t() | nil
  def build(item, conn)
end

defimpl SEO.Facebook.Build, for: Any do
  def build(item, _conn), do: SEO.Facebook.build(item)
end
