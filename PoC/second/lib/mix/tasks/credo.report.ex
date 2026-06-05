defmodule Mix.Tasks.Credo.Report do
  use Mix.Task

  @shortdoc "Runs Credo and writes the report to docs"

  @moduledoc """
  Runs `mix credo --strict`, mirrors the output to the console, and stores a
  text report in `docs/quality/credo.txt`.
  """

  @doc """
  Executes Credo and writes the report file.
  """
  @impl Mix.Task
  def run(args) do
    File.mkdir_p!(Path.expand("docs/quality", File.cwd!()))

    {output, exit_code} =
      System.cmd("mix", ["credo", "--strict" | args],
        env: [{"MIX_ENV", "dev"}],
        stderr_to_stdout: true,
        into: ""
      )

    File.write!(Path.expand("docs/quality/credo.txt", File.cwd!()), output)
    Mix.shell().info(output)

    if exit_code != 0 do
      Mix.raise("mix credo --strict failed with exit code #{exit_code}")
    end
  end
end
