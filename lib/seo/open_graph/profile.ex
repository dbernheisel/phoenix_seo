defmodule SEO.OpenGraph.Profile do
  @moduledoc """

  https://ogp.me/#type_profile

  - profile - Namespace URI: https://ogp.me/ns/profile#
  - profile:first_name - string - A name normally given to an individual by a parent or self-chosen.
  - profile:last_name - string - A name inherited from a family or marriage and by which the individual is commonly known.
  - profile:username - string - A short unique string to identify them.
  - profile:gender - enum(male, female) - Their gender.

  """
  defstruct [
    :first_name,
    :last_name,
    :username,
    :gender,
    namespace: "https://ogp.me/ns/profile#"
  ]

  @type t :: %__MODULE__{
          namespace: String.t(),
          first_name: String.t(),
          last_name: String.t(),
          username: String.t(),
          gender: String.t()
        }

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end
end
