defmodule Domoapi.Repo.Migrations.CreateTenants do
  use Ecto.Migration

  def change do
    create table(:tenants, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :deleted, :boolean
      add :phone_number, :string
      add :password, :string
      add :apartment_id, references(:apartments, on_delete: :nothing, type: :uuid)
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create unique_index(:tenants, [:phone_number])
    create index(:tenants, [:company_id])
    create index(:tenants, [:apartment_id])
  end
end
