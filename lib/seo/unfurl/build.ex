defprotocol SEO.Unfurl.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/1` which receives your item and return a `SEO.Unfurl.t` or `nil`
  """

  @spec build(term) :: SEO.Unfurl.t() | nil
  def build(item)
end
