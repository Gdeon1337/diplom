defmodule DomoapiWeb.CompanyRolesControllerTest do
  use DomoapiWeb.ConnCase

  alias Domoapi.Users
  alias Domoapi.Users.CompanyRoles

  @create_attrs_company %{
    title: "title"
  }

  @create_attrs %{
    title: "какой-то юсер",
    contract_view: true,
    contract_read: true
  }
  @update_attrs %{
    title: "какой-то юсер_2",
    contract_view: false,
    contract_read: false
  }
  @invalid_attrs %{
    title: nil
  }

  def token_fixture(attrs) do
    {:ok, token} =
      attrs
      |> Users.create_user
    token
  end

  def role_fixture(attrs) do
    {:ok, role} =
      attrs
      |> Users.create_role
    role
  end

  def fixture(:company_roles) do
    {:ok, company_roles} = Users.create_company_roles(@create_attrs)
    company_roles
  end

  def company_fixture() do
    {:ok, company} =
      %{
        title: "title"
      }
      |> Enum.into(@create_attrs_company)
      |> Users.create_company()
    company
  end

  setup %{conn: conn} do
    company = company_fixture()
      role = role_fixture(%{
        title: "admin"
      })
      user = token_fixture(%{
        company_id: company.id,
        title: "title",
        login: "admin",
        raw_password: "admin",
        role_id: role.id
      })
      {:ok, conn: put_req_header(conn, "accept", "application/json")}
      {:ok, conn: put_req_header(conn, "authorization", "Bearer #{Base.encode64("admin:admin")}")}
  end

  describe "index" do
    test "lists all company_roles", %{conn: conn} do
      conn = get(conn, Routes.company_roles_path(conn, :index, page: 1, page_size: 10))
      assert json_response(conn, 200) == %{
        "company_roles" => [],
        "page_number" => 1,
        "page_size" => 10,
        "total_entries" => 0,
        "total_pages" => 1
      }
    end
  end

  describe "create company_roles" do
    test "renders company_roles when data is valid", %{conn: conn} do
      conn = post(conn, Routes.company_roles_path(conn, :create), @create_attrs)
      assert %{    
        "title"=> "какой-то юсер",
        "contract_view" => true,
        "contract_read" => true} = json_response(conn, 201)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.company_roles_path(conn, :create), company_roles: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update company_roles" do
    test "renders company_roles when data is valid", %{conn: conn} do
      conn = post(conn, Routes.company_roles_path(conn, :create), @create_attrs)
      company_roles = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = put(conn, Routes.company_roles_path(conn, :update, company_roles.id), company_roles: @update_attrs)
      assert %{
        "title" => "какой-то юсер_2",
        "contract_view" => false,
        "contract_read" => false} = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.company_roles_path(conn, :create), @create_attrs)
      company_roles = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = put(conn, Routes.company_roles_path(conn, :update, company_roles.id), company_roles: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete company_roles" do
    test "deletes chosen company_roles", %{conn: conn} do
      conn = post(conn, Routes.company_roles_path(conn, :create), @create_attrs)
      company_roles = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = delete(conn, Routes.company_roles_path(conn, :delete, company_roles.id))
      assert response(conn, 204)
      end
  end

  defp create_company_roles(_) do
    company_roles = fixture(:company_roles)
    {:ok, company_roles: company_roles}
  end
end
