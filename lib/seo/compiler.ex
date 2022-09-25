defmodule SEO.Compiler do
  @moduledoc false

  defmacro __before_compile__(env) do
    config =
      Module.get_attribute(env.module, :seo_options)
      |> Keyword.put(:backend, env.module)

    Module.put_attribute(env.module, :config, config)

    poison = if Code.ensure_loaded?(Poison), do: Poison
    jason = if Code.ensure_loaded?(Jason), do: Jason
    phoenix_json = Application.get_env(:phoenix, :json_library)
    seo_json = Application.get_env(:seo, :json_library)
    json_library = seo_json || phoenix_json || jason || poison

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
      def json_library, do: @json_library
      @doc false
      def serialize(thing), do: @json_library.encode!(thing)

      SEO.define_components(@config)
    end
  end
end
