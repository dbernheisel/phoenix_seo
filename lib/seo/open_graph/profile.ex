defmodule SEO.OpenGraph.Profile do
  @moduledoc """

  ### Resources
  - https://ogp.me/#type_profile

  """

  use Phoenix.Component

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

  @doc """
  Build a OpenGraph Profile

  - `:first_name` - A name normally given to an individual by a parent or self-chosen.
  - `:last_name` - A name inherited from a family or marriage and by which the individual is commonly known.
  - `:username` - A short unique string to identify them.
  - `:gender` - Their gender.
  """
  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  attr(:content, :any, required: true)
  attr(:property, :string, default: "profile")

  def meta(assigns) do
    case assigns[:content] do
      %__MODULE__{} ->
        ~H"""
        <meta :if={@content.first_name} property={"#{@property}:first_name"} content={@content.first_name} />
        <meta :if={@content.last_name} property={"#{@property}:last_name"} content={@content.last_name} />
        <meta :if={@content.username} property={"#{@property}:username"} content={@content.username} />
        <meta :if={@content.gender} property={"#{@property}:gender"} content={@content.gender} />
        """

      _url ->
        ~H"""
        <SEO.Utils.url :if={@content} property={@property} content={@content} />
        """
    end
  end
end
