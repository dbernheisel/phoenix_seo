defprotocol SEO.Site.Build do
  @fallback_to_any true

  @spec build(term) :: SEO.Site.t() | nil
  def build(item)
end

defimpl SEO.Site.Build, for: Any do
  def build(item), do: SEO.Site.build(item)
end
