defmodule SEO.Test.Helpers do
  @moduledoc """
  Simple test helpers
  """
  def meta_content(html, selector, contains) do
    meta(html, selector, "content", contains)
  end

  def meta(html, selector, attr, contains) do
    case Floki.find(html, "meta[" <> selector <> "]") do
      [] ->
        false

      nil ->
        false

      tags ->
        attr_contains?(tags, attr, contains)
    end
  end

  defp attr_contains?(tags, attr, contains) do
    Enum.any?(tags, fn
      {_tag, attrs, _content} ->
        Enum.any?(attrs, fn
          {^attr, ^contains} -> true
          _ -> false
        end)

      _ ->
        false
    end)
  end

  def title(html, contains) do
    case Floki.find(html, "title") do
      [{"title", _, [^contains]}] ->
        true

      _ ->
        false
    end
  end

  def linking_data(html) do
    case Floki.find(html, "script[type='application/ld+json']") do
      [{"script", _, json}] ->
        Jason.decode!(json)

      _ ->
        false
    end
  end
end
