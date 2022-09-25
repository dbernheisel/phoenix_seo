defmodule SEO.OpenGraph.Audio do
  @moduledoc """

  Some properties can have extra metadata attached to them. These are specified in the same way as other metadata with
  property and content, but the property will have extra :.

  The `og:audio` tag only has the first 3 properties available (since size doesn't make sense for sound):

      <meta property="og:audio" content="https://example.com/sound.mp3" />
      <meta property="og:audio:secure_url" content="https://secure.example.com/sound.mp3" />
      <meta property="og:audio:type" content="audio/mpeg" />
  """

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

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
