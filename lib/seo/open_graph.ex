defmodule SEO.OpenGraph do
  @moduledoc """
  Build OpenGraph tags. This is destined for Facebook, Google, Twitter, and Slack.

  For example, the following is the Open Graph protocol markup for The Rock on IMDB:

  ```html
  <html>
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
  ```

  ### Resources

  - https://developers.google.com/search/docs/appearance/structured-data/intro-structured-data
  - https://developers.facebook.com/docs/sharing/webmasters/
  - https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/markup
  - https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards
  """

  ## TODO
  # - Tokenizer that turns HTML into sentences. re: https://github.com/wardbradt/HTMLST

  use Phoenix.Component
  alias SEO.OpenGraph.Article
  alias SEO.OpenGraph.Audio
  alias SEO.OpenGraph.Book
  alias SEO.OpenGraph.Image
  alias SEO.OpenGraph.Profile
  alias SEO.OpenGraph.Video

  defstruct [
    :url,
    :title,
    :description,
    :site_name,
    :type_detail,
    :image,
    :locale,
    :locale_alternate,
    :audio,
    :video,
    type: :website,
    determiner: :blank
  ]

  @type t :: %__MODULE__{
          title: String.t(),
          type: open_graph_type(),
          type_detail: type_detail(),
          url: URI.t() | String.t(),
          description: String.t() | nil,
          determiner: open_graph_determiner(),
          image: URI.t() | String.t() | Image.t() | nil,
          audio: URI.t() | String.t() | Audio.t() | nil,
          video: URI.t() | String.t() | Video.t() | nil,
          locale: language_territory() | nil,
          locale_alternate: language_territory() | list(language_territory()) | nil,
          site_name: String.t() | nil
        }

  @typedoc "language code and territory code, eg: en_US"
  @type language_territory :: String.t()
  @type type_detail :: Article.t() | Profile.t() | Book.t() | nil

  @typedoc """
  The word that appears before this item's title in a sentence. If `:auto` is chosen, the consumer of your data should
  chose between "a" or "an".
  """
  @type open_graph_determiner :: :a | :an | :the | :auto | :blank

  @type open_graph_type :: :article | :book | :profile | :website

  @doc """
  Turn your structs into graph items.

  ## Basic Metadata

  The four required properties for every page are:

  - `:title` - The title of your item as it should appear within the graph, e.g., "The Rock".
  - `:type` - The type of your item, e.g., `:article`. Depending on the type you specify, other properties
    may also be required.
  - `:image` - An image URL or `SEO.OpenGraph.Image` that represents your item within the graph.
  - `:url` - The canonical URL of your item that will be used as its permanent ID in the graph, e.g.,
    "https://www.imdb.com/title/tt0117500/". Ultimately, this is where the programs will scrape for metadata.
    For example, if you point the og:url to a YouTube video page, the scraper will use the metadata found on
    that video page and not the currently-visited site.

  ## Optional Metadata

  The following properties are optional for any item and are generally recommended:

  - `:audio` - A URL to a complementing audio file. You may also be more detail with `SEO.OpenGraph.Audio`
  - `:description` - A one to two sentence description of your item.
  - `:determiner` - The word that appears before this item's title in a sentence. An enum of `:a`, `:an`, `:the`,
    `:blank`, `:auto`. If `:auto` is chosen, the consumer of your data should chose between `:a` or `:an`.
    Default is `:blank`.
  - `:locale` - The locale these tags are marked up in. Of the format language_TERRITORY. Blank is treated as `"en_US"`.
  - `:locale:alternate` - An array of other locales this page is available in.
  - `:site_name` - If your item is part of a larger web site, the name which should be displayed for the overall
    site. e.g., "IMDb".
  - `:video` - A URL to a complementing video file. You may also provide more detail with `SEO.OpenGraph.Video`
  """

  def build(attrs, defaults \\ %__MODULE__{})

  def build(attrs, defaults) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, defaults)
    |> build_type_detail(attrs)
  end

  @doc false
  def build_type_detail(%{type: :website} = og, _attrs), do: og

  def build_type_detail(%{type: :article} = og, attrs) do
    %{og | type_detail: Article.build(attrs)}
  end

  def build_type_detail(%{type: :book} = og, attrs) do
    %{og | type_detail: Book.build(attrs)}
  end

  def build_type_detail(%{type: :profile} = og, attrs) do
    %{og | type_detail: Profile.build(attrs)}
  end

  attr(:item, __MODULE__, required: true)

  def meta(assigns) do
    ~H"""
    <meta property="og:title" content={@item.title} :if={@item.title} />
    <meta property="og:description" content={SEO.Utils.truncate(@item.description)} :if={@item.description} />
    <meta property="og:type" content={@item.type} />
    <SEO.Utils.url property="og:url" content={@item.url} :if={@item.url} />
    <meta property="og:site_name" content={@item.site_name} :if={@item.site_name} />
    <meta property="og:determiner" content={format_determiner(@item.determiner)} :if={@item.determiner !=:blank} />
    <meta property="og:locale" content={@item.locale} :if={@item.locale} />
    <meta :for={locale <- List.wrap(@item.locale_alternate)} property="og:locale:alternate" content={locale} :if={List.wrap(@item.locale_alternate) != []} />
    <Book.meta content={@item.type_detail} :if={@item.type == :book} />
    <Article.meta content={@item.type_detail} :if={@item.type == :article} />
    <Profile.meta content={@item.type_detail} :if={@item.type == :profile} />
    <Image.meta :for={image <- List.wrap(@item.image)} content={image} />
    <Audio.meta :for={audio <- List.wrap(@item.audio)} content={audio} />
    <Video.meta :for={video <- List.wrap(@item.video)} content={video} />
    """
  end

  defp format_determiner(:blank), do: nil
  defp format_determiner(determiner), do: "#{determiner}"
end
