defmodule SEO.TwitterTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias SEO.Twitter

  @valid_card_values [:summary, :summary_large_image, :app, :player]

  describe "card" do
    test "not rendered if no value is set by config and attrs" do
      result = render_component(&Twitter.meta/1, [])

      assert not String.contains?(result, ~s|<meta name="twitter:card"|)
    end

    test "default is rendered if card is not provided by attrs" do
      for card <- @valid_card_values do
        default = build_item(card: card)
        assigns = [config: default]

        result = render_component(&Twitter.meta/1, assigns)

        assert String.contains?(result, ~s|<meta name="twitter:card" content="#{card}">|)
      end
    end

    test "default is rendered if card in attrs is unspecified" do
      for card <- @valid_card_values do
        default = build_item(card: card)
        item = build_item(%{})

        assigns = [config: default, item: item]

        result = render_component(&Twitter.meta/1, assigns)

        assert String.contains?(result, ~s|<meta name="twitter:card" content="#{card}">|)
      end
    end

    test "attrs value is rendered" do
      default = build_item(card: :summary_large_image)

      for card <- @valid_card_values do
        item = build_item(%{card: card})

        assigns = [config: default, item: item]

        result = render_component(&Twitter.meta/1, assigns)

        assert String.contains?(result, ~s|<meta name="twitter:card" content="#{card}">|)
      end
    end
  end

  defp build_item(item), do: Twitter.Build.build(item, %Plug.Conn{})
end
