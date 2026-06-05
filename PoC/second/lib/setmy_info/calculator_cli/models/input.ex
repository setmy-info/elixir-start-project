defmodule SetmyInfo.CalculatorCli.Models.Input do
  @moduledoc """
  Input structure used by the CLI flow before calling the shared math service.
  """

  @type t() :: %__MODULE__{a: integer(), b: integer()}

  defstruct [:a, :b]
end
