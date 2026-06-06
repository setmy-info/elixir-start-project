defmodule Mix.Tasks.Quality do
  use Mix.Task

  @shortdoc "Validates formatting, compilation, tests, and quality checks"

  @moduledoc """
  Runs the project's local quality workflow.

  By default it verifies formatting, compiles with warnings treated as errors,
  runs the full test suite, and then executes the existing reporting tasks.

  Pass `--fix` to format files before validation.

  ## Examples

      mix quality
      mix quality --fix
  """

  @switches [fix: :boolean]

  @impl Mix.Task
  def run(args) do
    {options, _remaining, invalid} = OptionParser.parse(args, strict: @switches)

    case invalid do
      [] -> :ok
      _ -> Mix.raise("Unknown options: #{format_invalid_options(invalid)}")
    end

    if options[:fix] do
      run_mix_task!("format", [])
    else
      run_mix_task!("format", ["--check-formatted"])
    end

    run_mix_task!("compile", ["--warnings-as-errors"])
    run_mix_task!("test", [])
    run_mix_task!("credo.report", [])
    run_mix_task!("deps.audit", [])
    run_mix_task!("sobelow", ["--config"])
  end

  defp run_mix_task!(task, args) do
    {output, exit_code} =
      System.cmd("mix", [task | args],
        env: [{"MIX_ENV", preferred_env(task)}],
        stderr_to_stdout: true,
        into: ""
      )

    Mix.shell().info(output)

    if exit_code != 0 do
      Mix.raise("mix #{Enum.join([task | args], " ")} failed with exit code #{exit_code}")
    end
  end

  defp preferred_env("test"), do: "test"
  defp preferred_env("muzak"), do: "test"
  defp preferred_env(_task), do: "dev"

  defp format_invalid_options(invalid) do
    invalid
    |> Enum.map_join(", ", fn
      {option, nil} -> option
      {option, value} -> "#{option}=#{value}"
    end)
  end
end
