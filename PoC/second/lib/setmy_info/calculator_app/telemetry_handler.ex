defmodule SetmyInfo.CalculatorApp.TelemetryHandler do
  @moduledoc """
  Telemetry event handler for HTTP request metrics.

  Attaches to `[:calculator_app, :http, :stop]` events emitted by
  `Plug.Telemetry` and logs method, path, status, and duration.

  Call `attach/0` once during application startup (already done in
  `SetmyInfo.CalculatorApp.Application`).
  """

  require Logger

  @handler_id "calculator-http-handler"
  @events [[:calculator_app, :http, :stop]]

  @doc "Attach this handler to telemetry. Safe to call multiple times."
  def attach do
    :telemetry.detach(@handler_id)
    :telemetry.attach_many(@handler_id, @events, &handle_event/4, nil)
    :ok
  end

  @doc false
  def handle_event(
        [:calculator_app, :http, :stop],
        %{duration: duration},
        %{conn: conn},
        _config
      ) do
    ms = System.convert_time_unit(duration, :native, :millisecond)

    Logger.info(
      "HTTP #{conn.method} #{conn.request_path} → #{conn.status} (#{ms}ms)",
      request_id: conn.assigns[:request_id],
      method: conn.method,
      path: conn.request_path,
      status: conn.status,
      duration_ms: ms
    )
  end

  def handle_event(_event, _measurements, _metadata, _config), do: :ok
end
