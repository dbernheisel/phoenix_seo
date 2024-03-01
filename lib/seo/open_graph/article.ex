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

  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  use Phoenix.Component
  alias SEO.Utils

  attr :content, __MODULE__, default: nil

  def meta(assigns) do
    assigns = assign(assigns, :content, build(assigns[:content], assigns[:config]))

    ~H"""
    <%= if @content do %>
    <%= if @content.published_time do %>
    <meta property="article:published_time" content={Utils.to_iso8601(@content.published_time)} />
    <% end %><%= if @content.modified_time do %>
    <meta property="article:modified_time" content={Utils.to_iso8601(@content.modified_time)} />
    <% end %><%= if @content.expiration_time do %>
    <meta property="article:expiration_time" content={Utils.to_iso8601(@content.expiration_time)} />
    <% end %><%= if @content.section do %>
    <meta property="article:section" content={@content.section} />
    <% end %><%= if (authors = List.wrap(@content.author)) != [] do %>
    <SEO.OpenGraph.Profile.meta :for={author <- authors} property="article:author" content={author} />
    <% end %><%= if (tags = List.wrap(@content.tag)) != [] do %>
    <meta :for={tag <- tags} property="article:tag" content={tag} />
    <% end %>
    <% end %>
    """
  end
end
