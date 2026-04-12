defmodule SEO.LLMsTest do
  use ExUnit.Case, async: true
  use Plug.Test

  defmodule StaticProvider do
    @behaviour SEO.LLMs.Provider

    @impl true
    def sections do
      [
        {"Docs",
         [
           {"API Reference", "https://example.com/docs/api.md", "Full REST API docs"},
           {"Guides", "https://example.com/docs/guides.md"}
         ]},
        {"Optional",
         [
           {"Changelog", "https://example.com/changelog.md"}
         ]}
      ]
    end
  end

  test "provider module returns sections" do
    sections = StaticProvider.sections()
    assert [{"Docs", docs}, {"Optional", optional}] = sections
    assert [{"API Reference", _, "Full REST API docs"}, {"Guides", _}] = docs
    assert [{"Changelog", _}] = optional
  end
end
