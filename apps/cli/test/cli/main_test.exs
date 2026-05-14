defmodule SetmyInfo.Cli.MainTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias SetmyInfo.RuntimeEngine.Loader

  setup do
    on_exit(fn ->
      Loader.list_loaded() |> Enum.each(&Loader.release/1)
    end)

    :ok
  end

  test "add command prints correct result" do
    output = capture_io(fn -> SetmyInfo.Cli.Main.main(["add", "2", "3"]) end)
    assert output =~ "2 + 3 = 5"
  end

  test "multiply command prints correct result" do
    output = capture_io(fn -> SetmyInfo.Cli.Main.main(["multiply", "3", "4"]) end)
    assert output =~ "3 * 4 = 12"
  end

  test "no args prints help" do
    output = capture_io(fn -> SetmyInfo.Cli.Main.main([]) end)
    assert output =~ "Usage"
  end
end
