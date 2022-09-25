defmodule SEO.OpenGraph.Article do
  @moduledoc """
  https://ogp.me/#type_article

  - article - Namespace URI: https://ogp.me/ns/article#
  - article:published_time - datetime - When the article was first published.
  - article:modified_time - datetime - When the article was last changed.
  - article:expiration_time - datetime - When the article is out of date after.
  - article:author - profile array - Writers of the article.
  - article:section - string - A high-level section name. E.g. Technology
  - article:tag - string array - Tag words associated with this article.
  """

  defstruct [
    :published_time,
    :modified_time,
    :expiration_time,
    :author,
    :section,
    :tag,
    namespace: "https://ogp.me/ns/article#"
  ]

  @type t :: %__MODULE__{
          namespace: String.t(),
          published_time: DateTime.t() | NaiveDateTime.t() | Date.t(),
          modified_time: DateTime.t() | NaiveDateTime.t() | Date.t(),
          expiration_time: DateTime.t() | NaiveDateTime.t() | Date.t(),
          author: SEO.OpenGraph.Profile.t() | list(SEO.OpenGraph.Profile.t()),
          section: String.t(),
          tag: String.t() | list(String.t())
        }

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
