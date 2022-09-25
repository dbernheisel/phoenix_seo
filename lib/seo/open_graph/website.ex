defmodule SEO.OpenGraph.Website do
  @moduledoc """

  - website - Namespace URI: https://ogp.me/ns/website#
  """
  defstruct namespace: "https://ogp.me/ns/website#"

  @type t :: %__MODULE__{
          namespace: String.t()
        }
end
