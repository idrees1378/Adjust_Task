defmodule AdjustTask.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  
  def start(_type, _args) do
    Logger.info(fn -> "Application started." end)
    children = [
      AdjustTask.Repo,
      AdjustTask.Worker
    ]

    opts = [strategy: :one_for_one, name: AdjustTask.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
