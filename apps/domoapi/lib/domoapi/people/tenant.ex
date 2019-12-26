defmodule Domoapi.People.Tenant do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Bcrypt
  alias Domoapi.Place.Apartment
  alias Domoapi.People
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :title, :apartment_id]}
  schema "tenants" do
    field :title, :string
    field :deleted, :boolean, default: false
    field :phone_number, :string
    field :password, :string
    field :raw_password, :string, virtual: true
    belongs_to :company, Company
    belongs_to :apartment, Apartment
    has_many :devices, People.Device
    has_many :photos, People.Photo
    timestamps()
  end

  @doc false
  def changeset(tenant, attrs) do
    tenant
    |> cast(attrs, [:title, :phone_number, :raw_password, :deleted, :apartment_id, :company_id])
    |> validate_required([:title, :phone_number, :apartment_id, :company_id])
    |> unique_constraint(:phone_number)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{raw_password: raw_password}} = changeset) do
    changeset |> put_change(:password, Bcrypt.hash_pwd_salt(raw_password))
  end

  defp hash_password(changeset) do
    changeset
  end
end
