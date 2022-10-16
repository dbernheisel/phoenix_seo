defprotocol SEO.Site.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/2` which receives your item and conn and returns a `SEO.Site.t` or `nil`
  """

  @spec build(term, Plug.Conn.t()) :: SEO.Site.t() | nil
  def build(item, conn)
end

defimpl SEO.Site.Build, for: Any do
  def build(item, _conn), do: SEO.Site.build(item)
end
