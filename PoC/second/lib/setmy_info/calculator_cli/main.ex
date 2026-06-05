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
  def main([a, b]) do
    input = %Input{
      a: String.to_integer(a),
      b: String.to_integer(b)
    }

    result = MathService.add(input.a, input.b)

    IO.puts("Result: #{result}")
  end

  @doc false
  def main(_) do
    IO.puts("Usage: calculator_app <a> <b>")
  end
end
