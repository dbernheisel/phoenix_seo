defmodule SEO.JSONLD.Actions do
  @moduledoc """
  Helpers for Schema.org Action payloads — specifically the hyphenated
  `<property>-input` / `<property>-output` property-constraint syntax
  documented at https://schema.org/docs/actions.html (Part 4).

  Schema.org's Action types (e.g. `SEO.JSONLD.SearchAction`,
  `SEO.JSONLD.SolveMathAction`, `SEO.JSONLD.ReviewAction`,
  `SEO.JSONLD.WatchAction`) annotate required inputs with a hyphenated
  key whose value is a space-separated HTML-like attribute string:

      "query-input": "required maxlength=100 name=q"

  These hyphenated keys aren't expressible as Elixir atoms, so this
  module provides composable primitives:

    * `input_spec/1` builds the shorthand value for a single annotation.
    * `inputs/1` / `outputs/1` expand a list of property/constraint
      pairs into the full `%{"<property>-input" => "<spec>"}` map ready
      to merge into your Action `build/1` attrs.

  See `SEO.JSONLD.EntryPoint` when you need the richer target form
  (`urlTemplate` + `httpMethod` + `contentType`).

  ## Example

  ```elixir
  SEO.JSONLD.SolveMathAction.build(
    Map.merge(
      %{
        target: "https://example.com/solve?q={math_expression_string}",
        edu_question_type: ["Polynomial Equation"]
      },
      SEO.JSONLD.Actions.inputs(
        math_expression: [required: true, name: "math_expression_string"]
      )
    )
  )
  ```

  This module is hand-written and preserved by the generator.
  """

  @doc """
  Build the shorthand value string for a single property-constraint
  annotation. Accepts a keyword list of constraints:

    * `:required` (boolean) — whether the input must be supplied
    * `:name` — placeholder name referenced in `target` URL templates
      (e.g. `name: "q"` maps to `{q}` in the target)
    * `:max_length` / `:min_length` — length bounds (integers)
    * `:value_max` / `:value_min` — numeric value bounds
    * `:pattern` — regex pattern constraint
    * `:multiple_values` (boolean) — whether multiple values are allowed

  Options with a `nil` or `false` value are omitted. Unknown options fall
  back to a camelCased `key=value` pair.

      iex> SEO.JSONLD.Actions.input_spec(required: true, max_length: 100, name: "q")
      "required maxlength=100 name=q"

      iex> SEO.JSONLD.Actions.input_spec(required: true, multiple_values: true, name: "tag")
      "required multipleValues name=tag"
  """
  @spec input_spec(keyword()) :: String.t()
  def input_spec(opts) do
    opts
    |> Enum.flat_map(&render_opt/1)
    |> Enum.join(" ")
  end

  @doc """
  Expand a keyword list of property/constraint pairs into a map of
  hyphenated `<property>-input` keys. Each property key is camelCased
  (`:math_expression` becomes `mathExpression-input`).

      iex> SEO.JSONLD.Actions.inputs(
      ...>   query: [required: true, name: "q"],
      ...>   math_expression: [required: true, name: "expr"]
      ...> )
      %{
        "mathExpression-input" => "required name=expr",
        "query-input" => "required name=q"
      }
  """
  @spec inputs(keyword()) :: %{String.t() => String.t()}
  def inputs(entries), do: expand(entries, "-input")

  @doc """
  Like `inputs/1` but for `<property>-output` annotations, used by
  Actions that describe the shape of their result (e.g. `ReviewAction`
  declaring required output fields on the produced `Review`).
  """
  @spec outputs(keyword()) :: %{String.t() => String.t()}
  def outputs(entries), do: expand(entries, "-output")

  defp expand(entries, suffix) do
    Map.new(entries, fn {property, opts} ->
      {camelize(property) <> suffix, input_spec(opts)}
    end)
  end

  defp render_opt({:required, true}), do: ["required"]
  defp render_opt({:required, _}), do: []
  defp render_opt({:multiple_values, true}), do: ["multipleValues"]
  defp render_opt({:multiple_values, _}), do: []
  defp render_opt({_key, nil}), do: []
  defp render_opt({_key, false}), do: []
  defp render_opt({:max_length, v}), do: ["maxlength=#{v}"]
  defp render_opt({:min_length, v}), do: ["minlength=#{v}"]
  defp render_opt({:value_max, v}), do: ["valueMax=#{v}"]
  defp render_opt({:value_min, v}), do: ["valueMin=#{v}"]
  defp render_opt({:pattern, v}), do: ["pattern=#{v}"]
  defp render_opt({:name, v}), do: ["name=#{v}"]
  defp render_opt({k, v}) when is_atom(k), do: ["#{camelize(k)}=#{v}"]
  defp render_opt({k, v}) when is_binary(k), do: ["#{k}=#{v}"]

  defp camelize(atom) when is_atom(atom) do
    atom |> Atom.to_string() |> camelize()
  end

  defp camelize(string) when is_binary(string) do
    case String.split(string, "_") do
      [single] -> single
      [first | rest] -> first <> Enum.map_join(rest, "", &String.capitalize/1)
    end
  end
end
