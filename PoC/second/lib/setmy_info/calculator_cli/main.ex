defmodule SetmyInfo.CalculatorCli.Main do
  @moduledoc """
  Command-line entry point for the calculator application.

  The module accepts two integer arguments, adds them through
  `SetmyInfo.Math.MathService`, and prints the result for shell usage.
  """

  alias SetmyInfo.CalculatorCli.Models.Input
  alias SetmyInfo.Math.MathService

  @doc """
  Runs the calculator with two CLI arguments.

  When the arguments are invalid or missing, usage text is printed instead.
  """
  def main([a_str, b_str]) do
    with {a, ""} <- Integer.parse(a_str),
         {b, ""} <- Integer.parse(b_str) do
      input = %Input{a: a, b: b}
      result = MathService.add(input.a, input.b)
      IO.puts("Result: #{result}")
    else
      _ -> IO.puts("Usage: calculator_app <a> <b>")
    end
  end

  @doc false
  def main(_) do
    IO.puts("Usage: calculator_app <a> <b>")
  end
end
