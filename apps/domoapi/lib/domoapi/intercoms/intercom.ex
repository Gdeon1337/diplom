defmodule Domoapi.Intercoms.Intercom do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Place.IntercomsApartments
  alias Domoapi.Place.Apartment
  alias Domoapi.Intercoms
  alias Domoapi.Place.House
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :title, :serial_key, :hardware_version, :software_version, :host_name]}
  schema "intercoms" do
    field :title, :string
    field :enabled, :boolean
    field :serial_key, :string
    field :hardware_version, :string
    field :software_version, :string
    field :host_name, :string
    field :deleted, :boolean, default: false

    belongs_to :company, Company
    belongs_to :house, House

    many_to_many :apartments, Apartment, join_through: IntercomsApartments
    has_many :intercoms_apartments, IntercomsApartments
    has_one :cameras, Intercoms.Camera
    has_many :keys, Intercoms.Key
    has_many :settings, Intercoms.Setting
    timestamps()
  end

  @doc false
  def changeset(intercom, attrs) do
    intercom
    |> cast(attrs, [:title, :enabled, :deleted, :serial_key, :hardware_version, :software_version, :host_name, :house_id, :company_id])
    |> validate_required([:title, :enabled, :serial_key, :hardware_version, :software_version, :host_name, :house_id, :company_id])
  end
end
