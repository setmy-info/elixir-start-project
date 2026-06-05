defmodule Mix.Tasks.Rest.Server do
  use Mix.Task

  @shortdoc "Starts the shared web server (deprecated alias)"

  @moduledoc """
  Starts the shared HTTP server for REST, GraphQL, GraphiQL, and static web files.

  Deprecated: prefer `mix server`.

  ## Example

      mix server
  """

  @doc """
  Delegates to `mix server` for backwards compatibility.
  """
  @impl Mix.Task
  def run(args) do
    Mix.shell().info("mix rest.server is deprecated; use mix server instead.")
    Mix.Task.run("server", args)
  end
end
