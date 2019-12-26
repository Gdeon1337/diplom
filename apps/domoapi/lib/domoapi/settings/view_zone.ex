defmodule Domoapi.Users.CompanyRoles do
  use Domoapi.Schema
  alias Domoapi.Users
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :title, :houses_view, :houses_read, :intercoms_view, :intercoms_read, :apartments_view, :apartments_read, :cameras_view, :cameras_read, :settings_view, :settings_read, :keys_view, :keys_read, :tenants_view, :tenants_read, :photos_view, :photos_read, :device_view, :device_read, :users_view, :users_read, :company_roles_view, :company_roles_read, :binding_token_view, :binding_token_read, :contract_view, :contract_read]}
  schema "company_roles" do
    belongs_to :company, Users.Company

    field :title, :string

    field :houses_view, :boolean, default: false
    field :houses_read, :boolean, default: false

    field :intercoms_view, :boolean, default: false
    field :intercoms_read, :boolean, default: false

    field :apartments_view, :boolean, default: false
    field :apartments_read, :boolean, default: false

    field :cameras_view, :boolean, default: false
    field :cameras_read, :boolean, default: false

    field :settings_view, :boolean, default: false
    field :settings_read, :boolean, default: false

    field :keys_view, :boolean, default: false
    field :keys_read, :boolean, default: false

    field :tenants_view, :boolean, default: false
    field :tenants_read, :boolean, default: false

    field :photos_view, :boolean, default: false
    field :photos_read, :boolean, default: false

    field :device_view, :boolean, default: false
    field :device_read, :boolean, default: false

    field :company_roles_view, :boolean, default: false
    field :company_roles_read, :boolean, default: false

    field :binding_token_view, :boolean, default: false
    field :binding_token_read, :boolean, default: false

    field :users_view, :boolean, default: false
    field :users_read, :boolean, default: false

    field :contract_view, :boolean, default: false
    field :contract_read, :boolean, default: false

    field :deleted, :boolean, default: false
    timestamps()
  end

  @doc false
  def changeset(company_roles, attrs) do
    company_roles
    |> cast(attrs, [:title, :contract_view, :contract_read, :deleted, :houses_view, :houses_read, :intercoms_view, :intercoms_read, :apartments_view, :apartments_read, :cameras_view, :cameras_read, :settings_view, :settings_read, :keys_view, :keys_read, :tenants_view, :tenants_read, :photos_view, :photos_read, :device_view, :device_read, :users_view, :users_read, :company_roles_view, :company_roles_read, :binding_token_view, :binding_token_read, :company_id])
    |> validate_required([:title, :company_id])
  end
end
