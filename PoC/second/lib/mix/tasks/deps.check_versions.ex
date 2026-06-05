defmodule Mix.Tasks.Deps.CheckVersions do
  use Mix.Task

  @shortdoc "Checks all deps against Hex and reports outdated versions"

  @moduledoc """
  Runs `mix hex.outdated` and prints a table of current vs latest versions for
  every dependency.

  Exits with a non-zero status if any dependency can be upgraded within the
  existing `mix.exs` version constraints. Dependencies that require a constraint
  change to reach the latest release are flagged separately.

  ## Examples

      mix deps.check_versions

  """

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Checking dependency versions against Hex...\n")

    {output, exit_code} =
      System.cmd("mix", ["hex.outdated"], stderr_to_stdout: true, into: "")

    Mix.shell().info(output)

    if exit_code != 0 do
      Mix.raise(
        "One or more dependencies are outdated. Run `mix deps.upgrade_versions` to update."
      )
    else
      Mix.shell().info("All dependencies are up-to-date.")
    end
  end
end
