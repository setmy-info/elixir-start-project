defmodule SetmyInfo.CalculatorRest.Schema do
  use Absinthe.Schema

  @moduledoc """
  GraphQL schema exposed by the shared HTTP server.

  Defines a custom `DateTime` scalar (ISO 8601 UTC, millisecond precision)
  and an `AddResult` object so both the numeric result and the server-side
  timestamp are returned together.
  """

  alias SetmyInfo.Math.MathService

  @desc "ISO 8601 UTC datetime with millisecond precision (e.g. 2026-01-01T12:00:00.123Z)"
  scalar :datetime, name: "DateTime" do
    serialize(fn dt ->
      dt |> DateTime.truncate(:millisecond) |> DateTime.to_iso8601()
    end)

    parse(fn
      %Absinthe.Blueprint.Input.String{value: value} ->
        case DateTime.from_iso8601(value) do
          {:ok, dt, _} -> {:ok, DateTime.truncate(dt, :millisecond)}
          _ -> :error
        end

      _ ->
        :error
    end)
  end

  @desc "Result of an addition operation."
  object :add_result do
    field(:result, non_null(:integer), description: "Sum of a and b.")
    field(:at, non_null(:datetime), description: "UTC server timestamp at time of calculation.")
  end

  query do
    @desc "Adds two integers and returns the result with a server-side UTC timestamp."
    field :add, non_null(:add_result) do
      arg(:a, non_null(:integer))
      arg(:b, non_null(:integer))

      resolve(fn %{a: a, b: b}, _resolution ->
        {:ok,
         %{
           result: MathService.add(a, b),
           at: DateTime.utc_now() |> DateTime.truncate(:millisecond)
         }}
      end)
    end
  end
end
