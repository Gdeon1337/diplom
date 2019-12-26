defmodule Domoapi.Users.Company do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Place.House
  alias Domoapi.Users.User

  @derive {Jason.Encoder, only: [:id, :title]}
  schema "companies" do
    field :title, :string
    field :deleted, :boolean, default: false

    has_many :houses, House
    has_many :users, User
    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:title, :deleted])
    |> validate_required([:title])
  end
end
