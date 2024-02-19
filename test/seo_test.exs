defmodule SEOTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import SEO.Test.Helpers

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
      {:ok, html} = Floki.parse_fragment(result)

      assert title(html, "foo")
    end

    test "renders everything from item" do
      item = %MyApp.Article{title: "Title", description: "Description"}

      result = render_component(&SEO.juice/1, build_assigns(item, json_library: Jason))
      {:ok, html} = Floki.parse_fragment(result)

      # assert an attribute for each domain
      # site
      assert title(html, "Title")
      assert meta_content(html, "name='description'", item.description)
      # opengraph
      assert meta_content(html, "property='og:type'", "article")
      # twitter
      assert meta_content(html, "name='twitter:card'", "summary")
      # unfurl
      assert meta_content(html, "name='twitter:label2'", "Reading Time")
      # facebook
      assert meta_content(html, "name='fb:app_id'", "123")

      # breadcrumb
      ld = linking_data(html)
      assert ld["@type"] == "BreadcrumbList"

      assert ld["itemListElement"] == [
               %{
                 "@type" => "ListItem",
                 "item" => "https://example.com/articles",
                 "name" => "Articles",
                 "position" => 1
               },
               %{
                 "@type" => "ListItem",
                 "item" => "https://example.com/articles/my_id",
                 "name" => "Title",
                 "position" => 2
               }
             ]
    end

    test "renders almost nothing when struct not implemented" do
      item = %MyApp.NotImplemented{id: "No"}
      result = render_component(&SEO.juice/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)

      # assert an attribute for each domain
      # site
      assert title(html, "")
      # opengraph default
      assert meta_content(html, "property='og:type'", "website")
    end

    test "renders from map" do
      item = %{title: "Title"}
      result = render_component(&SEO.juice/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)

      assert title(html, "Title")
    end

    test "renders from list" do
      item = [title: "Title"]
      result = render_component(&SEO.juice/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)

      assert title(html, "Title")
    end

    test "renders with a function config" do
      config = [
        site: fn _conn ->
          [description: "functional programming is fun"]
        end
      ]

      item = [title: "Title"]

      result = render_component(&SEO.juice/1, build_assigns(item, config))
      {:ok, html} = Floki.parse_fragment(result)

      assert title(html, "Title")
      assert meta_content(html, "name='description'", "functional programming is fun")
    end

    test "renders with a module config" do
      item = [title: "Title"]

      result = render_component(&SEO.juice/1, build_assigns(item, SEOTest.TestConfig))
      {:ok, html} = Floki.parse_fragment(result)

      assert title(html, "Title")
      assert meta_content(html, "name='description'", "TestConfig Description")
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
