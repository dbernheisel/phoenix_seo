defprotocol SEO.LLMs.Build do
  @fallback_to_any true
  @moduledoc """
  Implement `build/2` which receives your item and conn and returns an
  `SEO.LLMs.Entry.t()`, a list of entries, or `nil`.

  This tells phoenix_seo how your resource should appear in llms.txt
  and what markdown content to serve when the resource is requested
  in markdown format.

  ## Example

      defimpl SEO.LLMs.Build, for: MyApp.Article do
        def build(article, _conn) do
          SEO.LLMs.Entry.build(
            section: "Articles",
            title: article.title,
            url: "/articles/\#{article.slug}",
            description: article.summary,
            content: article.body
          )
        end
      end
  """

  @spec build(term, Plug.Conn.t()) :: SEO.LLMs.Entry.t() | [SEO.LLMs.Entry.t()] | nil
  def build(item, conn)
end

defimpl SEO.LLMs.Build, for: Any do
  def build(_item, _conn), do: nil
end
