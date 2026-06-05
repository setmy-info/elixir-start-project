# Calculator App

Small Elixir CLI app that adds two integers and prints the result.
It also includes a small REST layer for addition.

## Project structure

- `mix.exs` - project configuration, app metadata, and `escript` build setup
- `lib\setmy_info\calculator_cli\main.ex` - CLI entry point (`SetmyInfo.CalculatorCli.Main`)
- `lib\setmy_info\calculator_rest\router.ex` - REST endpoint for addition (`SetmyInfo.CalculatorRest.Router`)
- `lib\setmy_info\calculator_cli\models\input.ex` - input struct used by the CLI (`SetmyInfo.CalculatorCli.Models.Input`)
- `lib\setmy_info\math\math_service.ex` - math logic (`SetmyInfo.Math.MathService`)
- `lib\mix\tasks\server.ex` - recommended Mix task to start the shared web server
- `lib\mix\tasks\rest.server.ex` - backwards-compatible deprecated alias for the old server task name
- `lib\setmy_info\calculator_app\application.ex` - application supervisor (`SetmyInfo.CalculatorApp.Application`)
- `lib\setmy_info\calculator_rest\swagger.ex` - Swagger/OpenAPI document and Swagger UI support (`SetmyInfo.CalculatorRest.Swagger`)
- `scripts\calculator_app.cmd` - Windows launcher for the built CLI
- `scripts\calculator_app.sh` - POSIX shell launcher for the built CLI
- `scripts\server.cmd` - Windows launcher for the shared web server
- `scripts\server.sh` - POSIX shell launcher for the shared web server
- `test\unit\setmy_info\math\math_service_test.exs` - unit tests for the math service
- `test\integration\setmy_info\calculator_cli\main_test.exs` - integration tests for CLI behavior
- `test\integration\setmy_info\calculator_rest\router_test.exs` - integration tests for the REST endpoint
- `test\e2e\setmy_info\calculator_cli\main_test.exs` - end-to-end test suite for CLI flow
- `test\test_helper.exs` - starts `ExUnit`

## Setup after cloning

Open PowerShell in the project root and run:

```powershell
mix deps.get
mix compile
```

This downloads project dependencies and compiles the project.

After the first clone or after adding new dependencies, make sure `mix deps.get` is run before `mix compile`.

## Build

To build the CLI executable after compiling:

```powershell
mix escript.build
```

This creates the build output file:

```text
calculator_app
```

## Live build during development

If you want a simple live rebuild workflow while changing Elixir files, rerun compilation whenever files change:

```powershell
mix compile
```

For a manual development loop on Windows, keep one PowerShell open in the project root, edit your files, and run:

```powershell
mix compile
mix test .\test\unit
```

Then run the CLI again to verify the current behavior:

```powershell
mix run -e "SetmyInfo.CalculatorCli.Main.main([\"2\", \"3\"])"
```

If you want to refresh the built CLI artifact after source changes, rebuild the `escript`:

```powershell
mix escript.build
```

There is no dedicated file-watching live-build setup configured in this project yet, so the current recommended approach
is to rerun `mix compile` during development and `mix escript.build` when you want an updated built output.

## Run without building

You can run the app directly with Mix:

```powershell
mix run -e "SetmyInfo.CalculatorCli.Main.main([\"2\", \"3\"])"
```

Expected output:

```text
Result: 5
```

## Run shared web server

The best-practice local start command is now:

```powershell
mix server
```

This starts one shared HTTP server for:

- REST
- GraphQL
- GraphiQL
- Swagger UI
- static HTML, CSS, JS, and favicon files

The older command still works as a compatibility alias, but it is deprecated:

```powershell
mix rest.server
```

You can also use the helper starter scripts:

```powershell
.\scripts\server.cmd
```

```sh
./scripts/server.sh
```

By default, it listens on:

```text
http://localhost:4000
```

Example REST request from PowerShell:

```powershell
Invoke-RestMethod -Method Post -Uri http://localhost:4000/api/add -ContentType "application/json" -Body '{"a":2,"b":3}'
```

The REST endpoint expects JSON headers:

- `Content-Type: application/json`
- `Accept: application/json`

If `Content-Type` is not JSON, the server returns HTTP `415`.
If `Accept` does not allow JSON, the server returns HTTP `406`.

Expected response:

```json
{
    "result": 5
}
```

If the JSON body is missing `a` or `b`, or if either value is not an integer, the REST layer returns HTTP `400`
with a JSON error response.

Swagger UI for the REST API is also available from the same server:

```text
http://localhost:4000/swagger
```

The generated OpenAPI 3.2.0 JSON document is available at:

```text
http://localhost:4000/swagger.json
```

## GraphQL on the same server

The same `mix server` process also exposes GraphQL at:

```text
http://localhost:4000/api/graphql
```

Example GraphQL request from PowerShell:

```powershell
Invoke-RestMethod -Method Post -Uri http://localhost:4000/api/graphql -ContentType "application/json" -Body '{"query":"query Add($a:Int!,$b:Int!){ add(a:$a,b:$b) }","variables":{"a":2,"b":3}}'
```

Example query for the in-browser GraphQL console:

```graphql
query Add($a: Int!, $b: Int!) {
    add(a: $a, b: $b)
}
```

Example variables for the GraphQL console:

```json
{
    "a": 2,
    "b": 3
}
```

Expected response:

```json
{
    "data": {
        "add": 5
    }
}
```

GraphQL UI is also available from the same server:

```text
http://localhost:4000/graphiql
```

The web page at `/` includes a dropdown that lets you choose REST or GraphQL for the add request.

## Static web files on the same server

The same `mix server` process also serves ordinary static web files on the same port.

Static files live in:

```text
web-app
```

Current example files:

- `web-app\index.html`
- `web-app\app.css`
- `web-app\app.js`

After starting the server, open:

```text
http://localhost:4000/
```

This serves `index.html`, and related CSS/JS files are served from the same shared server.

## Run built result

## Generate code documentation

Generate Elixir API documentation with ExDoc into the root `docs` folder:

```powershell
mix docs
```

This writes the generated HTML site to:

```text
docs
```

## Generate coverage documentation

Generate HTML test coverage with ExCoveralls into the docs area:

```powershell
mix coveralls.html
```

This writes the coverage report to:

```text
docs\coverage
```

## Generate Credo report

Run code-quality checks with Credo and store the text report under `docs\quality`:

```powershell
mix credo.report
```

Report output:

```text
docs\quality\credo.txt
```

## Validate or auto-fix local code quality

Run the local quality workflow in validation mode:

```powershell
mix quality
```

This checks formatting, compiles with warnings as errors, runs the full test suite,
then runs `mix credo.report` and `mix deps.audit`.

If you want Mix to reformat files before running the same checks, use:

```powershell
mix quality --fix
```

Use `mix quality --fix` when formatting drift is expected and `mix quality` in CI-style validation.

## Generate dependency audit report

Run the dependency retirement audit and store the text report under `docs\quality`:

```powershell
mix deps.audit
```

Report output:

```text
docs\quality\deps-audit.txt
```

Internally this runs `mix hex.audit` and copies the console output into the docs area.

## Generate both docs and coverage together

To generate ExDoc output, the ExCoveralls HTML report, the Credo report, and the dependency audit report in one step,
run:

```powershell
mix docs.generate
```

This keeps generated documentation and QA reports under the root `docs` folder.

On Windows, run the built result through `escript`:

```powershell
escript .\calculator_app 2 3
```

Or use the included Windows command file from the `scripts` folder:

```powershell
.\scripts\calculator_app.cmd 2 3
```

Or from a POSIX shell:

```sh
./scripts/calculator_app.sh 2 3
```

Both should print:

```text
Result: 5
```

If you pass the wrong number of arguments:

```powershell
.\scripts\calculator_app.cmd 2
```

Output:

```text
Usage: calculator_app <a> <b>
```

## Test

Run all tests with:

```powershell
mix test
```

This runs all tests in the project.

Run only unit tests with:

```powershell
mix test.unit
```

Run only integration tests with:

```powershell
mix test.integration
```

This includes the REST endpoint integration tests.

Run only e2e tests with:

```powershell
mix test.e2e
```

If you want, the direct path-based commands still work too:

```powershell
mix test .\test\unit
mix test .\test\integration
mix test .\test\e2e
```

## Logging

The application writes logs to both the console and a rolling log file.

- Console logging is enabled for local development output.
- File logging writes to `log\calculator_app.log`.
- The configured format places time first, then metadata, then log level, then the message.
- File logs rotate by size with a 1 MB limit per file and 5 kept files.

The log directory is created automatically when the application starts.

## QA

The following continuous POSIX shell script runs the currently available checks without stopping at the first failure.
It covers tests, documentation/report generation, server startup, the web add-two-numbers UI wiring, and the key HTTP
pages/endpoints to inspect.

```sh
set +e
mix deps.get
mix compile
mix validate
mix test
mix test.unit
mix test.integration
mix test.e2e
mix quality
mix deps.check_versions
mix docs
mix coveralls.html
mix credo.report
mix sobelow --config
mix deps.audit
mix docs.generate
mix escript.build
./scripts/hello.exs | tee /tmp/calculator-hello.txt
grep -q 'Hello, World!' /tmp/calculator-hello.txt
./scripts/calculator_app.sh 2 3 | tee /tmp/calculator-cli-valid.txt
grep -q 'Result: 5' /tmp/calculator-cli-valid.txt
./scripts/calculator_app.sh 2 | tee /tmp/calculator-cli-invalid.txt
grep -q 'Usage: calculator_app <a> <b>' /tmp/calculator-cli-invalid.txt
./scripts/server.sh >/tmp/calculator-server.log 2>&1 & SERVER_PID=$!
sleep 5
curl -fsS http://localhost:4000/ | tee /tmp/calculator-index.html
grep -q 'id="add-form"' /tmp/calculator-index.html
grep -q 'id="number-a"' /tmp/calculator-index.html
grep -q 'id="number-b"' /tmp/calculator-index.html
grep -q 'Add numbers' /tmp/calculator-index.html
curl -fsS http://localhost:4000/app.css >/tmp/calculator-app.css
curl -fsS http://localhost:4000/app.js | tee /tmp/calculator-app.js
grep -q '/api/add' /tmp/calculator-app.js
grep -q '/api/graphql' /tmp/calculator-app.js
curl -i http://localhost:4000/favicon.ico
curl -i http://localhost:4000/graphiql
curl -i http://localhost:4000/swagger
curl -i http://localhost:4000/swagger.json
curl -i -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"a":2,"b":3}' http://localhost:4000/api/add
curl -i -H 'Accept: application/json' -H 'Content-Type: application/json' -d '{"query":"query Add($a:Int!,$b:Int!){ add(a:$a,b:$b) }","variables":{"a":2,"b":3}}' http://localhost:4000/api/graphql
kill $SERVER_PID
wait $SERVER_PID 2>/dev/null
```

Things to verify while going through the QA flow:

- `mix validate` passes — formatting check and compile with warnings-as-errors both succeed.
- `mix quality` completes successfully — formatting, compile, full test suite, Credo report, and dependency audit.
- `mix deps.check_versions` prints the version table and exits cleanly when all deps are current.
- `mix sobelow --config` completes with no findings.
- `./scripts/hello.exs` prints `Hello, World!` and exits with code 0.
- The built CLI runs through `scripts/calculator_app.sh 2 3` and prints `Result: 5`.
- The built CLI invalid-argument path runs through `scripts/calculator_app.sh 2` and prints `Usage: calculator_app <a> <b>`.
- `http://localhost:4000/` serves the web UI.
- The served web page contains the add form, both number inputs, and the `Add numbers` button.
- The served `app.js` still targets both `/api/add` and `/api/graphql`, so the web UI can submit the add-two-numbers
  request through either backend.
- `POST /api/add` returns JSON `{ "result": 5 }`.
- `POST /api/graphql` returns GraphQL data with `add: 5`.
- `http://localhost:4000/graphiql` opens the GraphQL GUI.
- `http://localhost:4000/swagger` opens the REST Swagger UI.
- `http://localhost:4000/swagger.json` returns the generated OpenAPI 3.2.0 API description for app version `2.0`.
- `docs`, `docs\coverage`, and `docs\quality` contain the generated reports.

For a manual browser sanity check of the same feature, open `http://localhost:4000/`, leave `REST` selected,
enter `2` and `3`, click `Add numbers`, and confirm `Result: 5` is shown. Then repeat with `GraphQL` selected.

## Prerequisites

Install these on Windows before building or running the project:

- Erlang/OTP
- Elixir `~> 1.18`

Check your installation with:

```powershell
elixir -v
mix -v
```

## About `MIX_ENV`

`Mix` uses environments to control how the project is compiled and run.

Built-in environments still matter in this project:

- `dev` - the normal default Mix environment when you do not set `MIX_ENV`
- `test` - used when running tests

This project also defines two project-specific profiles:

- `local` - the preferred profile for local app execution
- `live` - the production-style profile for deployed execution

For this project, if you do not set anything manually, plain commands like these still normally use `dev` because that is Mix's built-in default:

```powershell
mix deps.get
mix compile
mix run -e "SetmyInfo.CalculatorCli.Main.main([\"2\", \"3\"])"
mix escript.build
```

Tests automatically use the `test` environment:

```powershell
mix test
mix test.unit
mix test.integration
mix test.e2e
```

The recommended local server command is still:

```powershell
mix server
```

and it now defaults to the `local` profile through `mix.exs` `preferred_envs`.

If you want to run other commands explicitly in the `local` profile on Windows PowerShell, set `$env:MIX_ENV` first:

```powershell
$env:MIX_ENV = "local"
mix compile
mix run -e "SetmyInfo.CalculatorCli.Main.main([\"2\", \"3\"])"
```

If you want a live deployment-style build, use `live` as the project standard profile name:

```powershell
$env:MIX_ENV = "live"
mix compile
mix server
```

The `live` profile uses the stricter runtime behavior from `config/runtime.exs`, so it requires `PORT` to be set.

To switch back to normal local development defaults in the same PowerShell session:

```powershell
$env:MIX_ENV = "dev"
```

Or remove the variable completely and let Mix use its default behavior again:

```powershell
Remove-Item Env:MIX_ENV
```

For this small project, the usual workflow is:

- use `mix server` for local web execution, which now runs in `local`
- use `MIX_ENV=local` when you want other Mix commands to follow the local-execution profile explicitly
- use `mix test` for tests, which runs in `test`
- use `MIX_ENV=live` for the project's live deployment-style configuration

## Where to put non-Elixir files

Keep helper files for other environments or shells out of the project root when possible.

- Put Windows command helpers in `scripts\`
- Keep Elixir source in `lib\`
- Keep tests in `test\`
- Leave the root mainly for Mix project files and generated build output such as `calculator_app`

---

## Guidelines

### Namespace convention

All modules use the `SetmyInfo.*` root namespace — the Elixir equivalent of the Java
reverse-domain prefix `info.setmy.*`.

| Java | Elixir |
|------|--------|
| `info.setmy.calculatorapp.Application` | `SetmyInfo.CalculatorApp.Application` |
| `info.setmy.calculatorrest.Router` | `SetmyInfo.CalculatorRest.Router` |
| `info.setmy.calculatorrest.Schema` | `SetmyInfo.CalculatorRest.Schema` |
| `info.setmy.math.MathService` | `SetmyInfo.Math.MathService` |

Mix tasks are the exception — they must live under `Mix.Tasks.*` to be discoverable
by the Mix CLI (`Mix.Tasks.Server`, `Mix.Tasks.Test.Unit`, etc.).

### File and directory layout

Every module name maps directly to its file path under `lib/`:

- `SetmyInfo.CalculatorApp.Application` → `lib/setmy_info/calculator_app/application.ex`
- `SetmyInfo.CalculatorRest.Router` → `lib/setmy_info/calculator_rest/router.ex`
- `SetmyInfo.Math.MathService` → `lib/setmy_info/math/math_service.ex`
- `Mix.Tasks.Server` → `lib/mix/tasks/server.ex`

Test files mirror the source path under `test/unit/`, `test/integration/`, or `test/e2e/`:

- `test/unit/setmy_info/math/math_service_test.exs`
- `test/integration/setmy_info/calculator_rest/router_test.exs`

Static web assets live in `priv/static/` so they are packaged correctly by Mix releases
and accessible via `:code.priv_dir(:calculator_app)` at runtime.

### Module naming

- CamelCase module names, snake_case file names — enforced by the Elixir compiler.
- No `Service` suffix — a module named `SetmyInfo.Math` exposes `add/2` directly.
  `MathService` is a Java-ism; the module name already implies the role.
  `SetmyInfo.Math.MathService` is kept temporarily with a TODO in `@moduledoc`
  until the library is extracted into its own Hex package as `SetmyInfo.Math`.
- No `Models` namespace layer — prefer `SetmyInfo.CalculatorCli.Input` over
  `SetmyInfo.CalculatorCli.Models.Input` in new code.

### Elixir coding standards

- `@moduledoc` on every public module; `@moduledoc false` on internal helpers.
- `@doc` on every public function.
- `@spec` on every public function.
- `@impl true` on all behaviour callbacks including `Mix.Task` `run/1`.
- `@type t()` on modules that define a struct.
- Guard clauses (`when is_integer(a)`) at API boundaries rather than runtime checks.
- Return `{:ok, result}` / `{:error, reason}` from fallible functions.
- Bang (`!`) suffix on functions that raise instead of returning an error tuple.

### Mix environments

This project uses `live` instead of `prod` as the production-style environment name.
This is an intentional internal standard — Mix accepts any atom as an environment name.

| Environment | Purpose |
|-------------|---------|
| `dev` | Default Mix env for compilation and development |
| `test` | Running the test suite (`mix test`) |
| `local` | Local server execution (`mix server`) — aliases `dev.exs` |
| `live` | Production-style deployment — requires `PORT` env var |

### Code quality tools

Run all checks before committing:

```sh
mix validate          # format check + compile --warnings-as-errors
mix test              # full test suite
mix credo --strict    # static analysis (config pinned in .credo.exs)
mix sobelow --config  # security scan (config pinned in .sobelow-conf)
mix deps.check_versions  # verify all deps are current
mix deps.audit        # check for known vulnerabilities
```

Or run everything in one step:

```sh
mix quality
```

### Dependency management

- `mix deps.check_versions` — compare all locked deps against Hex latest; exits
  non-zero if any dep can be upgraded within existing constraints.
- `mix deps.upgrade_versions` — update all deps within current `mix.exs`
  constraints, then report anything still behind due to a constraint boundary.
  After running, commit the updated `mix.lock`.
- To upgrade past a constraint boundary (e.g. `~> 2.7` → `3.0`), edit the version
  requirement in `mix.exs` first, then run `mix deps.upgrade_versions`.

### Commit checklist

1. `mix validate` passes
2. `mix test` passes with no failures
3. `mix credo --strict` passes
4. `mix sobelow --config` passes
5. `mix deps.check_versions` shows all deps up-to-date
6. `mix.lock` committed if deps were updated
