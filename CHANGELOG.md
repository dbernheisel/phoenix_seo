# Changelog

## unreleased

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
