defprotocol SEO.Facebook.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/1` which receives your item and return a `SEO.Facebook.t` or `nil`
  """

  @spec build(term) :: SEO.Facebook.t() | nil
  def build(item)
end

defimpl SEO.Facebook.Build, for: Any do
  def build(item), do: SEO.Facebook.build(item)
end
