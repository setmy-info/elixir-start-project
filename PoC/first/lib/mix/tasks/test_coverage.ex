defmodule Mix.Tasks.Test.Coverage do
  use Mix.Task

  @shortdoc "Run unit-test coverage and collect HTML reports into _build/cover/<app>/"

  @apps ~w(core_logic runtime_engine graphql_api cli wasm lessons)
  @test_paths Enum.map(@apps, &"apps/#{&1}/test")
  @output_root "_build/cover"

  def run(_args) do
    Mix.Task.run("coveralls.html", @test_paths)
    collect_reports()
  end

  defp collect_reports do
    File.mkdir_p!(@output_root)

    Enum.each(@apps, fn app ->
      src = "apps/#{app}/cover"

      if File.exists?(src) do
        dst = Path.join(@output_root, app)
        File.rm_rf!(dst)
        File.cp_r!(src, dst)
        File.rm_rf!(src)
      end
    end)

    Mix.shell().info("Coverage reports written to #{@output_root}/")
  end
end
