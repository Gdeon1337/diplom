defmodule Domoapi.Users.Role do
  use Domoapi.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :title]}
  schema "roles" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(role, attrs) do
    role
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end
