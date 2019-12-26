defmodule Domoapi.Repo.Migrations.CreateBindingToken do
  use Ecto.Migration

  def change do
    create table(:binding_token, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :time_to_live, :integer
      add :activated, :boolean
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create index(:binding_token, [:tenant_id])  
  end
end
