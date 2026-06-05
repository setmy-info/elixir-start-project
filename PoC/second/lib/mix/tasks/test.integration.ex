defmodule Mix.Tasks.Test.Integration do
  use Mix.Task

  @shortdoc "Runs integration tests"

  @moduledoc """
  Runs only the integration test suite under `test/integration`.
  """

  @doc """
  Delegates to `mix test` with the integration-test directory.
  """
  @impl Mix.Task
  def run(args) do
    Mix.Task.run("test", ["test/integration" | args])
  end
end
