defprotocol SEO.Twitter.Build do
  @fallback_to_any true

  @spec build(term) :: SEO.Twitter.t() | nil
  def build(item)
end

defimpl SEO.Twitter.Build, for: Any do
  def build(item), do: SEO.Twitter.build(item)
end
