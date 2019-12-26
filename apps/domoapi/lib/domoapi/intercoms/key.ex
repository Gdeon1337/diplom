defmodule Domoapi.Intercoms.Key do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :key_data, :key_type]}
  schema "keys" do
    field :key_data, :string
    field :key_type, :string
    field :deleted, :boolean, default: false
    belongs_to :company, Company
    belongs_to :intercom, Intercom
    timestamps()
  end

  @doc false
  def changeset(key, attrs) do
    key
    |> cast(attrs, [:key_data, :key_type, :deleted, :intercom_id, :company_id])
    |> validate_required([:key_data, :key_type, :intercom_id, :company_id])
  end
end
