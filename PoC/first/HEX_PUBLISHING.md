# Hex.pm Publishing Guide

This document covers everything needed to publish the umbrella sub-apps to [hex.pm](https://hex.pm/).

---

## Overview

This is an **Elixir umbrella project**. Each sub-app is published as an independent hex package.
The umbrella root (`ElixirStartProject`) is **not** published.

| App | Hex package name | Depends on |
|---|---|---|
| `apps/core_logic` | `setmy_info_core_logic` | *(none — leaf library)* |
| `apps/runtime_engine` | `setmy_info_runtime_engine` | `setmy_info_core_logic` |
| `apps/graphql_api` | `setmy_info_graphql_api` | `setmy_info_core_logic`, `setmy_info_runtime_engine` |
| `apps/cli` | `setmy_info_cli` | `setmy_info_runtime_engine` |
| `apps/lessons` | `setmy_info_lessons` | *(none — standalone)* |
| `apps/wasm` | `setmy_info_wasm` | `setmy_info_runtime_engine` |
| `apps/integration_tests` | — | **not published** (test-only) |

---

## Step 1 — Create a hex.pm account

1. Go to <https://hex.pm/> and click **Sign up**.
2. Confirm your email address.
3. Authenticate the local Hex client:

```sh
mix hex.user auth
# prompts for username + password, then stores an API key in ~/.hex/
```

To verify:

```sh
mix hex.user whoami
```

---

## Step 2 — One-time setup per machine

```sh
# Install / update the Hex package manager itself
mix local.hex --force

# Install Rebar (needed for some Erlang deps)
mix local.rebar --force
```

---

## Step 3 — Copy LICENSE into each app directory

Hex packages only include files relative to the app's own directory. The root `LICENSE`
is not automatically included. Run this once before publishing:

```sh
for app in core_logic runtime_engine graphql_api cli lessons wasm; do
  cp LICENSE apps/$app/LICENSE
done
```

> Add `apps/*/LICENSE` to `.gitignore` if you prefer not to commit the copies,
> or commit them explicitly — both are valid approaches.

---

## Step 4 — Convert `in_umbrella` dependencies

Before publishing any app that depends on another umbrella app, you must replace
`in_umbrella: true` references with the published hex package name and version.

Do this **only in the copies used for publishing** (or after the upstream package is already on hex.pm).

| Current (umbrella dev) | Replace with (hex publish) |
|---|---|
| `{:core_logic, in_umbrella: true}` | `{:setmy_info_core_logic, "~> 0.1"}` |
| `{:runtime_engine, in_umbrella: true}` | `{:setmy_info_runtime_engine, "~> 0.1"}` |

The comments already placed in each app's `mix.exs` mark exactly where to make these changes.

---

## Step 5 — Verify the package contents before publishing

```sh
# Dry-run: shows what files would be included in the package
cd apps/core_logic
mix hex.build

# Inspect the generated tarball manually
tar tf core_logic-0.1.0.tar
```

Confirm the tarball includes: `lib/`, `mix.exs`, `README.md`, `LICENSE`.

---

## Step 6 — Publish in dependency order

Publish leaf packages first so downstream packages can reference the correct hex version.

### 6.1 — core_logic (no umbrella deps)

```sh
cd apps/core_logic
mix hex.publish
```

### 6.2 — runtime_engine (depends on core_logic)

Edit `apps/runtime_engine/mix.exs` deps:
```elixir
# Replace:
{:core_logic, in_umbrella: true},
# With:
{:setmy_info_core_logic, "~> 0.1"},
```

Then:
```sh
cd apps/runtime_engine
mix deps.get
mix hex.publish
```

### 6.3 — lessons (no umbrella deps)

```sh
cd apps/lessons
mix hex.publish
```

### 6.4 — cli (depends on runtime_engine)

Edit `apps/cli/mix.exs` deps:
```elixir
# Replace:
{:runtime_engine, in_umbrella: true},
# With:
{:setmy_info_runtime_engine, "~> 0.1"},
```

Then:
```sh
cd apps/cli
mix deps.get
mix hex.publish
```

### 6.5 — wasm (depends on runtime_engine)

Same dep swap as `cli`, then:
```sh
cd apps/wasm
mix deps.get
mix hex.publish
```

### 6.6 — graphql_api (depends on core_logic + runtime_engine)

Edit `apps/graphql_api/mix.exs` deps:
```elixir
# Replace:
{:core_logic, in_umbrella: true},
{:runtime_engine, in_umbrella: true},
# With:
{:setmy_info_core_logic, "~> 0.1"},
{:setmy_info_runtime_engine, "~> 0.1"},
```

Then:
```sh
cd apps/graphql_api
mix deps.get
mix hex.publish
```

---

## Step 7 — Verify on hex.pm

After each `mix hex.publish`, the package page is available at:

```
https://hex.pm/packages/setmy_info_core_logic
https://hex.pm/packages/setmy_info_runtime_engine
https://hex.pm/packages/setmy_info_graphql_api
https://hex.pm/packages/setmy_info_cli
https://hex.pm/packages/setmy_info_lessons
https://hex.pm/packages/setmy_info_wasm
```

Hex documentation is automatically published to HexDocs:

```
https://hexdocs.pm/setmy_info_core_logic
https://hexdocs.pm/setmy_info_runtime_engine
```

---

## Step 8 — Publishing a new version

1. Bump `@version` in the relevant app's `mix.exs`.
2. Update `CHANGELOG.md` (move unreleased items under the new version header).
3. Commit and tag:

```sh
git add -A
git commit -m "Release v0.2.0"
git tag v0.2.0
git push && git push --tags
```

4. Publish:

```sh
cd apps/core_logic   # or whichever app changed
mix hex.publish
```

---

## Useful hex.pm commands

| Command | Purpose |
|---|---|
| `mix hex.user auth` | Authenticate with hex.pm |
| `mix hex.user whoami` | Show logged-in user |
| `mix hex.build` | Dry-run: build tarball without publishing |
| `mix hex.publish` | Publish to hex.pm |
| `mix hex.publish --revert 0.1.0` | Revert a published version (within 24 h) |
| `mix hex.docs` | Publish docs separately to HexDocs |
| `mix hex.info setmy_info_core_logic` | Show package info |
| `mix hex.search setmy_info` | Search hex.pm |

---

## Checklist before first publish

- [ ] hex.pm account created and email confirmed
- [ ] `mix hex.user auth` completed on this machine
- [ ] `LICENSE` file copied into each app directory (`apps/*/LICENSE`)
- [ ] Each app's `mix.exs` has `description`, `package`, and `docs` filled in
- [ ] Each app directory has a `README.md`
- [ ] `CHANGELOG.md` updated
- [ ] `mix hex.build` dry-run passes for each app
- [ ] `in_umbrella: true` deps replaced with hex references in publishing copies
- [ ] Git tag created for the release version
- [ ] Packages published in dependency order (core_logic → runtime_engine → others)

---

## Notes on umbrella vs. standalone publishing

Publishing umbrella sub-apps to hex.pm requires a **temporary switch** from `in_umbrella: true`
to real hex dependencies. The two most common strategies are:

**Strategy A — Edit-publish-revert (simplest)**
Manually edit `mix.exs`, publish, then revert. Good for infrequent releases.

**Strategy B — Separate branch**
Maintain a `hex-release` branch where all `in_umbrella` deps are replaced.
Merge into it before each release, publish, then continue on `master`.

**Strategy C — Conditional deps**
Use a Mix environment variable or config flag to switch between umbrella and hex deps.
More complex, but keeps a single `mix.exs` for both workflows:

```elixir
defp deps do
  shared = [
    {:ex_doc, "~> 0.34", only: :dev, runtime: false}
  ]
  if System.get_env("HEX_PUBLISH") do
    [{:setmy_info_core_logic, "~> 0.1"} | shared]
  else
    [{:core_logic, in_umbrella: true} | shared]
  end
end
```

Then publish with:
```sh
HEX_PUBLISH=true mix hex.publish
```
