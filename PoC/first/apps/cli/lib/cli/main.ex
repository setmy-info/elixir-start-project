defmodule SetmyInfo.Cli.Main do
  @moduledoc """
  Escript entry point for the CLI.

  Demonstrates calling SetmyInfo.RuntimeEngine from a CLI context.

  Usage (after `mix escript.build`):
    ./cli add 2 3        # => 2 + 3 = 5
    ./cli multiply 3 4   # => 3 * 4 = 12
    ./cli --help
  """

  alias SetmyInfo.RuntimeEngine.Executor

  def main(args) do
    IO.puts("Elixir Start Project CLI")

    case parse_args(args) do
      {:add, a, b} ->
        run_operation(:math_module, :add, a, b, "+")

      {:multiply, a, b} ->
        run_operation(:math_module, :multiply, a, b, "*")

      :help ->
        print_help()

      {:error, message} ->
        IO.puts("Error: #{message}")
        print_help()
        System.halt(1)
    end
  end

  defp run_operation(module, function, a, b, operator) do
    case Executor.run_and_release(module, function, [a, b]) do
      {:ok, result} ->
        IO.puts("#{a} #{operator} #{b} = #{result}")

      {:error, reason} ->
        IO.puts("Execution error: #{inspect(reason)}")
        System.halt(1)
    end
  end

  defp parse_args(["add", a_str, b_str]), do: parse_numeric(:add, a_str, b_str)
  defp parse_args(["multiply", a_str, b_str]), do: parse_numeric(:multiply, a_str, b_str)
  defp parse_args(["--help"]), do: :help
  defp parse_args(["-h"]), do: :help
  defp parse_args([]), do: :help
  defp parse_args(_), do: {:error, "unknown command"}

  defp parse_numeric(op, a_str, b_str) do
    with {a, ""} <- Integer.parse(a_str),
         {b, ""} <- Integer.parse(b_str) do
      {op, a, b}
    else
      _ -> {:error, "arguments must be integers"}
    end
  end

  defp print_help do
    IO.puts("""

    Usage:
      ./cli add <a> <b>         Add two integers via SetmyInfo.RuntimeEngine
      ./cli multiply <a> <b>    Multiply two integers via SetmyInfo.RuntimeEngine
      ./cli --help              Show this help
    """)
  end
end
