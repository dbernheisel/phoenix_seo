defmodule SEO.LLMs.Provider do
  @moduledoc """
  Behaviour for dynamically providing llms.txt sections.

  Implement `sections/1` to return a list of sections, where each section
  is a tuple of `{section_name, entries}`. The current `Plug.Conn` is passed
  in so implementations can build absolute URLs and call `entry/2` callbacks.

  Each entry is one of:
  - `{name, url}` — a link
  - `{name, url, description}` — a link with a description
  - `{name, entries}` — a sub-section (rendered as H3) containing its own entries
  - `"string"` — inline markdown content rendered as-is

  A section named `"Optional"` signals to LLMs that its content can be
  skipped when context is limited.

  ## Example

      defmodule MyAppWeb.LLMsProvider do
        @behaviour SEO.LLMs.Provider

        @impl true
        def sections(_conn) do
          [
            {"Docs", [
              {"API Reference", "/docs/api.md", "Full REST API docs"},
              {"Guides", "/docs/guides.md"}
            ]},
            {"SDKs", [
              {"TypeScript", [
                {"Client SDK", "/sdk/ts", "TypeScript client"},
                {"Server SDK", "/sdk/ts-server"}
              ]},
              {"Python", [
                {"Client SDK", "/sdk/py"}
              ]}
            ]},
            {"Optional", [
              {"Changelog", "/changelog.md"}
            ]}
          ]
        end
      end
  """

  @type link ::
          {name :: String.t(), url :: String.t()}
          | {name :: String.t(), url :: String.t(), description :: String.t()}
  @type sub_section :: {name :: String.t(), list(entry())}
  @type entry :: link() | sub_section() | String.t()
  @type section :: {name :: String.t(), list(entry())}

  @callback sections(Plug.Conn.t()) :: list(section())
end
