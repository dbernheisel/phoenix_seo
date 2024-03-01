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
  def to_iso8601(iso8601_string) when is_binary(iso8601_string), do: iso8601_string

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
