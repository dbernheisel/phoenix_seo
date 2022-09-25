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
    :label1,
    :data1,
    :label2,
    :data2,
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
          app_country: nil | String.t(),
          label1: nil | String.t(),
          data1: nil | String.t(),
          label2: nil | String.t(),
          data2: nil | String.t()
        }

  @typedoc "@username for the website used in the card footer"
  @type site :: String.t()

  @typedoc "@username for the content creator / author"
  @type creator :: String.t()
  @type pixels :: pos_integer()

  @config Application.compile_env(:seo, SEO.Twitter, [])
  def config, do: @config

  def build(map) when is_map(map) do
    struct(__MODULE__, Map.merge(Enum.into(@config, %{}), map))
  end

  def build(keyword) when is_list(keyword) do
    struct(__MODULE__, Keyword.merge(@config, keyword))
  end

  use Phoenix.Component

  attr(:twitter, :any, required: true)

  def meta(assigns) do
    ~H"""
    <meta name="twitter:card" content={@twitter.card} />
    <%= if @twitter.title do %>
    <meta name="twitter:title" content={@twitter.title} />
    <% end %>
    <%= if @twitter.description do %>
    <meta name="twitter:description" content={@twitter.description} />
    <% end %>
    <%= if @twitter.site do %>
    <meta name="twitter:site" content={@twitter.site} />
    <% end %>
    <%= if @twitter.site_id do %>
    <meta name="twitter:site_id" content={@twitter.site_id} />
    <% end %>
    <%= if @twitter.creator do %>
    <meta name="twitter:creator" content={@twitter.creator} />
    <% end %>
    <%= if @twitter.creator_id do %>
    <meta name="twitter:creator_id" content={@twitter.creator_id} />
    <% end %>
    <%= if @twitter.image do %>
    <meta name="twitter:image" content={"#{@twitter.image}"} />
    <% end %>
    <%= if @twitter.image_alt do %>
    <meta name="twitter:image:alt" content={@twitter.image_alt} />
    <% end %>
    <%= if @twitter.player do %>
    <meta name="twitter:player" content={"#{@twitter.player}"} />
    <%= if @twitter.player_width do %>
    <meta name="twitter:player:width" content={@twitter.width} />
    <% end %>
    <%= if @twitter.player_height do %>
    <meta name="twitter:player:height" content={@twitter.height} />
    <% end %>
    <% end %>
    <%= if @twitter.player_stream do %>
    <meta name="twitter:player:stream" content={"#{@twitter.player_stream}"} />
    <% end %>
    <%= if @twitter.app_name_iphone do %>
    <meta name="twitter:app:name:iphone" content={@twitter.app_name_iphone} />
    <% end %>
    <%= if @twitter.app_id_iphone do %>
    <meta name="twitter:app:id:iphone" content={@twitter.app_id_iphone} />
    <% end %>
    <%= if @twitter.app_url_iphone do %>
    <meta name="twitter:app:url:iphone" content={"#{@twitter.app_url_iphone}"} />
    <% end %>
    <%= if @twitter.app_name_ipad do %>
    <meta name="twitter:app:name:ipad" content={@twitter.app_name_ipad} />
    <% end %>
    <%= if @twitter.app_id_ipad do %>
    <meta name="twitter:app:id:ipad" content={@twitter.app_id_ipad} />
    <% end %>
    <%= if @twitter.app_url_ipad do %>
    <meta name="twitter:app:url:ipad" content={"#{@twitter.app_url_ipad}"} />
    <% end %>
    <%= if @twitter.app_name_googleplay do %>
    <meta name="twitter:app:name:googleplay" content={@twitter.app_name_googleplay} />
    <% end %>
    <%= if @twitter.app_id_googleplay do %>
    <meta name="twitter:app:id:googleplay" content={@twitter.app_id_googleplay} />
    <% end %>
    <%= if @twitter.app_url_googleplay do %>
    <meta name="twitter:app:url:googleplay" content={"#{@twitter.app_url_googleplay}"} />
    <% end %>
    <%= if @twitter.app_country do %>
    <meta name="twitter:app:country" content={@twitter.app_country} />
    <% end %>
    """
  end
end
