defmodule AdjustTaskTest.PostgresUtils do
    use ExUnit.Case, async: true
    alias AdjustTask.Postgres.PostgresUtils
  
    test "create or update failed" do
      params = Map.take(dummy_req_meta(), [:retries])
  
      assert {:error, _} = PostgresUtils.create_or_update_req_meta(params)
    end
  
    test "create or update failed with nil date" do
      params = Map.put(dummy_req_meta(), :req_date, nil)
  
      assert {:error, _} = PostgresUtils.create_or_update_req_meta(params)
    end
  
    test "create or update success" do
      params = dummy_req_meta()
      
      assert {:ok, params} = PostgresUtils.create_or_update_req_meta(params)
    end
  
    test "Get a meta record test with no record" do
      date = Date.add(Date.utc_today(), 1)
  
      refute PostgresUtils.get_req_meta(%{req_date: date})
    end
  
    test "Get a meta record test with record present" do
      date = Date.utc_today()
      params = dummy_req_meta()
      
      assert {:ok, params} = PostgresUtils.create_or_update_req_meta(params)
      assert params == PostgresUtils.get_req_meta(%{req_date: date})
    end
  
    test "Get last meta record test with record present" do
      params = dummy_req_meta()
      
      assert {:ok, params} = PostgresUtils.create_or_update_req_meta(params)
      assert params == PostgresUtils.get_last_req_meta()
    end
  
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(AdjustTask.Repo)
    end
  
    defp dummy_req_meta() do
      date = Date.utc_today()
  
      %{
        req_date: date,
        tries: 1,
        status: "success"
      }
    end
end
  