defmodule Domoapi.Repo.Migrations.CreateArchiveVisits do
  use Ecto.Migration

  def change do
    create table(:archive_visits) do

      timestamps()
    end

  end
end
