defmodule SEO.LLMs.Provider do
  @moduledoc """
  Behaviour for dynamically providing llms.txt sections.

  Implement `sections/0` to return a list of sections, where each section
  is a tuple of `{section_name, entries}`.

  Each entry is either:
  - `{name, url}` — a link with no description
  - `{name, url, description}` — a link with a description

  A section named `"Optional"` signals to LLMs that its content can be
  skipped when context is limited.

  ## Example

      defmodule MyAppWeb.LLMsProvider do
        @behaviour SEO.LLMs.Provider

        @impl true
        def sections do
          [
            {"Docs", [
              {"API Reference", "/docs/api.md", "Full REST API docs"},
              {"Guides", "/docs/guides.md"}
            ]},
            {"Optional", [
              {"Changelog", "/changelog.md"}
            ]}
          ]
        end
      end
  """

  @type entry ::
          {name :: String.t(), url :: String.t()}
          | {name :: String.t(), url :: String.t(), description :: String.t()}
  @type section :: {name :: String.t(), list(entry())}

  @callback sections() :: list(section())
end
