defmodule SEO.Builder do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def site(item, default), do: SEO.Site.build(item, default)
      def site(item), do: SEO.Site.build(item)
      def breadcrumb_list(item, default), do: SEO.Breadcrumb.List.build(item, default)
      def breadcrumb_list(item), do: SEO.Breadcrumb.List.build(item)
      def open_graph(item, default), do: SEO.OpenGraph.build(item, default)
      def open_graph(item), do: SEO.OpenGraph.build(item)
      def twitter(item, default), do: SEO.Twitter.build(item, default)
      def twitter(item), do: SEO.Twitter.build(item)
      def unfurl(item, default), do: SEO.Unfurl.build(item, default)
      def unfurl(item), do: SEO.Unfurl.build(item)

      defoverridable SEO.Build
    end
  end
end
