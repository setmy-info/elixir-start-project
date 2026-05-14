defmodule SetmyInfo.GraphqlApi.Router do
  @moduledoc """
  Plug router for the GraphQL API.

  Routes:
    GET/POST /graphql  — GraphiQL browser IDE + JSON API endpoint
    POST     /graphql  — JSON API endpoint (programmatic access)

  Plug.Parsers must sit before :match so the request body is available
  to Absinthe.Plug when it processes the route.  Without it every POST
  returns HTTP 500 with an empty body.
  """

  use Plug.Router

  # Parse body BEFORE routing.
  # Absinthe.Plug.Parser handles multipart/form-data GraphQL requests;
  # :json handles standard application/json requests.
  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  # Browser access: serves the GraphiQL interactive IDE.
  # GET  /graphql  → opens GraphiQL in the browser
  # POST /graphql  → standard JSON API (also handled here)
  forward("/graphql",
    to: Absinthe.Plug.GraphiQL,
    init_opts: [
      schema: SetmyInfo.GraphqlApi.Schema,
      interface: :simple,
      default_url: "/graphql"
    ]
  )

  match _ do
    send_resp(conn, 404, "Not found")
  end
end
