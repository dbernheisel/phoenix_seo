defprotocol SEO.Breadcrumb.Build do
  @fallback_to_any true

  @spec build(term) :: SEO.Breadcrumb.List.t() | nil
  def build(list_of_items)
end
