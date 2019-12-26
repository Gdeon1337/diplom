defmodule DomoapiWeb.ArchiveVisitControllerTest do
  use DomoapiWeb.ConnCase

  alias Domoapi.Place
  alias Domoapi.Place.ArchiveVisit

  @create_attrs %{

  }
  @update_attrs %{

  }
  @invalid_attrs %{}

  def fixture(:archive_visit) do
    {:ok, archive_visit} = Place.create_archive_visit(@create_attrs)
    archive_visit
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all archive_visits", %{conn: conn} do
      conn = get(conn, Routes.archive_visit_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create archive_visit" do
    test "renders archive_visit when data is valid", %{conn: conn} do
      conn = post(conn, Routes.archive_visit_path(conn, :create), archive_visit: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.archive_visit_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.archive_visit_path(conn, :create), archive_visit: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update archive_visit" do
    setup [:create_archive_visit]

    test "renders archive_visit when data is valid", %{conn: conn, archive_visit: %ArchiveVisit{id: id} = archive_visit} do
      conn = put(conn, Routes.archive_visit_path(conn, :update, archive_visit), archive_visit: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.archive_visit_path(conn, :show, id))

      assert %{
               "id" => id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, archive_visit: archive_visit} do
      conn = put(conn, Routes.archive_visit_path(conn, :update, archive_visit), archive_visit: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete archive_visit" do
    setup [:create_archive_visit]

    test "deletes chosen archive_visit", %{conn: conn, archive_visit: archive_visit} do
      conn = delete(conn, Routes.archive_visit_path(conn, :delete, archive_visit))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.archive_visit_path(conn, :show, archive_visit))
      end
    end
  end

  defp create_archive_visit(_) do
    archive_visit = fixture(:archive_visit)
    {:ok, archive_visit: archive_visit}
  end
end
