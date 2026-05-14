defmodule SetmyInfo.GraphqlApi.Application do
  @moduledoc """
  OTP Application for the GraphQL API layer.

  Starts a Cowboy HTTP server exposing the Absinthe schema at /graphql.
  The HTTP server is skipped in the :test environment (controlled by
  the :graphql_api, :start_http config key) so tests can call the
  schema directly without binding a port.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = http_children()

    opts = [strategy: :one_for_one, name: SetmyInfo.GraphqlApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp http_children do
    if Application.get_env(:graphql_api, :start_http, true) do
      port = Application.get_env(:graphql_api, :port, 4000)

      [
        {Plug.Cowboy, scheme: :http, plug: SetmyInfo.GraphqlApi.Router, options: [port: port]}
      ]
    else
      []
    end
  end
end
