defmodule Domoapi.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :deleted, :boolean
      timestamps()
    end

  end
end
