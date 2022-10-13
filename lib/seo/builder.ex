defmodule SEO.Builder do
  @moduledoc """
  Skeleton functions for use when implementing `SEO.Build`. This will
  implement the behaviour for you and allow you to override functions
  that make sense for your item.

  For example

  ```elixir
  defimpl SEO.Build, for: MyStruct do
    use SEO.Builder

    def open_graph(item) do
      SEO.OpenGraph.build(...)
    end

    # Optionally, you may also implement arity 2 which also receives the config for the domain
    def open_graph(item, default_open_graph_attrs) do
      SEO.OpenGraph.build(...)
    end
  end
  ```
  """

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
      def facebook(item, default), do: SEO.Facebook.build(item, default)
      def facebook(item), do: SEO.Facebook.build(item)

      defoverridable SEO.Build
    end
  end
end
