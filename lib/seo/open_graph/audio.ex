defmodule SEO.OpenGraph.Audio do
  @moduledoc """
  Data describing an audio file.
  """

  use Phoenix.Component

  defstruct [
    :url,
    :secure_url,
    :type
  ]

  @type t :: %__MODULE__{
          url: URI.t() | String.t(),
          secure_url: URI.t() | String.t(),
          type: mime()
        }

  @type mime :: String.t()

  @doc """
  The `og:audio` property has some optional structured properties:

  - `:url` - The url with metadata that describes the audio.
  - `:secure_url` - An alternate url to use if the webpage requires HTTPS.
  - `:type` - A MIME type for this audio, eg, `"audio/mpeg"`.
  """
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  attr(:content, :any, required: true)

  def meta(assigns) do
    case assigns[:content] do
      %__MODULE__{} ->
        ~H"""
        <%= if @content.url do %>
        <SEO.Utils.url property="og:audio" content={@content.url} />
        <SEO.Utils.url :if={@content.secure_url} property="og:audio:secure_url" content={@content.secure_url} />
        <meta :if={@content.type} property="og:audio:type" content={@content.type} />
        <% end %>
        """

      _url ->
        ~H"""
        <SEO.Utils.url property="og:audio" content={@content} />
        """
    end
  end
end
