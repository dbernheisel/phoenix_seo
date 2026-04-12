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

  describe "render/1" do
    test "renders full llms.txt markdown with all sections" do
      opts = %{
        title: "My App",
        description: "A project management tool for teams",
        sections: [
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
      }

      result = SEO.LLMs.render(opts)

      assert result ==
               """
               # My App

               > A project management tool for teams

               ## Docs

               - [API Reference](https://example.com/docs/api.md): Full REST API docs
               - [Guides](https://example.com/docs/guides.md)

               ## Optional

               - [Changelog](https://example.com/changelog.md)
               """
               |> String.trim_leading()
               |> String.trim_trailing()
    end

    test "renders with body text" do
      opts = %{
        title: "My App",
        description: "A tool for teams",
        body: "Key things to know:\n- It uses Phoenix\n- It requires Elixir 1.14+",
        sections: []
      }

      result = SEO.LLMs.render(opts)

      assert result =~ "# My App"
      assert result =~ "> A tool for teams"
      assert result =~ "Key things to know:"
      assert result =~ "- It uses Phoenix"
    end

    test "renders without description" do
      opts = %{title: "My App", sections: []}

      result = SEO.LLMs.render(opts)

      assert result == "# My App"
    end

    test "renders without sections" do
      opts = %{title: "My App", description: "A tool", sections: []}

      result = SEO.LLMs.render(opts)

      assert result == "# My App\n\n> A tool"
    end
  end
end
