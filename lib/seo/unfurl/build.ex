defprotocol SEO.Unfurl.Build do
  @fallback_to_any true

  @spec build(term) :: SEO.Unfurl.t() | nil
  def build(item)
end

defimpl SEO.Unfurl.Build, for: Any do
  def build(item), do: SEO.Unfurl.build(item)
end
