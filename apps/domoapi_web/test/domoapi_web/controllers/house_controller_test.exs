defmodule DomoapiWeb.HouseControllerTest do
    use DomoapiWeb.ConnCase
    alias Domoapi.Place
    alias Domoapi.Place.House
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
  
    def fixture(:house) do
      {:ok, house} = Place.create_house(@create_attrs)
      house
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
      address: "тут должен быть адрес"
    }

    describe "index" do
      test "lists all houses", %{conn: conn} do
        conn = get(conn, Routes.house_path(conn, :index, page: 1, page_size: 10))
        assert json_response(conn, 200) == %{
          "houses" => [],
          "page_number" => 1,
          "page_size" => 10,
          "total_entries" => 0,
          "total_pages" => 1
        }
      end
    end

    describe "create house" do  
      test "renders house when data is valid", %{conn: conn} do
        conn = post(conn, Routes.house_path(conn, :create), @create_attrs)
        assert %{"id" => id} = json_response(conn, 201)
        conn = get(conn, Routes.house_path(conn, :show, id))
        assert %{
          "id" => id,
          "title" => "some title"
        } = json_response(conn, 200)
      end
  
      test "renders errors when data is invalid", %{conn: conn} do
        conn = post(conn, Routes.house_path(conn, :create), house: @invalid_attrs)
        assert json_response(conn, 422)["errors"] != %{}
      end
    end
  
    describe "update house" do
      test "renders house when data is valid", %{conn: conn} do
        conn = post(conn, Routes.house_path(conn, :create), @create_attrs)
        house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
        # assert capture_log(fn ->
        #   Logger.debug("log msg")
        # end) =~ inspect(house)
        conn = put(conn, Routes.house_path(conn, :update, house.id), house: @update_attrs)
        conn = get(conn, Routes.house_path(conn, :show, house.id))
        assert %{
                 "id" => id,
                 "title" => "some updated title"
               } = json_response(conn, 200)
      end
    end
  
    describe "delete house" do
  
      test "deletes chosen house", %{conn: conn} do
        conn = post(conn, Routes.house_path(conn, :create), @create_attrs)
        house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
        conn = delete(conn, Routes.house_path(conn, :delete, house.id))
        assert response(conn, 200)
      end
    end
  
    defp create_house(_) do
      house = fixture(:house)
      {:ok, house: house}
    end

    
  end