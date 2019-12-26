defmodule Domoapi.Repo.Migrations.CreateContracts do
  use Ecto.Migration

  def change do
    create table(:contracts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :number_contracts, :integer
      add :intercom_service, :boolean, default: false
      add :video_service, :boolean, default: false
      add :recognition_service, :boolean, default: false
      add :docs, :binary
      add :datetime_video, :naive_datetime
      add :datetime_intercom, :naive_datetime
      add :datetime_recognition, :naive_datetime
      add :datetime_contract, :naive_datetime
      add :deleted, :boolean, default: false
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)
      add :apartment_id, references(:apartments, on_delete: :nothing, type: :uuid)
      add :tenant_id, references(:tenants, on_delete: :nothing, type: :uuid)

      timestamps()
    end

    create index(:contracts, [:company_id])  
    create index(:contracts, [:apartment_id])  
    create index(:contracts, [:tenant_id])  

  end
end
