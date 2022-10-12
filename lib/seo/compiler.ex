defmodule SEO.Compiler do
  @moduledoc false

  defmacro __before_compile__(env) do
    poison = if Code.ensure_loaded?(Poison), do: Poison
    jason = if Code.ensure_loaded?(Jason), do: Jason
    phoenix_json = Application.get_env(:phoenix, :json_library)
    seo_json = Application.get_env(:seo, :json_library)
    json_library = seo_json || phoenix_json || jason || poison

    config =
      Module.get_attribute(env.module, :seo_options, [])
      |> Enum.into(%{})
      |> Map.put_new(:json_library, json_library)

    Module.put_attribute(env.module, :config, config)

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

    Module.put_attribute(env.module, :json_library, json_library)

    quote location: :keep do
      @doc false
      def config, do: @config

      @doc false
      def config(mod), do: config()[mod] || struct(mod, [])

      SEO.define_juice()
    end
  end
end
