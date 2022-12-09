defmodule SEO.BreadcrumbTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  alias SEO.Breadcrumb

  describe "meta" do
    test "renders" do
      config = %{}

      items = [
        %{name: "Posts", item: "https://example.com"},
        %{name: "My Post", item: "https://example.com/page/1"}
      ]

      result = render_component(&Breadcrumb.meta/1, build_assigns(items, config))

      assert result ==
               "<script type=\"application/ld+json\">\n  {\"@context\":\"https://schema.org\",\"@type\":\"BreadcrumbList\",\"itemListElement\":[{\"@type\":\"ListItem\",\"item\":\"https://example.com\",\"name\":\"Posts\",\"position\":1},{\"@type\":\"ListItem\",\"item\":\"https://example.com/page/1\",\"name\":\"My Post\",\"position\":2}]}\n</script>"
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
