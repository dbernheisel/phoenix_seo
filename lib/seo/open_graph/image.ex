defmodule SEO.OpenGraph.Image do
  @moduledoc """
  URL or details for the image. The `og:image` property has some optional structured properties:

  - `:url` - Identical to `og:image`.
  - `:secure_url` - An alternate url to use if the webpage requires HTTPS.
  - `:type` - A MIME type for this image.
  - `:width` - The number of pixels wide.
  - `:height` - The number of pixels high.
  - `:alt` - A description of what is in the image (not a caption). If the page specifies an image it should
  also specify `:alt`.

  **NOTE**: to update an image after it's been published, use a new URL for the new image. Images are typically cached
  based on the URL and won't be updated unless the URL changes. In Phoenix, the URL is typically using a hashed
  version of the image (see `mix phx.digest`), so this should be handled automatically.

  Best practices:
  - Use images that are at least 1080 pixels in width for best display on high resolution devices. At the minimum, you should use images that are 600 pixels in width to display image link ads. We recommend using 1:1 images in your ad creatives for better performance with image link ads.
  - Pre-cache your images by running the URL through the URL Sharing Debugger tool to pre-fetch metadata for the website. You should also do this if you update the image for a piece of content.
  - Use `:width` and `:height` to specify the image dimensions to the crawler so that it can render the image immediately without having to asynchronously download and process it.

  Resources
  - https://ogp.me/#structured
  - https://developers.facebook.com/docs/sharing/best-practices#images
  """

  use Phoenix.Component
  alias SEO.Utils

  defstruct [
    :url,
    :secure_url,
    :type,
    :width,
    :height,
    :alt
  ]

  @type t :: %__MODULE__{
          url: URI.t() | String.t(),
          secure_url: URI.t() | String.t(),
          type: mime(),
          width: pixels(),
          height: pixels(),
          alt: String.t()
        }

  @type mime :: String.t()
  @type pixels :: pos_integer()

  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    __MODULE__
    |> Utils.merge_defaults(attrs, default)
    |> maybe_put_secure_url()
  end

  defp maybe_put_secure_url(image) do
    case image.url do
      %URI{scheme: "https"} = uri -> %{image | secure_url: uri}
      "https" <> _ = url -> %{image | secure_url: url}
      _ -> image
    end
  end

  attr(:content, :any, default: nil, doc: "Either an `SEO.OpenGraph.Image`, a string, or a URI")

  def meta(assigns) do
    case assigns[:content] do
      nil ->
        ~H""

      %__MODULE__{} ->
        ~H"""
        <%= if @content.url || @content.secure_url do %>
        <%= if @content.url do %>
        <Utils.url property="og:image" content={@content.url} />
        <% end %><%= if @content.secure_url do %>
        <Utils.url property="og:image:secure_url" content={@content.secure_url} />
        <% end %><%= if @content.type do %>
        <meta property="og:image:type" content={@content.type} />
        <% end %><%= if @content.width do %>
        <meta property="og:image:width" content={@content.width} />
        <% end %><%= if @content.height do %>
        <meta property="og:image:height" content={@content.height} />
        <% end %><%= if @content.alt do %>
        <meta property="og:image:alt" content={@content.alt} />
        <% end %>
        <% end %>
        """

      _url ->
        ~H"""
        <Utils.url property="og:image" content={@content} />
        """
    end
  end
end
