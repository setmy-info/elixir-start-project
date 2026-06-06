import Config

import_config "dev.exs"

config :calculator_app, SetmyInfo.Ecto.Repo, database: "calculator_app_local.db"
