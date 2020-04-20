defmodule AdjustTask.Scylla.Intensities do
    @moduledoc """
        This module contains method to insert and retrieve corbon intensities from database.
    """
    alias AdjustTask.Scylla.ScyllaUtils
    alias AdjustTask.Utils
    # AdjustTask.Scylla.CorbonIntensities.get(1587290400000, 1587292200000)
    @select_query "SELECT * FROM corbon_intensities WHERE year_start = ? AND from_time >= ? AND from_time <= ?"
    @insert_query "INSERT INTO corbon_intensities(year_start, from_time, to_time, forecast, actual, intensity_index) VALUES(?, ?, ?, ?, ?, ?)"

    @doc """
        Inserts corbon intensities to db in bulk.

        ## Parameters
        - date: %Date{} for the intensities. 2020-04-19
        - intensities: List of intensities from the api.
        [%{
            "from" => "2023-01-01T23:00Z",
            "to" => "2020-01-01T23:30Z",
            "intensity" => {
                "forecast" => 116,
                "actual" => 117,
                "index" => "low"
            }
        }]
    """
    def save(%Date{} = date, intensities) do
        batch = Xandra.Batch.new
        year_start = Utils.year_start(date)
        
        Enum.reduce(intensities, batch, fn(intensity, batch) ->
            add_to_batch(batch, year_start, intensity)
        end)
        |> ScyllaUtils.execute!
    end

    @doc """
        Get corbon intensities for a specific time period

        ##parameters
        - from: Unix timestamp
        - to: Unix timestamp
    """
    def get(from, to) do
        year_start = Utils.year_start(from)

        @select_query
        |> ScyllaUtils.prepare!
        |> ScyllaUtils.execute!([year_start, from, to], :local_quorum)
    end

    defp add_to_batch(batch, year_start, %{
        "from" => from,
        "to" => to,
        "intensity" => %{
            "forecast" => forecast,
            "actual" => actual,
            "index" => index
            }
        }) do
            to = Utils.unix_from_srt(to)
            from = Utils.unix_from_srt(from)

            query = ScyllaUtils.prepare!(@insert_query)
            Xandra.Batch.add(batch, query, [year_start, from, to, forecast, actual, index])
    end
    defp add_to_batch(batch, _, _), do: batch
end