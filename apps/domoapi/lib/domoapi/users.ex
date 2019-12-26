defmodule Domoapi.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Domoapi.Repo
  alias Domoapi.Users.Token
  alias Domoapi.Users.Company
  alias Bcrypt
  require Logger


  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

  """
  def list_companies(%{"page" => page, "page_size" => page_size}) do
    Company
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  
  def list_companies(%{"page" => page}) do
    Company
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page)
  end

  def list_companies(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id), do: Repo.get!(Company, id)

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  alias Domoapi.Place

  def delete_company(%Company{} = company) do
    comapny_preload = preload_company(company)
    comapny_preload.houses
    |> Enum.map(&Place.delete_house/1)
    comapny_preload.users
    |> Enum.map(&delete_user/1)
    company
    |> Company.changeset(%{deleted: true})
    |> Repo.update()
  end

  def preload_company(company) do
    Repo.preload(company, [:houses, :users])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{source: %Company{}}

  """
  def change_company(%Company{} = company) do
    Company.changeset(company, %{})
  end

  def check_user(login, password) do
    user = get_user_by_login(login)
    if check_pass(user, password) do
      user
    else
      {:error, :unauthorized}
    end
end

def check_user(_attrs) do
    Logger.info("error_no_param")
    {:error, :unauthorized}
end

def check_pass(user, password) when not is_nil(user) do
    Logger.info("check_pass")
    Bcrypt.verify_pass(password, user.password)
end

def check_pass(user, _password) when is_nil(user) do
    Logger.info("incorrect login or password")
    false
end

  alias Domoapi.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(%{"page" => page, "page_size" => page_size, "company_id" => company_id}) do
    User
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def list_users(%{"page" => page, "company_id" => company_id}) do
    User
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> Repo.paginate(page: page)
  end

  def list_users(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user_auth(id) do
    query = from u in User,
    where: u.id == ^id
    Repo.one(query)
  end

  def get_user_by_login(login), do: Repo.get_by(User, login: login)



  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    user
    |> User.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  alias Domoapi.Users.Role

  @doc """
  Returns the list of roles.

  ## Examples

      iex> list_roles()
      [%Role{}, ...]

  """
  def list_roles do
    Repo.all(Role)
  end

  @doc """
  Gets a single role.

  Raises `Ecto.NoResultsError` if the Role does not exist.

  ## Examples

      iex> get_role!(123)
      %Role{}

      iex> get_role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_role!(id), do: Repo.get!(Role, id)

  @doc """
  Creates a role.

  ## Examples

      iex> create_role(%{field: value})
      {:ok, %Role{}}

      iex> create_role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_role(attrs \\ %{}) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a role.

  ## Examples

      iex> update_role(role, %{field: new_value})
      {:ok, %Role{}}

      iex> update_role(role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Role.

  ## Examples

      iex> delete_role(role)
      {:ok, %Role{}}

      iex> delete_role(role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking role changes.

  ## Examples

      iex> change_role(role)
      %Ecto.Changeset{source: %Role{}}

  """
  def change_role(%Role{} = role) do
    Role.changeset(role, %{})
  end

  @doc """
  Returns the list of tokens.

  ## Examples

      iex> list_tokens()
      [%Token{}, ...]

  """
  def list_tokens do
    Repo.all(Token)
  end

  @doc """
  Gets a single token.

  Raises `Ecto.NoResultsError` if the Token does not exist.

  ## Examples

      iex> get_token!(123)
      %Token{}

      iex> get_token!(456)
      ** (Ecto.NoResultsError)

  """
  def get_token!(id), do: Repo.get!(Token, id)

  @doc """
  Creates a token.

  ## Examples

      iex> create_token(%{field: value})
      {:ok, %Token{}}

      iex> create_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_token(attrs \\ %{}) do
    %Token{}
    |> Token.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a token.

  ## Examples

      iex> update_token(token, %{field: new_value})
      {:ok, %Token{}}

      iex> update_token(token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_token(%Token{} = token, attrs) do
    token
    |> Token.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Token.

  ## Examples

      iex> delete_token(token)
      {:ok, %Token{}}

      iex> delete_token(token)
      {:error, %Ecto.Changeset{}}

  """
  def delete_token(%Token{} = token) do
    Repo.delete(token)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking token changes.

  ## Examples

      iex> change_token(token)
      %Ecto.Changeset{source: %Token{}}

  """
  def change_token(%Token{} = token) do
    Token.changeset(token, %{})
  end

  alias Domoapi.Users.CompanyRoles

  @doc """
  Returns the list of company_roles.

  ## Examples

      iex> list_company_roles()
      [%CompanyRoles{}, ...]

  """
  def list_company_roles(%{"page" => page, "page_size" => page_size, "company_id" => company_id}) do
    CompanyRoles
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_company_roles(%{"page" => page, "company_id" => company_id}) do
    CompanyRoles
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> Repo.paginate(page: page)
  end
  def list_company_roles(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single company_roles.

  Raises `Ecto.NoResultsError` if the View zone does not exist.

  ## Examples

      iex> get_company_roles!(123)
      %CompanyRoles{}

      iex> get_company_roles!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company_roles!(id), do: Repo.get!(CompanyRoles, id)

  @doc """
  Creates a company_roles.

  ## Examples

      iex> create_company_roles(%{field: value})
      {:ok, %CompanyRoles{}}

      iex> create_company_roles(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company_roles(attrs \\ %{}) do
    %CompanyRoles{}
    |> CompanyRoles.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a company_roles.

  ## Examples

      iex> update_company_roles(company_roles, %{field: new_value})
      {:ok, %CompanyRoles{}}

      iex> update_company_roles(company_roles, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company_roles(%CompanyRoles{} = company_roles, attrs) do
    company_roles
    |> CompanyRoles.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a CompanyRoles.

  ## Examples

      iex> delete_company_roles(company_roles)
      {:ok, %CompanyRoles{}}

      iex> delete_company_roles(company_roles)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company_roles(%CompanyRoles{} = company_roles) do
    company_roles
    |> CompanyRoles.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company_roles changes.

  ## Examples

      iex> change_company_roles(company_roles)
      %Ecto.Changeset{source: %CompanyRoles{}}

  """
  def change_company_roles(%CompanyRoles{} = company_roles) do
    CompanyRoles.changeset(company_roles, %{})
  end
end
