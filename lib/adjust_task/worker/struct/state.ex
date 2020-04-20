defmodule AdjustTask.Worker.State do
    @enforce_keys [:date]
    defstruct [:date, url: Application.get_env(:adjust_task, :api_url), retries: 0, status: "processing"]
end