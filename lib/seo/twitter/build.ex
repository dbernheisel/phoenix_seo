defprotocol SEO.Twitter.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/2` which receives your item and conn and returns a `SEO.Twitter.t` or `nil`
  """

  @spec build(term, Plug.Conn.t()) :: SEO.Twitter.t() | nil
  def build(item, conn)
end

defimpl SEO.Twitter.Build, for: Any do
  def build(item, _conn), do: SEO.Twitter.build(item)
end
