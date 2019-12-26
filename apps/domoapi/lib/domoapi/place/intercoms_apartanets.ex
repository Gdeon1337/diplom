defmodule Domoapi.Place.IntercomsApartments do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Place.Apartment
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:apartment_id, :intercom_id]}
  schema "intercoms_apartments" do
    belongs_to :apartment, Apartment
    belongs_to :intercom, Intercom
    timestamps()
  end

  @doc false
  def changeset(intercoms_apartments, attrs) do
    intercoms_apartments
    |> cast(attrs, [:apartment_id, :intercom_id])
    |> validate_required([:apartment_id, :intercom_id])
  end
end
