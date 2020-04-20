defmodule AdjustTask.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger
  
  def start(_type, _args) do
    Logger.info(fn -> "Application started." end)
    
    xandra_configs = Application.get_env(:xandra, Xandra)
    keyspace = xandra_configs[:keyspace]
    
    xandra_configs =
      [  after_connect: fn(conn) ->
         {:ok, _} = Xandra.execute(conn, "USE " <> keyspace)
      end] ++ xandra_configs

    children = [
      AdjustTask.Repo,
      {Xandra.Cluster, xandra_configs},
      {AdjustTask.Worker, nil}
    ]

    opts = [strategy: :one_for_one, name: AdjustTask.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
