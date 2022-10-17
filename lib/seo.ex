defmodule SEO do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  @doc """
  Setup your defaults. Domains are mapped:

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
      @behaviour SEO.Config
      @seo_options SEO.Config.validate!(opts)

      @doc """
      Get configuration for SEO.

      config/0 will return all SEO config
      config/1 with SEO domain atom will return that domain's config
      """
      @impl SEO.Config
      def config, do: @seo_options

      @impl SEO.Config
      def config(domain), do: config()[domain] || %{}
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
      conn={@conn}
      config={MyAppWeb.SEO.config()}
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

  attr(:conn, Plug.Conn,
    required: true,
    doc:
      "`Plug.Conn` for the request. Used for domain configs that are functions and to fetch the item."
  )

  attr(:item, :any,
    default: nil,
    doc: "Item to render that implements SEO protocols. Defaults to `SEO.item(@conn)`"
  )

  attr(:page_title, :string, default: nil, doc: "Page Title. Overrides item's title if supplied")

  attr(:config, :any,
    default: nil,
    doc: "Configuration for your SEO module or another module that implements `SEO.Config`"
  )

  attr(:json_library, :atom,
    default: nil,
    doc:
      "JSON library to use when rendering JSON. `config[:json_library]` will be used if not supplied."
  )

  def juice(assigns) do
    assigns =
      assigns
      |> assign_new(:item, fn -> SEO.item(assigns[:conn]) end)
      |> assign_configs(assigns[:config], assigns[:conn])

    ~H"""
    <SEO.Site.meta config={@site_config} item={SEO.Site.Build.build(@item, @conn)} page_title={@page_title} />
    <SEO.Unfurl.meta config={@unfurl_config} item={SEO.Unfurl.Build.build(@item, @conn)} />
    <SEO.OpenGraph.meta config={@open_graph_config} item={SEO.OpenGraph.Build.build(@item, @conn)} />
    <SEO.Twitter.meta config={@twitter_config} item={SEO.Twitter.Build.build(@item, @conn)} />
    <SEO.Facebook.meta config={@facebook_config} item={SEO.Facebook.Build.build(@item, @conn)} />
    <SEO.Breadcrumb.meta config={@breadcrumb_config} item={SEO.Breadcrumb.Build.build(@item, @conn)} json_library={@json_library} :if={@json_library} />
    """
  end

  defp assign_configs(assigns, mod, conn) when is_atom(mod) do
    config =
      case to_string(mod) do
        "Elixir." <> _ -> mod.config()
        "" -> []
      end

    assign_configs(assigns, config, conn)
  end

  defp assign_configs(assigns, config, conn) do
    assigns
    |> assign(:config, config)
    |> assign(:json_library, assigns[:json_library] || config[:json_library])
    |> assign_configs(conn)
  end

  @domains SEO.Config.domains()
  defp assign_configs(assigns, conn) do
    Enum.reduce(@domains, assigns, fn domain, assigns ->
      assign_new(assigns, :"#{domain}_config", fn ->
        get_domain_config(assigns[:config], domain, conn)
      end)
    end)
  end

  defp get_domain_config(config, domain, conn) do
    case config[domain] do
      nil -> %{}
      domain_config when is_function(domain_config) -> domain_config.(conn) || %{}
      domain_config -> domain_config
    end
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
  def item(%Plug.Conn{} = conn), do: conn.private[@key] || conn.assigns[@key] || []
  def item(%Phoenix.LiveView.Socket{} = socket), do: socket.assigns[@key] || []

  @typedoc "Attributes describing an item"
  @type attrs :: struct() | map() | Keyword.t() | nil

  @typedoc "Fallback attributes describing an item and configuration"
  @type config :: struct() | map() | Keyword.t() | nil
end
