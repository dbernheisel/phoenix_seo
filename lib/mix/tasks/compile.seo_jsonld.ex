defmodule Mix.Tasks.Compile.SeoJsonld do
  @moduledoc """
  Generates and compiles `SEO.JSONLD.*` typed builder modules from the
  Schema.org vocabulary bundled with `:phoenix_seo`.

  ## Usage

  Add the compiler to your project's compiler list:

      def project do
        [
          compilers: [:seo_jsonld] ++ Mix.compilers(),
          # ...
        ]
      end

  Pick which Schema.org types to materialize via application config.
  Accepts a single entry or a list of entries:

      config :phoenix_seo, json_ld_types: :all
      config :phoenix_seo, json_ld_types: [:google, SEO.JSONLD.SearchAction]

  ### Available config entries

  - `:google` — the types Google has rich-result guides for plus their
    supporting types (~200 modules with their closure). **This is the
    default.**
  - `:all` — every regular Schema.org class (~820 modules).
  - Category atoms like `:medical`, `:place`, `:travel`, `:shopping`,
    `:creative_work`, `:action`, etc. See
    `Mix.Tasks.Compile.SeoJsonld.Generator.groups/0` for the full list.
  - Module names like `SEO.JSONLD.Article` (or strings like
    `"Article"` / `"schema:Article"`).

  Ancestors and referenced types are pulled into the emit set
  automatically, so the typespecs always resolve.

  Defaults to `:google` when no config is supplied.
  """
  use Mix.Task.Compiler

  # Run per-app in the app's own project context. Without this, an umbrella
  # `mix compile` dispatches this (non-recursive) compiler mid-recursion through
  # `Mix.ProjectStack.on_recursing_root/1`, which switches the active project to
  # the umbrella root — where `Mix.Project.app_path/0` raises ("umbrellas have no
  # app"). Marking it recursive keeps it running in the child app that lists it.
  @recursive true

  alias Mix.Tasks.Compile.SeoJsonld.Generator

  @manifest_version 2

  @impl Mix.Task.Compiler
  def run(_args) do
    Mix.Task.run("loadpaths")

    schema_path = Generator.schema_path()

    unless File.exists?(schema_path) do
      Mix.raise(
        "phoenix_seo: schema file missing at #{schema_path}. " <>
          "Run `mix deps.compile phoenix_seo` to repopulate it."
      )
    end

    config = config_for_compile()
    schema_mtime = File.stat!(schema_path).mtime
    key = manifest_key(config, schema_mtime)

    case read_manifest() do
      %{version: @manifest_version, key: ^key} ->
        {:noop, []}

      previous ->
        rebuild(config, key, previous)
    end
  end

  @impl Mix.Task.Compiler
  def manifests, do: [manifest_path()]

  @impl Mix.Task.Compiler
  def clean do
    case read_manifest() do
      %{modules: modules} -> Enum.each(modules, &File.rm(beam_path(&1)))
      _ -> :ok
    end

    File.rm(manifest_path())
    File.rm_rf(sources_dir())
    :ok
  end

  ## Internal ------------------------------------------------------------

  defp rebuild(config, key, previous) do
    if previous, do: Enum.each(Map.get(previous, :modules, []), &File.rm(beam_path(&1)))
    File.rm_rf!(sources_dir())

    # Start the progress line; `parallel_compile` finishes it with the
    # module count once the .beams are on disk.
    IO.write("Generating SEO.JSONLD modules...")

    iris = Generator.expand_types(config)
    sources = Generator.emit_sources(iris)

    src_dir = sources_dir()
    ebin_dir = Mix.Project.compile_path()
    File.mkdir_p!(src_dir)
    File.mkdir_p!(ebin_dir)

    paths =
      Enum.map(sources, fn {_module, filename, source} ->
        path = Path.join(src_dir, filename)
        File.write!(path, source)
        path
      end)

    modules = parallel_compile(paths, ebin_dir)

    write_manifest(%{version: @manifest_version, key: key, modules: modules})

    IO.puts(" generated #{length(modules)} modules")
    {:ok, []}
  end

  defp parallel_compile(paths, ebin_dir) do
    # Same module may already be loaded from a previous invocation in the
    # same VM (e.g. `recompile` in iex). Allow re-definition rather than
    # noisy warnings.
    previous = Code.compiler_options()[:ignore_module_conflict]
    Code.put_compiler_option(:ignore_module_conflict, true)

    try do
      case Kernel.ParallelCompiler.compile_to_path(paths, ebin_dir, return_diagnostics: true) do
        {:ok, modules, _diagnostics} ->
          modules

        {:error, errors, _diagnostics} ->
          Mix.raise(
            "seo_jsonld: failed to compile #{length(errors)} module(s): #{inspect(errors)}"
          )
      end
    after
      Code.put_compiler_option(:ignore_module_conflict, previous || false)
    end
  end

  defp config_for_compile do
    Application.get_env(:phoenix_seo, :json_ld_types, :google)
  end

  defp manifest_key(config, mtime) do
    :erlang.phash2({config, mtime})
  end

  defp manifest_path, do: Path.join(Mix.Project.manifest_path(), "compile.seo_jsonld")
  defp sources_dir, do: Path.join(Mix.Project.app_path(), "seo_jsonld_generated")
  defp beam_path(module), do: Path.join(Mix.Project.compile_path(), "#{module}.beam")

  defp read_manifest do
    case File.read(manifest_path()) do
      {:ok, binary} -> :erlang.binary_to_term(binary)
      {:error, _} -> nil
    end
  rescue
    _ -> nil
  end

  defp write_manifest(data) do
    File.mkdir_p!(Path.dirname(manifest_path()))
    File.write!(manifest_path(), :erlang.term_to_binary(data))
  end
end
