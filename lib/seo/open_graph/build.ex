defprotocol SEO.OpenGraph.Build do
  @fallback_to_any true

  @spec build(term) :: SEO.OpenGraph.t() | nil
  def build(item)
end
