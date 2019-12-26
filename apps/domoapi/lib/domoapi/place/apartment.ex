defmodule Domoapi.Place.Apartment do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Place.IntercomsApartments
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.ApartmentSetting
  alias Domoapi.Place.House
  alias Domoapi.People.Tenant
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :apartment_number, :house_id]}
  schema "apartments" do
    field :deleted, :boolean, default: false
    field :apartment_number, :integer

    belongs_to :company, Company
    belongs_to :house, House

    has_many :tenants, Tenant
    has_many :intercoms_apartments, IntercomsApartments
    has_many :apartment_settings, ApartmentSetting

    many_to_many :intercoms, Intercom, join_through: IntercomsApartments

    timestamps()
  end

  @doc false
  def changeset(apartment, attrs) do
    apartment
    |> cast(attrs, [:deleted, :apartment_number, :house_id, :company_id])
    |> validate_required([:house_id, :apartment_number, :company_id])
  end
end
