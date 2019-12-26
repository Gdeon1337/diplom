defmodule DomoapiWeb.TenantControllerTest do
    use DomoapiWeb.ConnCase
  
    alias Domoapi.Place
    alias Domoapi.Place.Apartment
    alias Domoapi.People.Tenant
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
        title: "update title",
      }
      @invalid_attrs %{title: nil}
    
      def fixture(:apartment) do
        {:ok, apartment} = Place.create_apartment(@create_attrs)
        apartment
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
        test "lists all tenants", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
            house_id: house.id,
            apartment_number: 21
          }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          conn = get(conn, Routes.tenant_path(conn, :index, apartment_id: apartment.id))
          assert json_response(conn, 200) == []
        end
      end
  
      describe "create tenants" do  
        test "renders tenants when data is valid", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
            house_id: house.id,
            apartment_number: 21
          }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          tenant = %{
            title: "title",
            phone_number: "89176294234",
            apartment_id: apartment.id
          }
          conn = post(conn, Routes.tenant_path(conn, :create), tenant)
          assert %{"id" => id} = json_response(conn, 201)
          tenant =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          conn = get(conn, Routes.tenant_path(conn, :show, tenant.id))
          assert %{
                "title" => "title"
                 } = json_response(conn, 200)
        end
    
        test "renders errors when data is invalid", %{conn: conn} do
          conn = post(conn, Routes.tenant_path(conn, :create), @invalid_attrs)
          assert json_response(conn, 422)["errors"] != %{}
        end
      end
    
      describe "update tenant" do
        test "renders tenant when data is valid", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
              house_id: house.id,
              apartment_number: 21
            }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          tenant = %{
            title: "title",
            phone_number: "89176294234",
            apartment_id: apartment.id
          }
          conn = post(conn, Routes.tenant_path(conn, :create), tenant)
          tenant =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}

          # assert capture_log(fn ->
          #   Logger.debug("log msg")
          # end) =~ inspect(apartment)
          conn = put(conn, Routes.tenant_path(conn, :update, tenant.id), tenant: @update_attrs)
          conn = get(conn, Routes.tenant_path(conn, :show, tenant.id))
          assert %{
                   "title" => "update title",
                 } = json_response(conn, 200)
        end
      end
    
      describe "delete tenant" do
    
        test "deletes chosen tenant", %{conn: conn} do
            conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
            house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            apartment = %{
                house_id: house.id,
                apartment_number: 21
              }
            conn = post(conn, Routes.apartment_path(conn, :create), apartment)
            apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            tenant = %{
                title: "title",
                phone_number: "89176294234",
                apartment_id: apartment.id
            }
            conn = post(conn, Routes.tenant_path(conn, :create), tenant)
            tenant =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            conn = delete(conn, Routes.tenant_path(conn, :delete, tenant.id))
            assert response(conn, 200)
        end
      end
  
  end