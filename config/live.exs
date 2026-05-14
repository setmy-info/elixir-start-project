import Config

# Live (production) environment — read port from system environment.
config :graphql_api,
  port: String.to_integer(System.get_env("PORT") || "4000")

# Configure via environment variables at runtime:
# config :core_logic, SetmyInfo.CoreLogic.Repo,
#   url: System.get_env("DATABASE_URL"),
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
