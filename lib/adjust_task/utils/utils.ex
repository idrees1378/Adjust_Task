defmodule AdjustTask.Utils do
    @moduledoc """
    This module contains various utilities methods
    """    

    @seconds_in_one_day 86400

    @doc """
        Computes year start date from Date.Range
        ##parameters
        - date: Date from which year first day shall be computed
    """
    def year_start(timestamp) when is_integer(timestamp) do
        with {:ok , dt} <- DateTime.from_unix(timestamp, :millisecond) do
            dt
            |> Map.put(:month, 1)
            |> Map.put(:day, 1)
            |> Map.put(:hour, 0)
            |> Map.put(:minute, 0)
            |> Map.put(:second, 0)
            |> Map.put(:microsecond, {0, 0})
            |> DateTime.to_unix(:millisecond)
        else 
            _ -> :error
        end
    end

    def year_start(%Date{year: year}) do
        DateTime.utc_now
        |> Map.put(:year, year)
        |> Map.put(:month, 1)
        |> Map.put(:day, 1)
        |> Map.put(:hour, 0)
        |> Map.put(:minute, 0)
        |> Map.put(:second, 0)
        |> Map.put(:microsecond, {0, 0})
        |> DateTime.to_unix(:millisecond)
    end
    def year_start(_), do: :error

    def day_start(%DateTime{} = dt) do
        %DateTime{year: dt.year, month: dt.month, day: dt.day, zone_abbr: dt.zone_abbr,
                  hour: 0, minute: 0, second: 0, microsecond: {0, 0},
                  utc_offset: dt.utc_offset, std_offset: dt.utc_offset, time_zone: dt.time_zone}
        |> DateTime.to_unix(:millisecond)
    end
    def day_start(_), do: :error

    def previous_date(%Date{} = date) do
        Date.add(date, -1)
    end
    def previous_date(_), do: :error

    def next_day(%DateTime{} = date) do
        DateTime.add(date, @seconds_in_one_day, :second)
    end

    def next_date(%Date{} = date) do
        Date.add(date, 1)
    end
    def next_date(_), do: :error

    def is_past_date(%Date{} = date) do
        today = Date.utc_today
        Date.compare(date, today)
        |> case do
            :lt -> true
            _ -> false
        end
    end

    def unix_from_srt(date_str) when is_binary(date_str) do
        date_str = String.replace(date_str, "Z", ":00")
        
        with {:ok, date} <- NaiveDateTime.from_iso8601(date_str),
            {:ok, date_time} <- DateTime.from_naive(date, "Etc/UTC") do
            DateTime.to_unix(date_time, :millisecond)
        end
    end
end