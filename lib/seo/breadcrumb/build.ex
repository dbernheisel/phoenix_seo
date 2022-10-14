defprotocol SEO.Breadcrumb.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/1` which receives your item and return a `SEO.Breadcrumb.List.t` or `nil`
  """

  @spec build(term) :: SEO.Breadcrumb.List.t() | nil
  def build(list_of_items)
end

defimpl SEO.Breadcrumb.Build, for: Any do
  def build(item), do: SEO.Breadcrumb.List.build(item)
end
