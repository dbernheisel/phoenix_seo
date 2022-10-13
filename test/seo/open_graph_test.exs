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

    test "renders video URL" do
    end

    test "renders video details" do
    end
  end

  # defp build_assigns(item), do: [item: SEO.Build.open_graph(item)]
  defp build_assigns(item, default), do: [config: default, item: OpenGraph.Build.build(item)]
end
