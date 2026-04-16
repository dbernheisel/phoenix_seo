defprotocol SEO.JsonLD.Build do
  @fallback_to_any true
  @moduledoc """
  Derive or implement this protocol to build JSON-LD structured data for your schema.

  Implement `build/2` which receives your item and conn and returns a map, list of maps,
  or `nil`.

  The map(s) should contain `"@context"` and `"@type"` keys, or you can use one of the
  helper modules like `SEO.JsonLD.Article` to build them.

  ## Example

      defimpl SEO.JsonLD.Build, for: MyApp.Article do
        def build(article, _conn) do
          SEO.JsonLD.Article.build(
            headline: article.title,
            description: article.description,
            datePublished: article.published_at
          )
        end
      end
  """

  @spec build(term, Plug.Conn.t()) :: map() | list(map()) | nil
  def build(thing, conn)
end

defimpl SEO.JsonLD.Build, for: Any do
  def build(_item, _conn), do: nil
end
