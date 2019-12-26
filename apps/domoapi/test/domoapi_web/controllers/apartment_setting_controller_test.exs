defmodule DomoapiWeb.ApartmentSettingControllerTest do
  use DomoapiWeb.ConnCase

  alias Domoapi.Place
  alias Domoapi.Place.ApartmentSetting

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:apartment_setting) do
    {:ok, apartment_setting} = Place.create_apartment_setting(@create_attrs)
    apartment_setting
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all apartment_settings", %{conn: conn} do
      conn = get(conn, Routes.apartment_setting_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create apartment_setting" do
    test "renders apartment_setting when data is valid", %{conn: conn} do
      conn = post(conn, Routes.apartment_setting_path(conn, :create), apartment_setting: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.apartment_setting_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.apartment_setting_path(conn, :create), apartment_setting: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update apartment_setting" do
    setup [:create_apartment_setting]

    test "renders apartment_setting when data is valid", %{conn: conn, apartment_setting: %ApartmentSetting{id: id} = apartment_setting} do
      conn = put(conn, Routes.apartment_setting_path(conn, :update, apartment_setting), apartment_setting: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.apartment_setting_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, apartment_setting: apartment_setting} do
      conn = put(conn, Routes.apartment_setting_path(conn, :update, apartment_setting), apartment_setting: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete apartment_setting" do
    setup [:create_apartment_setting]

    test "deletes chosen apartment_setting", %{conn: conn, apartment_setting: apartment_setting} do
      conn = delete(conn, Routes.apartment_setting_path(conn, :delete, apartment_setting))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.apartment_setting_path(conn, :show, apartment_setting))
      end
    end
  end

  defp create_apartment_setting(_) do
    apartment_setting = fixture(:apartment_setting)
    {:ok, apartment_setting: apartment_setting}
  end
end
