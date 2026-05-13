# Changelog

## Unreleased

- **Breaking change**: JSON-LD modules (`SEO.JSONLD.*`) are now generated at
  compile time via a Mix compiler instead of being prebuilt in the package.
  Register the compiler in your `mix.exs` (`compilers: [:seo_jsonld] ++
  Mix.compilers()`) and pick which Schema.org types to materialize via
  `config :phoenix_seo, json_ld_types: :all` to materialize the full
  Schema.org vocabulary (default is `:google` — the ~24 rich-result
  types plus their closure). Accepts either a single entry or a list.
  See the README "Installation" section for details.
- **Breaking change (breadcrumbs)**: `SEO.Breadcrumb.*` is removed and folded
  into the JSON-LD namespace. Use `SEO.JSONLD.Breadcrumbs.build/1` in your
  `SEO.JSONLD.Build` impls (returned alongside other entities as a list).
- The `:config` attr on `<SEO.JSONLD.meta />` is removed along with the
  site-wide `json_ld:` config slot. `"@context"` is now applied to the
  top-level node by `SEO.JSONLD.meta/1` only, so nested typed builders no
  longer emit redundant per-node contexts.
- Convenience wrappers (`SEO.JSONLD.Breadcrumbs`, `SEO.JSONLD.FAQ`,
  `SEO.JSONLD.Actions`) are emitted only when their dependent modules are
  present in the compiled closure.

## 0.2.1 (2026-04-13)

- Fixup llms.txt rendering with module/function configs.

## 0.2.0 (2026-04-12)

- Add support for `llms.txt` standard. This allows LLMs, when browsing your
site, to get succinct information about progressively-revealed information with
optional sections to optimize context windows. See `SEO.LLMs` for more info.
- CI: Add Blend to test older Phoenix LiveView versions. Thank you @Flo0807
- Docs: Update ex_doc

## 0.1.11 (2024-11-25)

- Bugfix: Correct `locale_alternate` handling. Thank you @Hermanverschooten

## 0.1.10 (2024-07-21)

- Relax Phoenix Live View requirement. Thank you @srcrip

## 0.1.9 (2024-02-19)

- Fix twitter card. An empty value would always render `summary`. Thank you @Flo0807.

## 0.1.8 (2023-01-25)

- Fix behavior when no item is provided. Component was defaulting to nil for
  item when didn't let fallback to work. Thank you @hwatkins.

## 0.1.7 (2022-12-08)

- BREAKING: simplify OpenGraph fields `:type` and `:type_detail` into one
  `:detail`. The appropriate struct or values in `:detail` will infer to the type.

## 0.1.6 (2022-10-17)

- Add SEO.Config @behaviour and implement it during `use SEO`.
- SEO config is now a struct instead of a map

## 0.1.5 (2022-10-16)

- Allow for config to be a module that implements `config/0` and `config/1`
- Allow for domain config to be a function reference that receives a conn
- BREAKING: rework implementation to be arity 2 that accepts the item and the conn.

## 0.1.4 (2022-10-16)

- Fix empty breadcrumbs
- Squash newlines and trim description

## 0.1.3 (2022-10-14)

- Fix fetching SEO item from LiveView
- Improve docs.

## 0.1.2 (2022-10-14)

- Don't limit rendering twitter card meta
- Improve docs.

## 0.1.1 (2022-10-14)

- Rework implementation.

## 0.1.0 (2022-10-13)

- Initial release
