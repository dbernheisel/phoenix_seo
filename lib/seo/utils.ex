defmodule SEO.Utils do
  @moduledoc false

  use Phoenix.Component

  attr(:property, :string, required: true)
  attr(:content, :any, required: true, doc: "Either a string representing a URI, or a URI")

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

  def format_date(%Date{} = date), do: Date.to_iso8601(date)
  def format_date(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_iso8601(ndt)
  def format_date(%DateTime{} = dt), do: DateTime.to_iso8601(dt)

  def truncate(text, length \\ 200) do
    if String.length(text) <= length do
      text
    else
      String.slice(text, 0..length)
    end
    |> String.trim()
  end

  # def merge_defaults(assigns) do
  #   item = struct(assigns[:item], Map.from_struct(assigns[:default]))
  #   Phoenix.Component.assign(assigns, :item, item)
  # end

  def merge_defaults(module, attrs, defaults) when defaults == %{} or defaults == [] or is_nil(defaults) do
    merge_defaults(module, attrs, struct(module))
  end
  def merge_defaults(_module, attrs, defaults) when is_struct(defaults) and ( is_map(attrs) or is_list(attrs) ) and not is_struct(attrs) do
    struct(defaults, attrs)
  end
  def merge_defaults(module, attrs, defaults) when ( is_map(attrs) or is_list(attrs) ) and not is_struct(attrs) do
    merge_defaults(module, attrs, struct(module, defaults))
  end

  def to_iso8601(%NaiveDateTime{} = ndt), do: NaiveDateTime.to_iso8601(ndt)
  def to_iso8601(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  def to_iso8601(%Date{} = d), do: Date.to_iso8601(d)
end
