# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned

- Subtract and multiply operations across REST, GraphQL, and CLI layers
- `Plug.RequestId` for request traceability in logs
- `Plug.Telemetry` for HTTP duration metrics
- CORS headers for browser cross-origin support
- `GET /api/history` route backed by a `History` GenServer
- ETS-based result cache
- Sobelow static security scan
- `mix_audit` dependency vulnerability audit
- CI workflow (`.github/workflows/ci.yml`)
- `.credo.exs` configuration file
- `priv/static/` — move web assets from `web-app/` to standard Plug location

## [2.0.0] - 2026-06-05

### Added

- `Math.MathService` — pure-function `add/2` with integer guards and `@spec`
- `CalculatorRest.Router` — Plug router with `POST /api/add`, `GET /swagger.json`,
  `GET /swagger`, and a 404 catch-all; serves static web assets on the same port
- `CalculatorRest.Schema` — Absinthe GraphQL schema with `add` query at
  `POST /api/graphql`; GraphiQL UI at `GET /graphiql`
- `CalculatorRest.Swagger` — inline OpenAPI 3.2.0 spec and Swagger UI page
- `CalculatorCli.Main` — escript entry point; parses two integer arguments and
  prints the result via `Math.MathService`
- `CalculatorCli.Models.Input` — typed input struct for the CLI flow
- `CalculatorApp.Application` — OTP application supervisor; starts `Plug.Cowboy`
  when `:server` env is `true`; creates log directory and enables file logging on start
- Content-type negotiation: `415 Unsupported Media Type` when `Content-Type` is not
  JSON, `406 Not Acceptable` when `Accept` does not allow JSON
- Static web frontend (`web-app/`) served on the same HTTP port as REST and GraphQL;
  supports both REST and GraphQL transports via a dropdown
- Logger with file backend (`logger_file_backend`); rolling logs with 1 MB limit and
  5 kept files; log level and path configurable via environment variables
- Custom Mix tasks: `mix server`, `mix rest.server` (deprecated alias),
  `mix test.unit`, `mix test.integration`, `mix test.e2e`, `mix quality`,
  `mix credo.report`, `mix deps.audit`, `mix coveralls.html`, `mix docs.generate`
- `mix quality` task: runs format check, compile with warnings-as-errors, full test
  suite, Credo report, and dependency audit; `--fix` flag auto-formats before checking
- `mix docs.generate` task: generates ExDoc HTML, ExCoveralls HTML, Credo report, and
  dependency audit report in one step into the `docs/` directory
- ExCoveralls HTML coverage report at `docs/coverage/`
- ExDoc documentation with `README.md` as the main page, output to `docs/`
- Credo static analysis configured via `mix credo.report`
- `.editorconfig` with per-file-type rules (2-space Elixir, CRLF for `.cmd`, LF
  elsewhere)
- `coveralls.json` with coverage output pointing to `docs/coverage/`
- `scripts/calculator_app.sh` and `scripts/calculator_app.cmd` — CLI launchers
- `scripts/server.sh` and `scripts/server.cmd` — server launchers
- `config/local.exs` — local development profile (HTTP server enabled by default)
- `config/live.exs` — production-style profile requiring `PORT` env var
- `config/runtime.exs` — runtime config for port, server flag, log path, log level
- Unit tests for `Math.MathService` including `doctest`
- Integration tests for `CalculatorRest.Router` covering all status codes
  (200, 400, 406, 415) and GraphQL query
- Integration and e2e tests for `CalculatorCli.Main`

[Unreleased]: https://github.com/setmy-info/elixir-start-project/compare/poc-second-v2.0.0...HEAD
[2.0.0]: https://github.com/setmy-info/elixir-start-project/releases/tag/poc-second-v2.0.0
