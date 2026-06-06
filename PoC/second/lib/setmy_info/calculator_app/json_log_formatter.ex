defmodule SetmyInfo.CalculatorApp.JsonLogFormatter do
  @moduledoc """
  Logger formatter that emits one JSON object per log line.

  Enabled in the `:live` environment via `config/runtime.exs`:

      config :logger, :console,
        format: {SetmyInfo.CalculatorApp.JsonLogFormatter, :format}

  Each line contains `ts` (ISO8601), `level`, `msg`, and any non-nil
  metadata keys (`request_id`, `method`, `path`, `status`, `duration_ms`).
  """

  @doc false
  def format(level, message, timestamp, metadata) do
    {{y, mo, d}, {h, mi, s, ms}} = timestamp

    ts =
      :io_lib.format("~4..0B-~2..0B-~2..0BT~2..0B:~2..0B:~2..0B.~3..0BZ", [
        y,
        mo,
        d,
        h,
        mi,
        s,
        ms
      ])
      |> IO.chardata_to_string()

    entry =
      %{
        "ts" => ts,
        "level" => to_string(level),
        "msg" => IO.chardata_to_string(message),
        "request_id" => metadata[:request_id],
        "method" => metadata[:method],
        "path" => metadata[:path],
        "status" => metadata[:status],
        "duration_ms" => metadata[:duration_ms]
      }
      |> Map.reject(fn {_k, v} -> is_nil(v) end)

    [Jason.encode!(entry), "\n"]
  rescue
    _ -> "#{level}: #{IO.chardata_to_string(message)}\n"
  end
end
