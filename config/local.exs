import Config

# Local developer machine — HTTP on 4000, DB optional.
config :graphql_api,
  port: 4000

# Uncomment and adjust to enable the database locally:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   username: "postgres",
#   password: "postgres",
#   hostname: "localhost",
#   database: "elixir_start_local",
#   pool_size: 10
