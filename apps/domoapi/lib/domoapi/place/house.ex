defmodule Domoapi.Place.House do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Users.Company
  alias Domoapi.Place
  alias Domoapi.Intercoms.Intercom

  @derive {Jason.Encoder, only: [:id, :title, :address]}
  schema "houses" do
    field :title, :string
    field :address, :string
    field :deleted, :boolean, default: false
    belongs_to :company, Company
    has_many :intercoms, Intercom
    has_many :apartments, Place.Apartment
    timestamps()
  end

  @doc false
  def changeset(house, attrs) do
    house
    |> cast(attrs, [:title, :address, :deleted, :company_id])
    |> validate_required([:title, :address, :company_id])
  end
end
