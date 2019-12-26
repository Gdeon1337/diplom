defmodule DomoapiWeb.ApartmentsControllerTest do
    use DomoapiWeb.ConnCase
  
    alias Domoapi.Place
    alias Domoapi.Place.Apartment
    
    alias Domoapi.Users

    @create_attrs_company %{
        title: "title"
      }
      
    @create_attrs_house %{
        title: "some title",
        address: "тут должен быть адрес"
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
        apartment_number: 24,
      }
      @invalid_attrs %{title: nil}
    
      setup %{conn: conn} do
        company = company_fixture()
        role = role_fixture(%{
          title: "admin"
        })
        token_fixture(%{
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
        test "lists all apartments", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          conn = get(conn, Routes.apartment_path(conn, :index, house_id: house.id, page: 1, page_size: 10))
          assert json_response(conn, 200) == %{
            "apartments" => [],
            "page_number" => 1,
            "page_size" => 10,
            "total_entries" => 0,
            "total_pages" => 1
          }
        end
      end
  
      describe "create apartment" do  
        test "renders apartment when data is valid", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
            house_id: house.id,
            apartment_number: 21
          }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          assert %{"id" => id} = json_response(conn, 201)
          conn = get(conn, Routes.apartment_path(conn, :show, id))
          assert %{
                "apartment_number" => 21
                 } = json_response(conn, 200)
        end
    
        test "renders errors when data is invalid", %{conn: conn} do
          conn = post(conn, Routes.apartment_path(conn, :create), apartment: @invalid_attrs)
          assert json_response(conn, 422)["errors"] != %{}
        end
      end
    
      describe "update apartment" do
        test "renders apartment when data is valid", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
              house_id: house.id,
              apartment_number: 21
            }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          # assert capture_log(fn ->
          #   Logger.debug("log msg")
          # end) =~ inspect(apartment)
          conn = put(conn, Routes.apartment_path(conn, :update, apartment.id), apartment: @update_attrs)
          conn = get(conn, Routes.apartment_path(conn, :show, apartment.id))
          assert %{
                   "apartment_number" => 24,
                 } = json_response(conn, 200)
        end
      end
    
      describe "delete apartment" do
    
        test "deletes chosen apartment", %{conn: conn} do
            conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
            house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            apartment = %{
                house_id: house.id,
                apartment_number: 21
              }
            conn = post(conn, Routes.apartment_path(conn, :create), apartment)
            apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            conn = delete(conn, Routes.apartment_path(conn, :delete, apartment.id))
            assert response(conn, 200)
        end
      end
  end