defmodule AdjustTask.Postgres.Queries do
    import Ecto.Query, warn: false

    alias AdjustTask.Worker.ApiRequestMeta

    def get_req_meta_query(filter \\ nil) do
        query = 
            from arm in ApiRequestMeta,
                select: arm
        
        filter_by(query, filter)
    end

    def get_last_req_meta_query() do
        from q in get_req_meta_query(),
            order_by: [desc: q.req_date],
            limit: 1
    end

    defp filter_by(query, nil), do: query
    defp filter_by(query, filter) do
        Enum.reduce(filter, query, fn({key, value}, query) -> 
            case key do
                :req_date ->
                    from q in query,
                        where: q.req_date == ^value
                _ -> query
            end
        end)
    end
end