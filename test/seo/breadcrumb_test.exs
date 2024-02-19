defmodule SEO.BreadcrumbTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  import SEO.Test.Helpers
  alias SEO.Breadcrumb

  describe "meta" do
    test "renders" do
      config = %{}

      items = [
        %{name: "Posts", item: "https://example.com"},
        %{name: "My Post", item: "https://example.com/page/1"}
      ]

      result = render_component(&Breadcrumb.meta/1, build_assigns(items, config))
      {:ok, html} = Floki.parse_fragment(result)

      ld = linking_data(html)
      assert ld["@type"] == "BreadcrumbList"

      assert ld["itemListElement"] == [
               %{
                 "@type" => "ListItem",
                 "item" => "https://example.com",
                 "name" => "Posts",
                 "position" => 1
               },
               %{
                 "@type" => "ListItem",
                 "item" => "https://example.com/page/1",
                 "name" => "My Post",
                 "position" => 2
               }
             ]
    end

    test "doesn't render when list is empty or nil" do
      config = %{}

      item = []
      result = render_component(&Breadcrumb.meta/1, build_assigns(item, config))
      assert result == ""

      item = nil
      result = render_component(&Breadcrumb.meta/1, build_assigns(item, config))
      assert result == ""

      item = %{}
      result = render_component(&Breadcrumb.meta/1, build_assigns(item, config))
      assert result == ""

      item = [%{}, %{}]
      result = render_component(&Breadcrumb.meta/1, build_assigns(item, config))
      assert result == ""

      item = [[], []]
      result = render_component(&Breadcrumb.meta/1, build_assigns(item, config))
      assert result == ""
    end
  end

  defp build_assigns(item, config) do
    [item: item, config: config, json_library: Jason]
  end
end
