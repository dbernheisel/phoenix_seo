defmodule SEO.OpenGraph.Article do
  @moduledoc """
  Metadata describing an article.

  ### Resources

  - https://ogp.me/#type_article
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
          author:
            URI.t() | String.t() | SEO.OpenGraph.Profile.t() | list(SEO.OpenGraph.Profile.t()),
          section: String.t(),
          tag: String.t() | list(String.t())
        }

  @doc """
  Build metadata about an article.

  - `:published_time` - when the article was first published.
  - `:modified_time` - when the article was last changed.
  - `:expiration_time` - when the article is out of date after.
  - `:author` - Writers of the article. This can be nested author OpenGraph metadata or URLs that
  provide the metadata or simply the author's name.
  - `:section` - A high-level section name. E.g. `"Technology"`
  - `:tag` - Tag words associated with this article. E.g. `["Elixir", "Ecto"]`
  """
  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end

  use Phoenix.Component
  alias SEO.Utils

  attr(:content, __MODULE__, required: true)

  def meta(assigns) do
    ~H"""
    <meta :if={@content.published_time} property="article:published_time" content={Utils.to_iso8601(@content.published_time)} />
    <meta :if={@content.modified_time} property="article:modified_time" content={Utils.to_iso8601(@content.modified_time)} />
    <meta :if={@content.expiration_time} property="article:expiration_time" content={Utils.to_iso8601(@content.expiration_time)} />
    <meta :if={@content.section} property="article:section" content={@content.section} />
    <SEO.OpenGraph.Profile.meta :for={author <- List.wrap(@content.author)} :if={List.wrap(@content.author) != []} property="article:author" content={author} />
    <meta :for={tag <- List.wrap(@content.tag)} :if={List.wrap(@content.tag) != []} property="article:tag" content={tag} />
    """
  end
end
