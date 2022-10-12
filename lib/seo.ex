defmodule SEO do
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @seo_options opts
      @before_compile SEO.Compiler
    end
  end

  def define_juice do
    quote do
      use Phoenix.Component

      attr(:item, :any, required: true)
      attr(:page_title, :string, default: nil)

      def juice do
        ~H"""
        <SEO.Site.meta item={SEO.Build.site(@item, config(SEO.Site))} page_title={@page_title} />
        <SEO.Unfurl.meta item={SEO.Build.unfurl(@item, config(SEO.Unfurl))} />
        <SEO.OpenGraph.meta item={SEO.Build.open_graph(@item, config(SEO.OpenGraph))} />
        <SEO.Twitter.meta item={SEO.Build.twitter(@item, config(SEO.Twitter))} />
        <SEO.Facebook.meta item={SEO.Build.facebook(@item, config(SEO.Facebook))} />
        <SEO.Breadcrumb.meta item={SEO.Build.breadcrumb_list(@item, config(SEO.Breadcrumb))} />
        """
      end
    end
  end
end
