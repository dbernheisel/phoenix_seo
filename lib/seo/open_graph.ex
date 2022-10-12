defmodule SEO.OpenGraph do
  @moduledoc """
  Build OpenGraph tags. This is destined for Facebook, Google, Twitter, and Slack.

  ## Basic Metadata

  To turn your web pages into graph objects, you need to add basic metadata to your page. We've based the initial
  version of the protocol on RDFa which means that you'll place additional `<meta>` tags in the `<head>` of your web page. The four required properties for every page are:

  - `og:title` - The title of your object as it should appear within the graph, e.g., "The Rock".
  - `og:type` - The type of your object, e.g., "article". Depending on the type you specify, other properties may also be required.
  - `og:image` - An image URL which should represent your object within the graph.
  - `og:url` - The canonical URL of your object that will be used as its permanent ID in the graph, e.g., "https://www.imdb.com/title/tt0117500/".

  As an example, the following is the Open Graph protocol markup for The Rock on IMDB:

      <html prefix="og: https://ogp.me/ns#">
      <head>
      <title>The Rock (1996)</title>
      <meta property="og:title" content="The Rock" />
      <meta property="og:type" content="video.movie" />
      <meta property="og:url" content="https://www.imdb.com/title/tt0117500/" />
      <meta property="og:image" content="https://ia.media-imdb.com/images/rock.jpg" />
      ...
      </head>
      ...
      </html>

  ## Optional Metadata

  The following properties are optional for any object and are generally recommended:

  - `og:audio` - A URL to an audio file to accompany this object.
  - `og:description` - A one to two sentence description of your object.
  - `og:determiner` - The word that appears before this object's title in a sentence. An enum of (a, an, the, "", auto).
  If auto is chosen, the consumer of your data should chose between "a" or "an". Default is "" (blank).
  - `og:locale` - The locale these tags are marked up in. Of the format language_TERRITORY. Default is en_US.
  - `og:locale:alternate` - An array of other locales this page is available in.
  - `og:site_name` - If your object is part of a larger web site, the name which should be displayed for the overall
  site. e.g., "IMDb".
  - `og:video` - A URL to a video file that complements this object.

  ## Additional Resources

  https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data
  https://developers.facebook.com/docs/sharing/webmasters/
  https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/markup
  https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards
  https://api.slack.com/reference/messaging/link-unfurling#classic_unfurl
  """

  ## TODO
  # - Tokenizer that turns HTML into sentences. re: https://github.com/wardbradt/HTMLST

  defstruct [
    :title,
    :type_detail,
    :image,
    :url,
    :audio,
    :locale,
    :locale_alternate,
    :site_name,
    :video,
    type: :website,
    description: "",
    determiner: :blank
  ]

  @type t :: %__MODULE__{
          title: String.t(),
          type: open_graph_type(),
          type_detail: type_detail(),
          url: URI.t() | String.t(),
          description: String.t() | nil,
          determiner: open_graph_determiner(),
          image: String.t() | SEO.OpenGraph.Image.t() | nil,
          audio: String.t() | SEO.OpenGraph.Audio.t() | nil,
          video: String.t() | SEO.OpenGraph.Video.t() | nil,
          locale: language_territory() | nil,
          locale_alternate: language_territory() | list(language_territory()) | nil,
          site_name: String.t() | nil
        }

  @typedoc "language code and territory code, eg: en_US"
  @type language_territory :: String.t()
  @type type_detail ::
          SEO.OpenGraph.Article.t()
          | SEO.OpenGraph.Profile.t()
          | SEO.OpenGraph.Book.t()
          | nil

  @typedoc """
  The word that appears before this object's title in a sentence. If `:auto` is chosen, the consumer of your data should
  chose between "a" or "an".
  """
  @type open_graph_determiner :: :a | :an | :the | :auto | :blank

  @type open_graph_type :: :article | :book | :profile | :website

  def build(attrs, default \\ nil)

  def build(attrs, default) when is_map(attrs) do
    %SEO.OpenGraph{}
    |> struct(Map.merge(default || %{}, attrs))
    |> SEO.OpenGraph.build_type_detail(attrs)
  end

  def build(attrs, default) when is_list(attrs) do
    %SEO.OpenGraph{}
    |> struct(Keyword.merge(default || [], attrs))
    |> SEO.OpenGraph.build_type_detail(attrs)
  end

  @doc false
  def build_type_detail(%{type: :website} = og, _attrs), do: og

  def build_type_detail(%{type: :article} = og, attrs) do
    %{og | type_detail: SEO.OpenGraph.Article.build(attrs)}
  end

  def build_type_detail(%{type: :book} = og, attrs) do
    %{og | type_detail: SEO.OpenGraph.Book.build(attrs)}
  end

  def build_type_detail(%{type: :profile} = og, attrs) do
    %{og | type_detail: SEO.OpenGraph.Profile.build(attrs)}
  end

  defp to_iso8601(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_iso8601(ndt)
  defp to_iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp to_iso8601(%Date{} = d), do: Date.to_iso8601(d)

  use Phoenix.Component

  attr(:item, __MODULE__, required: true)

  def meta(assigns) do
    ~H"""
    <meta property="og:title" content={@item.title} :if={@item.title} />
    <meta property="og:description" content={@item.description} :if={@item.description} />
    <meta property="og:type" content={@item.type} />
    <.url property="og:url" content={@item.url} :if={@item.url} />
    <meta property="og:site_name" content={@item.site_name} :if={@item.site_name} />
    <meta property="og:locale" content={@item.locale} :if={@item.locale} />
    <meta :for={locale <- List.wrap(@item.locale_alternate)} :if={List.wrap(@item.locale_alternate) != []} property="og:locale:alternate" content={locale} />
    <.book :if={@item.type == :book} content={@item.type_detail} />
    <.article :if={@item.type == :article} content={@item.type_detail} />
    <.profile :if={@item.type == :profile} content={@item.type_detail} />
    <.image :for={image <- List.wrap(@item.image)} content={image} />
    <.audio :for={audio <- List.wrap(@item.audio)} content={audio} />
    <.video :for={video <- List.wrap(@item.video)} content={video} />
    """
  end

  attr(:property, :string, required: true)
  attr(:content, :any, required: true, doc: "Either a string representing a URI, or a URI")

  def url(assigns) do
    case assigns[:content] do
      %URI{} ->
        ~H"""
        <meta property={@property} content={"#{@content}"} />
        """

      url when is_binary(url) ->
        ~H"""
        <meta property={@property} content={@content} />
        """
    end
  end

  attr(:content, SEO.OpenGraph.Article, required: true)

  def article(assigns) do
    ~H"""
    <meta :if={@content.published_time} property="article:published_time" content={to_iso8601(@content.published_time)} />
    <meta :if={@content.modified_time} property="article:modified_time" content={to_iso8601(@content.modified_time)} />
    <meta :if={@content.expiration_time} property="article:expiration_time" content={to_iso8601(@content.expiration_time)} />
    <meta :if={@content.section} property="article:section" content={@content.section} />
    <meta :for={author <- List.wrap(@content.author)} :if={List.wrap(@content.author) != []} property="article:author" content={author} />
    <meta :for={tag <- List.wrap(@content.tag)} :if={List.wrap(@content.tag) != []} property="article:tag" content={tag} />
    """
  end

  attr(:content, SEO.OpenGraph.Book, required: true)

  def book(assigns) do
    ~H"""
    <meta property="book:release_date" content={to_iso8601(@content.release_date)} :if={@content.release_date} />
    <meta property="book:isbn" content={@content.isbn} :if={@content.isbn} />
    <meta :for={author <- List.wrap(@content.author)} property="book:author" content={author} :if={List.wrap(@content.author) != []} />
    <meta :for={tag <- List.wrap(@content.tag)} property="book:tag" content={tag} :if={List.wrap(@content.tag) != []} />
    """
  end

  attr(:content, SEO.OpenGraph.Profile, required: true)

  def profile(assigns) do
    ~H"""
    <meta :if={@content.first_name} property="profile:first_name" content={@content.first_name} />
    <meta :if={@content.last_name} property="profile:last_name" content={@content.last_name} />
    <meta :if={@content.username} property="profile:username" content={@content.username} />
    <meta :if={@content.gender} property="profile:gender" content={@content.gender} />
    """
  end

  attr(:content, :any, required: true, doc: "Either an `SEO.OpenGraph.Image`, a string, or a URI")

  def image(assigns) do
    case assigns[:content] do
      %SEO.OpenGraph.Image{} ->
        ~H"""
        <%= if @content.url do %>
        <.url property="og:image" content={@content.url} />
        <.url :if={@content.secure_url} property="og:image:secure_url" content={@content.secure_url} />
        <meta :if={@content.type} property="og:image:type" content={@content.type} />
        <meta :if={@content.width} property="og:image:width" content={@content.width} />
        <meta :if={@content.height} property="og:image:height" content={@content.height} />
        <meta :if={@content.alt} property="og:image:alt" content={@content.alt} />
        <% end %>
        """

      _url ->
        ~H"""
        <.url property="og:image" content={@content} />
        """
    end
  end

  attr(:content, :any, required: true)

  def video(assigns) do
    case assigns[:content] do
      %SEO.OpenGraph.Video{} ->
        ~H"""
        <%= if @content.url do %>
        <.url property="og:video" content={@content.url} />
        <.url :if={@content.secure_url} property="og:video:secure_url" content={@content.secure_url} />
        <meta :if={@content.mime} property="og:video:type" content={@content.mime} />
        <meta :if={@content.width} property="og:video:width" content={@content.width} />
        <meta :if={@content.height} property="og:video:height" content={@content.height} />
        <meta :if={@content.alt} property="og:video:alt" content={@content.alt} />
        <% end %>
        """

      _url ->
        ~H"""
        <.url property="og:video" content={@content} />
        """
    end
  end

  attr(:content, SEO.OpenGraph.Audio, required: true)

  def audio(assigns) do
    case assigns[:content] do
      %SEO.OpenGraph.Audio{} ->
        ~H"""
        <%= if @content.url do %>
        <.url property="og:audio" content={@content.url} />
        <.url :if={@content.secure_url} property="og:audio:secure_url" content={@content.secure_url} />
        <meta :if={@content.type} property="og:audio:type" content={@content.type} />
        <% end %>
        """

      _url ->
        ~H"""
        <.url property="og:audio" content={@content} />
        """
    end
  end
end
