defmodule SEO.OpenGraphTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  alias SEO.OpenGraph

  describe "meta" do
    test "renders article" do
      long_string = String.duplicate("A", 300)
      default = MyAppWeb.SEO.config(:open_graph)
      item = %MyApp.Article{author: "Foo Fighters", description: long_string, title: "MyTitle"}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      # truncated to 200
      assert result =~
               ~s|<meta property="og:description" content="#{long_string |> String.slice(0..199)}">|

      assert result =~ ~s|<meta property="og:title" content="MyTitle">|
      assert result =~ ~s|<meta property="og:type" content="article">|
      assert result =~ ~s|<meta property="og:site_name" content="David Bernheisel&#39;s Blog">|
      assert result =~ ~s|<meta property="og:locale" content="en_US">|
      assert result =~ ~s|<meta property="article:author" content="Foo Fighters">|
      assert result =~ ~s|<meta property="article:published_time" content="2022-10-13">|
      assert result =~ ~s|<meta property="article:section" content="Tech">|
    end

    test "renders book" do
      item = %MyApp.Book{
        author: ["https://example.com/bluey", URI.parse("https://example.com/bingo")],
        release_date: ~D[2022-01-01],
        isbn: "9781234567890"
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item))

      assert result =~ ~s|<meta property="og:type" content="book">|
      assert result =~ ~s|<meta property="book:release_date" content="2022-01-01">|
      assert result =~ ~s|<meta property="book:isbn" content="9781234567890">|
      assert result =~ ~s|<meta property="book:author" content="https://example.com/bluey">|
      assert result =~ ~s|<meta property="book:author" content="https://example.com/bingo">|
      assert result =~ ~s|<meta property="book:tag" content="comedy">|
      assert result =~ ~s|<meta property="book:tag" content="children">|
    end

    test "renders profile" do
      item = %MyApp.Profile{
        first_name: "Bluey",
        last_name: "Heeler",
        gender: "Female"
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item))

      assert result =~ ~s|<meta property="og:type" content="profile">|
      assert result =~ ~s|<meta property="profile:first_name" content="Bluey">|
      assert result =~ ~s|<meta property="profile:last_name" content="Heeler">|
      assert result =~ ~s|<meta property="profile:gender" content="Female">|
    end

    test "renders video URL" do
      default = %{video: "https://example.com/video.mp4"}
      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:video" content="https://example.com/video.mp4">|

      default = %{video: URI.parse("https://example.com/video.mp4")}
      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:video" content="https://example.com/video.mp4">|
    end

    test "populates video secure url if url is https" do
      item = %MyApp.Article{}

      default = %{
        video:
          OpenGraph.Video.build(
            type: "video/mpeg",
            url: "https://example.com/video.mp4"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:video" content="https://example.com/video.mp4">|

      assert result =~
               ~s|<meta property="og:video:secure_url" content="https://example.com/video.mp4">|

      default = %{
        video:
          OpenGraph.Video.build(
            type: "video/mpeg",
            url: URI.parse("https://example.com/video.mp4")
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:video" content="https://example.com/video.mp4">|

      assert result =~
               ~s|<meta property="og:video:secure_url" content="https://example.com/video.mp4">|
    end

    test "renders video details" do
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

      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:video" content="https://example.com/video.mp4">|
      assert result =~ ~s|<meta property="og:video:type" content="video/mpeg">|
      assert result =~ ~s|<meta property="og:video:width" content="2">|
      assert result =~ ~s|<meta property="og:video:height" content="3">|
      assert result =~ ~s|<meta property="og:video:alt" content="A piece of bread falling over">|
      assert result =~ ~s|<meta property="ya:ovs:bitrate" content="600">|
      assert result =~ ~s|<meta property="ya:ovs:allow_embed" content="true">|
      assert result =~ ~s|<meta property="ya:ovs:quality" content="HD">|
    end

    test "renders audio URL" do
      default = %{audio: "https://example.com/audio.mp3"}
      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:audio" content="https://example.com/audio.mp3">|

      default = %{audio: URI.parse("https://example.com/audio.mp3")}
      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:audio" content="https://example.com/audio.mp3">|
    end

    test "renders audio details" do
      default = %{
        audio:
          OpenGraph.Audio.build(
            type: "audio/mpeg",
            url: "https://example.com/audio.mp3"
          )
      }

      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:audio" content="https://example.com/audio.mp3">|
      assert result =~ ~s|<meta property="og:audio:type" content="audio/mpeg">|
    end

    test "populates audio secure url if url is https" do
      item = %MyApp.Article{}

      default = %{
        audio:
          OpenGraph.Audio.build(
            type: "audio/mpeg",
            url: "https://example.com/audio.mp3"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:audio" content="https://example.com/audio.mp3">|

      assert result =~
               ~s|<meta property="og:audio:secure_url" content="https://example.com/audio.mp3">|

      default = %{
        audio:
          OpenGraph.Audio.build(
            type: "audio/mp3",
            url: URI.parse("https://example.com/audio.mp3")
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:audio" content="https://example.com/audio.mp3">|

      assert result =~
               ~s|<meta property="og:audio:secure_url" content="https://example.com/audio.mp3">|
    end

    test "renders image URL" do
      default = %{image: "https://example.com/image.png"}
      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:image" content="https://example.com/image.png">|

      default = %{image: URI.parse("https://example.com/image.png")}
      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:image" content="https://example.com/image.png">|
    end

    test "populates image secure url if url is https" do
      item = %MyApp.Article{}

      default = %{
        image:
          OpenGraph.Image.build(
            type: "video/mpeg",
            url: "https://example.com/image.png"
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:image" content="https://example.com/image.png">|

      assert result =~
               ~s|<meta property="og:image:secure_url" content="https://example.com/image.png">|

      default = %{
        image:
          OpenGraph.Image.build(
            type: "video/mpeg",
            url: URI.parse("https://example.com/image.png")
          )
      }

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:image" content="https://example.com/image.png">|

      assert result =~
               ~s|<meta property="og:image:secure_url" content="https://example.com/image.png">|
    end

    test "renders image details" do
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

      item = %MyApp.Article{}

      result = render_component(&OpenGraph.meta/1, build_assigns(item, default))

      assert result =~ ~s|<meta property="og:image" content="https://example.com/image.png">|
      assert result =~ ~s|<meta property="og:image:type" content="image/png">|
      assert result =~ ~s|<meta property="og:image:width" content="2">|
      assert result =~ ~s|<meta property="og:image:height" content="3">|
      assert result =~ ~s|<meta property="og:image:alt" content="A piece of bread fallen over">|
    end
  end

  defp build_assigns(item), do: [item: OpenGraph.Build.build(item)]
  defp build_assigns(item, default), do: [config: default, item: OpenGraph.Build.build(item)]
end
