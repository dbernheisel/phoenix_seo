defmodule SEOTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest

  defmodule TestConfig do
    def config do
      [json_library: Jason, site: [description: "TestConfig Description"]]
    end

    def config(domain) do
      config()[domain] || []
    end
  end

  describe "juice" do
    test "renders item from conn when item not provided directly" do
      item = [title: "foo"]
      conn = Plug.Conn.put_private(%Plug.Conn{}, SEO.key(), item)
      result = render_component(&SEO.juice/1, conn: conn)

      assert result =~ ~s|<title>foo</title>|
    end

    test "renders everything from item" do
      item = %MyApp.Article{title: "Title", description: "Description"}
      result = render_component(&SEO.juice/1, build_assigns(item, json_library: Jason))

      # assert an attribute for each domain
      # site
      assert result =~ ~s|<meta name="description" content="Description">|
      # opengraph
      assert result =~ ~s|<meta property="og:type" content="article">|
      # twitter
      assert result =~ ~s|<meta name="twitter:card" content="summary">|
      # unfurl
      assert result =~ ~s|<meta name="twitter:label2" content="Reading Time">|
      # facebook
      assert result =~ ~s|<meta name="fb:app_id" content="123">|
      # breadcrumb
      assert result =~
               ~s|{"@type":"ListItem","item":"https://example.com/articles","name":"Articles","position":1}|

      assert result =~
               ~s|{"@type":"ListItem","item":"https://example.com/articles/my_id","name":"Title","position":2}|
    end

    test "renders almost nothing when struct not implemented" do
      item = %MyApp.NotImplemented{id: "No"}
      result = render_component(&SEO.juice/1, build_assigns(item))

      # assert an attribute for each domain
      # site
      assert result =~ ~s|<title></title>|
      # opengraph default
      assert result =~ ~s|<meta property="og:type" content="website">|
    end

    test "renders from map" do
      item = %{title: "Title"}
      result = render_component(&SEO.juice/1, build_assigns(item))

      assert result =~ ~s|<title>Title</title>|
    end

    test "renders from list" do
      item = [title: "Title"]
      result = render_component(&SEO.juice/1, build_assigns(item))

      assert result =~ ~s|<title>Title</title>|
    end

    test "renders with a function config" do
      config = [
        site: fn _conn ->
          [description: "functional programming is fun"]
        end
      ]

      item = [title: "Title"]
      result = render_component(&SEO.juice/1, build_assigns(item, config))

      assert result =~ ~s|<meta name="description" content="functional programming is fun">|
    end

    test "renders with a module config" do
      item = [title: "Title"]
      result = render_component(&SEO.juice/1, build_assigns(item, SEOTest.TestConfig))

      assert result =~ ~s|<meta name="description" content="TestConfig Description">|
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

  defp build_assigns(item, config \\ []) do
    [conn: %Plug.Conn{}, item: item, config: config]
  end
end
