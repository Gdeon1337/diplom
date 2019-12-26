defmodule DomoapiWeb.SettingControllerTest do
    use DomoapiWeb.ConnCase
  
    alias Domoapi.Intercoms
    alias Domoapi.Intercoms.Setting
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
  
    def fixture(:setting) do
      {:ok, setting} = Intercoms.create_setting(@create_attrs)
      setting
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
      test "lists all settings", %{conn: conn} do
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
        conn = get(conn, Routes.intercom_setting_path(conn, :index, intercom.id, page: 1, page_size: 10))
        assert json_response(conn, 200) == []
      end
    end
  
    describe "create setting" do
      test "renders setting when data is valid", %{conn: conn} do
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
        setting =
        %{ 
            title: "title",
            open_door_time: 2.1,
            microdevice_sensitivity: 2.1, 
            speaker_volume: 1.0,
            max_time_call: 1.0,
            max_time_talk: 1.0
          }
        conn = post(conn, Routes.intercom_setting_path(conn, :create, intercom.id), setting)
        assert %{"id" => id} = json_response(conn, 201)
  
        conn = get(conn, Routes.intercom_setting_path(conn, :show, intercom.id, id))
  
        assert %{"id" => id,"title" => "title"} = json_response(conn, 200)
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
        conn = post(conn, Routes.intercom_setting_path(conn, :create, intercom.id), @invalid_attrs)
        assert json_response(conn, 422)["errors"] != %{}
      end
    end
  
    describe "update setting" do
      test "renders setting when data is valid", %{conn: conn} do
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
        setting =
        %{ 
            title: "title",
            open_door_time: 2.1,
            microdevice_sensitivity: 2.1, 
            speaker_volume: 1.0,
            max_time_call: 1.0,
            max_time_talk: 1.0
          }
        conn = post(conn, Routes.intercom_setting_path(conn, :create, intercom.id), setting)
        setting = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
        conn = put(conn, Routes.intercom_setting_path(conn, :update, intercom.id, setting.id), setting: @update_attrs)
        conn = get(conn, Routes.intercom_setting_path(conn, :show, intercom.id, setting.id))
        assert %{"title" => "some updated title"} = json_response(conn, 200)
      end
    end
  
    describe "delete setting" do
      test "deletes chosen setting", %{conn: conn} do
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
        setting =
        %{ 
            title: "title",
            open_door_time: 2.1,
            microdevice_sensitivity: 2.1, 
            speaker_volume: 1.0,
            max_time_call: 1.0,
            max_time_talk: 1.0
          }
        conn = post(conn, Routes.intercom_setting_path(conn, :create, intercom.id), setting)
        setting = for {key, val} <- json_response(conn, 201), into: %{}, do: {String.to_atom(key), val}
        conn = delete(conn, Routes.intercom_setting_path(conn, :delete, intercom.id, setting.id))
        assert response(conn, 200)
        end
    end
  end
  