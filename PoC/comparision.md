# PoC Comparison: first vs second

## What each PoC demonstrates

### PoC/first — Umbrella OTP platform

Multi-app umbrella (`cli`, `core_logic`, `graphql_api`, `integration_tests`, `lessons`,
`runtime_engine`, `wasm`). The central idea is a **dynamic module loading engine**:
modules are registered by name, loaded on demand as isolated GenServer Workers under a
DynamicSupervisor, dispatched through an ETS-backed registry, and can be hot-swapped at
runtime without restarting the VM. Everything else (GraphQL, CLI, DB, scripts) is wired
on top of that engine.

### PoC/second — Single-app layered service

Flat single-app (`calculator_app`) with a clean three-layer architecture:
`SetmyInfo.Math.MathService` (pure logic) → `SetmyInfo.CalculatorRest.Router` (Plug REST) +
`SetmyInfo.CalculatorRest.Schema` (Absinthe GraphQL) + `SetmyInfo.CalculatorRest.Swagger` (OpenAPI 3.2) +
`SetmyInfo.CalculatorCli.Main` (escript). Static web frontend served on the same port.
Custom Mix tasks. Logger with file backend. Credo, Sobelow, and mutation testing (Muzak).
Gherkin BDD tests via White Bread. YAML and TOML parsing examples. Language lessons
(data types, data structures, algorithms and streams) in unit test execution environment.

---

## Feature matrix

| Feature                                                     | first | second |
|-------------------------------------------------------------|:-----:|:------:|
| OTP umbrella (multi-app)                                    |   ✓   |   —    |
| GenServer Worker per loaded module (one process per module) |   ✓   |   —    |
| Stateful GenServer (Loader / ModuleRegistry / History)      |   ✓   |   ✓    |
| Agent (shared mutable state)                                |   ✓   |   ✓    |
| DynamicSupervisor for Workers                               |   ✓   |   —    |
| Multi-level supervisor tree                                 |   ✓   |   ✓    |
| `rest_for_one` supervisor strategy                          |   ✓   |   —    |
| Registry (via-tuple named process lookup)                   |   ✓   |   ✓    |
| ETS table (public, named, read_concurrency)                 |   ✓   |   ✓    |
| ModuleRegistry (ETS-backed spec store)                      |   ✓   |   —    |
| Loader / Executor facade (full lifecycle API)               |   ✓   |   —    |
| Loader crash recovery (reconcile with Registry)             |   ✓   |   —    |
| Behaviour definition (`@behaviour` / `@callback`)           |   ✓   |   ✓    |
| Hot code swap (load_from_source / load_from_beam)           |   ✓   |   —    |
| Task / parallel computation (async_stream)                  |   —   |   ✓    |
| WASM engine stub                                            |   ✓   |   —    |
| Ecto Repo + SQLite + migrations                             |   ✓   |   ✓    |
| Ecto schema (`Person`) + context (`Persons`)                |   ✓   |   ✓    |
| REST API (Plug.Router)                                      |   ✓   |   ✓    |
| GraphQL (Absinthe)                                          |   ✓   |   ✓    |
| GraphiQL interactive UI                                     |   ✓   |   ✓    |
| CLI escript                                                 |   ✓   |   ✓    |
| YAML parsing (yaml_elixir / yamerl)                         |   ✓   |   ✓    |
| TOML parsing (toml library)                                 |   ✓   |   ✓    |
| Gherkin / BDD tests (White Bread)                           |   ✓   |   ✓    |
| Feature files (`.feature`)                                  |   ✓   |   ✓    |
| Standalone Elixir scripts (BEAM lifecycle)                  |   ✓   |   ✓    |
| Lessons app (data types, data structures, algos…)           |   ✓   |   ✓    |
| Bitwise operations                                          |   ✓   |   ✓    |
| Arithmetic ops beyond add (subtract / multiply / divide)    |   ✓   |   ✓    |
| Mutation testing (Muzak)                                    |   ✓   |   ✓    |
| Sobelow security scan                                       |   ✓   |   ✓    |
| mix_audit dependency vulnerability scan                     |   ✓   |   ✓    |
| Content-type negotiation (415 / 406)                        |   —   |   ✓    |
| Swagger / OpenAPI 3.2                                       |   —   |   ✓    |
| Static web frontend (HTML + CSS + JS)                       |   —   |   ✓    |
| Rate limiting (ETS per-IP fixed window)                     |   —   |   ✓    |
| CORS / OPTIONS preflight (CorsPlug)                         |   —   |   ✓    |
| Custom Mix tasks (Mix.Task modules)                         |   —   |   ✓    |
| Credo static analysis                                       |   —   |   ✓    |
| Logger with file backend                                    |   —   |   ✓    |
| Structured Spring Boot-like log format                      |   —   |   ✓    |
| Telemetry events (Plug.Telemetry)                           |   —   |   ✓    |
| Config.Provider (TOML runtime config)                       |   —   |   ✓    |
| Structured input model (defstruct for CLI)                  |   —   |   ✓    |
| Property-based tests (StreamData)                           |   —   |   ✓    |
| `doctest` in unit tests                                     |   —   |   ✓    |
| ExDoc `description:` + `package:` in mix.exs                |   —   |   ✓    |
| Separate unit / integration / e2e / gherkin tasks           |   —   |   ✓    |
| Dockerfile (host-built OTP release, runtime-only image)     |   —   |   ✓    |

---

## Good examples not yet in PoC/second

Listed from highest to lowest learning value for someone studying Elixir patterns.
Each item describes **what to implement**, **which Elixir concept it teaches**, and
**how it fits** the calculator domain.

Items 1–6 below have been **implemented** in PoC/second and are documented here for
reference only.

---

### 1. GenServer with state — stateful calculation history ✓ Done

**What:** `SetmyInfo.CalculatorApp.History` GenServer storing the last 100 operations.
`add_entry/3`, `last/0`, `all/0`, `clear/0`. `GET /api/history` returns the list.
Via-tuple registered under `ServiceRegistry`.

**Teaches:** `handle_call/3` vs `handle_cast/2`, graceful degradation when process not started,
`{:via, Registry, …}` registration.

---

### 2. ETS table — calculation result cache ✓ Done

**What:** `SetmyInfo.CalculatorApp.Cache` wrapping a named ETS table. `POST /api/add` checks
cache before calling `MathService`; hits return stored result instantly.

**Teaches:** `:ets.new/2`, `:ets.lookup/2`, `:ets.insert/2`, `read_concurrency: true`,
graceful `:ets.whereis/1` check when table not yet created.

---

### 3. Registry — named worker lookup ✓ Done

**What:** `ServiceRegistry` (`:unique` Registry) started first in the supervision tree.
`History` registers via `{:via, Registry, {ServiceRegistry, :history}}`.

**Teaches:** `{:via, Registry, {name, key}}`, `Registry.lookup/2`, decoupling caller from PID.

---

### 4. Behaviour definition — pluggable operation modules ✓ Done

**What:** `SetmyInfo.CalculatorApp.Operation` behaviour with `name/0` and `execute/2` callbacks.
`Add`, `Subtract`, `Multiply`, `Divide` implement it. `POST /api/calc` dispatches by name.

**Teaches:** `@behaviour`, `@callback`, `@impl`, compile-time enforcement, data-driven dispatch map.

---

### 5. OTP supervisor tree — multi-level supervision ✓ Done

**What:** `SetmyInfo.CalculatorApp.ServiceSupervisor` (`:one_for_one`) supervises
`Task.Supervisor`, `Cache`, and `History`. Started as a child under the root Application supervisor.

**Teaches:** Multi-level supervision trees, `child_spec` ordering, Task.Supervisor as named child.

---

### 6. Task — parallel computation ✓ Done

**What:** `SetmyInfo.CalculatorApp.Parallel` — `add_many/1` via `Task.async_stream`,
`supervised_add_many/2` via `Task.Supervisor.async_stream_nolink`. `POST /api/batch` endpoint.

**Teaches:** `Task.async_stream` vs `async_stream_nolink`, link semantics, `ordered: true`.

---

### 7. Agent — shared mutable state (simple alternative to GenServer) ✓ Done

**What:** `SetmyInfo.CalculatorApp.RunningTotal` Agent keeping a running sum.
`get/0`, `add/1`, `reset/0`. Three REST endpoints: `GET /api/total`, `POST /api/total`,
`DELETE /api/total`. Supervised under `ServiceSupervisor`.

**Teaches:** `Agent.start_link/2`, `Agent.get/2`, `Agent.update/2`,
`Agent.get_and_update/2`, when to choose Agent over GenServer (pure state
transformation, no custom message handling needed).

---

### 8. Ecto + SQLite — persist calculation results ✓ Done

**What:** `SetmyInfo.Ecto.Repo` (SQLite3), `SetmyInfo.Ecto.Person` schema,
`SetmyInfo.Ecto.Persons` context, and `priv/repo/migrations/`.

**Teaches:**

- `use Ecto.Schema`, `use Ecto.Repo`
- `Ecto.Changeset` for validation (`cast/3`, `validate_required/2`)
- `Repo.insert/1`, `Repo.all/1`, `Repo.get/2`, `Repo.delete/1`
- Migration lifecycle (`Ecto.Migrator.run/4`, `mix ecto.migrate`)
- Conditional Repo startup — started only when config entry exists

**Status: ✓ done** — `lib/setmy_info/ecto/`, `priv/repo/migrations/`, integration tests in
`test/integration/setmy_info/ecto/persons_test.exs`.

---

### 9. Hot code swap — reload MathService at runtime

**What:** Port `HotCode` from first PoC into second PoC.

**Teaches:**

- The BEAM's two-version module model (current + old)
- `:code.load_binary/3`, `:code.soft_purge/1`
- `Code.put_compiler_option(:ignore_module_conflict, true)`

---

### 10. Protocol — Calculable for different numeric types

**What:** Define a `SetmyInfo.CalculatorApp.Calculable` protocol with `to_number/1`.

**Teaches:**

- `defprotocol` and `defimpl`
- Protocol dispatch vs behaviour dispatch (data-driven vs module-driven)
- Protocol consolidation in production builds

---

### 11. Subtract and multiply operations

**What:** Add `subtract/2` and `multiply/2` to `SetmyInfo.Math.MathService`.

**Teaches:**

- Extending an existing clean API across all layers consistently
- Function clause guards for different arities

---

## PoC/second correctness by standards

Compliance assessment of the current second PoC code against the standards each layer
claims to implement. Legend: ✓ = compliant, ~ = partial, ✗ = missing or wrong.

---

### REST / HTTP (RFC 7231, RFC 9110)

| #  | Check                                                           | Status | Notes                                                                                         |
|----|-----------------------------------------------------------------|:------:|-----------------------------------------------------------------------------------------------|
| 1  | Correct status codes for success (200)                          |   ✓    | `/api/add` returns 200                                                                        |
| 2  | 400 for malformed / missing fields                              |   ✓    | Missing `a`/`b` or non-integer returns 400                                                    |
| 3  | 406 for unacceptable `Accept` header                            |   ✓    | Enforced by `ensure_json_headers/2` plug                                                      |
| 4  | 415 for wrong `Content-Type`                                    |   ✓    | Enforced by `ensure_json_headers/2` plug                                                      |
| 5  | 404 for unknown routes                                          |   ✓    | `match _` catch-all returns JSON 404                                                          |
| 6  | 405 Method Not Allowed for wrong verb                           |   ✗    | `GET /api/add` falls through to 404 instead of 405                                            |
| 7  | `Content-Type: application/json` on all JSON responses          |   ✓    | Set explicitly on every response                                                              |
| 8  | Consistent error response shape (`{"error": "..."}`)            |   ✓    | All error paths use the same shape                                                            |
| 9  | CORS headers for browser cross-origin requests                  |   ✓    | `CorsPlug` adds `Access-Control-Allow-Origin: *` to all responses                             |
| 10 | `OPTIONS` preflight handling                                    |   ✓    | `CorsPlug` returns 204 with `Access-Control-Allow-*` headers and halts                        |
| 11 | API versioning strategy                                         |   ✗    | Path is `/api/add` with no version segment                                                    |
| 12 | `X-Request-Id` / `request_id` propagated to response            |   ✓    | `Plug.RequestId` first in pipeline; stored in `conn.assigns[:request_id]` and Logger metadata |
| 13 | Idempotency — `POST /api/add` is not idempotent by definition   |   ~    | Correct HTTP verb; pure function so same inputs always yield same output                      |
| 14 | HTTPS support                                                   |   ✗    | Only HTTP; Cowboy 2 supports TLS but it is not configured                                     |
| 15 | Security headers (X-Content-Type-Options, X-Frame-Options, CSP) |   ✗    | None present                                                                                  |

---

### OpenAPI 3.2 / Swagger

| #  | Check                                                    | Status | Notes                                                                          |
|----|----------------------------------------------------------|:------:|--------------------------------------------------------------------------------|
| 1  | Valid `openapi: "3.2.0"` field                           |   ✓    | Correct version string                                                                                |
| 2  | `info.title`, `info.version` present                     |   ✓    | Title and `"2.0"` version present                                                                     |
| 3  | `servers` array with base URL                            |   ✓    | `servers: [%{url: "http://localhost:4000"}]` present                                                  |
| 4  | `operationId` on each operation                          |   ✓    | All 7 operations have `operationId` (addIntegers, calculate, batchAdd, getHistory, …)                 |
| 5  | Response schemas for all documented codes                |   ✓    | All endpoints document 200, 429, 500; POST endpoints also 400, 406, 415; `/api/total` POST also 503   |
| 6  | Example values in schemas                                |   ✓    | `example:` added to every schema property and at schema level                                         |
| 7  | `$ref` component schemas for all request/response bodies |   ✓    | All 13 schemas defined in `components/schemas` and referenced by `$ref`                               |
| 8  | `required` fields listed on request schema               |   ✓    | `required` array present on all request schemas                                                       |
| 9  | `info.contact` and `info.license`                        |   ✓    | `contact` (GitHub URL) and `license` (MIT) added to `info`                                            |
| 10 | Spec served at `/openapi.json` or `/swagger.json`        |   ✓    | Served at both `/openapi.json` (standard) and `/swagger.json` (legacy); Swagger UI uses `/openapi.json`|

---

### GraphQL (GraphQL June 2018 spec, Absinthe conventions)

| #  | Check                                           | Status | Notes                                                   |
|----|-------------------------------------------------|:------:|---------------------------------------------------------|
| 1  | Schema has at least one `query` type            |   ✓    | `query do … end` block present                          |
| 2  | Non-null fields and arguments where required    |   ✓    | `non_null(:integer)` on both args and return            |
| 3  | Resolver returns `{:ok, value}`                 |   ✓    | Correct Absinthe resolver shape                         |
| 4  | Error path returns `{:error, reason}`           |   ✗    | Resolver has no error clause                            |
| 5  | Mutations defined for state-changing operations |   ~    | Ecto is present (Person schema); CRUD mutations not yet implemented |
| 6  | Depth / complexity limiting                     |   ✗    | No `Absinthe.Plug` complexity or depth limits           |
| 7  | Introspection disabled in production            |   ✗    | Introspection is always on                              |
| 8  | `@desc` on all fields and types                 |   ✓    | `DateTime` scalar, `add_result` type, `add` field, and all sub-fields have `@desc` / `description:` |
| 9  | Custom scalars for domain types                 |   ✓    | `DateTime` scalar serialises to ISO 8601 with millisecond precision (`2026-01-01T12:00:00.123Z`)    |
| 10 | Authentication at resolver level                |   ✗    | No context-based auth check in any resolver             |

---

### Elixir / OTP coding standards

| #  | Check                                                             | Status | Notes                                                                                                                                              |
|----|-------------------------------------------------------------------|:------:|----------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | `@moduledoc` on all public modules                                |   ✓    | Every module has `@moduledoc`                                                                                                                      |
| 2  | `@doc` on all public functions                                    |   ~    | `MathService` and lessons fully documented; Router private helpers have `@doc false`                                                               |
| 3  | `@spec` on all public functions                                   |   ~    | `MathService.add/2`, parsers, and lessons have `@spec`; Router functions lack specs                                                                |
| 4  | `@type` for domain types                                          |   ✓    | `operand` in `MathService`; response types in `Router`; `entry` in `History`; `execute_result` in `Operation`; `pair`/`batch_result` in `Parallel` |
| 5  | `@impl true` on behaviour callbacks                               |   ~    | Used on GenServer/Supervisor/Application/Mix.Task callbacks; `CorsPlug` and `RateLimitPlug` Plug callbacks lacked `@impl Plug` (now fixed)         |
| 6  | Guard clauses for argument validation                             |   ✓    | `when is_integer(a) and is_integer(b)` in `MathService.add/2`                                                                                      |
| 7  | Pattern matching over conditionals                                |   ✓    | Router uses `with`, function clause matching throughout                                                                                            |
| 8  | `{:ok, result} \| {:error, reason}` convention                    |   ✓    | Used in parsers, Router `with` chain                                                                                                               |
| 9  | No bare `raise` in production code                                |   ✓    | `Application.start/2` uses `rescue` around file-logging setup                                                                                      |
| 10 | `defstruct` for typed data                                        |   ✓    | `SetmyInfo.CalculatorCli.Models.Input` and lessons `DataStructures.Person` use `defstruct`                                                         |
| 11 | Supervisor strategy chosen deliberately                           |   ✓    | `:one_for_one` is correct for independent HTTP server child                                                                                        |
| 12 | Application config via `Application.fetch_env!/2`                 |   ✓    | Port and server flag read from application env                                                                                                     |
| 13 | No hardcoded ports or paths in module body                        |   ✓    | Router uses `:code.priv_dir(:calculator_app)` — release-safe                                                                                       |
| 14 | `Plug.Logger` for request logging                                 |   ✓    | Present in the pipeline                                                                                                                            |
| 15 | Plug pipeline order: logger → static → parsers → match → dispatch |   ✓    | Correct order                                                                                                                                      |

---

### Testing

| #  | Check                                             | Status | Notes                                                                                                                       |
|----|---------------------------------------------------|:------:|-----------------------------------------------------------------------------------------------------------------------------|
| 1  | Unit tests cover all public functions             |   ✓    | `MathService`, parsers, and lesson modules all tested                                                                       |
| 2  | `doctest` matches implementation                  |   ✓    | `doctest SetmyInfo.Math.MathService` present and passes                                                                     |
| 3  | Integration tests use `Plug.Test` (no real HTTP)  |   ✓    | `conn(:post, …) \|> Router.call([])` pattern; YAML/TOML file parsing tests                                                  |
| 4  | All HTTP status codes tested                      |   ✓    | 200, 400, 406, 415, 404 covered in router test                                                                              |
| 5  | `async: true` where safe                          |   ✓    | Router integration tests and unit lessons run async                                                                         |
| 6  | `setup` / `on_exit` for file cleanup              |   ✓    | Web app files restored after router tests; Cowboy server stopped after gherkin tests                                        |
| 7  | E2E tests go through a real HTTP server           |   ✓    | Gherkin test starts Cowboy on port 4006 and calls via `:httpc` over real TCP/IP                                             |
| 8  | BDD / Gherkin tests (White Bread + feature files) |   ✓    | `features/calculator.feature` + `CalculatorContext` + `test/gherkin/calculator_gherkin_test.exs`                            |
| 9  | Mutation testing (Muzak)                          |   ✓    | `.muzak.exs` config; `mix test.mutation` task; targets math and lessons modules                                             |
| 10 | Property-based tests (StreamData)                 |   ✓    | `stream_data ~> 1.1` dep; 5 properties in `MathServicePropertyTest` (commutativity, identity, associativity)                |
| 11 | Test tags (`@tag :slow`, `@tag :integration`)     |   ✓    | `:unit`, `:integration`, `:e2e`, `:gherkin`, `:slow`, `:property`, `:concurrent` tags used; documented in `test_helper.exs` |
| 12 | Test for concurrent requests                      |   ✓    | `@tag :concurrent` test in `RouterTest` spawns 30 parallel `Task.async` calls to `POST /api/add`                            |
| 13 | CLI argument validation test                      |   ✓    | Tests cover valid 2-arg, invalid 1-arg, and non-integer strings; `Integer.parse/1` replaces `String.to_integer/1`           |
| 14 | Dedicated test tasks per type                     |   ✓    | `mix test.unit`, `mix test.integration`, `mix test.e2e`, `mix test.gherkin`, `mix test.mutation`                            |

---

### Security

| #  | Check                                      | Status | Notes                                                                                                                           |
|----|--------------------------------------------|:------:|---------------------------------------------------------------------------------------------------------------------------------|
| 1  | Input type validation at API boundary      |   ✓    | Router checks `is_integer(a) and is_integer(b)` before calling service                                                          |
| 2  | No SQL injection surface                   |   ✓    | Ecto/SQLite present; all queries use Ecto's parameterised query API — no raw SQL surface                                        |
| 3  | No command injection surface               |   ✓    | No shell calls from user input                                                                                                  |
| 4  | Sobelow static security scan               |   ✓    | Dep added (`~> 0.13`, dev/test only); `.sobelow-conf` committed; `mix quality` runs sobelow                                     |
| 5  | Dependency vulnerability audit (mix_audit) |   ✓    | `mix_audit` added (`~> 2.1`, dev/test only); `mix deps.audit` available                                                         |
| 6  | Rate limiting                              |   ✓    | ETS-backed fixed-window per-IP limiter; 429 + `Retry-After` on exceed; `/api/*` only                                            |
| 7  | Authentication / authorisation             |   ✗    | All endpoints public                                                                                                            |
| 8  | Integer overflow handling                  |   ✓    | Router validates inputs are in int32 range (−2147483648 … 2147483647); response declared `int64`                                |
| 9  | CORS / CSRF protection                     |   ✓    | `CorsPlug` adds `Access-Control-Allow-*` headers; OPTIONS → 204; CSRF mitigated by `Content-Type: application/json` requirement |
| 10 | No secrets in source or config             |   ✓    | No credentials committed                                                                                                        |

---

### Logging and observability

| # | Check                                       | Status | Notes                                                                                                         |
|---|---------------------------------------------|:------:|---------------------------------------------------------------------------------------------------------------|
| 1 | File logging configured                     |   ✓    | `logger_file_backend` with rotation                                                                           |
| 2 | Log level configurable at runtime           |   ✓    | `CALCULATOR_LOG_LEVEL` env var read in `runtime.exs`                                                          |
| 3 | `request_id` in log metadata                |   ✓    | Declared in logger format                                                                                     |
| 4 | `request_id` set per request in `Plug.Conn` |   ✓    | `Plug.RequestId` assigns unique ID; `method`, `path`, `status`, `duration_ms` also in metadata                |
| 5 | Structured / machine-readable log format    |   ✓    | Spring Boot-like text format: `$date $timeZ [$level] [$node] $metadata- $message`; `utc_log: true` in `:live` env produces `2026-06-06 20:22:41.038Z` timestamps |
| 6 | Telemetry events for HTTP requests          |   ✓    | `Plug.Telemetry` emits `[:calculator_app, :http, :stop]`; `TelemetryHandler` logs method/path/status/duration |
| 7 | Log directory created before logger starts  |   ✓    | `ensure_log_directory!/0` called in `Application.start/2`                                                     |
| 8 | Sensitive data not logged                   |   ✓    | No credentials or tokens flow through the app                                                                 |

---

### Configuration management

| # | Check                                                             | Status | Notes                                                                                        |
|---|-------------------------------------------------------------------|:------:|----------------------------------------------------------------------------------------------|
| 1 | Separate `dev`, `test`, `live` configs                            |   ✓    | All four present plus `local` and `runtime`                                                  |
| 2 | Runtime config via `System.get_env/2` with defaults               |   ✓    | Port, log path, log level all have fallbacks                                                 |
| 3 | `System.fetch_env!/1` for mandatory vars in `live`                |   ✓    | `PORT` is required in live env                                                               |
| 4 | No secrets in `config/*.exs` files                                |   ✓    | All sensitive values delegated to env vars                                                   |
| 5 | `Application.fetch_env!/2` to read app config                     |   ✓    | Used in `Application.start/2`                                                                |
| 6 | `Config.Reader` / `Config.Provider` for file-based runtime config |   ✓    | `ConfigProvider` reads TOML at release boot; `priv/config/example.toml` documents the schema |
| 7 | `.gitignore` excludes `config/local.exs` and secrets              |   ✓    | `config/local.exs` is correctly committed — contains no secrets                              |

---

### Code formatting and style

| # | Check                                       | Status | Notes                                                                              |
|---|---------------------------------------------|:------:|------------------------------------------------------------------------------------|
| 1 | `.formatter.exs` configured                 |   ✓    | Covers `lib`, `test`, `config`                                                     |
| 2 | `.editorconfig` present                     |   ✓    | 2-space Elixir, LF, UTF-8, CRLF for `.cmd`                                         |
| 3 | `mix format --check-formatted` passes       |   ✓    | No known formatting drift                                                          |
| 4 | Credo configured                            |   ✓    | Dep added; `mix credo.report` task defined                                         |
| 5 | No `IO.inspect` / `IO.puts` in library code |   ✓    | Lesson tests use `IO.puts` intentionally for educational output                    |
| 6 | No unused variables or aliases              |   ✓    | Clean compile with `--warnings-as-errors`                                          |
| 7 | Module naming follows Elixir conventions    |   ✓    | `CalculatorApp`, `CalculatorRest`, `CalculatorCli`, `Math`, `Lessons` — consistent |
| 8 | File names match module names               |   ✓    | All files follow snake_case → CamelCase convention                                 |

---

### Summary scorecard

| Standard area      | Compliant | Partial | Missing | Score |
|--------------------|:---------:|:-------:|:-------:|-------|
| REST / HTTP        |    10     |    1    |    4    | 67 %  |
| OpenAPI 3.2        |    10     |    0    |    0    | 100 % |
| GraphQL            |     5     |    1    |    4    | 50 %  |
| Elixir / OTP       |    12     |    3    |    0    | 80 %  |
| Testing            |    14     |    0    |    0    | 100 % |
| Security           |     9     |    0    |    1    | 90 %  |
| Logging            |     8     |    0    |    0    | 100 % |
| Configuration      |     7     |    0    |    0    | 100 % |
| Style / formatting |     8     |    0    |    0    | 100 % |

**Top gaps by impact:**

1. ~~**`Plug.RequestId`**~~ — done; `Plug.RequestId` first in pipeline, ID in Logger metadata and response.
2. **405 Method Not Allowed** — one extra `match` clause; required by HTTP spec.
3. ~~**CORS headers**~~ — done; `CorsPlug` + OPTIONS 204 preflight.
4. **`servers` in OpenAPI spec** — one field; required for Swagger UI to work against non-default origins.
5. ~~**Sobelow**~~ — done (dep added, `.sobelow-conf` committed, `mix quality` integration). `mix deps.audit` also
   added.
6. **`operationId` in OpenAPI** — one string per operation; required for client code generation.
7. ~~**Real E2E test**~~ — done via Gherkin (starts real Cowboy server on port 4006, calls via `:httpc`).
8. ~~**`Plug.Telemetry`**~~ — done; `TelemetryHandler` logs method/path/status/duration per request.
9. **Introspection guard in `live` env** — one Absinthe option; prevents schema disclosure.

## Directory structure, Elixir standards, and de facto conventions

This section compares the PoC/second layout and code against three reference points:

- **Mix official** — what `mix new` produces and what the Elixir docs mandate
- **Elixir official** — language-level conventions from the Elixir style guide and core docs
- **De facto** — what the Elixir ecosystem (Phoenix, Ecto, Hex packages) treats as standard

---

### Directory and file layout

#### Reference: standard single-app Mix project

```
my_app/                        ← project root
├── config/
│   ├── config.exs             ← shared config (mandatory)
│   ├── dev.exs
│   ├── test.exs
│   └── runtime.exs            ← runtime config (read after app start)
├── lib/
│   ├── my_app.ex              ← optional root module
│   └── my_app/                ← ONE top-level dir matching the OTP app name
│       ├── application.ex
│       └── ...
├── priv/                      ← static assets, DB migrations, seeds (by convention)
│   └── static/
├── test/
│   ├── test_helper.exs        ← mandatory
│   └── my_app/                ← mirrors lib/ structure
│       └── ...
├── .formatter.exs
├── mix.exs
└── mix.lock
```

#### PoC/second actual layout vs standard

| Path                                           | Status | Issue                                                                                       |
|------------------------------------------------|:------:|---------------------------------------------------------------------------------------------|
| `config/config.exs`                            |   ✓    | Correct                                                                                     |
| `config/dev.exs`, `test.exs`, `runtime.exs`    |   ✓    | Correct                                                                                     |
| `config/local.exs`                             |   ✓    | Committed correctly — contains only `import_config "dev.exs"`, no secrets                   |
| `config/live.exs`                              |   ✓    | `live` is the deliberate internal standard for this project                                 |
| `lib/setmy_info/calculator_app/`               |   ✓    | `SetmyInfo.CalculatorApp.*` — matches `SetmyInfo.*` root namespace                          |
| `lib/setmy_info/calculator_rest/`              |   ✓    | `SetmyInfo.CalculatorRest.*` — REST layer under shared org namespace                        |
| `lib/setmy_info/calculator_cli/`               |   ✓    | `SetmyInfo.CalculatorCli.*` — CLI layer under shared org namespace                          |
| `lib/setmy_info/math/`                         |   ~    | `SetmyInfo.Math.*` — namespace correct; `MathService` sub-module still redundant            |
| `lib/setmy_info/lessons/`                      |   ✓    | `SetmyInfo.Lessons.*` — data types, data structures, algorithms and streams lessons         |
| `lib/setmy_info/yaml_parser.ex`                |   ✓    | `SetmyInfo.YamlParser` — YAML parsing wrapper following `{:ok, result} \| {:error, reason}` |
| `lib/setmy_info/toml_parser.ex`                |   ✓    | `SetmyInfo.TomlParser` — TOML parsing wrapper, mirrors YamlParser API                       |
| `lib/mix/tasks/`                               |   ✓    | Correct location for custom Mix tasks                                                       |
| `test/unit/`, `test/integration/`, `test/e2e/` |   ~    | Intentional separation; doesn't mirror `lib/` strictly                                      |
| `test/gherkin/`                                |   ✓    | BDD test runner that calls `WhiteBread.run/3` against `features/`                           |
| `test/support/`                                |   ✓    | White Bread context (`CalculatorContext`) compiled in test env                              |
| `test/fixtures/yaml/`                          |   ✓    | YAML fixture files: `config.yml`, `types.yml`, `multi_doc.yml`, `persons.yml`               |
| `test/fixtures/toml/`                          |   ✓    | TOML fixture files: `config.toml`, `types.toml`, `persons.toml`                             |
| `features/`                                    |   ✓    | Gherkin feature files: `calculator.feature`                                                 |
| `test/test_helper.exs`                         |   ✓    | Correct                                                                                     |
| `priv/static/`                                 |   ✓    | Assets served via `{:calculator_app, "priv/static"}` — release-safe                         |
| `scripts/`                                     |   ✓    | De facto standard across Elixir/Erlang projects                                             |
| `.formatter.exs`                               |   ✓    | Correct                                                                                     |
| `.editorconfig`                                |   ✓    | Correct                                                                                     |
| `.gitignore`                                   |   ✓    | All generated artefacts excluded                                                            |
| `coveralls.json`                               |   ✓    | Standard location for ExCoveralls config                                                    |
| `CHANGELOG.md`                                 |   ✓    | Keep a Changelog 1.1.0 format                                                               |
| `LICENSE`                                      |   ✓    | MIT 2026 Imre Tabur                                                                         |
| `.credo.exs`                                   |   ✓    | Generated with `mix credo gen.config`                                                       |
| `.sobelow-conf`                                |   ✓    | Router path set; false positive (`Traversal.FileModule`) documented and suppressed          |
| `.muzak.exs`                                   |   ✓    | Targets `lib/setmy_info/math/**/*.ex` and `lib/setmy_info/lessons/**/*.ex`                  |

### Elixir official standards

#### `mix.exs` required and recommended fields

| Field                                 | Status | Note                                                          |
|---------------------------------------|:------:|---------------------------------------------------------------|
| `app:`                                |   ✓    | `:calculator_app`                                             |
| `version:` (semver)                   |   ✓    | `"2.0.0"`                                                     |
| `elixir:` constraint                  |   ✓    | `"~> 1.18"`                                                   |
| `start_permanent: Mix.env() == :live` |   ✓    | Present — VM exits when root supervisor crashes in `live` env |
| `description:`                        |   ✓    | Added — required for Hex publishing                           |
| `package:`                            |   ✓    | Added — name, licenses, links, files                          |
| `deps: deps()`                        |   ✓    |                                                               |
| `docs:` configured                    |   ✓    | ExDoc output dir, main, source_url                            |
| `test_coverage:` configured           |   ✓    | ExCoveralls wired                                             |

### De facto community standards

#### Tooling de facto checklist

| Tool / file                        | Status | Note                                                                  |
|------------------------------------|:------:|-----------------------------------------------------------------------|
| `.formatter.exs`                   |   ✓    | Present and covers all Elixir paths                                   |
| `.editorconfig`                    |   ✓    | Present with Elixir-correct indentation                               |
| `.credo.exs`                       |   ✓    | Generated with `mix credo gen.config`; rules and strictness pinned    |
| `mix.lock` committed               |   ✓    | Correct — reproducible builds                                         |
| `CHANGELOG.md`                     |   ✓    | Keep a Changelog 1.1.0 format                                         |
| `LICENSE`                          |   ✓    | MIT 2026 Imre Tabur                                                   |
| `.sobelow-conf`                    |   ✓    | Created; router and suppressed false positive documented              |
| `.muzak.exs`                       |   ✓    | Mutation testing config — targets math and lessons modules            |
| `coveralls.json`                   |   ✓    | `output_dir: "docs/coverage"` is configured                           |
| `mix_audit` in deps                |   ✓    | Added (`~> 2.1`, dev/test only)                                       |
| CI workflow (`.github/workflows/`) |   ✓    | `.github/workflows/ci.yml` — triggers on `PoC/second/**` path changes |

---

### Structure gap summary

| Category                                     | Compliant | Partial | Missing | Score |
|----------------------------------------------|:---------:|:-------:|:-------:|-------|
| Directory layout                             |    14     |    3    |    1    | 79 %  |
| `mix.exs` fields                             |     7     |    0    |    1    | 88 %  |
| Module attributes (`@impl`, `@spec`, `@doc`) |     3     |    4    |    2    | 44 %  |
| Namespace conventions                        |     3     |    2    |    2    | 50 %  |
| Mix task conventions                         |     5     |    0    |    0    | 100 % |
| Tooling files                                |     9     |    0    |    1    | 90 %  |

**Top structural gaps by impact:**

1. **`SetmyInfo.Math.MathService` → collapse to `SetmyInfo.Math` in `lib/setmy_info/math.ex`** — tracked as TODO in
   `@moduledoc`.
2. **`@spec` on all public module functions** — Router, Application, and task functions still lack specs.
3. **`SetmyInfo.CalculatorCli.Models.Input` → `SetmyInfo.CalculatorCli.Input`** — remove `Models` namespace layer.

## Remaining enhancements for PoC/second

Items 1–8 from the "Good examples" list above are all implemented.
The following three items remain:

| # | Item                                                 | Core concept                      |
|:-:|------------------------------------------------------|-----------------------------------|
| 9 | Hot code swap (`HotCode.load_from_source`)           | Runtime module reload (BEAM model)|
|10 | Protocol — `Calculable` for different numeric types  | Data-driven polymorphism          |
|11 | Subtract / multiply directly in `MathService`        | Extend existing layers uniformly  |

Note: subtract, multiply, and divide already exist as `Operation` behaviour
implementations (`Add`, `Subtract`, `Multiply`, `Divide`). Item 11 is about adding
them to `SetmyInfo.Math.MathService` directly so the pure math module is complete.
