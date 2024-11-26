# Changelog

## unreleased

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
