defmodule Domoapi.Users.Token do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Domoapi.Users.Company

  @derive {Jason.Encoder, only: [:id, :title]}
  schema "tokens" do
    field :title, :string
    belongs_to :company, Company
    timestamps()
  end

  @doc false
  def changeset(token, attrs) do
    token
    |> cast(attrs, [:title, :company_id])
    |> validate_required([:title, :company_id])
  end
end
