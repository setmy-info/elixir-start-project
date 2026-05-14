defmodule SetmyInfo.CoreLogic.Repo do
  @moduledoc """
  Ecto repository backed by PostgreSQL.

  Configure the connection in config/dev.exs, config/test.exs, and
  config/prod.exs (or via environment variables in config/runtime.exs).

  Basic usage:

      alias SetmyInfo.CoreLogic.Repo
      Repo.all(MySchema)
      Repo.insert(%MySchema{field: value})
  """

  use Ecto.Repo,
    otp_app: :core_logic,
    adapter: Ecto.Adapters.Postgres
end
