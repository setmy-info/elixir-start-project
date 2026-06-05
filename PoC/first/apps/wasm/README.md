# setmy_info_wasm

WebAssembly integration stub for `SetmyInfo.RuntimeEngine` — skeleton ready for [wasmex](https://github.com/tessi/wasmex) or [Extism](https://extism.org/docs/integrate-into-a-host-app/elixir).

Part of the [elixir-start-project](https://github.com/setmy-info/elixir-start-project) umbrella.

> **Note:** This package is a stub. The OTP supervision tree is wired up but no WASM runtime is bundled yet.

## Installation

```elixir
def deps do
  [
    {:setmy_info_wasm, "~> 0.1"}
  ]
end
```

## Extending

Implement `SetmyInfo.RuntimeEngine.Module` in `SetmyInfo.Wasm.Engine`, add `wasmex` or `extism` as a dependency, and plug it into `ModuleRegistry`.

```elixir
# Future: load a .wasm file as a named runtime module
SetmyInfo.Wasm.Engine.load_file(:my_wasm_module, "/path/to/module.wasm")
Executor.run_and_release(:my_wasm_module, :compute, [42])
```

## License

MIT — see [LICENSE](LICENSE).
