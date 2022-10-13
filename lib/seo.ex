defmodule SEO do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  defmacro __using__(opts) do
    SEO.define_config(opts)
  end

  def define_config(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @seo_options SEO.Config.validate!(opts)

      @doc false
      def config, do: @seo_options

      @doc false
      def config(domain), do: config()[domain] || []
    end
  end

  use Phoenix.Component

  attr(:item, :any, required: true)
  attr(:page_title, :string, default: nil)
  attr(:config, :any, default: %{})
  @doc "Provide SEO juice. Requires an item"
  def juice(assigns) do
    ~H"""
    <SEO.Site.meta item={SEO.Build.site(@item, @config[:site])} page_title={@page_title} />
    <SEO.Unfurl.meta item={SEO.Build.unfurl(@item, @config[:unfurl])} />
    <SEO.OpenGraph.meta item={SEO.Build.open_graph(@item, @config[:open_graph])} />
    <SEO.Twitter.meta item={SEO.Build.twitter(@item, @config[:twitter])} />
    <SEO.Facebook.meta item={SEO.Build.facebook(@item, @config[:facebook])} />
    <SEO.Breadcrumb.meta item={SEO.Build.breadcrumb_list(@item, @config[:breadcrumb])} json_library={@config[:json_library]} :if={@config[:json_library]} />
    """
  end

  @key :seo

  @doc "Assign the SEO item from the Plug.Conn or LiveView Socket"
  @spec assign(Plug.Conn.t() | Phoenix.LiveView.Socket.t(), any()) ::
          Plug.Conn.t() | Phoenix.LiveView.Socket.t()
  def assign(conn_or_socket_or_assigns, item)

  def assign(%Plug.Conn{} = conn, item) do
    Plug.Conn.put_private(conn, @key, item)
  end

  def assign(%Phoenix.LiveView.Socket{} = socket, item) do
    Phoenix.Component.assign(socket, @key, item)
  end

  def key, do: @key

  @doc "Fetch the SEO item from the Plug.Conn or LiveView Socket"
  @spec item(Plug.Conn.t() | Phoenix.LiveView.Socket.t()) :: any()
  def item(%Plug.Conn{} = conn), do: conn.private[@key] || []
  def item(%Phoenix.LiveView.Socket{} = socket), do: socket.assigns[@key] || []
end
