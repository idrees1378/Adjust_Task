defmodule AdjustTask.Worker.ApiRequestMeta do
    use Ecto.Schema
    import Ecto.Changeset

    alias AdjustTask.Worker.ApiRequestMeta

    @primary_key false
    schema "api_request_meta" do
        field :req_date, :date, primary_key: true
        field :tries, :integer, default: 0
        field :status, :string, values: ["success", "failed", "processing"], null: false

        timestamps([])
    end

    @required_fields [:req_date, :status]
    @optional_fields [:tries]

    def changeset(%ApiRequestMeta{} = changeset, params \\ %{}) do
        changeset
        |> cast(params, @required_fields ++ @optional_fields)
        |> validate_required(@required_fields)
    end
end