defmodule Domoapi.Repo.Migrations.CreateIntercomsApartments do
  use Ecto.Migration

  def change do
    create table(:intercoms, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :house_id, references(:houses, on_delete: :nothing, type: :uuid)
      add :enabled, :boolean
      add :serial_key, :string
      add :hardware_version, :string
      add :software_version, :string
      add :host_name, :string
      add :deleted, :boolean
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create table(:apartments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :deleted, :boolean
      add :apartment_number, :integer
      add :house_id, references(:houses, on_delete: :nothing, type: :uuid)
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create table(:intercoms_apartments, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :intercom_id, references(:intercoms, on_delete: :nothing, type: :uuid)
      add :apartment_id, references(:apartments, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:intercoms, [:house_id])
    create index(:intercoms, [:company_id])
    create index(:intercoms, [:serial_key])

    create index(:apartments, [:house_id])
    create index(:apartments, [:company_id])
    create index(:apartments, [:apartment_number])

    create index(:intercoms_apartments, [:intercom_id])
    create index(:intercoms_apartments, [:apartment_id])
  end
end
