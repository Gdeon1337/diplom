defmodule Domoapi.People.Device do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.People.Tenant
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :device_type, :token]}  
  schema "devices" do
    field :serial_key, :string
    field :device_type, :string
    field :deleted, :boolean, default: false
    field :token, :string
    belongs_to :tenant, Tenant
    timestamps()
  end

  @doc false
  def changeset(device, attrs) do
    device
    |> cast(attrs, [:device_type, :token, :serial_key, :deleted, :tenant_id])
    |> validate_required([:device_type, :serial_key, :token, :tenant_id])
  end
end
