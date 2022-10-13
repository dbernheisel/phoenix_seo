defmodule SEO.Unfurl do
  @moduledoc """
  Some platforms (eg, Slack and Discord) have adopted an older and deprecated Twitter Product Card specification that
  allows for two arbitrary data points. For example, some blogs may include a reading time. Another example, if selling a product you may display a variation (eg, color is black) and also display the price (eg, price is $20).

  This module should be used alongside the `SEO.OpenGraph` module for completeness.

  For example, in the screenshot below, `:label1` is `"Reading Time"` and `:data1` is `"15 minutes"`, and `:label2` is
  `"Published"` and `:data2` is `"2020-01-19"`.

  ![Unfurl example](./assets/unfurl-example.png)

  Resources
  - https://api.slack.com/reference/messaging/link-unfurling#classic_unfurl
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

  @doc """
  Arbitrary data points about your object. label1 and data1 both should be provided in order to render. Same with label2/data2.

  For example, label1 could be `"price"` and data1 could be `"$10"`.

  - `:label1` - Label describing data1
  - `:data1` - 1st data point
  - `:label2` - Label describing data2
  - `:data2` - 2nd data point

  """

  def build(attrs, default \\ nil)

  def build(attrs, default) do
    SEO.Utils.merge_defaults(__MODULE__, attrs, default)
  end

  use Phoenix.Component

  attr(:item, __MODULE__, required: true)
  attr(:config, :any, default: nil)

  def meta(assigns) do
    assigns = assign(assigns, :item, build(assigns[:item], assigns[:config]))

    ~H"""
    <%= if @item do %>
    <%= if @item.data1 && @item.label1 do %>
    <meta name="twitter:label1" content={@item.label1} />
    <meta name="twitter:data1" content={@item.data1} />
    <% end %><%= if @item.data2 && @item.label2 do %>
    <meta name="twitter:label2" content={@item.label2} />
    <meta name="twitter:data2" content={@item.data2} />
    <% end %>
    <% end %>
    """
  end
end
