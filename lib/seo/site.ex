defmodule SEO.Site do
  @moduledoc """
  Metadata about your site.

  ### Resources

  - https://developer.mozilla.org/en-US/docs/Learn/HTML/Introduction_to_HTML/The_head_metadata_in_HTML
  - https://www.bing.com/webmasters/help/which-robots-metatags-does-bing-support-5198d240
  - https://developers.google.com/search/docs/crawling-indexing/consolidate-duplicate-urls
  - https://developers.google.com/search/docs/crawling-indexing/robots-meta-tag
  - https://developers.google.com/search/docs/crawling-indexing/special-tags
  - https://developers.google.com/search/docs/appearance/title-link
  """

  use Phoenix.Component

  defstruct [
    :description,
    :title,
    :default_title,
    :title_prefix,
    :title_suffix,
    :canonical_url,
    :rating,
    :google,
    :googlebot,
    :google_site_verification,
    :robots,
    alternate_languages: []
  ]

  @type t :: %__MODULE__{
          default_title: String.t() | nil,
          title: String.t() | nil,
          title_prefix: String.t() | nil,
          title_suffix: String.t() | nil,
          canonical_url: URI.t() | String.t() | nil,
          rating: String.t() | nil,
          robots: String.t() | list(String.t()) | nil,
          googlebot: String.t() | nil,
          alternate_languages: list({String.t(), String.t() | URI.t()}),
          google: String.t() | list(String.t()) | nil,
          description: String.t() | nil
        }

  @doc """
  Metadata that describes the site generally.

  - `:title` - Title of the page.
  - `:description` - A one to two sentence description of your item.
  - `:canonical_url` - A URL that is most representative of your item.
  - `:rating` - `"adult"`. If a rating of `"adult"` is applied, it's also recommended to separate adult assets into a
  folder such as `example.com/explicit/wow.jpg`. No value provided means the content is appropriate for everyone.
  - `:alternate_languages` -  If your site is multilingual, you can inform search engines. Supply a list of tuples of the
  lang_code and the URL for the page. For example:
    ```elixir
    [
      {"en_US", Routes.article_url(@endpoint, article.id)},
      {"ja_JP", Routes.jp_article_url(@endpoint, article.id)}
    ]
    ```
  - `:google` - Google-specific metadata. It can be one of these values or a list of these values:
    - `"nositelinkssearch"`. When users search for your site, Google Search results sometimes display a search box
    specific to your site, along with other direct links to your site. This tag tells Google not to show the sitelinks
    search box. [Learn more about sitelinks search box.](https://developers.google.com/search/docs/appearance/structured-data/sitelinks-searchbox)
    - `"nopagereadaloud"` - Prevents various [Google text-to-speech services](https://developers.google.com/search/docs/crawling-indexing/read-aloud-user-agent) from reading aloud web pages using text-to-speech (TTS). Prevents various

  - `:googlebot` - Google crawler bot metadata.
    - `"notranslate"` - when Google recognizes that the contents of a page aren't in the language that the user
    likely wants to read, Google may provide a translated title link and snippet in search results. If the user
    clicks the translated title link, all further user interaction with the page is through Google Translate,
    which will automatically translate any links followed. In general, this gives you the chance to provide
    your unique and compelling content to a much larger group of users. However, there may be situations where
    this is not desired. This meta tag tells Google that you don't want Google to provide a translation for
    this page.
  - `:google_site_verification` - You can use this tag on the top-level page of your site to verify ownership for Search
  Console. Please note that while the values of the name and content attributes must match exactly what is provided to
  you (including upper and lower case), it doesn't matter if you change the tag from XHTML to HTML or if the format of
  the tag matches the format of your page.

  - `:robots` - Robot instructions. You may provide or a list of the values:
    - `"noindex"` do not index the page
    - `"noimageindex"` do not index images on this page. If you don't specify this value, images on the page may be
    indexed and shown in search results.
    - `unavailable_after: [date/time]` do not show this page in search results after the specified date/time. The
    date/time must be specified in a widely adopted format including ISO 8601.
    - `"nofollow"` do not follow outlines from the page.
    - `"none"` Equivalent to `noindex, nofollow`
    - `"all"` There are no restrictions for indexing or serving. This directive is the default value and has no effect if explicitly listed.
    - `"indexifembedded"` Google is allowed to index the content of a page if it's embedded in another page through
    iframes or similar HTML tags, in spite of a noindex directive.
    - `"notranslate"` don't offer translation of this page in search results
    - `"noarchive"` do not store a cached page
    - `"nocache"` do not store a cached page. Same as `"noarchive"`
    - `"noodp"` do not use a description from [Open Directory Project](http://dmoz.org)
    - `"nosnippet"` do not show a description nor a preview thumbnail for the page
    - `"max-snippet:[number]"` max text length in characters to show in search results. The number may be:
      - `0` no text snippet
      - `-1` no limit
    - `"max-image-preview:[value]"` Max size of an image preview. The value may be:
      - `none` do not show an image preview
      - `standard` show a standard size image
      - `large` show a large size image
      - any other value will mean there is no image size limit
    - `"max-video-preview:[number]"` Max number of seconds of a video preview. The number may be:
      - `0` show a static image instead
      - `-1` allow any preview length
  """
  def build(attrs, default \\ %__MODULE__{})

  def build(attrs, default) when is_map(attrs) do
    %__MODULE__{}
    |> Map.merge(default)
    |> Map.merge(attrs)
  end

  def build(attrs, default) when is_list(attrs) do
    build(Enum.into(attrs, %{}), default)
  end

  attr(:item, :any, required: true)
  attr(:page_title, :string, default: nil)

  def meta(assigns) do
    ~H"""
    <.live_title prefix={@item.title_prefix} suffix={@item.title_suffix}><%= @page_title || @item.title || @item.default_title %></.live_title>
    <link :if={@item.canonical_url} rel="canonical" href={@item.canonical_url} />
    <link :for={{lang, url} <- @item.alternate_languages} rel="alternate" hreflag={lang} href={"#{url}"} />
    <meta :if={@item.description} name="description" content={@item.description} />
    <meta :if={@item.rating} name="rating" content={@item.rating} />
    <%= if @item.robots && !Enum.empty?(List.wrap(@item.robots)) do %>
    <meta name="robots" content={Enum.join(List.wrap(@item.robots), ", ")} />
    <% end %><%= if @item.google && !Enum.empty?(List.wrap(@item.google)) do %>
    <meta name="google" content={Enum.join(List.wrap(@item.google), ", ")} />
    <% end %>
    <meta :if={@item.googlebot} name="googlebot" content={@item.googlebot} />
    <meta :if={@item.google_site_verification} name="google-site-verification" content={@item.google_site_verification} />
    """
  end
end
