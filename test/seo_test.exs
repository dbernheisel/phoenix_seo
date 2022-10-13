defmodule SEOTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  doctest SEO

  describe "juice" do
    test "renders everything" do
      item = %MyApp.Article{title: "Title"}
      result = render_component(&SEO.juice/1, config: MyAppWeb.SEO.config(), item: item)

      assert result =~ ~s|<title data-suffix="Suf">TitleSuf</title>|
      assert result =~ ~s|<meta property="og:locale" content="en_US">|
    end
  end

  describe "item" do
    test "gets the item from a Plug.Conn" do
      item = %{foo: :bar}
      conn = %Plug.Conn{} |> SEO.assign(item)

      assert ^item = SEO.item(conn)
    end

    test "gets the item from a LiveView Socket" do
      item = %{foo: :bar}
      socket = %Phoenix.LiveView.Socket{} |> SEO.assign(item)

      assert ^item = SEO.item(socket)
    end
  end

  describe "assign" do
    test "assigns for a Plug.Conn" do
      item = %{foo: :bar}
      conn = %Plug.Conn{} |> SEO.assign(item)

      assert %{private: %{seo: ^item}} = conn
    end

    test "assigns for a LiveView Socket" do
      item = %{foo: :bar}
      socket = %Phoenix.LiveView.Socket{} |> SEO.assign(item)

      assert %{assigns: %{seo: ^item}} = socket
    end
  end
end
