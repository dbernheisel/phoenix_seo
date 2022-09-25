defmodule SEO.Site do
  @moduledoc """

  ## Metadata that all sites should have.

  - title - Title of the page. https://developers.google.com/search/docs/appearance/title-link

  - description

  ## Metadata that might be necessary

  - canonical_url

  - rating - `adult`. If a rating of `adult` is applied, it's also recommended to separate adult assets into a folder
  such as `example.com/explicit/wow.jpg`. No value provided means the content is appropriate for everyone.any()

  - alternate languages. If your site is multilingual, you can inform search engines. Supply a list of tuples of the
  lang_code and the URL for the page, eg: `[{"en_US", Routes.article_url(@endpoint, article.id)}, {"ja_JP",
  Routes.jp_article_url(@endpoint, article.id)}]`

  ## Google-specific metadata

  - google
    - `nositelinkssearch`. When users search for your site, Google Search results sometimes display a search box
    specific to your site, along with other direct links to your site. This tag tells Google not to show the sitelinks
    search box. [Learn more about sitelinks search
    box.](https://developers.google.com/search/docs/appearance/structured-data/sitelinks-searchbox)
    - `nopagereadaloud` - Prevents various [Google text-to-speech
    services](https://developers.google.com/search/docs/crawling-indexing/read-aloud-user-agent) from reading aloud web pages using text-to-speech (TTS). Prevents various

  - googlebot - `notranslate` - when Google recognizes that the contents of a page aren't in the language that the user likely wants to
  read, Google may provide a translated title link and snippet in search results. If the user clicks the translated
  title link, all further user interaction with the page is through Google Translate, which will automatically translate
  any links followed. In general, this gives you the chance to provide your unique and compelling content to a much
  larger group of users. However, there may be situations where this is not desired. This meta tag tells Google that you
  don't want Google to provide a translation for this page.

  - google_site_verification - You can use this tag on the top-level page of your site to verify ownership for Search
  Console. Please note that while the values of the name and content attributes must match exactly what is provided to
  you (including upper and lower case), it doesn't matter if you change the tag from XHTML to HTML or if the format of
  the tag matches the format of your page.

  ## Crawler instructions

  - robots
    - https://www.bing.com/webmasters/help/which-robots-metatags-does-bing-support-5198d240
    - https://developers.google.com/search/docs/crawling-indexing/special-tags
    - `noindex` do not index the page
    - `nofollow` do not follow outlines from the page.
    - `noarchive` or `nocache` do not store a cached page
    - `noodp` do not use a description from Open Directory Project [http://dmoz.org]
    - `nosnippet` do not show a description nor a preview thumbnail for the page
    - `max-snippet:[number]` max text length in characters to show in search results.
      - `0` no text snippet
      - `-1` no limit
    - `max-image-preview:[value]` Max size of an image preview.
      - `none` do not show an image preview
      - `standard` show a standard size image
      - `large` show a large size image
      - any other value will mean there is no image size limit
    - `max-video-preview:[number]` Max number of seconds of a video preview.
      - `0` show a static image instead
      - `-1` allow any preview length
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
    alternate_languages: [],
    suffix_with_default_title: false,
    prefix_with_default_title: false
  ]

  @type t :: %__MODULE__{
          default_title: String.t() | nil,
          title: String.t() | nil,
          title_prefix: String.t() | nil,
          title_suffix: String.t() | nil,
          suffix_with_default_title: boolean(),
          prefix_with_default_title: boolean(),
          canonical_url: URI.t() | String.t() | nil,
          rating: String.t() | nil,
          robots: String.t() | list(String.t()) | nil,
          googlebot: String.t() | nil,
          alternate_languages: list({String.t(), String.t() | URI.t()}),
          google: String.t() | list(String.t()) | nil,
          description: String.t() | nil
        }

  @config Application.compile_env(:seo, SEO.Site, [])
  def config, do: @config

  def build(map) when is_map(map) do
    struct(%__MODULE__{}, Map.merge(Enum.into(@config, %{}), map))
  end

  def build(keyword) when is_list(keyword) do
    struct(%__MODULE__{}, Keyword.merge(@config, keyword))
  end

  attr(:site, :any, required: true)
  attr(:canonical_url, :string)

  def head(assigns) do
    assigns = assigns |> maybe_clear_prefix(assigns[:site]) |> maybe_clear_suffix(assigns[:site])

    ~H"""
    <.live_title prefix={@site.title_prefix} suffix={@site.title_suffix}>
      <%= assigns[:page_title] || @site.title || @site.default_title %>
    </.live_title>
    <%= if @site.canonical_url do %>
    <link rel="canonical" href={@site.canonical_url} />
    <% end %>
    <%= for {lang, url} <- @site.alternate_languages do %>
    <link rel="alternate" hreflag={lang} href={url} />
    <% end %>
    <%= if @site.description do %>
    <meta name="description" content={@site.description} />
    <% end %>
    <%= if @site.rating do %>
    <meta name="rating" content={@site.rating} />
    <% end %>
    <%= if @site.robots && !Enum.empty?(List.wrap(@site.robots))do %>
    <meta name="robots" content={Enum.join(List.wrap(@site.robots), ", ")} />
    <% end %>
    <%= if @site.google && !Enum.empty?(List.wrap(@site.google))do %>
    <meta name="google" content={Enum.join(List.wrap(@site.google), ", ")} />
    <% end %>
    <%= if @site.googlebot do %>
    <meta name="googlebot" content={@site.googlebot} />
    <% end %>
    <%= if @site.google_site_verification do %>
    <meta name="google-site-verification" content={@site.google_site_verification} />
    <% end %>
    """
  end

  def maybe_clear_suffix(assigns, %{title: nil, suffix_with_default_title: false} = site) do
    assign(assigns, :site, %{site | title_suffix: nil})
  end

  def maybe_clear_suffix(assigns, _site), do: assigns

  def maybe_clear_prefix(assigns, %{title: nil, prefix_with_default_title: false} = site) do
    assign(assigns, :site, %{site | title_prefix: nil})
  end

  def maybe_clear_prefix(assigns, _site), do: assigns
end
