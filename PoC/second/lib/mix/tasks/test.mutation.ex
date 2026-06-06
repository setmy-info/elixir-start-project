defmodule Mix.Tasks.Test.Mutation do
  use Mix.Task

  @shortdoc "Runs mutation testing via Muzak"

  @moduledoc """
  Runs mutation testing against the library source using Muzak.

  Muzak mutates the source code and re-runs the test suite for each mutant.
  A mutant that is not caught by any test is a "surviving mutant" — evidence
  that the tests are not sensitive enough to detect that code change.

  Configuration is read from `.muzak.exs` in the project root.

  ## Example

      mix test.mutation

  ## Prerequisites

  Muzak requires a valid license. See https://muzak.dev for details.
  """

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("muzak", args)
  end
end
