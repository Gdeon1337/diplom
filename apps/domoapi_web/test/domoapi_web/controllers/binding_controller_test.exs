defmodule DomoapiWeb.BindingTokenControllerTest do
    use DomoapiWeb.ConnCase
  
    alias Domoapi.Place
    alias Domoapi.Place.Apartment
    alias Domoapi.People.Tenant
    alias Domoapi.People.BindingToken
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
  
      describe "index" do
        test "lists all binding_tokens", %{conn: conn} do
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
          conn = get(conn, Routes.tenant_binding_token_path(conn, :index, tenant.id))
          assert json_response(conn, 200) == []
        end
      end
  
      describe "create binding_token" do  
        test "renders binding_token when data is valid", %{conn: conn} do
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
          binding_token = %{
            title: "title"
          }
          conn = post(conn, Routes.tenant_binding_token_path(conn, :create, tenant.id), binding_token)
          binding_token =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          assert %{
                "time_to_live" => 86400
                 } = json_response(conn, 201)
        end
      end
    
      describe "delete binding_token" do
        test "deletes chosen binding_token", %{conn: conn} do
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
            binding_token = %{
                title: "title"
              }
            conn = post(conn, Routes.tenant_binding_token_path(conn, :create, tenant.id), binding_token)
            binding_token =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            conn = delete(conn, Routes.tenant_binding_token_path(conn, :delete, tenant.id, binding_token.id))
            assert response(conn, 200)
        end
      end
  
  end