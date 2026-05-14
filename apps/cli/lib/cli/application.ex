defmodule SetmyInfo.Cli.Application do
  @moduledoc """
  OTP Application for the CLI interface.

  Intentionally lightweight: no permanent GenServer processes.
  The Application module is required to satisfy OTP conventions even
  for CLI-only apps.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: SetmyInfo.Cli.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
