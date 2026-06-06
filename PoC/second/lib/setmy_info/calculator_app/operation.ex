defmodule SetmyInfo.CalculatorApp.Operation do
  @moduledoc """
  Behaviour that all arithmetic operations must implement.

  Each implementation provides a URL-friendly `name/0` and an `execute/2`
  that returns `{:ok, result}` or `{:error, reason}`.

  ## Polymorphism vs protocols

  Behaviours enforce the contract at compile time (`@impl` warnings) and
  are idiomatic when the dispatch key is a string/atom rather than the
  data type itself.  Protocols are idiomatic when dispatch is on data shape.

  ## Registered operations

  | Name         | Module                                             |
  |--------------|----------------------------------------------------|
  | `"add"`      | `SetmyInfo.CalculatorApp.Operations.Add`           |
  | `"subtract"` | `SetmyInfo.CalculatorApp.Operations.Subtract`      |
  | `"multiply"` | `SetmyInfo.CalculatorApp.Operations.Multiply`      |
  | `"divide"`   | `SetmyInfo.CalculatorApp.Operations.Divide`        |
  """

  alias SetmyInfo.CalculatorApp.Operations.{Add, Divide, Multiply, Subtract}

  @type execute_result :: {:ok, number()} | {:error, String.t()}

  @doc "Returns the URL-friendly name of this operation (e.g. `\"add\"`)."
  @callback name() :: String.t()

  @doc "Performs the operation on two operands."
  @callback execute(integer(), integer()) :: execute_result()

  @doc "Return the implementation module for an operation name, or `nil` if unknown."
  @spec find(String.t()) :: module() | nil
  def find(op_name), do: Map.get(operations(), op_name)

  @doc "Return the map of all registered operation names to modules."
  @spec all() :: %{String.t() => module()}
  def all, do: operations()

  defp operations do
    %{
      "add" => Add,
      "divide" => Divide,
      "multiply" => Multiply,
      "subtract" => Subtract
    }
  end
end
