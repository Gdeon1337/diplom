defmodule Domoapi.Repo.Migrations.CreateDevices do
  use Ecto.Migration

  def change do
    create table(:devices, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :serial_key, :string
      add :device_type, :string
      add :deleted, :boolean
      add :token, :string
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create index(:devices, [:serial_key])    
    create index(:devices, [:tenant_id])    
  end
end
