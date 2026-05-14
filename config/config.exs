import Config

config :graphql_api,
  port: 4000

# Mix defaults to :dev when no MIX_ENV is set.
# Map :dev → :local so a plain `mix` on a developer machine uses local.exs.
# Set MIX_ENV=dev explicitly to target the shared development server config.
effective_env = if config_env() == :dev, do: :local, else: config_env()
import_config "#{effective_env}.exs"
