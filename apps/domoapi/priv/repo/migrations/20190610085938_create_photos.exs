defmodule Domoapi.Repo.Migrations.CreatePhotos do
  use Ecto.Migration

  def change do
    create table(:photos, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :photo_base64, :text
      add :deleted, :boolean
      add :encodings, {:array, :float}
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create index(:photos, [:tenant_id])    
  end
end
