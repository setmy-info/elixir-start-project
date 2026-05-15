# elixir-start-project

A production-oriented **Elixir umbrella project** by [setmy.info](https://setmy.info)
demonstrating OTP-first architecture, dynamic runtime execution, and clean module separation.

**Namespace convention:** `SetmyInfo.*` — mirrors the Java `info.setmy` reverse-domain
convention but in Elixir's `CamelCase` module form.

---

## Quick-reference commands

| Goal | Command |
|---|---|
| Install deps + compile | `mix build` |
| Compile only | `mix compile` |
| Validate (strict compile + format) | `mix validate` |
| Format code | `mix format` |
| Unit tests only | `mix test.unit` |
| Integration tests only | `mix test.integration` |
| E2E tests only | `mix test.e2e` |
| Gherkin BDD e2e tests only | `mix test.gherkin` |
| All tests | `mix test.all` |
| **Mutation testing** | `mix test.mutation` |
| **Unit-test coverage (HTML)** | `mix test.coverage` |
| **Generate API docs** | `mix docs` |
| **Dependency vulnerability audit** | `mix audit` |
| **Static security analysis** | `mix security` |
| **Full report suite** | `mix report` |
| Start GraphQL API server | `mix run --no-halt` |
| Build CLI escript | `cd apps/cli && mix escript.build` |

---

## Environments

| `MIX_ENV` | Purpose | Default? |
|---|---|---|
| *(unset)* | Maps to `local` automatically | Yes — Mix default |
| `local` | Developer's own machine | Yes (via default mapping) |
| `dev` | Shared development server | `MIX_ENV=dev mix run --no-halt` |
| `test` | Running tests manually | `MIX_ENV=test mix test` |
| `live` | Production / live server | `MIX_ENV=live mix run --no-halt` |
| `ci` | GitHub Actions CI pipeline | Set in `.github/workflows/ci.yml` |

When no `MIX_ENV` is set, Mix defaults to `:dev` — `config/config.exs` maps that to
`local.exs` so developers get the local config without any shell setup.

To permanently default to `local` in your shell:

```sh
echo 'export MIX_ENV=local' >> ~/.bashrc  # or ~/.zshrc
```

---

## Project structure

```
elixir-start-project/               ← umbrella root
├── apps/
│   ├── core_logic/                 SetmyInfo.CoreLogic.*
│   ├── runtime_engine/             SetmyInfo.RuntimeEngine.*
│   ├── graphql_api/                SetmyInfo.GraphqlApi.*
│   ├── cli/                        SetmyInfo.Cli.*
│   ├── wasm/                       SetmyInfo.Wasm.* (stub)
│   ├── lessons/                    SetmyInfo.Lessons.* ← Elixir learning examples
│   └── integration_tests/          SetmyInfo.IntegrationTests.*
├── config/                         Shared config per Mix env
├── features/                       Gherkin .feature files + White Bread config
├── .muzak.exs                      Mutation testing configuration
├── .sobelow-conf                   Static security analysis configuration
└── .github/workflows/ci.yml        GitHub Actions CI
```

### App dependency graph

```
core_logic  ←── runtime_engine ←── graphql_api
                      ↑                  ↑
                     cli        integration_tests
                     wasm
lessons (standalone — no production deps)
```

---

## Prerequisites

- Elixir 1.17+ (with OTP 27)
- Mix (bundled with Elixir)

Install via the included script:

```sh
sh install.sh elixir@latest otp@latest
# then add the printed export lines to your ~/.bashrc
```

Or via [asdf](https://asdf-vm.com/):

```sh
asdf install erlang 27.0
asdf install elixir 1.17.0-otp-27
```

---

## Build

```sh
# Fetch dependencies and compile
mix build

# Compile only (without fetching deps)
mix compile
```

---

## Validation

```sh
# Compile with warnings-as-errors AND check formatting
mix validate

# Check formatting alone
mix format --check-formatted

# Auto-fix formatting
mix format
```

---

## Running tests

The `test.unit`, `test.integration`, `test.e2e`, `test.gherkin`, and `test.all` aliases
automatically run under `MIX_ENV=test` via `preferred_envs` in `mix.exs` — no prefix needed.

### Unit tests (all apps including lessons)

```sh
mix test.unit
```

### Integration tests only

```sh
mix test.integration
```

The integration tests start the full OTP supervision tree and exercise the real
load → execute → release lifecycle against live processes — no mocks.

### E2E tests only

```sh
mix test.e2e
```

E2E tests follow the same lifecycle as Maven's pre-integration-test / integration-test /
post-integration-test phases:

1. **Pre** — `setup_all` starts a real Cowboy HTTP server on port 4003.
2. **Test** — tests send HTTP POST requests to `/graphql` using Erlang's built-in `:httpc`.
3. **Post** — `on_exit` shuts the server down after the suite finishes.

This verifies the full stack: HTTP → Plug router → Absinthe schema → RuntimeEngine →
Math module.

### Gherkin BDD e2e tests only

```sh
mix test.gherkin
```

BDD scenarios are written in Gherkin (`.feature` files under `features/`) and executed
via [White Bread](https://github.com/meadsteve/white-bread). The server lifecycle
(start/stop) is managed by an ExUnit `setup_all`/`on_exit` wrapper in
`apps/integration_tests/test/e2e/graphql_gherkin_test.exs` — the Gherkin context
(`GraphqlApiContext`) contains only pure step definitions, no server management.

The Gherkin test runs on port 4004 (separate from the plain ExUnit e2e port 4003) so
both suites can coexist in `mix test.all`.

### All tests (unit + integration + e2e + Gherkin)

```sh
mix test.all
# or equivalently:
mix test
```

### Run a single app's tests directly

```sh
cd apps/runtime_engine && mix test
cd apps/integration_tests && mix test
```

---

## Lessons app

`apps/lessons/` is a standalone learning module containing executable Elixir examples
structured as ExUnit tests. The test runner is the execution environment — each test
prints output to stdout **and** asserts the expected value.

```sh
# Run all lessons
mix test apps/lessons/test

# Run a specific lesson
mix test apps/lessons/test/lessons/data_types_test.exs
```

### Lessons covered

| File | Topics |
|---|---|
| `data_types_test.exs` | Booleans, integers (binary/octal/hex), floats, atoms, strings, nil, charlists |
| `data_structures_test.exs` | Tuples, lists, maps, keyword lists, **structs (data class replacement)**, Date/DateTime |
| `flow_control_test.exs` | `if/else`, `unless`, `cond` (if-elsif-else), `case`, `with`, `for` (comprehension), tail recursion (while substitute) |
| `operators_test.exs` | Arithmetic `+−×÷`, comparison `==`/`===`, logical `and/or/&&/\|\|`, `<>`, `++/--`, pattern match `=`, pipe `\|>` |
| `bitwise_ops_test.exs` | Bitwise `&&&/\|\|\|/^^^/~~~`, shifts `<<</>>>`, flag operations, RGB packing, IPv4 binary parsing, XOR cipher, popcount |
| `functions_test.exs` | Named functions, multi-clause dispatch, defaults, anonymous functions, higher-order, closures, captures, recursion |
| `algorithms_test.exs` | Fibonacci (naive/tail-recursive/stream), factorial, sum/max/min, binary search, flatten, reverse, palindrome, GCD/LCM, prime |
| `collections_test.exs` | `Enum.map/filter/reduce/any?/all?/sort/zip/group_by`, `Map.*`, lazy `Stream` |

---

## YAML parsing (Task 7)

YAML support is provided by `SetmyInfo.CoreLogic.YamlParser`, a thin wrapper around
[yaml_elixir](https://hex.pm/packages/yaml_elixir) (backed by the Erlang `yamerl` NIF).

```elixir
alias SetmyInfo.CoreLogic.YamlParser

# Parse a YAML string
{:ok, config} = YamlParser.parse("host: localhost\nport: 4000\n")

# Parse a YAML file
{:ok, data} = YamlParser.parse_file("/path/to/config.yml")

# Multi-document YAML (--- separator)
{:ok, [doc1, doc2, doc3]} = YamlParser.parse_all(multi_doc_string)
```

### YAML → Elixir type mapping

| YAML | Elixir |
|---|---|
| `string` / bare word | `String.t()` |
| `42` / `-17` | `integer()` |
| `3.14` / `1.5e3` | `float()` |
| `true` / `false` | `boolean()` |
| `~` / `null` | `nil` |
| `- item` sequence | `list()` |
| `key: value` mapping | `map()` (string keys) |
| `\|` literal block | multi-line string with `\n` |
| `>` folded block | single-line string |
| `&anchor` / `*alias` | shared Elixir value |

### Fixture files

YAML fixture files live in `apps/integration_tests/test/fixtures/yaml/`:

| File | Demonstrates |
|---|---|
| `config.yml` | Application config with nested maps and feature flags |
| `persons.yml` | List of person records → Ecto changeset hydration |
| `types.yml` | All YAML types, multi-line strings, anchors/aliases |
| `multi_doc.yml` | Multi-document YAML with `---` separators |

### Integration tests

```sh
mix test.integration
# or directly:
mix test apps/integration_tests/test/integration/yaml_parsing_test.exs
```

---

## Mutation testing (Task 2)

Mutation testing modifies source code (flips operators, removes branches, changes values)
and re-runs unit tests to verify each mutation is "killed" (tests fail). A surviving
mutation reveals a gap in test coverage — the equivalent of PITEST / PIT for Maven.

**Tool:** [muzak](https://hex.pm/packages/muzak)

```sh
# Run mutation tests against production source files (unit tests only)
mix test.mutation
```

Configuration in `.muzak.exs` limits mutations to production code in `apps/*/lib/`
(not lessons or integration tests), mirroring Maven's `src/main/java` convention.

---

## Documentation generation (Task 3)

Elixir uses [ExDoc](https://hexdocs.pm/ex_doc/) — the equivalent of Javadoc.
Documentation is written in Markdown inside `@moduledoc` / `@doc` attributes and
includes `iex>` doctests.

```sh
# Generate HTML docs — output in doc/
mix docs

# View docs
open doc/index.html
```

All lesson modules include full `@moduledoc` and `@doc` coverage. The umbrella-wide
docs include a README entry point and per-app module groupings.

---

## Unit-test coverage (Task 4)

Coverage is measured with [ExCoveralls](https://github.com/parroty/excoveralls) — the
Elixir equivalent of JaCoCo.

```sh
# HTML coverage report — output in cover/
mix test.coverage

# View report
open cover/excoveralls.html

# Summary only (terminal)
mix coveralls

# With per-line detail
mix coveralls.detail
```

Coverage is measured for all unit-tested apps (`core_logic`, `runtime_engine`,
`graphql_api`, `cli`, `wasm`, `lessons`).

---

## Running the GraphQL API server

```sh
mix run --no-halt
```

The server starts on **port 4000** and exposes the GraphQL endpoint at `/graphql`.

### Try it with curl

```sh
# Add two numbers: 2 + 3
curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ add(a: 2, b: 3) }"}' | jq .
# => { "data": { "add": 5 } }

# Multiply: 3 × 4
curl -s -X POST http://localhost:4000/graphql \
  -H "Content-Type: application/json" \
  -d '{"query": "{ multiply(a: 3, b: 4) }"}' | jq .
# => { "data": { "multiply": 12 } }
```

### Try it in the browser (GraphiQL)

Open `http://localhost:4000/graphql` in a browser — Absinthe serves an interactive
GraphiQL IDE at that URL automatically.

### Available queries

```graphql
{
  add(a: 2, b: 3)       # returns 5
  multiply(a: 3, b: 4)  # returns 12
}
```

---

## Running the CLI

```sh
cd apps/cli
mix escript.build

./cli add 2 3        # => 2 + 3 = 5
./cli multiply 3 4   # => 3 * 4 = 12
./cli --help
```

---

## Interactive REPL

```sh
iex -S mix

iex> SetmyInfo.RuntimeEngine.Executor.run_and_release(:math_module, :add, [2, 3])
{:ok, 5}

iex> SetmyInfo.RuntimeEngine.Loader.list_loaded()
[]
```

---

## Security and dependency analysis (Task 6)

These tools are the Elixir equivalents of Maven's OWASP DependencyCheck and
FindSecBugs/SpotBugs.

### Dependency vulnerability audit

[mix_audit](https://github.com/mirego/mix_audit) checks all Hex dependencies against
the [Elixir security advisories database](https://github.com/dependabot/elixir-security-advisories).

```sh
# Check for known CVEs in dependencies
mix audit
# or directly:
mix deps.audit
```

### Static security analysis

[Sobelow](https://github.com/nccgroup/sobelow) performs static analysis of Elixir/Plug
code for common web vulnerabilities (XSS, SQL injection, directory traversal, etc.).

```sh
# Run security analysis
mix security
# or directly:
mix sobelow --config
```

Configuration is in `.sobelow-conf`.

### Full report suite (Maven Site equivalent)

Elixir has no single `mvn site` equivalent, but the `mix report` alias generates all
reports in sequence:

```sh
# Generates:
#   doc/            — ExDoc HTML documentation
#   cover/          — ExCoveralls HTML coverage report
#   stdout          — dependency audit results
mix report
```

| Maven | Elixir |
|---|---|
| Javadoc | `mix docs` → `doc/` |
| JaCoCo HTML | `mix test.coverage` → `cover/` |
| OWASP DependencyCheck | `mix audit` |
| SpotBugs / FindSecBugs | `mix security` |
| PITEST mutation testing | `mix test.mutation` |
| Maven Site | `mix report` (docs + coverage + audit) |

---

## Architecture

### OTP supervision tree

```
SetmyInfo.RuntimeEngine.ApplicationSupervisor   (one_for_one)
├── SetmyInfo.RuntimeEngine.Registry            (built-in Registry)
└── SetmyInfo.RuntimeEngine.Supervisor          (rest_for_one)
    ├── SetmyInfo.RuntimeEngine.ModuleRegistry  (GenServer + ETS — all known specs)
    ├── SetmyInfo.RuntimeEngine.DynamicSupervisor
    └── SetmyInfo.RuntimeEngine.Loader          (GenServer + ETS — loaded instances)

SetmyInfo.CoreLogic.ApplicationSupervisor       (one_for_one)
└── SetmyInfo.CoreLogic.Supervisor

SetmyInfo.GraphqlApi.Supervisor                 (one_for_one)
└── Plug.Cowboy                                 (HTTP server on port 4000)

SetmyInfo.Wasm.ApplicationSupervisor            (one_for_one)
└── SetmyInfo.Wasm.Supervisor                   (stub — ready for wasmex/Extism)
```

### Runtime module lifecycle

```
1. Loader.load(:math_module)
   → DynamicSupervisor starts a Worker process
   → Worker registers in Registry
   → Loader records {name, pid} in ETS

2. Worker.execute(:math_module, :add, [2, 3])  → {:ok, 5}
   → Registry lookup → GenServer.call → Modules.Math.execute(:add, [2, 3])

3. Loader.release(:math_module)
   → DynamicSupervisor terminates the Worker
   → Loader removes ETS entry
```

### Hot code reload (no Worker restart)

Because Workers dispatch via `apply(impl_module, :execute, ...)`, simply replacing
the BEAM code with `SetmyInfo.RuntimeEngine.HotCode.load_from_source/1` makes the
**same Worker process** use new code on the very next call:

```elixir
# v1: doubles the input
HotCode.load_from_source("""
  defmodule SetmyInfo.RuntimeEngine.Modules.DemoCalc do
    @behaviour SetmyInfo.RuntimeEngine.Module
    def name, do: :demo_calc
    def execute(:compute, [x]), do: {:ok, x * 2}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
""")
ModuleRegistry.register(:demo_calc, SetmyInfo.RuntimeEngine.Modules.DemoCalc)
Loader.load(:demo_calc)

Worker.execute(:demo_calc, :compute, [5])  # => {:ok, 10}

# v2: triples the input — hot swap, no Worker restart
HotCode.load_from_source("""
  defmodule SetmyInfo.RuntimeEngine.Modules.DemoCalc do
    @behaviour SetmyInfo.RuntimeEngine.Module
    def name, do: :demo_calc
    def execute(:compute, [x]), do: {:ok, x * 3}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
""")

Worker.execute(:demo_calc, :compute, [5])  # => {:ok, 15}  ← same PID!
```

---

## Namespace convention

| Java (info.setmy) | Elixir (SetmyInfo.*) |
|---|---|
| `info.setmy.core.Orchestrator` | `SetmyInfo.CoreLogic.Orchestrator` |
| `info.setmy.runtime.Loader` | `SetmyInfo.RuntimeEngine.Loader` |
| `info.setmy.api.Schema` | `SetmyInfo.GraphqlApi.Schema` |

Elixir module names are atoms — there is no classloader conflict, so reverse-domain
is not required. The `SetmyInfo` prefix serves purely as an organisational namespace.

---

## Future extensions

### Lua engine
Add [luerl](https://github.com/rvirding/luerl), implement `SetmyInfo.RuntimeEngine.Module`,
register with `ModuleRegistry`. No changes to Loader/Worker/Executor needed.

### WASM engine
Add [wasmex](https://github.com/tessi/wasmex) or [Extism](https://extism.org/docs/integrate-into-a-host-app/elixir),
implement the Module behaviour. `SetmyInfo.Wasm.Engine` already provides the skeleton.

### Hot reload from disk
```elixir
SetmyInfo.RuntimeEngine.HotCode.load_from_file("/opt/modules/my_module")
Loader.reload(:my_module)
```
