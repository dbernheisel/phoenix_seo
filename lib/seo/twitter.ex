defmodule SEO.Twitter do
  @moduledoc """
  With Twitter Cards, you can attach rich photos, videos and media experiences to Tweets, helping to drive traffic to
  your website. Users who Tweet links to your content will have a "Card" added to the Tweet that's visible to their
  followers.

  The different Card types each have a beautiful consumption experience built for Twitter’s web and mobile clients:

  - Summary Card: Title, description, and thumbnail.
  - Summary Card with Large Image: Similar to the Summary Card, but with a prominently-featured image.
  - App Card: A Card with a direct download to a mobile app.
  - Player Card: A Card that can display video/audio/media.

  If used alongside the OpenGraph tags, the Twitter tags will win when shared on Twitter. If not provided, Twitter will
  use the OpenGraph tags. Unless you have specific messaging for Twitter followers, it's typically good enough to use
  OpenGraph for most data.

  https://developer.twitter.com/en/docs/twitter-for-websites/cards/guides/getting-started
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

  def build(attrs, default \\ nil)

  def build(attrs, default) when is_map(attrs) do
    struct(__MODULE__, Map.merge(default || %{}, attrs))
  end

  def build(attrs, default) when is_list(attrs) do
    struct(__MODULE__, Keyword.merge(default || [], attrs))
  end

  use Phoenix.Component

  attr(:item, SEO.Twitter, required: true)

  def meta(assigns) do
    ~H"""
    <meta name="twitter:card" content={@item.card} :if={@item.title || @title.description} />
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
