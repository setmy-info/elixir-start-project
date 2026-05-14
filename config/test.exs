import Config

# Disable HTTP server startup during tests
config :graphql_api,
  start_http: false,
  port: 4001

# Uncomment to run tests against a real database:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "elixir_start_test",
#   pool: Ecto.Adapters.SQL.Sandbox
