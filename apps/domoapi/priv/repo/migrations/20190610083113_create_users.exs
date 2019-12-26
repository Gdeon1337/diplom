defmodule Domoapi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:company_roles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      
      add :houses_view, :boolean, default: false
      add :houses_read, :boolean, default: false

      add :intercoms_view, :boolean, default: false
      add :intercoms_read, :boolean, default: false

      add :apartments_view, :boolean, default: false
      add :apartments_read, :boolean, default: false

      add :cameras_view, :boolean, default: false
      add :cameras_read, :boolean, default: false

      add :settings_view, :boolean, default: false
      add :settings_read, :boolean, default: false

      add :keys_view, :boolean, default: false
      add :keys_read, :boolean, default: false

      add :tenants_view, :boolean, default: false
      add :tenants_read, :boolean, default: false

      add :photos_view, :boolean, default: false
      add :photos_read, :boolean, default: false

      add :device_view, :boolean, default: false
      add :device_read, :boolean, default: false
      
      add :users_view, :boolean, default: false
      add :users_read, :boolean, default: false

      add :company_roles_view, :boolean, default: false
      add :company_roles_read, :boolean, default: false

      add :binding_token_view, :boolean, default: false
      add :binding_token_read, :boolean, default: false

      add :contract_view, :boolean, default: false
      add :contract_read, :boolean, default: false

      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)

      add :deleted, :boolean, default: false    

      timestamps()
    end
    
    create table(:roles, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      timestamps()
    end

    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :title, :string
      add :login, :string
      add :password, :string
      add :deleted, :boolean
      add :company_id, references(:companies, on_delete: :nothing, type: :uuid)
      add :role_id, references(:roles, on_delete: :nothing, type: :uuid)
      add :company_role_id, references(:company_roles, on_delete: :nothing, type: :uuid)
      timestamps()
    end

    create unique_index(:users, [:login])
    create index(:company_roles, [:company_id])
    create index(:users, [:company_id])
    create index(:users, [:company_role_id])
    create index(:users, [:role_id])
  end
end
