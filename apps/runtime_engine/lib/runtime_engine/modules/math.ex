defmodule SetmyInfo.RuntimeEngine.Modules.Math do
  @moduledoc """
  Built-in math runtime module implementing the SetmyInfo.RuntimeEngine.Module behaviour.

  Demonstrates the load -> execute -> release lifecycle with simple arithmetic.
  Replace or extend this to add Lua/WASM-backed execution in the future.
  """

  @behaviour SetmyInfo.RuntimeEngine.Module

  @impl SetmyInfo.RuntimeEngine.Module
  def name, do: :math_module

  @impl SetmyInfo.RuntimeEngine.Module
  def execute(:add, [a, b]) when is_number(a) and is_number(b), do: {:ok, a + b}
  def execute(:multiply, [a, b]) when is_number(a) and is_number(b), do: {:ok, a * b}
  def execute(:subtract, [a, b]) when is_number(a) and is_number(b), do: {:ok, a - b}
  def execute(function, _args), do: {:error, {:undefined_function, function}}
end
