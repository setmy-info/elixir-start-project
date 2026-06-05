defmodule Mix.Tasks.Test.E2e do
  use Mix.Task

  @shortdoc "Runs end-to-end tests"

  @moduledoc """
  Runs only the end-to-end test suite under `test/e2e`.
  """

  @doc """
  Delegates to `mix test` with the end-to-end test directory.
  """
  @impl Mix.Task
  def run(args) do
    Mix.Task.run("test", ["test/e2e" | args])
  end
end
