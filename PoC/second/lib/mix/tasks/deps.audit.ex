defmodule Mix.Tasks.Deps.Audit do
  use Mix.Task

  @shortdoc "Runs Hex dependency retirement audit and writes docs output"

  @moduledoc """
  Runs `mix hex.audit`, mirrors the output to the console, and stores a report in
  `docs/quality/deps-audit.txt`.
  """

  @doc """
  Executes the dependency audit and writes the report file.
  """
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
