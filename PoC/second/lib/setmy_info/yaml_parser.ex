defmodule SetmyInfo.YamlParser do
  @moduledoc """
  YAML parsing backed by `YamlElixir` (which uses the Erlang `yamerl` NIF).

  Provides a thin wrapper that follows Elixir's `{:ok, result} | {:error, reason}`
  convention and delegates to `YamlElixir` for actual parsing.

  ## YAML → Elixir type mapping

  | YAML | Elixir |
  |---|---|
  | `string` | `String.t()` |
  | `integer` | `integer()` |
  | `float` | `float()` |
  | `true` / `false` | `boolean()` |
  | `~` / `null` | `nil` |
  | sequence `- …` | `list()` |
  | mapping `key: val` | `map()` with string keys |
  | multi-document `---` | use `parse_all/1` |

  ## Example

      iex> SetmyInfo.YamlParser.parse("name: Alice\\nage: 30")
      {:ok, %{"age" => 30, "name" => "Alice"}}
  """

  @doc """
  Parse a YAML string.
  Returns `{:ok, data}` on success, `{:error, reason}` on parse failure.
  """
  @spec parse(String.t()) :: {:ok, term()} | {:error, term()}
  def parse(string) when is_binary(string) do
    YamlElixir.read_from_string(string)
  end

  @doc """
  Parse a YAML string, raising on failure.
  """
  @spec parse!(String.t()) :: term()
  def parse!(string) when is_binary(string) do
    YamlElixir.read_from_string!(string)
  end

  @doc """
  Parse a YAML file at `path`.
  Returns `{:ok, data}` on success, `{:error, reason}` on failure.
  """
  @spec parse_file(Path.t()) :: {:ok, term()} | {:error, term()}
  def parse_file(path) do
    YamlElixir.read_from_file(path)
  end

  @doc """
  Parse a YAML file, raising on failure.
  """
  @spec parse_file!(Path.t()) :: term()
  def parse_file!(path) do
    YamlElixir.read_from_file!(path)
  end

  @doc """
  Parse a multi-document YAML string (documents separated by `---`).
  Returns `{:ok, [doc, ...]}` or `{:error, reason}`.
  """
  @spec parse_all(String.t()) :: {:ok, [term()]} | {:error, term()}
  def parse_all(string) when is_binary(string) do
    {:ok, YamlElixir.read_all_from_string!(string)}
  rescue
    error -> {:error, error}
  end

  @doc """
  Parse a multi-document YAML file.
  Returns `{:ok, [doc, ...]}` or `{:error, reason}`.
  """
  @spec parse_all_file(Path.t()) :: {:ok, [term()]} | {:error, term()}
  def parse_all_file(path) do
    {:ok, YamlElixir.read_all_from_file!(path)}
  rescue
    error -> {:error, error}
  end
end
