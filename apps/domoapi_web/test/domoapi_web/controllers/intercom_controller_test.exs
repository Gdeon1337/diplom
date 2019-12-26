defmodule DomoapiWeb.IntercomControllerTest do
  use DomoapiWeb.ConnCase

  alias Domoapi.Intercoms
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Users


  @create_attrs %{
    title: "some title"
  }
  @update_attrs %{
    title: "some updated title"
  }
  @invalid_attrs %{title: nil}

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

  def fixture(:intercom) do
    {:ok, intercom} = Intercoms.create_intercom(@create_attrs)
    intercom
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
    test "lists all intercoms", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = get(conn, Routes.intercom_path(conn, :index, house_id: house.id, page: 1, page_size: 10))
      assert json_response(conn, 200) == %{
        "intercoms" => [],
        "page_number" => 1,
        "page_size" => 10,
        "total_entries" => 0,
        "total_pages" => 1
      }
    end
  end

  describe "open the door" do
    test "intercom open the door", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      assert %{"id" => id} = json_response(conn, 201)
      conn = get(conn, Routes.intercom_intercom_path(conn, :open_door, id))

      assert %{} = json_response(conn, 200)
    end
  end

  describe "create intercom" do
    test "renders intercom when data is valid", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      assert %{"id" => id} = json_response(conn, 201)

      conn = get(conn, Routes.intercom_path(conn, :show, id))

      assert %{
               "id" => id,
               "title" => "title"
             } = json_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.intercom_path(conn, :create), intercom: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update intercom" do
    test "renders intercom when data is valid", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      intercom = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = put(conn, Routes.intercom_path(conn, :update, intercom.id), intercom: @update_attrs)
      conn = get(conn, Routes.intercom_path(conn, :show, intercom.id))
      assert %{
               "title" => "some updated title"
             } = json_response(conn, 200)
    end
  end

  describe "delete intercom" do
    test "deletes chosen intercom", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      intercom = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = delete(conn, Routes.intercom_path(conn, :delete, intercom.id))
      assert response(conn, 200)
      end
  end

  describe "bind apartments" do
    test "bind apartments valid attributes", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      intercom = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      apartment = %{
        house_id: house.id,
        apartment_number: 21
      }
      conn = post(conn, Routes.apartment_path(conn, :create), apartment)
      apartment = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = post(conn, Routes.intercom_intercom_path(conn, :bind_apartment, intercom.id, apartment_id: apartment.id))
      assert %{
        apartment_id: apartment.id,
        intercom_id: intercom.id
        } == for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
    end
    test "bind apartments invalid attributes", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      intercom = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = post(conn, Routes.intercom_intercom_path(conn, :bind_apartment, intercom.id, apartment_id: nil))
      assert json_response(conn, 415) == %{"error" => "incorrect_data", "status" => 415}
    end
  end

  describe "unbind apartments" do
    test "unbind apartments valid attributes", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      intercom = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      apartment = %{
        house_id: house.id,
        apartment_number: 21
      }
      conn = post(conn, Routes.apartment_path(conn, :create), apartment)
      apartment = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = post(conn, Routes.intercom_intercom_path(conn, :bind_apartment, intercom.id, apartment_id: apartment.id))
      conn = delete(conn, Routes.intercom_intercom_path(conn, :unbind_apartment, intercom.id, apartment_id: apartment.id))
      assert json_response(conn, 200) == %{}
    end
  end

  describe "binds apartments" do
    test "binds apartments valid attributes", %{conn: conn} do
      conn = post(conn, Routes.house_path(conn, :create), @create_attrs_house)
      house =  for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      intercom =
      %{ 
        title: "title", 
        enabled: true,
        serial_key: "1234", 
        hardware_version: "1",
        software_version: "2",
        host_name: "host_name",
        house_id: house.id
        }
      conn = post(conn, Routes.intercom_path(conn, :create), intercom)
      intercom = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
      conn = get(conn, Routes.intercom_intercom_path(conn, :bind_apartments, intercom.id, page: 1, page_size: 10))
      assert json_response(conn, 200) == %{
        "intercoms_apartments" => [],
        "page_number" => 1,
        "page_size" => 10,
        "total_entries" => 0,
        "total_pages" => 1
        }
    end
  end

  defp create_intercom(_) do
    intercom = fixture(:intercom)
    {:ok, intercom: intercom}
  end
end
