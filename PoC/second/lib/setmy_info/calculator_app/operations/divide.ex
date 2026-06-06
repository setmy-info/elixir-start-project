defmodule SetmyInfo.CalculatorApp.Operations.Divide do
  @moduledoc "Integer division operation. Returns `{:error, ...}` on division by zero."

  alias SetmyInfo.CalculatorApp.Operation

  @behaviour Operation

  @impl Operation
  def name, do: "divide"

  @impl Operation
  def execute(_a, 0), do: {:error, "Division by zero is not allowed."}
  def execute(a, b), do: {:ok, div(a, b)}
end
