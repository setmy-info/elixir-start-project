defmodule Mix.Tasks.Deps.UpgradeVersions do
  use Mix.Task

  @shortdoc "Updates all deps to latest versions allowed by mix.exs constraints"

  @moduledoc """
  Updates all dependencies to the latest versions permitted by the version
  constraints in `mix.exs`, then prints the resulting version table.

  This is equivalent to running `mix deps.update --all` followed by
  `mix hex.outdated`. Dependencies whose latest Hex release lies outside the
  current `mix.exs` constraint are flagged in the output — those require a
  manual constraint edit in `mix.exs` before they can be upgraded further.

  ## Examples

      mix deps.upgrade_versions

  ## Notes

  - Only upgrades within existing constraints (e.g. `~> 2.7` will not jump to `3.0`).
  - After running, commit the updated `mix.lock` to pin the new versions for
    all contributors.
  - To upgrade past a constraint boundary, edit the version requirement in
    `mix.exs` first, then run this task again.

  """

  @impl Mix.Task
  def run(_args) do
    Mix.shell().info("Updating all dependencies within current mix.exs constraints...\n")

    {update_output, update_exit} =
      System.cmd("mix", ["deps.update", "--all"], stderr_to_stdout: true, into: "")

    Mix.shell().info(update_output)

    if update_exit != 0 do
      Mix.raise("mix deps.update --all failed with exit code #{update_exit}")
    end

    Mix.shell().info(
      "\nChecking for versions still outdated after update (constraint-blocked)...\n"
    )

    {outdated_output, _} =
      System.cmd("mix", ["hex.outdated"], stderr_to_stdout: true, into: "")

    Mix.shell().info(outdated_output)

    Mix.shell().info("""
    Update complete. If any dependencies above show a newer \"Latest\" version \
    than \"Current\", their mix.exs constraint must be widened manually before \
    they can be upgraded further.

    Commit mix.lock to pin the updated versions for all contributors.
    """)
  end
end
