defmodule SEO.TwitterTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  alias SEO.Twitter

  @valid_card_values [:summary, :summary_large_image, :app, :player]

  describe "card" do
    test "not rendered if no value is set by config and attrs" do
      item = %{}
      default = %{}

      result = render_component(&Twitter.meta/1, build_assigns(item, default))

      assert not String.contains?(result, ~s(<meta name="twitter:card"))
    end

    test "default is rendered if card is not provided in attrs" do
      for card <- @valid_card_values do
        item = %{}
        default = Twitter.build(card: card)

        result = render_component(&Twitter.meta/1, build_assigns(item, default))

        assert String.contains?(result, ~s(<meta name="twitter:card" content="#{card}">))
      end
    end

    test "default is rendered if card in attrs is invalid" do
      item = %{card: :invalid}

      for card <- @valid_card_values do
        default = Twitter.build(card: card)

        result = render_component(&Twitter.meta/1, build_assigns(item, default))

        assert String.contains?(result, ~s(<meta name="twitter:card" content="#{card}">))
      end
    end

    test "not rendered if card in attrs is invalid" do
      item = %{card: :invalid}
      default = %{}

      result = render_component(&Twitter.meta/1, build_assigns(item, default))

      assert not String.contains?(result, ~s(<meta name="twitter:card"))
    end

    test "attrs is rendered if valid" do
      default = Twitter.build(card: :summary_large_image)

      for card <- @valid_card_values do
        item = %{card: card}

        result = render_component(&Twitter.meta/1, build_assigns(item, default))

        assert String.contains?(result, ~s(<meta name="twitter:card" content="#{card}">))
      end
    end
  end

  defp build_assigns(item, default),
    do: [item: Twitter.Build.build(item, %Plug.Conn{}), config: default]
end
