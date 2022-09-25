defmodule SEO.Utils do
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
end
