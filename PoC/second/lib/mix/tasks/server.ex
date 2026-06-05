defmodule Mix.Tasks.Server do
  use Mix.Task

  @shortdoc "Starts the shared web server"

  @moduledoc """
  Starts the shared HTTP server for REST, GraphQL, GraphiQL, Swagger, and static web files.

  This is the recommended command for local development because it follows the
  common Mix application startup flow and keeps the application running with
  `mix run --no-halt` semantics.

  ## Example

      mix server
  """

  @doc """
  Enables the HTTP server and delegates to `mix run --no-halt`.
  """
  def run(args) do
    System.put_env("CALCULATOR_SERVER", "true")
    Mix.Task.run("run", args ++ ["--no-halt"])
  end
end
