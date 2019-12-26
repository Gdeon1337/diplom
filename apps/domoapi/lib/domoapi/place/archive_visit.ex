defmodule Domoapi.Place.ArchiveVisit do
  use Domoapi.Schema
  alias Domoapi.Place.Apartment
  alias Domoapi.Users.Company
  alias Domoapi.Place.Tenant

  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :apartment_number, :house_id]}
  schema "archive_visits" do
    field :image, :string
    field :date_time, :naive_datetime
    field :type, :string

    field :deleted, :boolean, default: false
    
    belongs_to :company, Company
    belongs_to :apartment, Apartment
    belongs_to :tenant, Tenant
    timestamps()
  end

  @doc false
  def changeset(archive_visit, attrs) do
    archive_visit
    |> cast(attrs, [])
    |> validate_required([])
  end
end
