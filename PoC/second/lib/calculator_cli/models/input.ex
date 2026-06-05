defmodule CalculatorCli.Models.Input do
  @moduledoc """
  Input structure used by the CLI flow before calling the shared math service.
  """

  defstruct [:a, :b]
end
