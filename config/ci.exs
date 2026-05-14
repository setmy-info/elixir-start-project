import Config

# CI environment — no HTTP server, fixed port, DB sandbox when enabled.
config :graphql_api,
  start_http: false,
  port: 4002

# Uncomment to run CI tests against a real database:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "elixir_start_ci",
#   pool: Ecto.Adapters.SQL.Sandbox
