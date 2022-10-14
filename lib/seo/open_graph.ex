defmodule SEO.OpenGraph do
  @moduledoc """
  Build OpenGraph tags. This is consumed by platforms such as Google, Facebook, Twitter,
  Slack, and others.

  For example, the following is the OpenGraph markup for the movie "The Rock" on IMDB:

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

  use Phoenix.Component
  alias SEO.OpenGraph.Article
  alias SEO.OpenGraph.Audio
  alias SEO.OpenGraph.Book
  alias SEO.OpenGraph.Image
  alias SEO.OpenGraph.Profile
  alias SEO.OpenGraph.Video
  alias SEO.Utils

  defstruct [
    :url,
    :title,
    :description,
    :determiner,
    :site_name,
    :type_detail,
    :image,
    :locale,
    :locale_alternate,
    :audio,
    :video,
    type: :website
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
  The word that appears before this item's title in a sentence.

  If `:auto` is chosen, the consumer of your data should chose between "a" or "an".
  """
  @type open_graph_determiner :: :a | :an | :the | :auto | nil

  @typedoc "The type of OpenGraph object."
  @type open_graph_type :: :article | :book | :profile | :website

  @doc """
  Represent your items on the graph of the internet. 🤩🌐📄

  ## Basic Metadata

  The four required properties for every page are:

  - `:title` - The title of your item as it should appear within the graph, e.g., "The Rock".
  - `:type` - The type of your item, e.g., `:article`. Depending on the type you specify, other properties
    may also be required. Default is `:website`.
  - `:image` - An image URL or `SEO.OpenGraph.Image` that represents your item within the graph.
  - `:url` - The canonical URL of your item that will be used as its permanent ID in the graph, e.g.,
    "https://www.imdb.com/title/tt0117500/". Ultimately, this is where the programs will scrape for metadata.
    For example, if you use a url of a YouTube video page, the scraper will use the OpenGraph tags found on
    that video page and not the currently-visited site.

  ## Optional Metadata

  The following properties are optional for any item and are generally recommended:

  - `:audio` - A URL to a complementing audio file. You may also be more detail with `SEO.OpenGraph.Audio`
  - `:description` - A one to two sentence description of your item.
  - `:determiner` - The word that appears before this item's title in a sentence. An enum of `:a`, `:an`, `:the`,
    `nil`, `:auto`. If `:auto` is chosen, the consumer of your data should chose between `:a` or `:an`.
  - `:locale` - The locale these tags are marked up in. Of the format language_TERRITORY.
    Unsupplied is consumed as `"en_US"`.
  - `:locale_alternate` - A list of other locales this page is available in and their URLs.
  - `:site_name` - If your item is part of a larger web site, the name which should be displayed for the overall
    site. e.g., "IMDb".
  - `:video` - A URL to a complementing video file. You may also provide more detail with `SEO.OpenGraph.Video`
  """

  @spec build(SEO.attrs()) :: t() | nil
  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    __MODULE__
    |> Utils.merge_defaults(attrs, default)
    |> build_type_detail()
  end

  @doc false
  def build_type_detail(nil), do: nil
  def build_type_detail(%{type: :website} = og), do: og

  def build_type_detail(%{type: :article} = og) do
    %{og | type_detail: Article.build(og.type_detail)}
  end

  def build_type_detail(%{type: :book} = og) do
    %{og | type_detail: Book.build(og.type_detail)}
  end

  def build_type_detail(%{type: :profile} = og) do
    %{og | type_detail: Profile.build(og.type_detail)}
  end

  attr(:item, __MODULE__, default: nil)
  attr(:config, :any, default: nil)

  def meta(assigns) do
    assigns = assign(assigns, :item, build(assigns[:item], assigns[:config]))

    ~H"""
    <%= if @item do %>
    <%= if @item.title do %>
    <meta property="og:title" content={@item.title} />
    <% end %>
    <%= if @item.description do %>
    <meta property="og:description" content={@item.description |> Utils.squash_newlines() |> Utils.truncate()} />
    <% end %>
    <meta property="og:type" content={@item.type} />
    <%= if @item.url do %>
    <Utils.url property="og:url" content={@item.url} />
    <% end %><%= if @item.site_name do %>
    <meta property="og:site_name" content={@item.site_name} />
    <% end %><%= if @item.determiner do %>
    <meta property="og:determiner" content={"#{@item.determiner}"} />
    <% end %><%= if @item.locale do %>
    <meta property="og:locale" content={@item.locale} />
    <% end %><%= if locales = List.wrap(@item.locale_alternate) != [] do %>
    <meta :for={locale <- locales} property="og:locale:alternate" content={locale} />
    <% end %><%= if @item.type == :book do %>
    <Book.meta content={@item.type_detail} />
    <% end %><%= if @item.type == :article do %>
    <Article.meta content={@item.type_detail} />
    <% end %><%= if @item.type == :profile do %>
    <Profile.meta content={@item.type_detail} />
    <% end %><%= if (images = List.wrap(@item.image)) != [] do %>
    <Image.meta :for={image <- images} content={image} />
    <% end %><%= if (audios = List.wrap(@item.audio)) != [] do %>
    <Audio.meta :for={audio <- audios} content={audio} />
    <% end %><%= if (videos = List.wrap(@item.video)) != [] do %>
    <Video.meta :for={video <- videos} content={video} />
    <% end %>
    <% end %>
    """
  end
end
