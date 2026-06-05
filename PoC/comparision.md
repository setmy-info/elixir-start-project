# PoC Comparison: first vs second

## What each PoC demonstrates

### PoC/first — Umbrella OTP platform

Multi-app umbrella (`cli`, `core_logic`, `graphql_api`, `integration_tests`, `lessons`,
`runtime_engine`, `wasm`). The central idea is a **dynamic module loading engine**:
modules are registered by name, loaded on demand as isolated GenServer Workers under a
DynamicSupervisor, dispatched through an ETS-backed registry, and can be hot-swapped at
runtime without restarting the VM. Everything else (GraphQL, CLI, DB, scripts) is wired
on top of that engine.

### PoC/second — Single-app layered service (add only)

Flat single-app (`calculator_app`) with a clean three-layer architecture:
`SetmyInfo.Math.MathService` (pure logic) → `SetmyInfo.CalculatorRest.Router` (Plug REST) +
`SetmyInfo.CalculatorRest.Schema` (Absinthe GraphQL) + `SetmyInfo.CalculatorRest.Swagger` (OpenAPI 3.2) +
`SetmyInfo.CalculatorCli.Main` (escript). Static web frontend served on the same port.
Custom Mix tasks. Logger with file backend. Credo static analysis.

---

## Feature matrix

| Feature                                            | first | second |
|----------------------------------------------------|:-----:|:------:|
| OTP umbrella (multi-app)                           |   ✓   |   —    |
| GenServer Worker per loaded module                 |   ✓   |   —    |
| DynamicSupervisor for Workers                      |   ✓   |   —    |
| ETS table (public, named, read_concurrency)        |   ✓   |   —    |
| Registry (via-tuple process lookup)                |   ✓   |   —    |
| ModuleRegistry (ETS-backed spec store)             |   ✓   |   —    |
| Hot code swap (load_from_source / load_from_beam)  |   ✓   |   —    |
| Behaviour definition (`Module` behaviour)          |   ✓   |   —    |
| Ecto Repo + SQLite + migrations                    |   ✓   |   —    |
| Ecto schema (`Person`) + context (`Persons`)       |   ✓   |   —    |
| YAML parsing (yaml_elixir / yamerl)                |   ✓   |   —    |
| TOML parsing (toml library)                        |   ✓   |   —    |
| Gherkin / BDD tests (White Bread)                  |   ✓   |   —    |
| Feature files (`.feature`)                         |   ✓   |   —    |
| Lessons app (algorithms, collections, data types…) |   ✓   |   —    |
| Bitwise operations                                 |   ✓   |   —    |
| WASM engine stub                                   |   ✓   |   —    |
| Standalone Elixir scripts (BEAM lifecycle)         |   ✓   |   —    |
| Mutation testing (Muzak)                           |   ✓   |   —    |
| Sobelow security scan                              |   ✓   |   —    |
| Multiply / subtract in math module                 |   ✓   |   —    |
| REST API (Plug.Router)                             |   ✓   |   ✓    |
| GraphQL (Absinthe)                                 |   ✓   |   ✓    |
| CLI escript                                        |   ✓   |   ✓    |
| Content-type negotiation (415 / 406)               |   —   |   ✓    |
| Swagger / OpenAPI 3.2                              |   —   |   ✓    |
| Static web frontend (HTML + CSS + JS)              |   —   |   ✓    |
| GraphiQL interactive UI                            |   —   |   ✓    |
| Custom Mix tasks (Mix.Task modules)                |   —   |   ✓    |
| Credo static analysis                              |   —   |   ✓    |
| Logger with file backend                           |   —   |   ✓    |
| Structured input model (defstruct for CLI)         |   —   |   ✓    |
| `doctest` in unit tests                            |   —   |   ✓    |

---

## Good examples not yet in PoC/second

Listed from highest to lowest learning value for someone studying Elixir patterns.
Each item describes **what to implement**, **which Elixir concept it teaches**, and
**how it fits** the calculator domain.

---

### 1. GenServer with state — stateful calculation history

**What:** A `SetmyInfo.CalculatorApp.History` GenServer that stores the last N operations and
their results in its state. Expose `add_entry/3`, `last/0`, `all/0`, `clear/0`.

**Teaches:**

- `use GenServer` callbacks (`init/1`, `handle_call/3`, `handle_cast/2`)
- GenServer state as plain maps
- Named registration (`name: __MODULE__`)
- Difference between `call` (synchronous reply) and `cast` (fire-and-forget)
- Supervision: start it as a child in `SetmyInfo.CalculatorApp.Application`

**Calculator fit:** Every `/api/add` call appends `{a, b, result, timestamp}` to the
history. New route `GET /api/history` returns the list.

---

### 2. ETS table — calculation result cache

**What:** A `SetmyInfo.CalculatorApp.Cache` module that wraps a named ETS table. On a cache hit
(same `{a, b}` pair seen before) the Router returns the stored result without calling
`MathService`. On a miss it computes, stores, and returns.

**Teaches:**

- `:ets.new/2`, `:ets.lookup/2`, `:ets.insert/2`
- Table options: `:named_table`, `:public`, `:set`, `read_concurrency: true`
- Bypassing a GenServer mailbox for reads (same pattern as first PoC's Loader)
- Ownership: ETS table must be created in a supervised process (e.g. a GenServer or
  the Application `start/2`) so it survives caller crashes

**Calculator fit:** Caching `{2, 3} → 5` avoids recomputing repeated calls, which also
makes the performance difference between cached and uncached requests testable.

---

### 3. Registry — named worker lookup

**What:** Start a `Registry` in the supervision tree. When the History GenServer starts,
register it under a logical name (e.g. `{:calculator, :history}`). Look it up by name
from the Router without holding a direct PID.

**Teaches:**

- `Registry.start_link/1` and `{:via, Registry, {name, key}}` pattern
- Decoupling caller from PID lifecycle (PID changes on restart; Registry key stays)
- `Registry.lookup/2` vs `GenServer.whereis/1`
- Why this matters in supervision trees

**Calculator fit:** The Router fetches the history worker via Registry instead of a
module alias, demonstrating real-world process discovery.

---

### 4. Behaviour definition — pluggable operation modules

**What:** Define a `SetmyInfo.CalculatorApp.Operation` behaviour with callbacks `name/0` and
`execute/2`. Implement it for `Add`, `Subtract`, `Multiply`, `Divide`. A dispatcher
selects the right implementation by name.

**Teaches:**

- `@behaviour`, `@callback`, `@impl`
- Compile-time enforcement of callbacks
- Polymorphism through behaviours (vs protocols, which are data-driven)
- How first PoC's `SetmyInfo.RuntimeEngine.Module` behaviour works

**Calculator fit:** `MathService` becomes a thin dispatcher; each operation is a
separate module, making it trivial to add new operations without changing existing code.

---

### 5. OTP supervisor tree — multi-level supervision

**What:** Add a second supervisor level. Create `SetmyInfo.CalculatorApp.ServiceSupervisor` that
supervises the Cache GenServer and the History GenServer. The Application supervisor
supervises `ServiceSupervisor` (the `:rest_for_one` strategy) and optionally Cowboy.

**Teaches:**

- Multi-level supervision trees
- `:one_for_one` vs `:rest_for_one` vs `:one_for_all` — why the strategy choice
  matters (History crash should not kill the Cache)
- `Supervisor.child_spec/2` and `child_id` collisions
- How first PoC's nested supervisor (`Application → Supervisor → DynamicSupervisor`)
  is structured

---

### 6. Task — parallel computation

**What:** A `SetmyInfo.CalculatorApp.Parallel` module that accepts a list of `{a, b}` pairs and
computes all results concurrently using `Task.async/1` + `Task.await/2` (or
`Task.async_stream/3`).

**Teaches:**

- `Task.async` / `Task.await` and the calling-process link
- `Task.async_stream` for bounded concurrency with backpressure
- `Task.Supervisor.async_nolink` for fire-and-forget without crashing the caller
- Error handling: what happens when a Task raises
- New route: `POST /api/add/batch` accepts `[{a, b}]`, returns `[result]`

---

### 7. Agent — shared mutable state (simple alternative to GenServer)

**What:** A `SetmyInfo.CalculatorApp.RunningTotal` Agent that keeps a running sum. Operations:
`add/1` (accumulate), `get/0` (current total), `reset/0`.

**Teaches:**

- `Agent.start_link/2`, `Agent.get/2`, `Agent.update/2`, `Agent.get_and_update/2`
- When to choose Agent over GenServer (no custom message handling needed)
- Agent is a thin wrapper around a GenServer; same OTP guarantees apply
- New route: `GET /api/total` returns the accumulated sum

---

### 8. Ecto + SQLite — persist calculation results

**What:** Add `ecto_sqlite3` and define an `CalculationResult` schema with fields
`a`, `b`, `result`, `inserted_at`. Persist every `/api/add` call. Add
`GET /api/results` returning the last 20 rows.

**Teaches:**

- `use Ecto.Schema`, `@primary_key`, `belongs_to`
- `Ecto.Changeset` for validation (reject non-integers before hitting the DB)
- `Repo.insert/1`, `Repo.all/1` with `order_by` and `limit`
- Migrations (`mix ecto.gen.migration`, `mix ecto.migrate`)
- How first PoC stores Person records in the same SQLite adapter

---

### 9. YAML and TOML config parsing

**What:** Add `yaml_elixir` and `toml` as deps. Load calculator configuration
(port, log level, cache TTL, max history length) from `config/config.yaml` at
application start using `YamlParser` and `TomlParser` wrappers identical to first PoC.

**Teaches:**

- Wrapping third-party libraries in `{:ok, result} | {:error, reason}` conventions
- `@spec` and `@doc` on public functions
- Multi-document YAML (`---` separator)
- TOML's native datetime / integer literal types
- `Application.put_env/3` for runtime config injection from parsed files

---

### 10. Gherkin / BDD tests

**What:** Add `white_bread` and a `features/calculator.feature` file with scenarios
covering the add endpoint over HTTP. Write a `CalculatorContext` module with
`given_/when_/then_` steps.

**Teaches:**

- Behaviour-driven development vocabulary (Given/When/Then)
- How White Bread maps regex step patterns to Elixir functions
- When to use BDD tests vs ExUnit integration tests
- Writing feature files that non-developers can read
- Matches the Gherkin pattern already in first PoC's `features/graphql_api.feature`

---

### 11. Hot code swap — reload MathService at runtime

**What:** Port `HotCode` from first PoC into second PoC. Add a Mix task
`mix calculator.reload` that compiles a new version of `SetmyInfo.Math.MathService` from source
and loads it into the running VM with `Code.compile_string/1` without restarting the
application.

**Teaches:**

- The BEAM's two-version module model (current + old)
- `:code.load_binary/3`, `:code.soft_purge/1`
- `Code.put_compiler_option(:ignore_module_conflict, true)` to silence the redefine
  warning during hot swap
- Why hot swaps are safe for stateless modules (no Worker state to migrate) vs
  stateful GenServers (need `code_change/3`)

---

### 12. Protocol — Calculable for different numeric types

**What:** Define a `SetmyInfo.CalculatorApp.Calculable` protocol with `to_number/1`. Implement
it for `Integer`, `Float`, and `BitString` (parses string to integer). Update
`MathService.add/2` to call `Calculable.to_number/1` before computing.

**Teaches:**

- `defprotocol` and `defimpl`
- Protocol dispatch vs behaviour dispatch (data-driven vs module-driven)
- Protocol consolidation in production builds
- Extending existing types without modifying them (`defimpl` for `BitString`)
- How first PoC uses behaviours for module plugins; how protocols would differ

---

### 13. Standalone Elixir scripts

**What:** Add `scripts/add.exs` — a standalone script that takes two integer arguments,
calls `SetmyInfo.Math.MathService.add/2` inline (no running app), and prints the result. Also
demonstrate BEAM lifecycle: compile a helper module at startup, use it, purge it.

**Teaches:**

- `#!/usr/bin/env elixir` shebang execution
- `System.argv/0` for argument parsing
- `Code.compile_file/2` and `:code.load_abs/1`
- `:code.purge/1` / `:code.delete/1` for cleanup
- The difference between running inside a Mix project vs a standalone script
- Matches `scripts/hello.exs` pattern from first PoC

---

### 14. Subtract and multiply operations

**What:** Add `subtract/2` and `multiply/2` to `SetmyInfo.Math.MathService`, expose them on
the REST API (`POST /api/subtract`, `POST /api/multiply`), the GraphQL schema
(`:subtract`, `:multiply` fields), and the CLI (`calculator_app add 2 3`,
`calculator_app multiply 2 3`).

**Teaches:**

- Extending an existing clean API across all layers consistently
- Function clause guards for different arities
- How first PoC's `SetmyInfo.RuntimeEngine.Modules.Math` implements all three with
  pattern-matched clauses
- GraphQL field addition without schema breaking changes

---

### 15. Mutation testing (Muzak)

**What:** Add `{:muzak, "~> 1.0", only: :test}` and a `.muzak.exs` config. Run
`mix muzak` against `SetmyInfo.Math.MathService` to see how many mutants survive undetected.

**Teaches:**

- What mutation testing is and why 100% line coverage can still miss bugs
- Muzak's mutation operators (arithmetic operator swap, boundary conditions)
- Writing tests that are sensitive to operator mutations (test `a + b ≠ a - b`)
- How first PoC uses Muzak as part of its quality pipeline

---

## PoC/second correctness by standards

Compliance assessment of the current second PoC code against the standards each layer
claims to implement. Legend: ✓ = compliant, ~ = partial, ✗ = missing or wrong.

---

### REST / HTTP (RFC 7231, RFC 9110)

| #  | Check                                                           | Status | Notes                                                                                              |
|----|-----------------------------------------------------------------|:------:|----------------------------------------------------------------------------------------------------|
| 1  | Correct status codes for success (200)                          |   ✓    | `/api/add` returns 200                                                                             |
| 2  | 400 for malformed / missing fields                              |   ✓    | Missing `a`/`b` or non-integer returns 400                                                         |
| 3  | 406 for unacceptable `Accept` header                            |   ✓    | Enforced by `ensure_json_headers/2` plug                                                           |
| 4  | 415 for wrong `Content-Type`                                    |   ✓    | Enforced by `ensure_json_headers/2` plug                                                           |
| 5  | 404 for unknown routes                                          |   ✓    | `match _` catch-all returns JSON 404                                                               |
| 6  | 405 Method Not Allowed for wrong verb                           |   ✗    | `GET /api/add` falls through to 404 instead of 405                                                 |
| 7  | `Content-Type: application/json` on all JSON responses          |   ✓    | Set explicitly on every response                                                                   |
| 8  | Consistent error response shape (`{"error": "..."}`)            |   ✓    | All error paths use the same shape                                                                 |
| 9  | CORS headers for browser cross-origin requests                  |   ✗    | No `Access-Control-Allow-Origin` header; browser fetch from a different origin will be blocked     |
| 10 | `OPTIONS` preflight handling                                    |   ✗    | No preflight response; required when CORS is added                                                 |
| 11 | API versioning strategy                                         |   ✗    | Path is `/api/add` with no version segment; no `Accept: application/vnd.calculator.v2+json` either |
| 12 | `X-Request-Id` / `request_id` propagated to response            |   ✗    | Logger metadata includes `request_id` but it is not echoed back in response headers                |
| 13 | Idempotency — `POST /api/add` is not idempotent by definition   |   ~    | Correct HTTP verb; document that repeated calls with same body return same result (pure function)  |
| 14 | HTTPS support                                                   |   ✗    | Only HTTP; Cowboy 2 supports TLS but it is not configured                                          |
| 15 | Security headers (X-Content-Type-Options, X-Frame-Options, CSP) |   ✗    | None present; a Plug pipeline step is the right place to add them                                  |

---

### OpenAPI 3.2 / Swagger

| #  | Check                                                    | Status | Notes                                                                                                                         |
|----|----------------------------------------------------------|:------:|-------------------------------------------------------------------------------------------------------------------------------|
| 1  | Valid `openapi: "3.2.0"` field                           |   ✓    | Correct version string                                                                                                        |
| 2  | `info.title`, `info.version` present                     |   ✓    | Title and `"2.0"` version present                                                                                             |
| 3  | `servers` array with base URL                            |   ✗    | Missing `servers: [%{url: "http://localhost:4000"}]`; Swagger UI defaults to the page origin, which works but is not explicit |
| 4  | `operationId` on each operation                          |   ✗    | No `operationId` field; tooling that generates clients uses this                                                              |
| 5  | Response schemas for all documented codes                |   ~    | 200, 400, 406, 415 documented; 404 and 500 not documented                                                                     |
| 6  | Example values in schemas                                |   ✗    | No `example:` fields on schema properties                                                                                     |
| 7  | `$ref` component schemas for all request/response bodies |   ✓    | `AddRequest`, `AddResponse`, `ErrorResponse` all use `$ref`                                                                   |
| 8  | `required` fields listed on request schema               |   ✓    | `required: ["a", "b"]` present                                                                                                |
| 9  | `info.contact` and `info.license`                        |   ✗    | Not present; required for published APIs                                                                                      |
| 10 | Spec served at `/openapi.json` or `/swagger.json`        |   ~    | Served at `/swagger.json`; the OpenAPI 3 convention recommends `/openapi.json`                                                |

---

### GraphQL (GraphQL June 2018 spec, Absinthe conventions)

| #  | Check                                           | Status | Notes                                                                                                                                      |
|----|-------------------------------------------------|:------:|--------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | Schema has at least one `query` type            |   ✓    | `query do … end` block present                                                                                                             |
| 2  | Non-null fields and arguments where required    |   ✓    | `non_null(:integer)` on both args and return                                                                                               |
| 3  | Resolver returns `{:ok, value}`                 |   ✓    | Correct Absinthe resolver shape                                                                                                            |
| 4  | Error path returns `{:error, reason}`           |   ✗    | Resolver has no error clause; `MathService.add/2` never fails currently, but division by zero or overflow would crash the resolver process |
| 5  | Mutations defined for state-changing operations |   ~    | No mutations needed now; when Ecto is added, `createCalculation` should be a mutation, not a query                                         |
| 6  | Depth / complexity limiting                     |   ✗    | No `Absinthe.Plug` complexity or depth limits; an adversary can send deeply nested introspection queries                                   |
| 7  | Introspection disabled in production            |   ✗    | Introspection is always on; should be disabled or restricted in `live` env                                                                 |
| 8  | `@desc` on all fields and types                 |   ~    | Only the `add` field has `@desc`; the schema type itself has no description                                                                |
| 9  | Custom scalars for domain types                 |   ✗    | Using built-in `:integer`; a `BigInteger` scalar would be needed if results can exceed 32-bit range                                        |
| 10 | Authentication at resolver level                |   ✗    | No context-based auth check in any resolver                                                                                                |

---

### Elixir / OTP coding standards

| #  | Check                                                             |            Status            | Notes                                                                                                                          |
|----|-------------------------------------------------------------------|:----------------------------:|--------------------------------------------------------------------------------------------------------------------------------|
| 1  | `@moduledoc` on all public modules                                |              ✓               | Every module has `@moduledoc`                                                                                                  |
| 2  | `@doc` on all public functions                                    |              ~               | Public functions in Router have `@doc false` on private helpers; `MathService` and `Application` are fully documented          |
| 3  | `@spec` on all public functions                                   |              ~               | `MathService.add/2` has `@spec`; Router public functions (`call/2`, `init/1`) rely on Plug behaviour and have no explicit spec |
| 4  | `@type` for domain types                                          |              ✗               | No custom types defined; an `t()` type for `Input` struct would improve specs                                                  |
| 5  | `@impl true` on behaviour callbacks                               |              ✓               | Used on `Application.start/2`                                                                                                  |
| 6  | Guard clauses for argument validation                             |              ✓               | `when is_integer(a) and is_integer(b)` in `MathService.add/2`                                                                  |
| 7  | Pattern matching over conditionals                                |              ✓               | Router uses `with`, function clause matching throughout                                                                        |
| 8  | `{:ok, result}                                                    | {:error, reason}` convention | ✓                                                                                                                              | `MathService` implicitly (no errors); Router uses `with` |
| 9  | No bare `raise` in production code                                |              ✓               | `Application.start/2` uses `rescue` around file-logging setup                                                                  |
| 10 | `defstruct` for typed data                                        |              ✓               | `SetmyInfo.CalculatorCli.Models.Input` uses `defstruct`                                                                                  |
| 11 | Supervisor strategy chosen deliberately                           |              ✓               | `:one_for_one` is correct for independent HTTP server child                                                                    |
| 12 | Application config via `Application.fetch_env!/2`                 |              ✓               | Port and server flag read from application env                                                                                 |
| 13 | No hardcoded ports or paths in module body                        |              ✓               | `@web_app_dir` removed; router uses `:code.priv_dir(:calculator_app)` and `{:calculator_app, "priv/static"}` — both release-safe |
| 14 | `Plug.Logger` for request logging                                 |              ✓               | Present in the pipeline                                                                                                        |
| 15 | Plug pipeline order: logger → static → parsers → match → dispatch |              ✓               | `Plug.Logger` moved before `Plug.Static` — all requests including static file serving are now timed                            |

---

### Testing

| #  | Check                                            | Status | Notes                                                                                                                                              |
|----|--------------------------------------------------|:------:|----------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | Unit tests cover all public functions            |   ✓    | `MathService` has tests for positive, negative, zero, large values                                                                                 |
| 2  | `doctest` matches implementation                 |   ✓    | `doctest SetmyInfo.Math.MathService` present and passes                                                                                                      |
| 3  | Integration tests use `Plug.Test` (no real HTTP) |   ✓    | `conn(:post, …)                                                                                                                                    |> Router.call([])` pattern |
| 4  | All HTTP status codes tested                     |   ✓    | 200, 400, 406, 415, 404 covered in router test                                                                                                     |
| 5  | `async: true` where safe                         |   ✓    | Router integration tests run async                                                                                                                 |
| 6  | `setup` / `on_exit` for file cleanup             |   ✓    | Web app files restored after router tests                                                                                                          |
| 7  | E2E tests go through a real HTTP server          |   ✗    | E2E test calls `CalculatorCli.Main.main/1` in-process — identical to integration test; true E2E would start the server and call `curl` or `:httpc` |
| 8  | Property-based tests (StreamData)                |   ✗    | Not present; a property test `∀ a b: add(a,b) == b+a` would catch operator mutations                                                               |
| 9  | Test tags (`@tag :slow`, `@tag :integration`)    |   ✗    | No ExUnit tags; all tests run as one undifferentiated set                                                                                          |
| 10 | Test for concurrent requests                     |   ✗    | Not present; `async: true` means tests run in parallel but no test exercises concurrent calls to the same endpoint                                 |
| 11 | CLI argument validation test                     |   ~    | Tests cover valid 2-arg and invalid 1-arg; no test for non-integer strings, very large numbers, or negative inputs                                 |

---

### Security

| #  | Check                                      | Status | Notes                                                                                                                                                            |
|----|--------------------------------------------|:------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1  | Input type validation at API boundary      |   ✓    | Router checks `is_integer(a) and is_integer(b)` before calling service                                                                                           |
| 2  | No SQL injection surface                   |   ✓    | No database; not applicable                                                                                                                                      |
| 3  | No command injection surface               |   ✓    | No shell calls from user input                                                                                                                                   |
| 4  | Sobelow static security scan               |   ✓    | Added to deps (`~> 0.13`, dev/test only); `.sobelow-conf` committed with router path and one documented false-positive suppression                                                                                                                        |
| 5  | Dependency vulnerability audit (mix_audit) |   ✗    | Not in deps; first PoC includes it                                                                                                                               |
| 6  | Rate limiting                              |   ✗    | None; a single client can flood the service                                                                                                                      |
| 7  | Authentication / authorisation             |   ✗    | All endpoints public                                                                                                                                             |
| 8  | Integer overflow handling                  |   ✗    | Elixir integers are arbitrary precision; no overflow — but the Swagger schema declares `format: int32`, which would overflow if the result exceeds 2 147 483 647 |
| 9  | CORS / CSRF protection                     |   ✗    | No CORS headers; a forged form on another origin can POST to `/api/add`                                                                                          |
| 10 | No secrets in source or config             |   ✓    | No credentials committed                                                                                                                                         |

---

### Logging and observability

| # | Check                                       | Status | Notes                                                                        |
|---|---------------------------------------------|:------:|------------------------------------------------------------------------------|
| 1 | File logging configured                     |   ✓    | `logger_file_backend` with rotation                                          |
| 2 | Log level configurable at runtime           |   ✓    | `CALCULATOR_LOG_LEVEL` env var read in `runtime.exs`                         |
| 3 | `request_id` in log metadata                |   ✓    | Declared in logger format                                                    |
| 4 | `request_id` set per request in `Plug.Conn` |   ✗    | No `Plug.RequestId` plug in the pipeline; `request_id` is always nil in logs |
| 5 | Structured / machine-readable log format    |   ✗    | Plain string format; JSON logs would allow log aggregators to index fields   |
| 6 | Telemetry events for HTTP requests          |   ✗    | `Plug.Telemetry` not added; no duration/status metrics emitted               |
| 7 | Log directory created before logger starts  |   ✓    | `ensure_log_directory!/0` called in `Application.start/2`                    |
| 8 | Sensitive data not logged                   |   ✓    | No credentials or tokens flow through the app                                |

---

### Configuration management

| # | Check                                                             | Status | Notes                                                    |
|---|-------------------------------------------------------------------|:------:|----------------------------------------------------------|
| 1 | Separate `dev`, `test`, `live` configs                            |   ✓    | All four present plus `local` and `runtime`              |
| 2 | Runtime config via `System.get_env/2` with defaults               |   ✓    | Port, log path, log level all have fallbacks             |
| 3 | `System.fetch_env!/1` for mandatory vars in `live`                |   ✓    | `PORT` is required in live env                           |
| 4 | No secrets in `config/*.exs` files                                |   ✓    | All sensitive values delegated to env vars               |
| 5 | `Application.fetch_env!/2` to read app config                     |   ✓    | Used in `Application.start/2`                            |
| 6 | `Config.Reader` / `Config.Provider` for file-based runtime config |   ✗    | Not implemented; env vars only                           |
| 7 | `.gitignore` excludes `config/local.exs` and secrets              |   ✓    | `config/local.exs` is correctly committed — it contains no secrets, only `import_config "dev.exs"` |

---

### Code formatting and style

| # | Check                                       | Status | Notes                                                                            |
|---|---------------------------------------------|:------:|----------------------------------------------------------------------------------|
| 1 | `.formatter.exs` configured                 |   ✓    | Covers `lib`, `test`, `config`                                                   |
| 2 | `.editorconfig` present                     |   ✓    | 2-space Elixir, LF, UTF-8, CRLF for `.cmd`                                       |
| 3 | `mix format --check-formatted` passes       |   ✓    | No known formatting drift                                                        |
| 4 | Credo configured                            |   ✓    | Dep added; `mix credo.report` task defined                                       |
| 5 | No `IO.inspect` / `IO.puts` in library code |   ✓    | Only in `CalculatorCli.Main.main/1` (intentional CLI output)                     |
| 6 | No unused variables or aliases              |   ✓    | Clean compile with `--warnings-as-errors`                                        |
| 7 | Module naming follows Elixir conventions    |   ✓    | `CalculatorApp`, `CalculatorRest`, `CalculatorCli`, `Math` — consistent prefixes |
| 8 | File names match module names               |   ✓    | `calculator_rest/router.ex` → `SetmyInfo.CalculatorRest.Router`                            |

---

### Summary scorecard

| Standard area      | Compliant | Partial | Missing | Score |
|--------------------|:---------:|:-------:|:-------:|-------|
| REST / HTTP        |     8     |    1    |    6    | 53 %  |
| OpenAPI 3.2        |     4     |    1    |    5    | 45 %  |
| GraphQL            |     3     |    2    |    5    | 40 %  |
| Elixir / OTP       |    11     |    3    |    1    | 77 %  |
| Testing            |     6     |    1    |    4    | 59 %  |
| Security           |     3     |    0    |    7    | 30 %  |
| Logging            |     4     |    0    |    4    | 50 %  |
| Configuration      |     5     |    1    |    1    | 79 %  |
| Style / formatting |     8     |    0    |    0    | 100 % |

**Top gaps by impact:**

1. **`Plug.RequestId`** — one line in the pipeline; makes every log line traceable.
2. **405 Method Not Allowed** — one extra `match` clause; required by HTTP spec.
3. **CORS headers** — one Plug; required for any browser app on a different origin.
4. **`servers` in OpenAPI spec** — one field; required for Swagger UI to work against non-default origins.
5. ~~**Sobelow**~~ — done (dep added, `.sobelow-conf` committed). `mix_audit` still missing.
6. **`operationId` in OpenAPI** — one string per operation; required for client code generation.
7. **Real E2E test** — test that starts the HTTP server and calls it with `:httpc` or `Req`.
8. **`Plug.Telemetry`** — one plug; enables duration metrics for every request.
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

| Path                                           | Status | Issue                                                                                                                                                                                                                                                      |
|------------------------------------------------|:------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `config/config.exs`                            |   ✓    | Correct                                                                                                                                                                                                                                                    |
| `config/dev.exs`, `test.exs`, `runtime.exs`    |   ✓    | Correct                                                                                                                                                                                                                                                    |
| `config/local.exs`                             |   ✓    | Committed correctly — contains only `import_config "dev.exs"`, no secrets or machine-specific values; belongs in git alongside `dev.exs` and `test.exs`                                                                                                   |
| `config/live.exs`                              |   ✓    | `live` is the deliberate internal standard for this project; `:prod` is the community convention but not required — any env name works in Mix                                                                                                              |
| `lib/setmy_info/calculator_app/`               |   ✓    | `SetmyInfo.CalculatorApp.*` — matches `SetmyInfo.*` root namespace                                                                                                                                                                                         |
| `lib/setmy_info/calculator_rest/`              |   ✓    | `SetmyInfo.CalculatorRest.*` — REST layer under shared org namespace                                                                                                                                                                                       |
| `lib/setmy_info/calculator_cli/`               |   ✓    | `SetmyInfo.CalculatorCli.*` — CLI layer under shared org namespace                                                                                                                                                                                         |
| `lib/setmy_info/math/`                         |   ~    | `SetmyInfo.Math.*` — standalone namespace correct for extractable library; `MathService` sub-module is still redundant (see module naming table)                                                                                                           |
| `lib/mix/tasks/`                               |   ✓    | Correct location for custom Mix tasks                                                                                                                                                                                                                      |
| `test/unit/`, `test/integration/`, `test/e2e/` |   ~    | Intentional separation is useful; but it does **not** mirror `lib/` — standard is `test/setmy_info/calculator_rest/router_test.exs` mirroring `lib/setmy_info/calculator_rest/router.ex`                                                                   |
| `test/test_helper.exs`                         |   ✓    | Correct                                                                                                                                                                                                                                                    |
| `priv/static/`                                 |   ✓    | Moved from `web-app/`; router uses `{:calculator_app, "priv/static"}` and `:code.priv_dir/1` — correct for Mix releases                                                                                                                                   |
| `scripts/`                                     |   ✓    | De facto standard across Elixir/Erlang projects                                                                                                                                                                                                            |
| `docs/`                                        |   ✓    | Exists on disk (generated by `mix docs`) but **not tracked by git** — `.gitignore` entry works correctly                                                                                                                                                   |
| `log/calculator_app.log`                       |   ✓    | Exists on disk (written at runtime) but **not tracked by git** — `.gitignore` entry works correctly                                                                                                                                                        |
| `calculator_app` (binary)                      |   ✓    | Exists on disk (built by `mix escript.build`) but **not tracked by git** — `.gitignore` entry works correctly                                                                                                                                              |
| `.formatter.exs`                               |   ✓    | Correct                                                                                                                                                                                                                                                    |
| `.editorconfig`                                |   ✓    | Correct                                                                                                                                                                                                                                                    |
| `.gitignore`                                   |   ✓    | All generated artefacts (`docs/`, `log/`, `_build/`, `deps/`, `calculator_app` binary) are listed and correctly excluded — none are tracked by git                                                                                                         |
| `coveralls.json`                               |   ✓    | Standard location for ExCoveralls config                                                                                                                                                                                                                   |
| `CHANGELOG.md`                                 |   ✓    | Present — Keep a Changelog 1.1.0 format, versions from 2.0.0                                                                                                                                                                                               |
| `LICENSE`                                      |   ✓    | Present — MIT 2026 Imre Tabur                                                                                                                                                                                                                              |
| `.credo.exs`                                   |   ✓    | Generated with `mix credo gen.config`; rules and strictness are now pinned for all contributors                                                                                                                                                            |
| `.sobelow-conf`                                |   ✓    | Created; router path set to `lib/setmy_info/calculator_rest/router.ex`; one false positive (`Traversal.FileModule` on config-driven log dir) documented and suppressed                                                                                     |

### Elixir official standards

#### Module naming and file path matching (mandatory)

Elixir requires the file path under `lib/` to match the module name in snake_case.

| Module                       | File                                 | Status | Note                                                                                                                                                                                      |
|------------------------------|--------------------------------------|:------:|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `SetmyInfo.CalculatorApp.Application`  | `lib/setmy_info/calculator_app/application.ex`         |   ✓    |                                                                                 |
| `SetmyInfo.CalculatorRest.Router`      | `lib/setmy_info/calculator_rest/router.ex`             |   ✓    |                                                                                 |
| `SetmyInfo.CalculatorCli.Main`         | `lib/setmy_info/calculator_cli/main.ex`                |   ✓    |                                                                                 |
| `SetmyInfo.CalculatorCli.Models.Input` | `lib/setmy_info/calculator_cli/models/input.ex`        |   ~    | Path matches; `Models` is a Java-ism — prefer `SetmyInfo.CalculatorCli.Input`  |
| `SetmyInfo.Math.MathService`           | `lib/setmy_info/math/math_service.ex`                  |   ~    | Namespace correct for extractable library; `MathService` sub-module redundant — should be `SetmyInfo.Math` in `lib/setmy_info/math.ex` |
| `Mix.Tasks.Test.Unit`        | `lib/mix/tasks/test.unit.ex`         |   ✓    | Correct Mix task naming                                                                                                                                                                   |

#### `mix.exs` required and recommended fields

| Field                                 | Status | Note                                                                                                                                                                                             |
|---------------------------------------|:------:|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `app:`                                |   ✓    | `:calculator_app`                                                                                                                                                                                |
| `version:` (semver)                   |   ✓    | `"2.0.0"`                                                                                                                                                                                        |
| `elixir:` constraint                  |   ✓    | `"~> 1.18"`                                                                                                                                                                                      |
| `start_permanent: Mix.env() == :live` |   ✓    | Present — VM exits when root supervisor crashes in `live` env                                                                                                                                    |
| `description:`                        |   ✗    | Missing — required for Hex publishing                                                                                                                                                            |
| `package:`                            |   ✗    | Missing — required for Hex publishing                                                                                                                                                            |
| `deps: deps()`                        |   ✓    |                                                                                                                                                                                                  |
| `docs:` configured                    |   ✓    | ExDoc output dir and main set                                                                                                                                                                    |
| `test_coverage:` configured           |   ✓    | ExCoveralls wired                                                                                                                                                                                |

#### Module attributes (official Elixir style guide)

| Attribute                              | Status | Note                                                                                                                                                                                                                          |
|----------------------------------------|:------:|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `@moduledoc` on every public module    |   ✓    | All modules documented                                                                                                                                                                                                        |
| `@moduledoc false` on internal modules |   ~    | Mix task helper functions use `@doc false` but no module uses `@moduledoc false`                                                                                                                                              |
| `@doc` on every public function        |   ~    | `MathService` fully documented; Router private helpers have `@doc false`; Mix task `run/1` functions lack `@doc` in most tasks                                                                                                |
| `@spec` on every public function       |   ~    | Only `MathService.add/2` has `@spec`; all Router, Application, and task functions lack specs                                                                                                                                  |
| `@type t()` for struct types           |   ✓    | `SetmyInfo.CalculatorCli.Models.Input` now has `@type t() :: %__MODULE__{a: integer(), b: integer()}`                                                                                                                                  |
| `@impl true` on behaviour callbacks    |   ~    | `Application.start/2` has `@impl true`; Mix task `run/1` is missing `@impl Mix.Task` in `Server`, `Rest.Server`, `Test.Unit`, `Test.Integration`, `Test.E2e`, `Coveralls.Html`, `Credo.Report`, `Deps.Audit`, `Docs.Generate` |
| Aliases ordered alphabetically         |   ✓    | `SetmyInfo.CalculatorRest.Swagger` before `SetmyInfo.Math.MathService` — C before M                                                                                                                                          |

#### Elixir data conventions

| Convention                                                        | Status | Note                                                                                              |
|-------------------------------------------------------------------|:------:|---------------------------------------------------------------------------------------------------|
| `{:ok, result} \| {:error, reason}` return convention             |   ✓    | Used in Router `with` chain                                                                       |
| Pattern matching over `if`/`cond` for branching                   |   ✓    | `with`, function clauses, `case` used throughout                                                  |
| `!`-suffix functions raise instead of returning error tuple       |   ~    | Not needed here, but `Application.ensure_log_directory!/0` correctly uses the bang convention     |
| No bare atoms as error reasons — use descriptive atoms or structs |   ~    | Router returns `{:error, :bad_request}` implicitly via `send_bad_request` — actual atoms not used |
| Avoid `String.to_atom/1` on user input                            |   ✓    | Not present                                                                                       |
| No `apply/3` on user-supplied function names                      |   ✓    | Not present                                                                                       |

---

### De facto community standards

#### Namespace conventions (Phoenix / Elixir ecosystem)

The dominant de facto convention, established by Phoenix and followed by most major
Elixir projects, is two root namespaces per app:

```
lib/my_app/          ← business logic, contexts, schemas (no web coupling)
lib/my_app_web/      ← HTTP layer: controllers, routers, views, live views
```

| Convention                                                | PoC/second                             | Gap                                                                                                                                                                                       |
|-----------------------------------------------------------|----------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `SetmyInfo.*` root namespace for all modules              | ✓ all modules                          | Done — matches Java `info.setmy.*` reverse-domain convention                                                                                                                              |
| Extractable library: own namespace, no app coupling       | `SetmyInfo.Math.MathService`           | Namespace correct; `MathService` sub-module still redundant — tracked as TODO in `@moduledoc`                                                                                             |
| HTTP layer namespaced clearly                             | `SetmyInfo.CalculatorRest.*`           | ✓ Acceptable — `SetmyInfo.CalculatorRest` is clear and consistent                                                                                                                        |
| CLI layer namespaced clearly                              | `SetmyInfo.CalculatorCli.*`            | ✓ Acceptable — `SetmyInfo.CalculatorCli` is clear and consistent                                                                                                                         |
| No `Models` namespace                                     | `SetmyInfo.CalculatorCli.Models.Input` | `Models` is a Rails/Java-ism; prefer `SetmyInfo.CalculatorCli.Input`                                                                                                                     |
| No `Service` suffix                                       | `SetmyInfo.Math.MathService`           | `Service` is a Java-ism; callers write `SetmyInfo.Math.add/2`, not `SetmyInfo.Math.MathService.add/2`                                                                                    |

#### Static asset location

| Convention                                                                   | PoC/second     | Gap                                                                                                                                       |
|------------------------------------------------------------------------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| `priv/static/` for Plug.Static assets (Phoenix / Plug standard)              | `priv/static/` | ✓ Fixed — assets moved from `web-app/`; served via `{:calculator_app, "priv/static"}` |
| Assets served from `priv/` are accessible in releases via `:code.priv_dir/1` | `priv/static/` | ✓ Fixed — router uses `:code.priv_dir(:calculator_app)` for the index path               |

#### Context module pattern (Elixir/Phoenix de facto)

Context modules are the Elixir equivalent of a service layer — they expose a clean
public API for a bounded domain and hide internal details.

| Convention                                             | PoC/second         | Gap                                                                                                                                                                                          |
|--------------------------------------------------------|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Extractable library: own root namespace, no app prefix | `SetmyInfo.Math.MathService` | `Math` namespace is correct; but the module should be `Math` itself (in `lib/math.ex`), not a sub-module `SetmyInfo.Math.MathService` in `lib/math/math_service.ex` — the sub-module name adds nothing |
| No `Service` suffix                                    | `SetmyInfo.Math.MathService` | `Service` is a Java-ism; callers write `Math.add/2`, not `SetmyInfo.Math.MathService.add/2`                                                                                                            |
| Context hides schema / repo details                    | N/A yet            | Will matter when Ecto is added                                                                                                                                                               |
| One context per bounded domain                         | Implicit           | `Math`, `CLI`, `REST` are three separate domains — correct split                                                                                                                             |

#### Mix task conventions (de facto)

| Convention                                                                  | Status | Note                                                                                                                                         |
|-----------------------------------------------------------------------------|:------:|----------------------------------------------------------------------------------------------------------------------------------------------|
| `@shortdoc` one-liner on every task                                         |   ✓    | All tasks have it                                                                                                                            |
| `@moduledoc` explains options and examples                                  |   ✓    | Most tasks have it                                                                                                                           |
| `@impl Mix.Task` on `run/1`                                                 |   ✓    | Added to all 11 tasks                                                                                                                         |
| Tasks that wrap `mix test` delegate via `Mix.Task.run/2` not `System.cmd/3` |   ~    | `Test.Unit/Integration/E2e` use `Mix.Task.run` (correct); `Quality` uses `System.cmd` with an explicit env override (acceptable but heavier) |
| Deprecated tasks warn and delegate                                          |   ✓    | `Rest.Server` prints deprecation notice and delegates to `Server`                                                                            |
| Tasks in `lib/mix/tasks/` not in `lib/<app>/`                               |   ✓    | Correct                                                                                                                                      |

#### Tooling de facto checklist

| Tool / file                        | Status | Note                                                                             |
|------------------------------------|:------:|----------------------------------------------------------------------------------|
| `.formatter.exs`                   |   ✓    | Present and covers all Elixir paths                                              |
| `.editorconfig`                    |   ✓    | Present with Elixir-correct indentation                                          |
| `.credo.exs`                       |   ✓    | Generated with `mix credo gen.config`; rules and strictness pinned                |
| `mix.lock` committed               |   ✓    | Correct — reproducible builds                                                    |
| `CHANGELOG.md`                     |   ✓    | Present — Keep a Changelog 1.1.0 format, versions from 2.0.0                     |
| `LICENSE`                          |   ✓    | Present — MIT 2026 Imre Tabur                                                    |
| `.sobelow-conf`                    |   ✓    | Created; router and suppressed false positive documented                          |
| `coveralls.json`                   |   ✓    | Present; `output_dir: "docs/coverage"` is configured                             |
| `mix_audit` in deps                |   ✗    | Not present; first PoC includes it                                               |
| CI workflow (`.github/workflows/`) |   ✗    | Missing — first PoC has `ci.yml`; second PoC has no CI definition                |

---

### Structure gap summary

| Category                                     | Compliant | Partial | Missing | Score |
|----------------------------------------------|:---------:|:-------:|:-------:|-------|
| Directory layout                             |     8     |    4    |    5    | 47 %  |
| `mix.exs` fields                             |     5     |    0    |    3    | 63 %  |
| Module attributes (`@impl`, `@spec`, `@doc`) |     3     |    4    |    2    | 44 %  |
| Namespace conventions                        |     3     |    2    |    2    | 50 %  |
| Mix task conventions                         |     3     |    1    |    2    | 58 %  |
| Tooling files                                |     6     |    1    |    3    | 60 %  |

**Top structural gaps by impact:**

1. **`SetmyInfo.Math.MathService` → collapse to `SetmyInfo.Math` in `lib/setmy_info/math.ex`** — `MathService` sub-module is redundant; tracked as TODO in `@moduledoc`.
2. ~~**`web-app/` → move to `priv/static/`**~~ — done.
3. ~~**`@impl Mix.Task` on all task `run/1`**~~ — done (all 11 tasks).
4. ~~**`.credo.exs`**~~ — done.
5. ~~**`start_permanent: Mix.env() == :live`**~~ — done.
6. ~~**`config/local.exs` in `.gitignore`**~~ — not needed; file contains no secrets.
7. **`CI workflow`** — `.github/workflows/ci.yml` mirroring first PoC.
8. ~~**`CHANGELOG.md` and `LICENSE`**~~ — done.
9. **`SetmyInfo.CalculatorCli.Models.Input` → `SetmyInfo.CalculatorCli.Input`** — remove `Models` namespace layer.
10. ~~**`@type t()` on struct types**~~ — done (`SetmyInfo.CalculatorCli.Models.Input`).
11. **`@spec` on all public module functions** — Router, Application, and task functions still lack specs.

## Implementation priority

| Priority | Item                      | Core concept                     |
|:--------:|---------------------------|----------------------------------|
|    1     | Subtract / Multiply (#14) | Extend existing layers uniformly |
|    2     | Behaviour (#4)            | Pluggable modules, `@callback`   |
|    3     | GenServer history (#1)    | Stateful OTP process             |
|    4     | ETS cache (#2)            | Lock-free in-memory reads        |
|    5     | Registry (#3)             | Named process lookup             |
|    6     | Supervisor tree (#5)      | Multi-level OTP supervision      |
|    7     | Task batch (#6)           | Concurrent computation           |
|    8     | Agent total (#7)          | Simple shared state              |
|    9     | Ecto + SQLite (#8)        | Database persistence             |
|    10    | YAML / TOML (#9)          | Structured config parsing        |
|    11    | Gherkin tests (#10)       | BDD test layer                   |
|    12    | Standalone scripts (#13)  | BEAM script lifecycle            |
|    13    | Hot code swap (#11)       | Runtime module reload            |
|    14    | Protocol (#12)            | Data-driven polymorphism         |
|    15    | Mutation testing (#15)    | Test quality measurement         |
