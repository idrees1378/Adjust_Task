defmodule AdjustTask.Postgres.PostgresUtils do
    alias AdjustTask.Worker.ApiRequestMeta
    alias AdjustTask.Postgres.Queries
    alias AdjustTask.Repo

    def create_or_update_req_meta(%{req_date: nil}), do: {:error, :invalid_input}
    def create_or_update_req_meta(%{req_date: req_date} = params) do
        with %{req_date: _} = changeset <- get_req_meta(%{req_date: req_date}) do
            changeset
            |> ApiRequestMeta.changeset(params)
            |> Repo.update

        else
            _ -> create_req_meta(params)
        end
    end
    def create_or_update_req_meta(_), do: {:error, :invalid_input}

    def create_req_meta(params) do
        %ApiRequestMeta{}
        |> ApiRequestMeta.changeset(params)
        |> Repo.insert
    end

    def get_req_meta(filter) do
        filter
        |> Queries.get_req_meta_query
        |> get
    end

    def get_last_req_meta() do
       get(Queries.get_last_req_meta_query())
    end

    @doc """
        It can be implemented later.
    """
    def get_all_failed_reqs_meta(), do: {:ok, []}

    defp get(query) do
        Repo.get_by(query, [])
    end
end