defmodule SEO do
  @external_resource "README.md"
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

  @spec assign(
          Plug.Conn.t() | Phoenix.LiveView.Socket.t() | Phoenix.LiveView.Socket.assigns(),
          :term
        ) ::
          Plug.Conn.t()
          | Phoenix.LiveView.Socket.t()
          | Phoenix.LiveView.Socket.assigns()
  def assign(%Plug.Conn{} = conn_or_socket_or_assigns, item) do
    Plug.Conn.assign(conn_or_socket_or_assigns, :seo, item)
  end

  def assign(conn_or_socket_or_assigns, item) do
    Phoenix.Component.assign(conn_or_socket_or_assigns, :seo, item)
  end

  @doc false
  def define_juice do
    quote do
      use Phoenix.Component

      attr(:item, :any, required: true)
      attr(:page_title, :string, default: nil)

      @doc "Provide SEO juice"
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
