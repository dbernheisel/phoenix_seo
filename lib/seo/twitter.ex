defmodule SEO.Twitter do
  @moduledoc """
  With Twitter Cards, you can attach rich photos, videos and media experiences to Tweets, helping to drive traffic to
  your website. Users who Tweet links to your content will have a "Card" added to the Tweet that's visible to their
  followers.

  Examples

  Summary card with large image: ![Summary card with Large Image](./assets/twitter-summary-large-example.png)

  Player card: ![Player card](./assets/twitter-player-example.png)

  ### Resources

  - https://developer.twitter.com/en/docs/twitter-for-websites/cards/guides/getting-started
  """

  defstruct [
    :site,
    :site_id,
    :creator,
    :creator_id,
    :image,
    :image_alt,
    :title,
    :description,
    :player,
    :player_width,
    :player_height,
    :player_stream,
    :app_name_iphone,
    :app_id_iphone,
    :app_url_iphone,
    :app_name_ipad,
    :app_id_ipad,
    :app_url_ipad,
    :app_name_googleplay,
    :app_id_googleplay,
    :app_url_googleplay,
    :app_country,
    card: :summary
  ]

  @type t :: %__MODULE__{
          card: :summary | :summary_large_image | :app | :player,
          site: nil | site(),
          site_id: nil | String.t(),
          creator: nil | creator(),
          creator_id: nil | String.t(),
          image: nil | URI.t() | String.t(),
          image_alt: nil | String.t(),
          title: nil | String.t(),
          description: nil | String.t(),
          player: nil | String.t(),
          player_width: nil | pixels(),
          player_height: nil | pixels(),
          player_stream: nil | URI.t() | String.t(),
          app_name_iphone: nil | String.t(),
          app_id_iphone: nil | String.t(),
          app_url_iphone: nil | URI.t() | String.t(),
          app_name_ipad: nil | String.t(),
          app_id_ipad: nil | String.t(),
          app_url_ipad: nil | URI.t() | String.t(),
          app_name_googleplay: nil | String.t(),
          app_id_googleplay: nil | String.t(),
          app_url_googleplay: nil | URI.t() | String.t(),
          app_country: nil | String.t()
        }

  @typedoc "@username for the website used in the card footer"
  @type site :: String.t()

  @typedoc "@username for the content creator / author"
  @type creator :: String.t()
  @type pixels :: pos_integer()

  @doc """
  Build tags that customize how Twitter displays your page.

  - `:card` - The different `:card` types each have a beautiful consumption experience built for Twitter’s
  web and mobile clients.
    - `:summary`: Title, description, and thumbnail.
    - `:summary_large_image`: Similar to the Summary Card, but with a prominently-featured image.
    - `:app`: A Card with a direct download to a mobile app.
    - `:player`: A Card that can display video/audio/media.
  - `:site` - The Twitter @username the card should be attributed to
  - `:title` - A concise title for the related content.
  - `:description` - A description that concisely summarizes the content as appropriate for presentation within a Tweet.
  - `:image` - A URL to a unique image representing the content of the page. You should not use a generic
  image such as your website logo, author photo, or other image that spans multiple pages. Images for this
  Card support an aspect ratio of 2:1 with minimum dimensions of 300x157 or maximum of 4096x4096 pixels.
  Images must be less than 5MB in size. JPG, PNG, WEBP and GIF formats are supported. Only the first frame
  of an animated GIF will be used. SVG is not supported.
  - `:image_alt` - A text description of the image conveying the essential nature of an image to users who
  are visually impaired. Maximum 420 characters.
  - `:player` - HTTPS URL of player iframe
  - `:player_width` - Width of iframe in pixels
  - `:player_height` - Height of iframe in pixels
  - `:player_stream` - URL to raw video or audio stream
  - `:app_name_iphone` - Name of your iPhone app
  - `:app_id_iphone` - Your app ID in the iTunes App Store
  - `:app_url_iphone` - Your app's custom URL scheme
  - `:app_name_ipad` - Name of your iPad optimized app
  - `:app_id_ipad` - Your app ID in the iTunes App Store
  - `:app_url_ipad` - Your app's custom URL scheme
  - `:app_name_googleplay` - Name of your Android app
  - `:app_id_googleplay` - Your app ID in the Google Play Store
  - `:app_url_googleplay` - Your app’s custom URL scheme
  - `:app_country` - If your application is not available in the US App Store, you must set this value to the two-letter country code for the App Store that contains your application.

  If used alongside the OpenGraph tags, the Twitter tags will win when shared on Twitter. If not provided, Twitter will
  use the OpenGraph tags. Unless you have specific messaging for Twitter followers, it's typically good enough to use
  OpenGraph for most data.
  """
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  use Phoenix.Component

  attr(:item, SEO.Twitter, required: true)

  def meta(assigns) do
    ~H"""
    <meta name="twitter:card" content={@item.card} :if={@item.title || @item.description} />
    <meta name="twitter:title" content={@item.title} :if={@item.title} />
    <meta name="twitter:description" content={@item.description} :if={@item.description} />
    <meta name="twitter:site" content={@item.site} :if={@item.site} />
    <meta name="twitter:site_id" content={@item.site_id} :if={@item.site_id} />
    <meta name="twitter:creator" content={@item.creator} :if={@item.creator} />
    <meta name="twitter:creator_id" content={@item.creator_id} :if={@item.creator_id} />
    <meta name="twitter:image" content={"#{@item.image}"} :if={@item.image} />
    <meta name="twitter:image:alt" content={@item.image_alt} :if={@item.image_alt} />
    <meta name="twitter:player" content={"#{@item.player}"} :if={@item.player} />
    <meta name="twitter:player:width" content={@item.player_width} :if={@item.player_width} />
    <meta name="twitter:player:height" content={@item.player_height} :if={@item.player_height} />
    <meta name="twitter:player:stream" content={"#{@item.player_stream}"} :if={@item.player_stream} />
    <meta name="twitter:app:name:iphone" content={@item.app_name_iphone} :if={@item.app_name_iphone} />
    <meta name="twitter:app:id:iphone" content={@item.app_id_iphone} :if={@item.app_id_iphone} />
    <meta name="twitter:app:url:iphone" content={"#{@item.app_url_iphone}"} :if={@item.app_url_iphone} />
    <meta name="twitter:app:name:ipad" content={@item.app_name_ipad} :if={@item.app_name_ipad} />
    <meta name="twitter:app:id:ipad" content={@item.app_id_ipad} :if={@item.app_id_ipad} />
    <meta name="twitter:app:url:ipad" content={"#{@item.app_url_ipad}"} :if={@item.app_url_ipad} />
    <meta name="twitter:app:name:googleplay" content={@item.app_name_googleplay} :if={@item.app_name_googleplay} />
    <meta name="twitter:app:id:googleplay" content={@item.app_id_googleplay} :if={@item.app_id_googleplay} />
    <meta name="twitter:app:url:googleplay" content={"#{@item.app_url_googleplay}"} :if={@item.app_url_googleplay} />
    <meta name="twitter:app:country" content={@item.app_country} :if={@item.app_country} />
    """
  end
end
