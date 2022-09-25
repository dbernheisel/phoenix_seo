defmodule SEO.OpenGraph.Image do
  @moduledoc """
  https://ogp.me/#structured

  The og:image property has some optional structured properties:

  - og:image:url - Identical to og:image.
  - og:image:secure_url - An alternate url to use if the webpage requires HTTPS.
  - og:image:type - A MIME type for this image.
  - og:image:width - The number of pixels wide.
  - og:image:height - The number of pixels high.
  - og:image:alt - A description of what is in the image (not a caption). If the page specifies an og:image it should specify og:image:alt.
  """
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

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
