defmodule Mix.Tasks.Test.Gherkin do
  use Mix.Task

  @shortdoc "Runs Gherkin BDD scenarios via White Bread"

  @moduledoc """
  Runs only the Gherkin / BDD test suite under `test/gherkin`.

  The test starts a real Cowboy HTTP server, runs all `.feature` files from
  `features/` through White Bread, and stops the server after the suite.

  ## Examples

      mix test.gherkin
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("test", ["test/gherkin" | args])
  end
end
