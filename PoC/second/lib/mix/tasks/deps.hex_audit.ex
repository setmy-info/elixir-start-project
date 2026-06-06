defmodule Mix.Tasks.Deps.HexAudit do
  use Mix.Task

  @shortdoc "Runs Hex dependency retirement audit and writes docs output"

  @moduledoc """
  Runs `mix hex.audit` (checks for retired Hex packages), mirrors the output to
  the console, and stores a report in `docs/quality/deps-audit.txt`.

  For CVE / vulnerability scanning use `mix deps.audit` (provided by `mix_audit`).
  """

  @impl Mix.Task
  def run(args) do
    File.mkdir_p!(Path.expand("docs/quality", File.cwd!()))

    {output, exit_code} =
      System.cmd("mix", ["hex.audit" | args], stderr_to_stdout: true, into: "")

    File.write!(Path.expand("docs/quality/deps-audit.txt", File.cwd!()), output)
    Mix.shell().info(output)

    if exit_code != 0 do
      Mix.raise("mix hex.audit failed with exit code #{exit_code}")
    end
  end
end
