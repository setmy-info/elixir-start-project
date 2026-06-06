defmodule SetmyInfo.Ecto.Repo do
  @moduledoc """
  Ecto repository backed by SQLite3.

  Configure the database path per environment:

  - `test`  → `config/test.exs`
  - `local` → `config/local.exs`
  - `live`  → `config/live.exs` or `DATABASE_PATH` env var

  The repository is only started when a configuration entry exists for
  `{:calculator_app, SetmyInfo.Ecto.Repo}`.  Running without a database
  (e.g. in `dev`) is intentionally supported.

  ## Basic usage

      alias SetmyInfo.Ecto.Repo
      Repo.all(SetmyInfo.Ecto.Person)
      Repo.insert(%SetmyInfo.Ecto.Person{first_name: "Alice", last_name: "Smith"})
  """

  use Ecto.Repo,
    otp_app: :calculator_app,
    adapter: Ecto.Adapters.SQLite3
end
