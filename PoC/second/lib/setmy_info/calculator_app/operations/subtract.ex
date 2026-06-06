defmodule SetmyInfo.CalculatorApp.Operations.Subtract do
  @moduledoc "Arithmetic subtraction operation."

  alias SetmyInfo.CalculatorApp.Operation

  @behaviour Operation

  @impl Operation
  def name, do: "subtract"

  @impl Operation
  def execute(a, b), do: {:ok, a - b}
end
