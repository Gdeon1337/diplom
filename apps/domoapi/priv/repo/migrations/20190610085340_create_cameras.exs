defmodule Domoapi.Repo.Migrations.CreateCameras do
  use Ecto.Migration

  def change do
    create table(:cameras, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :url, :string
      add :deleted, :boolean
      add :intercom_id, references(:intercoms, on_delete: :nothing, type: :uuid)
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:cameras, [:company_id])
    create index(:cameras, [:intercom_id])    
  end
end
