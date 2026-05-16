# setmy_info_cli

CLI escript for `SetmyInfo.RuntimeEngine` — dispatches arithmetic commands via the dynamic module system.

Part of the [elixir-start-project](https://github.com/setmy-info/elixir-start-project) umbrella.

## Installation

```elixir
def deps do
  [
    {:setmy_info_cli, "~> 0.1"}
  ]
end
```

## Building the escript

```sh
cd apps/cli
mix escript.build
```

## Usage

```sh
./cli add 2 3        # => 2 + 3 = 5
./cli multiply 3 4   # => 3 * 4 = 12
./cli --help
```

## License

MIT — see [LICENSE](LICENSE).
