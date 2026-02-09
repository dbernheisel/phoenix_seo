defmodule SEO.Config do
  @moduledoc "Configuration for SEO. This is implemented for you when you `use SEO`"
  defstruct [
    :json_library,
    site: %{},
    facebook: %{},
    twitter: %{},
    unfurl: %{},
    open_graph: %{},
    breadcrumb: %{},
    json_ld: %{}
  ]

  @callback config() :: map()
  @callback config(atom) :: map()

  @doc false
  def validate!(config) do
    poison = if Code.ensure_loaded?(Poison), do: Poison
    jason = if Code.ensure_loaded?(Jason), do: Jason
    phoenix_json = Application.get_env(:phoenix, :json_library)
    seo_json = Application.get_env(:phoenix_seo, :json_library)
    json_library = seo_json || phoenix_json || jason || poison
    validate_json!(json_library, seo_json)

    __MODULE__
    |> struct(config)
    |> Map.put(:json_library, config[:json_library] || json_library)
  end

  def domains, do: %__MODULE__{} |> Map.keys() |> List.delete(:json_library)

  defp validate_json!(json_library, seo_json) do
    cond do
      Code.ensure_loaded?(json_library) and function_exported?(json_library, :encode!, 1) ->
        :ok

      seo_json ->
        raise ArgumentError,
              "Could not load configured :json_library, " <>
                "make sure #{inspect(seo_json)} is listed as a dependency"

      true ->
        raise ArgumentError, """
        A JSON library has not been configured. Please configure a JSON library
        in your `mix.exs` file. The suggested library is `:jason`.

        For example, in your `mix.exs`:

            def deps do
              [
                {:jason, "~> 1.0"},
                ...
              ]
            end

        You can then configure this library for `seo` in your `config/config.exs`:

            defmodule MyAppWeb.SEO do
              use SEO, json_library: Jason
            end

        If no configuration is provided, `seo` will attempt to use the library
        configured for Phoenix, then it will try to try to use Jason or Poison if
        available.
        """
    end
  end

  # Access implementation
  @behaviour Access

  @impl Access
  @doc false
  def fetch(config, key), do: Map.fetch(config, key)

  @impl Access
  @doc false
  def get_and_update(config, key, fun) do
    Map.get_and_update(config, key, fun)
  end

  @impl Access
  @doc false
  def pop(config, key) do
    case fetch(config, key) do
      {:ok, val} ->
        {val, Map.put(config, key, nil)}

      :error ->
        {nil, config}
    end
  end
end
