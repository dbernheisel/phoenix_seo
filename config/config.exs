import Config

# This library's own compile materializes the full Schema.org vocabulary
# so its ExDoc site and tests cover every emitted type. User apps get the
# `:google` default unless they configure otherwise.
config :phoenix_seo, json_ld_types: :all

if Mix.env() == :test, do: import_config("test.exs")
