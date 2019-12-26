defmodule Domoapi.Repo.Migrations.CreateKeys do
  use Ecto.Migration

  def change do
    create table(:keys, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :key_data, :string
      add :key_type, :string
      add :deleted, :boolean
      add :intercom_id, references(:intercoms, on_delete: :nothing, type: :uuid)
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:keys, [:company_id])
    create index(:keys, [:intercom_id])    
  end
end
