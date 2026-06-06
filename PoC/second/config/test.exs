import Config

config :logger, level: :warning

config :calculator_app, SetmyInfo.Ecto.Repo,
  database: "/tmp/elixir_second_test.db",
  pool_size: 1
