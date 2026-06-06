import Config

config :logger, level: :info

config :logger, :console, format: {SetmyInfo.CalculatorApp.JsonLogFormatter, :format}

# Configure via DATABASE_PATH env var or fall back to a local file.
# config :calculator_app, SetmyInfo.Ecto.Repo,
#   database: System.get_env("DATABASE_PATH", "calculator_app.db")
