defmodule Mix.Tasks.Docs.Generate do
  use Mix.Task

  @shortdoc "Generates docs, coverage, and quality reports into docs"

  @moduledoc """
  Builds the project documentation site, coverage HTML artifacts, and quality
  reports under the `docs` folder.

  It runs `mix docs` in the `dev` environment and `mix coveralls.html --output docs/coverage`
  in the `test` environment so the generated documentation can be published from a single place.

  ## Example

      mix docs.generate
  """

  @doc """
  Generates ExDoc, coverage output, and quality reports under the `docs` directory.
  """
  def run(_args) do
    docs_dir = Path.expand("docs", File.cwd!())
    File.mkdir_p!(docs_dir)

    run_mix_command!("docs", [], %{"MIX_ENV" => "dev"})
    run_mix_command!("coveralls.html", [], %{"MIX_ENV" => "test"})
    run_mix_command!("credo.report", [], %{"MIX_ENV" => "dev"})
    run_mix_command!("deps.audit", [], %{"MIX_ENV" => "dev"})

    Mix.shell().info("Documentation generated in #{docs_dir}")
  end

  @doc false
  defp run_mix_command!(task, args, extra_env) do
    env = Map.to_list(extra_env)

    {output, exit_code} =
      System.cmd("mix", [task | args],
        env: env,
        stderr_to_stdout: true,
        into: ""
      )

    Mix.shell().info(output)

    if exit_code != 0 do
      Mix.raise("mix #{Enum.join([task | args], " ")} failed with exit code #{exit_code}")
    end
  end
end
