defmodule SetmyInfo.CalculatorApp.Operations.Multiply do
  @moduledoc "Arithmetic multiplication operation."

  alias SetmyInfo.CalculatorApp.Operation

  @behaviour Operation

  @impl Operation
  def name, do: "multiply"

  @impl Operation
  def execute(a, b), do: {:ok, a * b}
end
