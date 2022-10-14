defmodule SEO do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @doc """
  Setup your defaults. Domains are mapped this way:

  - `:site` -> `SEO.Site`
  - `:open_graph` -> `SEO.OpenGraph`
  - `:unfurl` -> `SEO.Unfurl`
  - `:facebook` -> `SEO.Facebook`
  - `:twitter` -> `SEO.Twitter`
  - `:breadcrumb` -> `SEO.Breadcrumb`

  For example:

  ```elixir
  use SEO, [
    site: SEO.Site.build(description: "My Blog of many words and infrequent posts", default_title: "Fanastic Site")
    facebook: SEO.Facebook.build(app_id: "123")
  ]
  ```
  """
  defmacro __using__(opts) do
    SEO.define_config(opts)
  end

  @doc false
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

  @doc """
  Provide SEO juice. Requires an item and passes the item through all available domains

  ```heex
  <head>
    <%# remove the Phoenix-generated <.live_title> component %>
    <%# and replace with SEO.juice component %>
    <SEO.juice
      config={MyAppWeb.SEO.config()}
      item={SEO.item(assigns)}
      page_title={assigns[:page_title]}
    />
  </head>
  ```

  Alternatively, you may selectively render components:

  ```heex
  <head>
    <%# With your SEO module's configuration %>
    <SEO.OpenGraph.meta
      config={MyAppWeb.SEO.config(:open_graph)}
      item={SEO.OpenGraph.Build.build(SEO.item(assigns))}
    />

    <%# Or with runtime configuration %>
    <SEO.Twitter.meta
      config={%{site_name: "Foo Fighters"}}
      item={SEO.Twitter.Build.build(SEO.item(assigns))}
    />

    <%# Or without configuration is fine too %>
    <SEO.Unfurl.meta item={SEO.Unfurl.Build.build(SEO.item(assigns))} />
  </head>
  ```
  """

  attr(:item, :any, required: true, doc: "Item to render that implements `SEO.Build`")
  attr(:page_title, :string, default: nil, doc: "Page Title. Overrides item's title if supplied")
  attr(:config, :any, default: nil, doc: "Configuration for your SEO module")

  def juice(assigns) do
    assigns = assign_configs(assigns, assigns[:config])

    ~H"""
    <SEO.Site.meta config={@site_config} item={SEO.Site.Build.build(@item)} page_title={@page_title} />
    <SEO.Unfurl.meta config={@unfurl_config} item={SEO.Unfurl.Build.build(@item)} />
    <SEO.OpenGraph.meta config={@open_graph_config} item={SEO.OpenGraph.Build.build(@item)} />
    <SEO.Twitter.meta config={@twitter_config} item={SEO.Twitter.Build.build(@item)} />
    <SEO.Facebook.meta config={@facebook_config} item={SEO.Facebook.Build.build(@item)} />
    <SEO.Breadcrumb.meta config={@breadcrumb_config} item={SEO.Breadcrumb.Build.build(@item)} json_library={@config[:json_library]} :if={@config[:json_library]} />
    """
  end

  @keys ~w[site unfurl open_graph twitter facebook breadcrumb]a
  defp assign_configs(assigns, config) do
    Enum.reduce(@keys, assigns, fn domain, assigns ->
      assign_new(assigns, :"#{domain}_config", fn -> config && config[domain] end)
    end)
  end

  @key :seo

  @doc "Assign the SEO item from the Plug.Conn or LiveView Socket"
  @spec assign(Plug.Conn.t() | Phoenix.LiveView.Socket.t(), any()) ::
          Plug.Conn.t() | Phoenix.LiveView.Socket.t()
  def assign(conn_or_socket, item)

  def assign(%Plug.Conn{} = conn, item) do
    Plug.Conn.put_private(conn, @key, item)
  end

  def assign(%Phoenix.LiveView.Socket{} = socket, item) do
    Phoenix.Component.assign(socket, @key, item)
  end

  def key, do: @key

  @doc "Fetch the SEO item from the Plug.Conn or LiveView Socket"
  @spec item(Plug.Conn.t() | Phoenix.LiveView.Socket.t()) :: any()
  def item(conn_or_socket)
  def item(%Plug.Conn{} = conn), do: conn.private[@key] || []
  def item(%Phoenix.LiveView.Socket{} = socket), do: socket.assigns[@key] || []
end
