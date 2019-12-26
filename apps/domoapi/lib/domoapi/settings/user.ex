defmodule Domoapi.Users.User do
  use Domoapi.Schema
  import Ecto.Changeset
  alias Bcrypt
  alias Domoapi.Users

  @derive {Jason.Encoder, only: [:id, :title, :login, :company_role_id]}
  schema "users" do
    field :login, :string
    field :password, :string
    field :title, :string
    field :raw_password, :string, virtual: true
    field :deleted, :boolean, default: false

    belongs_to :company_role, User.CompanyRoles
    belongs_to :company, Users.Company
    belongs_to :role, Users.Role
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:title, :login, :company_role_id, :deleted, :raw_password, :role_id, :company_id])
    |> validate_required([:title, :login, :raw_password, :role_id, :company_id])
    |> unique_constraint(:login)
    |> hash_password
  end

  defp hash_password(%Ecto.Changeset{valid?: true, changes: %{raw_password: raw_password}} = changeset) do
    changeset |> put_change(:password, Bcrypt.hash_pwd_salt(raw_password))
  end

  defp hash_password(changeset) do
    changeset
  end

end
