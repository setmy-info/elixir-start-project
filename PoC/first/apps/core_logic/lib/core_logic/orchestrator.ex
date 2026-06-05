defmodule SetmyInfo.CoreLogic.Orchestrator do
  @moduledoc """
  High-level business logic orchestration.

  Provides pure functions for core domain operations.
  Does not hold state — delegates stateful work to SetmyInfo.RuntimeEngine.
  """

  @spec add(number(), number()) :: number()
  def add(a, b), do: a + b

  @spec multiply(number(), number()) :: number()
  def multiply(a, b), do: a * b

  @spec subtract(number(), number()) :: number()
  def subtract(a, b), do: a - b
end
