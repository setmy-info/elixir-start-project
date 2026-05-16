# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Added
- Hex.pm packaging metadata for all publishable apps (`core_logic`, `runtime_engine`, `graphql_api`, `cli`, `lessons`, `wasm`)
- Per-app `README.md` files required by hex.pm
- `HEX_PUBLISHING.md` step-by-step publishing guide

---

## [0.1.0] - 2026-05-16

### Added
- Umbrella project scaffold with `core_logic`, `runtime_engine`, `graphql_api`, `cli`, `wasm`, `lessons`, `integration_tests`
- OTP-based dynamic module loader with hot-code reload (`runtime_engine`)
- Ecto schemas + YAML parsing (`core_logic`)
- GraphQL API with Absinthe + Plug + Cowboy (`graphql_api`)
- CLI escript (`cli`)
- Elixir learning examples as executable ExUnit tests (`lessons`)
- ExDoc documentation generation (`mix docs`)
- ExCoveralls unit-test coverage (`mix test.coverage`)
- Muzak mutation testing (`mix test.mutation`)
- Sobelow static security analysis (`mix security`)
- mix_audit dependency vulnerability audit (`mix audit`)
- Gherkin BDD e2e tests via White Bread
- SQLite integration with Ecto migration scripts

[Unreleased]: https://github.com/setmy-info/elixir-start-project/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/setmy-info/elixir-start-project/releases/tag/v0.1.0
