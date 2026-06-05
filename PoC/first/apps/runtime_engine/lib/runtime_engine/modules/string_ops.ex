defmodule SetmyInfo.RuntimeEngine.Modules.StringOps do
  @moduledoc """
  Built-in string operations runtime module.

  Registered as :string_module in the ModuleRegistry.
  Demonstrates that the engine supports multiple pluggable modules.
  """

  @behaviour SetmyInfo.RuntimeEngine.Module

  @impl SetmyInfo.RuntimeEngine.Module
  def name, do: :string_module

  @impl SetmyInfo.RuntimeEngine.Module
  def execute(:upcase, [s]) when is_binary(s), do: {:ok, String.upcase(s)}
  def execute(:downcase, [s]) when is_binary(s), do: {:ok, String.downcase(s)}
  def execute(:reverse, [s]) when is_binary(s), do: {:ok, String.reverse(s)}
  def execute(:length, [s]) when is_binary(s), do: {:ok, String.length(s)}
  def execute(:trim, [s]) when is_binary(s), do: {:ok, String.trim(s)}
  def execute(function, _args), do: {:error, {:undefined_function, function}}
end
