# setmy_info_core_logic

Core business logic for the SetmyInfo umbrella project: Ecto schemas, YAML parsing, and an OTP supervision tree.

Part of the [elixir-start-project](https://github.com/setmy-info/elixir-start-project) umbrella.

## Installation

```elixir
def deps do
  [
    {:setmy_info_core_logic, "~> 0.1"}
  ]
end
```

## Features

- **Ecto schemas** — `Person` schema with changeset validation
- **Dual-DB support** — PostgreSQL (`:postgrex`) and SQLite (`:ecto_sqlite3`) via `Repo`
- **YAML parsing** — `YamlParser` wraps `yaml_elixir` for string, file, and multi-doc parsing
- **OTP supervision** — `CoreLogic.Application` starts a named supervisor tree

## Usage

```elixir
alias SetmyInfo.CoreLogic.YamlParser

{:ok, config} = YamlParser.parse("host: localhost\nport: 4000\n")
{:ok, data}   = YamlParser.parse_file("/path/to/config.yml")
{:ok, [d1, d2]} = YamlParser.parse_all(multi_doc_string)
```

## License

MIT — see [LICENSE](LICENSE).
