defmodule SEO.OpenGraph.Video do
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
