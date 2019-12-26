defmodule Domoapi.Intercoms.Camera do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :title, :url]}
  schema "cameras" do
    field :title, :string
    field :url, :string
    field :deleted, :boolean, default: false
    belongs_to :company, Company
    belongs_to :intercom, Intercom
    timestamps()
  end

  @doc false
  def changeset(camera, attrs) do
    camera
    |> cast(attrs, [:title, :url, :deleted, :intercom_id, :company_id])
    |> validate_required([:title, :url, :intercom_id, :company_id])
  end
end
