# setmy_info_runtime_engine

OTP-based dynamic module loader with hot-code reload, GenServer workers, and ETS-backed registry.

Part of the [elixir-start-project](https://github.com/setmy-info/elixir-start-project) umbrella.

## Installation

```elixir
def deps do
  [
    {:setmy_info_runtime_engine, "~> 0.1"}
  ]
end
```

## Features

- **Dynamic loading** — start/stop named module workers at runtime via `DynamicSupervisor`
- **Hot-code reload** — swap module implementation without restarting the worker process
- **ETS registry** — fast name-to-PID lookups via `Loader` + `ModuleRegistry`
- **Module behaviour** — implement `SetmyInfo.RuntimeEngine.Module` to plug in custom logic
- **Bundled modules** — `Modules.Math` (add, subtract, multiply, divide) and `Modules.StringOps`

## Usage

```elixir
alias SetmyInfo.RuntimeEngine.Executor

# Load, call, and release in one step
{:ok, 5} = Executor.run_and_release(:math_module, :add, [2, 3])

# Hot-code reload — same PID, new behaviour on next call
SetmyInfo.RuntimeEngine.HotCode.load_from_source("""
  defmodule SetmyInfo.RuntimeEngine.Modules.DemoCalc do
    @behaviour SetmyInfo.RuntimeEngine.Module
    def name, do: :demo_calc
    def execute(:compute, [x]), do: {:ok, x * 3}
    def execute(f, _), do: {:error, {:undefined_function, f}}
  end
""")
```

## License

MIT — see [LICENSE](LICENSE).
