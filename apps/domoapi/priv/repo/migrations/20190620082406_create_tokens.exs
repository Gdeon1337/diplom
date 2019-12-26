defmodule Domoapi.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def change do
    create table(:tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create index(:tokens, [:company_id])  
  end
end
