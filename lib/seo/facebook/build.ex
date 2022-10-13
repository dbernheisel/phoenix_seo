defprotocol SEO.Facebook.Build do
  @fallback_to_any true

  @spec build(term) :: SEO.Facebook.t() | nil
  def build(item)
end
