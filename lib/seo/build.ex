defprotocol SEO.Build do
  @fallback_to_any true

  @spec breadcrumb_list(term) :: SEO.Breadcrumb.List.t() | nil
  def breadcrumb_list(term)

  @spec open_graph(term) :: SEO.OpenGraph.t() | nil
  def open_graph(term)

  @spec twitter(term) :: SEO.Twitter.t() | nil
  def twitter(term)

  @spec site(term) :: SEO.Site.t() | nil
  def site(term)
end

defmodule SEO.Builder do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      def site(_item), do: SEO.Site.build([])
      def breadcrumb_list(_item), do: SEO.Breadcrumb.List.build([])
      def open_graph(_item), do: SEO.OpenGraph.build([])
      def twitter(_item), do: SEO.Twitter.build([])

      defoverridable site: 1, breadcrumb_list: 1, open_graph: 1, twitter: 1
    end
  end
end

defimpl SEO.Build, for: Any do
  use SEO.Builder
end

defimpl SEO.Build, for: [Map, List] do
  def breadcrumb_list(x), do: SEO.Breadcrumb.List.build(x)
  def open_graph(x), do: SEO.OpenGraph.build(x)
  def twitter(x), do: SEO.Twitter.build(x)
  def site(x), do: SEO.Site.build(x)
end
