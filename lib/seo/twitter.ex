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
    :card
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

  - `:card` - The different `:card` types each have a different presentation
    - `:summary` - card with title, description, and thumbnail.
    - `:summary_large_image` - similar to the `:summary` card, but with a prominently-featured image.
    - `:app` - card with a direct download to a mobile app.
    - `:player` - card that can display video/audio/media.
  - `:creator` - The Twitter @username the card should be attributed to.
  - `:creator_id` - The Twitter id of the user the card should be attributed to.
  - `:site` - The Twitter @username for the website.
  - `:site_id` - The Twitter id for the website.
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

  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  use Phoenix.Component

  attr :item, SEO.Twitter, default: nil
  attr :config, :any, default: nil

  def meta(assigns) do
    assigns = assign(assigns, :item, build(assigns[:item], assigns[:config]))

    ~H"""
    <%= if @item do %>
    <%= if @item.card do %>
    <meta name="twitter:card" content={@item.card} />
    <% end %><%= if @item.title do %>
    <meta name="twitter:title" content={@item.title} />
    <% end %><%= if @item.description do %>
    <meta name="twitter:description" content={@item.description} />
    <% end %><%= if @item.site do %>
    <meta name="twitter:site" content={@item.site} />
    <% end %><%= if @item.site_id do %>
    <meta name="twitter:site_id" content={@item.site_id} />
    <% end %><%= if @item.creator do %>
    <meta name="twitter:creator" content={@item.creator} />
    <% end %><%= if @item.creator_id do %>
    <meta name="twitter:creator_id" content={@item.creator_id} />
    <% end %><%= if @item.image do %>
    <meta name="twitter:image" content={"#{@item.image}"} />
    <% end %><%= if @item.image_alt do %>
    <meta name="twitter:image:alt" content={@item.image_alt} />
    <% end %><%= if @item.player do %>
    <meta name="twitter:player" content={"#{@item.player}"} />
    <% end %><%= if @item.player_width do %>
    <meta name="twitter:player:width" content={@item.player_width} />
    <% end %><%= if @item.player_height do %>
    <meta name="twitter:player:height" content={@item.player_height} />
    <% end %><%= if @item.player_stream do %>
    <meta name="twitter:player:stream" content={"#{@item.player_stream}"} />
    <% end %><%= if @item.app_name_iphone do %>
    <meta name="twitter:app:name:iphone" content={@item.app_name_iphone} />
    <% end %><%= if @item.app_id_iphone do %>
    <meta name="twitter:app:id:iphone" content={@item.app_id_iphone} />
    <% end %><%= if @item.app_url_iphone do %>
    <meta name="twitter:app:url:iphone" content={"#{@item.app_url_iphone}"} />
    <% end %><%= if @item.app_name_ipad do %>
    <meta name="twitter:app:name:ipad" content={@item.app_name_ipad} />
    <% end %><%= if @item.app_id_ipad do %>
    <meta name="twitter:app:id:ipad" content={@item.app_id_ipad} />
    <% end %><%= if @item.app_url_ipad do %>
    <meta name="twitter:app:url:ipad" content={"#{@item.app_url_ipad}"} />
    <% end %><%= if @item.app_name_googleplay do %>
    <meta name="twitter:app:name:googleplay" content={@item.app_name_googleplay} />
    <% end %><%= if @item.app_id_googleplay do %>
    <meta name="twitter:app:id:googleplay" content={@item.app_id_googleplay} />
    <% end %><%= if @item.app_url_googleplay do %>
    <meta name="twitter:app:url:googleplay" content={"#{@item.app_url_googleplay}"} />
    <% end %><%= if @item.app_country do %>
    <meta name="twitter:app:country" content={@item.app_country} />
    <% end %>
    <% end %>
    """
  end
end
