defmodule SetmyInfo.CoreLogic.TomlParser do
  @moduledoc """
  TOML parsing backed by the `toml` library.

  Provides a thin wrapper that follows Elixir's `{:ok, result} | {:error, reason}`
  convention, with string keys in all returned maps for consistency with
  `SetmyInfo.CoreLogic.YamlParser`.

  ## TOML → Elixir type mapping

  | TOML | Elixir |
  |---|---|
  | `"string"` | `String.t()` |
  | `42` / `-17` | `integer()` |
  | `0xFF` / `0o77` / `0b1010` | `integer()` |
  | `3.14` / `1.5e3` / `inf` | `float()` |
  | `true` / `false` | `boolean()` |
  | `[a, b, c]` | `list()` |
  | `[section]` | `map()` with string keys |
  | `[[array_of_tables]]` | `[map()]` |
  | `1979-05-27` | `Date.t()` |
  | `07:32:00` | `Time.t()` |
  | `1979-05-27T07:32:00` | `NaiveDateTime.t()` |
  | `1979-05-27T07:32:00Z` | `DateTime.t()` |

  **Notable TOML differences from YAML:**
  - No null/nil — absence of a key means "not set"
  - No multi-document files
  - No anchors/aliases
  - Native datetime, date, and time types
  - Integer literals support hex (`0x`), octal (`0o`), binary (`0b`) prefixes

  ## Example

      iex> SetmyInfo.CoreLogic.TomlParser.parse(~s(name = "Alice"\\nage = 30))
      {:ok, %{"name" => "Alice", "age" => 30}}
  """

  @opts [keys: :strings]

  @doc """
  Parse a TOML string.
  Returns `{:ok, map}` on success, `{:error, %Toml.Error{}}` on failure.
  """
  @spec parse(String.t()) :: {:ok, map()} | {:error, term()}
  def parse(string) when is_binary(string) do
    Toml.decode(string, @opts)
  end

  @doc """
  Parse a TOML string, raising on failure.
  """
  @spec parse!(String.t()) :: map()
  def parse!(string) when is_binary(string) do
    Toml.decode!(string, @opts)
  end

  @doc """
  Parse a TOML file at `path`.
  Returns `{:ok, map}` on success, `{:error, reason}` on failure.
  """
  @spec parse_file(Path.t()) :: {:ok, map()} | {:error, term()}
  def parse_file(path) do
    Toml.decode_file(path, @opts)
  end

  @doc """
  Parse a TOML file, raising on failure.
  """
  @spec parse_file!(Path.t()) :: map()
  def parse_file!(path) do
    Toml.decode_file!(path, @opts)
  end
end
