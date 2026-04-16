defmodule SEO.Utils do
  @moduledoc false

  use Phoenix.Component

  attr :property, :string, required: true
  attr :content, :any, required: true, doc: "Either a string representing a URI, or a URI"

  def url(assigns) do
    case assigns[:content] do
      %URI{} ->
        ~H"""
        <meta property={@property} content={"#{@content}"} />
        """

      url when is_binary(url) ->
        ~H"""
        <meta property={@property} content={@content} />
        """
    end
  end

  ## TODO
  # - Tokenizer that turns HTML into sentences. eg: https://github.com/wardbradt/HTMLST

  def truncate(text, length \\ 200) do
    if String.length(text) <= length do
      text
    else
      String.slice(text, 0..(length - 1))
    end
    |> String.trim()
  end

  def squash_newlines(text), do: String.replace(text, "\n", " ")

  def to_iso8601(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_iso8601(ndt)
  def to_iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  def to_iso8601(%Date{} = d), do: Date.to_iso8601(d)
  def to_iso8601(%Time{} = t), do: Time.to_iso8601(t)
  def to_iso8601(%Duration{} = d), do: Duration.to_iso8601(d)
  def to_iso8601(iso8601_string) when is_binary(iso8601_string), do: iso8601_string

  def to_url_string(%URI{} = uri), do: URI.to_string(uri)
  def to_url_string(url) when is_binary(url), do: url

  # Build pipeline helpers, shared by every generated SEO.JSONLD.* module.
  # Each step is a no-op when its metadata table is empty, so modules with
  # no enum/date/uri fields pay zero runtime cost for that stage.

  def build_convert_enums(map, enum_fields) when is_map(enum_fields) do
    Enum.reduce(enum_fields, map, fn {field, values}, acc ->
      case Map.fetch(acc, field) do
        :error ->
          acc

        {:ok, atom} when is_atom(atom) ->
          Map.put(acc, field, Map.fetch!(values, atom))

        {:ok, other} ->
          raise ArgumentError,
                "expected an atom for #{inspect(field)}, got: #{inspect(other)}. " <>
                  "Valid values: #{inspect(Map.keys(values))}"
      end
    end)
  end

  # Walk the attrs map and coerce any Date/DateTime/Time/Duration/URI
  # struct value to its canonical string form — at the top level and inside
  # top-level lists. This sidesteps per-field allowlists: if the user passes
  # a struct we can't serialize, convert it regardless of whether the
  # schema.org range includes a URL/Date type. Nested maps are assumed to
  # already be serializable (typically built by another `build/1` call).
  def build_coerce_structs(map) do
    Map.new(map, fn {k, v} -> {k, coerce_value(v)} end)
  end

  defp coerce_value(%Date{} = v), do: to_iso8601(v)
  defp coerce_value(%DateTime{} = v), do: to_iso8601(v)
  defp coerce_value(%NaiveDateTime{} = v), do: to_iso8601(v)
  defp coerce_value(%Time{} = v), do: to_iso8601(v)
  defp coerce_value(%Duration{} = v), do: to_iso8601(v)
  defp coerce_value(%URI{} = v), do: to_url_string(v)
  defp coerce_value(list) when is_list(list), do: Enum.map(list, &coerce_value/1)
  defp coerce_value(v), do: v

  def build_camelize_keys(map, key_map) do
    Map.new(map, fn {k, v} ->
      key =
        case k do
          atom when is_atom(atom) -> Map.get(key_map, atom) || Atom.to_string(atom)
          other -> other
        end

      {key, v}
    end)
  end

  # For Action descendants only (classes whose ancestry includes
  # schema:Action). Pops the `:inputs` and `:outputs` pseudo-fields and
  # expands them via `SEO.JSONLD.Actions` into the hyphenated
  # `<property>-input` / `<property>-output` keys Schema.org's Action
  # syntax requires (https://schema.org/docs/actions.html#part-4). Keys
  # are already in their final `"<camel>-input"` string form, so the
  # subsequent `build_camelize_keys` pass leaves them alone.
  def build_expand_action_io(map) do
    map
    |> expand_action_io(:inputs, &SEO.JSONLD.Actions.inputs/1)
    |> expand_action_io(:outputs, &SEO.JSONLD.Actions.outputs/1)
  end

  defp expand_action_io(map, key, expander) do
    case Map.pop(map, key) do
      {nil, _} -> map
      {entries, rest} -> Map.merge(rest, expander.(entries))
    end
  end

  def merge_defaults(_mod, nil, nil), do: nil
  def merge_defaults(mod, attrs, nil), do: struct(mod, to_map(attrs))
  def merge_defaults(mod, attrs, []), do: struct(mod, to_map(attrs))

  def merge_defaults(mod, attrs, defaults) do
    struct(mod, Map.merge(to_map(defaults), to_map(attrs)))
  end

  def to_map(nil), do: %{}
  def to_map([]), do: %{}
  def to_map(x) when is_struct(x), do: Map.from_struct(x) |> drop_nils()
  def to_map(x) when is_list(x), do: Enum.into(x, %{}) |> drop_nils()
  def to_map(x) when is_map(x), do: drop_nils(x)

  defp drop_nils(map) when is_map(map) do
    for {k, v} <- map, v != nil, into: %{}, do: {k, v}
  end
end
