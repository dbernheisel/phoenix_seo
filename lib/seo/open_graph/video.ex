defmodule SEO.OpenGraph.Video do
  @moduledoc """
  Data describing a video.

  Commonly, an `og:video` is accompanied with an `og:image` that provides the preview image for the video.

  ### Resources

  - https://ogp.me/#structured
  - https://developers.facebook.com/docs/sharing/webmasters/#video
  - https://yandex.com/support/video/partners/open-graph.html
  """

  use Phoenix.Component
  alias SEO.Utils

  defstruct [
    :url,
    :secure_url,
    :type,
    :width,
    :height,
    :ya_bitrate,
    :ya_quality,
    :ya_allow_embed,
    :alt
  ]

  @type t :: %__MODULE__{
          url: URI.t() | String.t(),
          secure_url: URI.t() | String.t() | nil,
          type: mime(),
          width: pixels(),
          height: pixels(),
          ya_bitrate: yandex_bitrate(),
          ya_quality: yandex_quality(),
          ya_allow_embed: boolean() | nil,
          alt: String.t() | nil
        }

  @type mime :: String.t() | nil
  @type pixels :: pos_integer() | nil
  @type yandex_bitrate :: pos_integer() | nil
  @type yandex_quality :: :low | :medium | :hd | :full_hd | nil

  @doc """
  The `og:video` property has some optional structured properties:

  - `:url` - The url with metadata that describes the video.
  - `:secure_url` - An alternate url to use if the webpage requires HTTPS. If the URL starts with `https` then
  - `:type` - A MIME type for this video. Facebook supports both mp4 and Flash videos, `application/x-shockwave-flash`
    or `video/mp4`, but please for the love of all that is holy don't use Shockwave Flash.
  - `:width` - The width in pixels.
  - `:height` - The height in pixels.
  - `:alt` - A description of what is in the video (not a caption). If the page specifies an `og:video` it should
    specify `og:video:alt`.

  Supply a secure URL for both the `og:video:url` and `og:video:secure_url` tags to make your video eligible to play
  in-line in Facebook's Feed.

  For Yandex, there are additional properties:

  - `:ya_bitrate` - Maximum bitrate in kilobits per second
  - `:ya_allow_embed` - Allow embedding in Yandex search results
  - `:ya_quality` - The quality in resolution and bitrate
    - `:low` - Low quality with resolution less than 360x640 and bitrate lower than 717kbps
    - `:medium` - Average quality with resolution between 360x640 and 720x1280 and bitrate between than 717kbps-1Mbps
    - `:hd` - HD quality with resolution between 720x1280 and 1080x1920 and bitrate between than 1MBps-2Mbps
    - `:full_hd` - 1080p quality with resolution greater than 1080x1920 and bitrate higher than 2Mbps
  """

  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    __MODULE__
    |> Utils.merge_defaults(attrs, default)
    |> maybe_put_secure_url()
  end

  defp maybe_put_secure_url(video) do
    case video.url do
      %URI{scheme: "https"} = uri -> %{video | secure_url: uri}
      "https" <> _ = url -> %{video | secure_url: url}
      _ -> video
    end
  end

  attr(:content, :any, default: nil)

  def meta(assigns) do
    case assigns[:content] do
      nil ->
        ~H""

      %__MODULE__{} ->
        ~H"""
        <%= if @content.url || @content.secure_url do %>
        <%= if @content.url do %>
        <Utils.url property="og:video" content={@content.url} />
        <% end %><%= if @content.secure_url do %>
        <Utils.url property="og:video:secure_url" content={@content.secure_url} />
        <% end %><%= if @content.type do %>
        <meta property="og:video:type" content={@content.type} />
        <% end %><%= if @content.width do %>
        <meta property="og:video:width" content={@content.width} />
        <% end %><%= if @content.height do %>
        <meta property="og:video:height" content={@content.height} />
        <% end %><%= if @content.alt do %>
        <meta property="og:video:alt" content={@content.alt} />
        <% end %><%= if @content.ya_bitrate do %>
        <meta property="ya:ovs:bitrate" content={@content.ya_bitrate} />
        <% end %><%= if @content.ya_quality do %>
        <meta property="ya:ovs:quality" content={format_ya_quality(@content.ya_quality)} />
        <% end %><%= if @content.ya_allow_embed do %>
        <meta property="ya:ovs:allow_embed" content={"#{@content.ya_allow_embed}"} />
        <% end %>
        <% end %>
        """

      _url ->
        ~H"""
        <Utils.url property="og:video" content={@content} />
        """
    end
  end

  defp format_ya_quality(nil), do: nil
  defp format_ya_quality(:low), do: "low"
  defp format_ya_quality(:medium), do: "medium"
  defp format_ya_quality(:hd), do: "HD"
  defp format_ya_quality(:full_hd), do: "full HD"
end
