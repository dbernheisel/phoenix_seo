defmodule SEO.OpenGraphTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import SEO.Test.Helpers
  alias SEO.OpenGraph

  describe "meta" do
    @long_string String.duplicate("A", 300)
    test "renders article" do
      default = MyAppWeb.SEO.config(:open_graph)
      item = %MyApp.Article{author: "Foo Fighters", description: @long_string, title: "MyTitle"}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      # truncated to 200
      assert meta_content(html, "property='og:description'", String.slice(@long_string, 0..199))
      assert meta_content(html, "property='og:title'", "MyTitle")
      assert meta_content(html, "property='og:type'", "article")
      assert meta_content(html, "property='og:site_name'", "David Bernheisel's Blog")
      assert meta_content(html, "property='og:locale'", "en_US")
      assert meta_content(html, "property='article:author'", "Foo Fighters")
      assert meta_content(html, "property='article:published_time'", "2022-10-13")
      assert meta_content(html, "property='article:section'", "Tech")
    end

    test "renders book" do
      item = %MyApp.Book{
        author: ["https://example.com/bluey", URI.parse("https://example.com/bingo")],
        release_date: ~D[2022-01-01],
        isbn: "9781234567890"
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:type'", "book")
      assert meta_content(html, "property='book:release_date'", "2022-01-01")
      assert meta_content(html, "property='book:isbn'", "9781234567890")
      assert meta_content(html, "property='book:author'", "https://example.com/bluey")
      assert meta_content(html, "property='book:author'", "https://example.com/bingo")
      assert meta_content(html, "property='book:tag'", "comedy")
      assert meta_content(html, "property='book:tag'", "children")
    end

    test "renders profile" do
      item = %MyApp.Profile{
        first_name: "Bluey",
        last_name: "Heeler",
        gender: "Female"
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:type'", "profile")
      assert meta_content(html, "property='profile:first_name'", "Bluey")
      assert meta_content(html, "property='profile:last_name'", "Heeler")
      assert meta_content(html, "property='profile:gender'", "Female")
    end

    test "renders video URL string" do
      default = %{video: "https://example.com/video.mp4"}
      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:video'", "https://example.com/video.mp4")
    end

    test "renders video URI struct" do
      default = %{video: URI.parse("https://example.com/video.mp4")}
      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:video'", "https://example.com/video.mp4")
    end

    test "populates video secure url if url is https string" do
      item = %MyApp.Article{}

      default = %{
        video:
          OpenGraph.Video.build(
            type: "video/mpeg",
            url: "https://example.com/video.mp4"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:video'", "https://example.com/video.mp4")
      assert meta_content(html, "property='og:video:secure_url'", "https://example.com/video.mp4")
    end

    test "populates video secure url if url is https struct" do
      item = %MyApp.Article{}

      default = %{
        video:
          OpenGraph.Video.build(
            type: "video/mpeg",
            url: URI.parse("https://example.com/video.mp4")
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:video'", "https://example.com/video.mp4")
      assert meta_content(html, "property='og:video:secure_url'", "https://example.com/video.mp4")
    end

    test "renders video details" do
      item = %MyApp.Article{}

      default = %{
        video:
          OpenGraph.Video.build(
            type: "video/mpeg",
            width: 2,
            height: 3,
            alt: "A piece of bread falling over",
            url: "https://example.com/video.mp4",
            ya_bitrate: 600,
            ya_allow_embed: true,
            ya_quality: :hd
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:video'", "https://example.com/video.mp4")
      assert meta_content(html, "property='og:video:type'", "video/mpeg")
      assert meta_content(html, "property='og:video:width'", "2")
      assert meta_content(html, "property='og:video:height'", "3")
      assert meta_content(html, "property='og:video:alt'", "A piece of bread falling over")
      assert meta_content(html, "property='ya:ovs:bitrate'", "600")
      assert meta_content(html, "property='ya:ovs:allow_embed'", "true")
      assert meta_content(html, "property='ya:ovs:quality'", "HD")
    end

    test "renders audio URL string" do
      item = %MyApp.Article{}
      default = %{audio: "https://example.com/audio.mp3"}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:audio'", "https://example.com/audio.mp3")
    end

    test "renders audio URI struct" do
      item = %MyApp.Article{}
      default = %{audio: URI.parse("https://example.com/audio.mp3")}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:audio'", "https://example.com/audio.mp3")
    end

    test "renders audio details" do
      item = %MyApp.Article{}

      default = %{
        audio:
          OpenGraph.Audio.build(
            type: "audio/mpeg",
            url: "https://example.com/audio.mp3"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:audio'", "https://example.com/audio.mp3")
      assert meta_content(html, "property='og:audio:type'", "audio/mpeg")
    end

    test "populates audio secure url if url is https string" do
      item = %MyApp.Article{}

      default = %{
        audio:
          OpenGraph.Audio.build(
            type: "audio/mpeg",
            url: "https://example.com/audio.mp3"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:audio'", "https://example.com/audio.mp3")
      assert meta_content(html, "property='og:audio:secure_url'", "https://example.com/audio.mp3")
    end

    test "populates audio secure url if url is https struct" do
      item = %MyApp.Article{}

      default = %{
        audio:
          OpenGraph.Audio.build(
            type: "audio/mp3",
            url: URI.parse("https://example.com/audio.mp3")
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:audio'", "https://example.com/audio.mp3")
      assert meta_content(html, "property='og:audio:secure_url'", "https://example.com/audio.mp3")
    end

    test "renders image URL string" do
      item = %MyApp.Article{}
      default = %{image: "https://example.com/image.png"}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:image'", "https://example.com/image.png")
    end

    test "renders image URI struct" do
      item = %MyApp.Article{}
      default = %{image: URI.parse("https://example.com/image.png")}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:image'", "https://example.com/image.png")
    end

    test "populates image secure url if url is https string" do
      item = %MyApp.Article{}

      default = %{
        image:
          OpenGraph.Image.build(
            type: "video/mpeg",
            url: "https://example.com/image.png"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:image'", "https://example.com/image.png")
      assert meta_content(html, "property='og:image:secure_url'", "https://example.com/image.png")
    end

    test "populates image secure url if url is https struct" do
      item = %MyApp.Article{}

      default = %{
        image:
          OpenGraph.Image.build(
            type: "video/mpeg",
            url: URI.parse("https://example.com/image.png")
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:image'", "https://example.com/image.png")
      assert meta_content(html, "property='og:image:secure_url'", "https://example.com/image.png")
    end

    test "renders image details" do
      item = %MyApp.Article{}

      default = %{
        image:
          OpenGraph.Image.build(
            type: "image/png",
            width: 2,
            height: 3,
            alt: "A piece of bread fallen over",
            url: "https://example.com/image.png"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))
      {:ok, html} = Floki.parse_fragment(result)

      assert meta_content(html, "property='og:image'", "https://example.com/image.png")
      assert meta_content(html, "property='og:image:type'", "image/png")
      assert meta_content(html, "property='og:image:width'", "2")
      assert meta_content(html, "property='og:image:height'", "3")
      assert meta_content(html, "property='og:image:alt'", "A piece of bread fallen over")
    end
  end

  defp build_assigns(item), do: [item: OpenGraph.Build.build(item, %Plug.Conn{})]

  defp build_assigns(item, default),
    do: [config: default, item: OpenGraph.Build.build(item, %Plug.Conn{})]
end
