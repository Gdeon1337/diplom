defmodule DomoapiWeb.UserControllerTest do
    use DomoapiWeb.ConnCase
    alias Domoapi.Users
    import ExUnit.CaptureLog
    require Logger

    @create_attrs_company %{
      title: "title"
    }

    def company_fixture() do
      {:ok, company} =
        %{
          title: "title"
        }
        |> Enum.into(@create_attrs_company)
        |> Users.create_company()
      company
    end

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

    
    @update_attrs %{
      title: "some updated title"
    }
    @invalid_attrs %{title: nil}
  
    def fixture(:user) do
      {:ok, user} = Place.create_user(@create_attrs)
      user
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

    @create_attrs %{
      title: "some title",
      login: "login",
      raw_password: "password"
    }

    describe "index" do
      test "lists all users", %{conn: conn} do
        conn = get(conn, Routes.user_path(conn, :index, page: 1, page_size: 10))
        assert %{
            "users" => [%{
               "title" => "title"
  
            }],
            "page_number" => 1,
            "page_size" => 10,
            "total_entries" => 1,
            "total_pages" => 1
          } = json_response(conn, 200) 
      end
    end
    
  end