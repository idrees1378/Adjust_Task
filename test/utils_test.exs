defmodule AdjustTaskTest.Utils do
    use ExUnit.Case, async: true

    alias AdjustTask.Utils

    test "day Start Test. Failed" do
        assert :error == Utils.day_start(%{year: 2018})
    end

    test "day Start Test. Success" do
        date = ~U[2020-04-01 06:07:00.0Z]
        day_start = DateTime.to_unix(~U[2020-04-01 00:00:00.0Z], :millisecond)

        assert day_start == Utils.day_start(date)
    end

    test "Is past date. true success" do
        date = ~D[2018-08-12]

        assert true == Utils.is_past_date(date)
    end

    test "Is past date. false Success" do
        date = Date.utc_today

        assert false == Utils.is_past_date(date)
    end
end