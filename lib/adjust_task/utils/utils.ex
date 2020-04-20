defmodule AdjustTask.Utils do
    @moduledoc """
    This module contains various utilities methods
    """    
    @seconds_in_one_day 86400
    
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
end