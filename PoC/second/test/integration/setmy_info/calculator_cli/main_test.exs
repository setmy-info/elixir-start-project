defmodule SetmyInfo.CalculatorCli.MainTest do
  use ExUnit.Case

  import ExUnit.CaptureIO

  alias SetmyInfo.CalculatorCli.Main

  test "prints the result for valid input" do
    output = capture_io(fn -> Main.main(["2", "3"]) end)

    assert output == "Result: 5\n"
  end

  test "prints usage for invalid argument count" do
    output = capture_io(fn -> Main.main(["2"]) end)

    assert output == "Usage: calculator_app <a> <b>\n"
  end

  test "prints usage for non-integer string arguments" do
    output = capture_io(fn -> Main.main(["foo", "bar"]) end)

    assert output == "Usage: calculator_app <a> <b>\n"
  end
end
