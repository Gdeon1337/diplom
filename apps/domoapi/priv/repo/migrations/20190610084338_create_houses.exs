defmodule Domoapi.Repo.Migrations.CreateHouses do
  use Ecto.Migration

  def change do
    create table(:houses, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :address, :string
      add :deleted, :boolean
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create index(:houses, [:company_id])
  end
end
