defmodule Domoapi.PlaceTest do
  use Domoapi.DataCase

  alias Domoapi.Place

  describe "archive_visits" do
    alias Domoapi.Place.ArchiveVisit

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def archive_visit_fixture(attrs \\ %{}) do
      {:ok, archive_visit} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Place.create_archive_visit()

      archive_visit
    end

    test "list_archive_visits/0 returns all archive_visits" do
      archive_visit = archive_visit_fixture()
      assert Place.list_archive_visits() == [archive_visit]
    end

    test "get_archive_visit!/1 returns the archive_visit with given id" do
      archive_visit = archive_visit_fixture()
      assert Place.get_archive_visit!(archive_visit.id) == archive_visit
    end

    test "create_archive_visit/1 with valid data creates a archive_visit" do
      assert {:ok, %ArchiveVisit{} = archive_visit} = Place.create_archive_visit(@valid_attrs)
    end

    test "create_archive_visit/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Place.create_archive_visit(@invalid_attrs)
    end

    test "update_archive_visit/2 with valid data updates the archive_visit" do
      archive_visit = archive_visit_fixture()
      assert {:ok, %ArchiveVisit{} = archive_visit} = Place.update_archive_visit(archive_visit, @update_attrs)
    end

    test "update_archive_visit/2 with invalid data returns error changeset" do
      archive_visit = archive_visit_fixture()
      assert {:error, %Ecto.Changeset{}} = Place.update_archive_visit(archive_visit, @invalid_attrs)
      assert archive_visit == Place.get_archive_visit!(archive_visit.id)
    end

    test "delete_archive_visit/1 deletes the archive_visit" do
      archive_visit = archive_visit_fixture()
      assert {:ok, %ArchiveVisit{}} = Place.delete_archive_visit(archive_visit)
      assert_raise Ecto.NoResultsError, fn -> Place.get_archive_visit!(archive_visit.id) end
    end

    test "change_archive_visit/1 returns a archive_visit changeset" do
      archive_visit = archive_visit_fixture()
      assert %Ecto.Changeset{} = Place.change_archive_visit(archive_visit)
    end
  end

  describe "apartment_settings" do
    alias Domoapi.Place.ApartmentSetting

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def apartment_setting_fixture(attrs \\ %{}) do
      {:ok, apartment_setting} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Place.create_apartment_setting()

      apartment_setting
    end

    test "list_apartment_settings/0 returns all apartment_settings" do
      apartment_setting = apartment_setting_fixture()
      assert Place.list_apartment_settings() == [apartment_setting]
    end

    test "get_apartment_setting!/1 returns the apartment_setting with given id" do
      apartment_setting = apartment_setting_fixture()
      assert Place.get_apartment_setting!(apartment_setting.id) == apartment_setting
    end

    test "create_apartment_setting/1 with valid data creates a apartment_setting" do
      assert {:ok, %ApartmentSetting{} = apartment_setting} = Place.create_apartment_setting(@valid_attrs)
    end

    test "create_apartment_setting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Place.create_apartment_setting(@invalid_attrs)
    end

    test "update_apartment_setting/2 with valid data updates the apartment_setting" do
      apartment_setting = apartment_setting_fixture()
      assert {:ok, %ApartmentSetting{} = apartment_setting} = Place.update_apartment_setting(apartment_setting, @update_attrs)
    end

    test "update_apartment_setting/2 with invalid data returns error changeset" do
      apartment_setting = apartment_setting_fixture()
      assert {:error, %Ecto.Changeset{}} = Place.update_apartment_setting(apartment_setting, @invalid_attrs)
      assert apartment_setting == Place.get_apartment_setting!(apartment_setting.id)
    end

    test "delete_apartment_setting/1 deletes the apartment_setting" do
      apartment_setting = apartment_setting_fixture()
      assert {:ok, %ApartmentSetting{}} = Place.delete_apartment_setting(apartment_setting)
      assert_raise Ecto.NoResultsError, fn -> Place.get_apartment_setting!(apartment_setting.id) end
    end

    test "change_apartment_setting/1 returns a apartment_setting changeset" do
      apartment_setting = apartment_setting_fixture()
      assert %Ecto.Changeset{} = Place.change_apartment_setting(apartment_setting)
    end
  end
end
