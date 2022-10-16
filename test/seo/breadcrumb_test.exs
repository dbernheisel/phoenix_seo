defmodule SEO.BreadcrumbTest do
  use ExUnit.Case, async: true
  import Phoenix.LiveViewTest
  alias SEO.Breadcrumb

  describe "meta" do
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
    end
  end

  defp build_assigns(item, config) do
    [item: item, config: config, json_library: Jason]
  end
end
