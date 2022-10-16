defprotocol SEO.Breadcrumb.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/2` which receives your item and conn and returns a `SEO.Breadcrumb.List.t` or `nil`
  """

  @spec build(term, Plug.Conn.t()) :: SEO.Breadcrumb.List.t() | nil
  def build(list_of_items, conn)
end

defimpl SEO.Breadcrumb.Build, for: Any do
  def build(item, _conn), do: SEO.Breadcrumb.List.build(item)
end
