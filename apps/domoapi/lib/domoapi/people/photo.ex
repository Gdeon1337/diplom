defmodule Domoapi.People.Photo do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.People.Tenant
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :photo_base64, :tenant_id]}  
  schema "photos" do
    field :photo_base64, :string
    field :deleted, :boolean, default: false
    field :encodings, {:array, :float}
    belongs_to :tenant, Tenant
    timestamps()
  end

  @doc false
  def changeset(photo, attrs) do
    photo
    |> cast(attrs, [:deleted, :tenant_id, :photo_base64])
    |> validate_required([:tenant_id, :photo_base64])
  end
end
