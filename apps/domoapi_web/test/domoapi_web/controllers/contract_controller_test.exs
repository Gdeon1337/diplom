defmodule DomoapiWeb.ContractControllerTest do
    use DomoapiWeb.ConnCase
    alias Domoapi.Place
    alias Domoapi.Place.Apartment
    alias Domoapi.People.Tenant
    alias Domoapi.Place.Contract
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
        intercom_service: false
      }
          
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
        test "lists all contract apartment", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
            house_id: house.id,
            apartment_number: 21
          }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          conn = get(conn, Routes.contract_path(conn, :index, apartment_id: apartment.id, page: 1, page_size: 10))
          assert json_response(conn, 200) == %{
            "contracts" => [],
            "page_number" => 1,
            "page_size" => 10,
            "total_entries" => 0,
            "total_pages" => 1
          }
        end
        test "lists all contract tenant", %{conn: conn} do
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
          conn = get(conn, Routes.contract_path(conn, :index, tenant_id: tenant.id, page: 1, page_size: 10))
          assert json_response(conn, 200) == %{
            "contracts" => [],
            "page_number" => 1,
            "page_size" => 10,
            "total_entries" => 0,
            "total_pages" => 1
          }
        end
      end
  
      describe "create contract" do  
        test "renders contract tenant when data is valid", %{conn: conn} do
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
          contract = %{
            number_contracts: "12343453",
            intercom_service: true, 
            video_service: true, 
            recognition_service: true,
            datetime_video: "2019-07-18T07:30:25",
            datetime_intercom: "2019-07-18T07:30:25",
            datetime_recognition: "2019-07-18T07:30:25",
            datetime_contract: "2019-07-18T07:30:25",
            tenant_id: tenant.id
          }
          conn = post(conn, Routes.contract_path(conn, :create), contract)
          contract =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          conn = get(conn, Routes.contract_path(conn, :show, contract.id))
          assert %{
            "datetime_contract" => "2019-07-18T07:30:25",
            "datetime_intercom" => "2019-07-18T07:30:25",
            "datetime_recognition" => "2019-07-18T07:30:25",
            "datetime_video" => "2019-07-18T07:30:25",
            "docs" => nil,
            "intercom_service" => true,
            "number_contracts" => 12343453,
            "recognition_service" => true,
            "video_service" => true
          } = json_response(conn, 200)
        end

        test "renders contract apartment when data is valid", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
            house_id: house.id,
            apartment_number: 21
          }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          contract = %{
            number_contracts: "12343453",
            intercom_service: true, 
            video_service: true, 
            recognition_service: true,
            datetime_video: "2019-07-18T07:30:25",
            datetime_intercom: "2019-07-18T07:30:25",
            datetime_recognition: "2019-07-18T07:30:25",
            datetime_contract: "2019-07-18T07:30:25",
            apartment_id: apartment.id
          }
          conn = post(conn, Routes.contract_path(conn, :create), contract)
          contract =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          conn = get(conn, Routes.contract_path(conn, :show, contract.id))
          assert %{
            "datetime_contract" => "2019-07-18T07:30:25",
            "datetime_intercom" => "2019-07-18T07:30:25",
            "datetime_recognition" => "2019-07-18T07:30:25",
            "datetime_video" => "2019-07-18T07:30:25",
            "docs" => nil,
            "intercom_service" => true,
            "number_contracts" => 12343453,
            "recognition_service" => true,
            "tenant_id" => nil,
            "video_service" => true
          } = json_response(conn, 200)
        end
    
        test "renders errors when data is invalid", %{conn: conn} do
          conn = post(conn, Routes.contract_path(conn, :create), @invalid_attrs)
          assert json_response(conn, 422)["errors"] != %{}
        end
      end
    
      describe "update contract" do
        test "renders contract when data is valid", %{conn: conn} do
          conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
          house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          apartment = %{
              house_id: house.id,
              apartment_number: 21
            }
          conn = post(conn, Routes.apartment_path(conn, :create), apartment)
          apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          contract = %{
            number_contracts: "12343453",
            intercom_service: true, 
            video_service: true, 
            recognition_service: true,
            datetime_video: "2019-07-18T07:30:25",
            datetime_intercom: "2019-07-18T07:30:25",
            datetime_recognition: "2019-07-18T07:30:25",
            datetime_contract: "2019-07-18T07:30:25",
            apartment_id: apartment.id
          }
          conn = post(conn, Routes.contract_path(conn, :create), contract)
          contract =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
          conn = put(conn, Routes.contract_path(conn, :update, contract.id), contract: @update_attrs)
          conn = get(conn, Routes.contract_path(conn, :show, contract.id))
          assert %{"intercom_service" => false} = json_response(conn, 200)
        end
      end
    
      describe "delete contract" do
        test "deletes chosen contract", %{conn: conn} do
            conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
            house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            apartment = %{
                house_id: house.id,
                apartment_number: 21
              }
            conn = post(conn, Routes.apartment_path(conn, :create), apartment)
            apartment =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            contract = %{
              number_contracts: "12343453",
              intercom_service: true, 
              video_service: true, 
              recognition_service: true,
              datetime_video: "2019-07-18T07:30:25",
              datetime_intercom: "2019-07-18T07:30:25",
              datetime_recognition: "2019-07-18T07:30:25",
              datetime_contract: "2019-07-18T07:30:25",
              apartment_id: apartment.id
            }
            conn = post(conn, Routes.contract_path(conn, :create), contract)
            contract =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
            conn = delete(conn, Routes.contract_path(conn, :delete, contract.id))
            assert response(conn, 200)
        end
      end
  
  end