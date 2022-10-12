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

  def build(attrs, default \\ nil)

  def build(attrs, default) when is_list(attrs) do
    struct(%__MODULE__{}, Keyword.merge(default || [], attrs))
  end

  def build(attrs, default) when is_map(attrs) do
    struct(%__MODULE__{}, Map.merge(default || %{}, attrs))
  end

  use Phoenix.Component

  attr(:item, :any, required: true)

  def meta(assigns) do
    ~H"""
    <%= if @item.data1 && @item.label1 do %>
    <meta name="twitter:label1" content={@item.label1} />
    <meta name="twitter:data1" content={@item.data1} />
    <% end %><%= if @item.data2 && @item.label2 do %>
    <meta name="twitter:label2" content={@item.label2} />
    <meta name="twitter:data2" content={@item.data2} />
    <% end %>
    """
  end
end
