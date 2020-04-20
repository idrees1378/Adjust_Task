defmodule AdjustTask.Scylla.ScyllaUtils do
    @moduledoc """
      This module contains scylla utilities and common methods to be used to query scylla db.
    """
  
    def prepare!(statement) do
      Xandra.Cluster.prepare!(name(), statement, pool: pool())
    end
    
    def execute!(statement) do
      Xandra.Cluster.execute!(name(), statement,
        pool: pool(), timestamp_format: :integer, consistency: :one)
    end
  
    def execute!(statement, params, consistency \\ :local_quorum) do
        Xandra.Cluster.execute!(name(), statement, params, pool: pool(), 
        timestamp_format: :integer, consistency: consistency)
    end
  
    defp name() do
      Application.get_env(:xandra, Xandra)[:name]
    end
  
    defp pool() do
      Application.get_env(:xandra, Xandra)[:pool]
    end
end
  