defmodule SEO.Unfurl do
  @moduledoc """
  Other platforms seem to have adopted an older deprecated Twitter Product Card specification that allowed for two
  arbitrary data points. For example, some blogs may include a reading time. Another example, if selling a product you
  may display a variation (eg, color is black) and also display the price (eg, price is $20).

  This module should be used alongside the SEO.OpenGraph module for completeness.

  https://api.slack.com/reference/messaging/link-unfurling
  """

  defstruct [
    :label1,
    :data1,
    :label2,
    :data2
  ]

  @type t :: %__MODULE__{
          label1: nil | String.t(),
          data1: nil | String.t(),
          label2: nil | String.t(),
          data2: nil | String.t()
        }

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end

  use Phoenix.Component

  attr(:unfurl, :any, required: true)

  def meta(assigns) do
    ~H"""
    <%= if @unfurl.data1 && @unfurl.label1 do %>
    <meta name="twitter:label1" content={@unfurl.label1} />
    <meta name="twitter:data1" content={@unfurl.data1} />
    <% end %>
    <%= if @unfurl.data2 && @unfurl.label2 do %>
    <meta name="twitter:label2" content={@unfurl.label2} />
    <meta name="twitter:data2" content={@unfurl.data2} />
    <% end %>
    """
  end
end
