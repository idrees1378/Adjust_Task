import Config

# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.

configs = Config.Reader.read!("/opt/adjust/task/configs_#{Mix.env()}.exs")
pg_configs = Keyword.fetch!(configs, :pg_configs)

config :adjust_task, ecto_repos: [AdjustTask.Repo]
config :adjust_task, AdjustTask.Repo,
    username: pg_configs[:username],
    password: pg_configs[:password],
    database: pg_configs[:database],
    hostname: pg_configs[:hostname],
    pool_size: pg_configs[:pool_size]

scylla_configs = Keyword.fetch!(configs, :scylla_configs)
scylla_auth = [username: Keyword.fetch!(scylla_configs, :username),
                password: Keyword.fetch!(scylla_configs, :password)]

config :xandra, Xandra,
    name: CassandraCluster,
    pool: Xandra.Cluster,
    autodiscovery: false,
    authentication: {Xandra.Authenticator.Password, scylla_auth},
    pool_size: scylla_configs[:pool_size],
    nodes: scylla_configs[:nodes],
    keyspace: scylla_configs[:keyspace]

config :adjust_task,
  api_url: "https://api.carbonintensity.org.uk/intensity/date/",
  start_date: "2020-04-11",
  max_retries: 3

import_config "#{Mix.env()}.exs"