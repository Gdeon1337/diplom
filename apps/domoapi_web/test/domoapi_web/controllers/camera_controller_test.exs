defmodule DomoapiWeb.CameraControllerTest do
    use DomoapiWeb.ConnCase
  
    alias Domoapi.Intercoms
    alias Domoapi.Intercoms.Camera
    alias Domoapi.Intercoms.Intercom
    alias Domoapi.Users
  
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
      test "lists all cameras", %{conn: conn} do
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
        conn = get(conn, Routes.intercom_camera_path(conn, :index, intercom.id))
        assert json_response(conn, 200) == []
      end
    end
  
    describe "create camera" do
      test "renders camera when data is valid", %{conn: conn} do
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
        camera =
        %{ 
          title: "title", 
          url: "123.124.124.3"
          }
        conn = post(conn, Routes.intercom_camera_path(conn, :create, intercom.id), camera)
        assert %{"id" => id} = json_response(conn, 201)
  
        conn = get(conn, Routes.intercom_camera_path(conn, :show, intercom.id, id))
  
        assert %{
                 "id" => id,
                 "title" => "title"
               } = json_response(conn, 200)
      end
  
      test "renders errors when data is invalid", %{conn: conn} do
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
        conn = post(conn, Routes.intercom_camera_path(conn, :create, intercom.id), @invalid_attrs)
        assert json_response(conn, 422)["errors"] != %{}
      end
    end
  
    describe "update camera" do
      test "renders camera when data is valid", %{conn: conn} do
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
        camera =
        %{ 
          title: "title", 
          url: "123.124.124.3"
          }
        conn = post(conn, Routes.intercom_camera_path(conn, :create, intercom.id), camera)
        camera = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
        conn = put(conn, Routes.intercom_camera_path(conn, :update, intercom.id, camera.id), camera: @update_attrs)
        conn = get(conn, Routes.intercom_camera_path(conn, :show, intercom.id, camera.id))
        assert %{
                 "title" => "some updated title"
               } = json_response(conn, 200)
      end
    end
  
    describe "delete camera" do
      test "deletes chosen camera", %{conn: conn} do
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
        camera =
        %{ 
          title: "title", 
          url: "123.124.124.3"
          }
        conn = post(conn, Routes.intercom_camera_path(conn, :create, intercom.id), camera)
        camera = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
        conn = delete(conn, Routes.intercom_camera_path(conn, :delete, intercom.id, camera.id))
        assert response(conn, 200)
        end
    end
  end
  