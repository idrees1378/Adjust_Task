defmodule AdjustTask.Repo do
    use Ecto.Repo, otp_app: :adjust_task, adapter: Ecto.Adapters.Postgres
end