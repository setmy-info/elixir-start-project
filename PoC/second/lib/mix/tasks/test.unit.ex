defmodule Mix.Tasks.Test.Unit do
  use Mix.Task

  @shortdoc "Runs unit tests"

  @moduledoc """
  Runs only the unit test suite under `test/unit`.
  """

  @doc """
  Delegates to `mix test` with the unit-test directory.
  """
  @impl Mix.Task
  def run(args) do
    Mix.Task.run("test", ["test/unit" | args])
  end
end
