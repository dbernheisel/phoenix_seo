defmodule SEO.OpenGraph.Audio do
  @moduledoc """
  Data describing an audio file.
  """

  use Phoenix.Component
  alias SEO.Utils

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

  @spec build(SEO.attrs(), SEO.config()) :: t() | nil
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    __MODULE__
    |> Utils.merge_defaults(attrs, default)
    |> maybe_put_secure_url()
  end

  defp maybe_put_secure_url(audio) do
    case audio.url do
      %URI{scheme: "https"} = uri -> %{audio | secure_url: uri}
      "https" <> _ = url -> %{audio | secure_url: url}
      _ -> audio
    end
  end

  attr(:content, :any, default: nil)

  def meta(assigns) do
    case assigns[:content] do
      nil ->
        ~H""

      %__MODULE__{} ->
        ~H"""
        <%= if @content.url do %>
        <Utils.url property="og:audio" content={@content.url} /><%= if @content.secure_url do %>
        <Utils.url property="og:audio:secure_url" content={@content.secure_url} />
        <% end %><%= if @content.type do %>
        <meta property="og:audio:type" content={@content.type} />
        <% end %>
        <% end %>
        """

      _url ->
        ~H"""
        <Utils.url property="og:audio" content={@content} />
        """
    end
  end
end
