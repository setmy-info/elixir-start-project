defmodule SetmyInfo.CalculatorApp.Operations.Add do
  @moduledoc "Arithmetic addition operation."

  alias SetmyInfo.CalculatorApp.Operation

  @behaviour Operation

  @impl Operation
  def name, do: "add"

  @impl Operation
  def execute(a, b), do: {:ok, a + b}
end
