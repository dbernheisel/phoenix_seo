defmodule SEO.Facebook do
  @moduledoc """
  Facebook originally developed the OpenGraph standard, so much of social-sharing techniques
  are contained in `SEO.OpenGraph`, however there remains one Facebook-specific attribute: the `:app_id`.

  In order to use Facebook Insights you must add the app ID to your page. Insights lets you view analytics for traffic
  to your site from Facebook. Find the app ID in your App Dashboard.

  https://developers.facebook.com/docs/sharing/webmaster
  """

  defstruct [:app_id]

  @type t :: %__MODULE__{
          app_id: String.t()
        }

  def build(attrs) when is_map(attrs) or is_list(attrs) do
    struct(%__MODULE__{}, attrs)
  end

  use Phoenix.Component

  attr(:item, :any, required: true)

  def meta(assigns) do
    ~H"""
    <%= if @item.app_id do %>
    <meta name="fb:app_id" content={@item.app_id} />
    <% end %>
    """
  end
end
