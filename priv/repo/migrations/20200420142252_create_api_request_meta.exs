defmodule AdjustTask.Repo.Migrations.CreateApiRequestMeta do
  use Ecto.Migration

  def change do
    create table(:api_request_meta, primary_key: false) do
      add :req_date, :date, primary_key: true
      add :tries, :integer, default: 0
      add :status, :string, null: false

      timestamps()
    end
  end
end
