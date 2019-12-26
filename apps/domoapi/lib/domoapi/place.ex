defmodule Domoapi.Place do
  @moduledoc """
  The Place context.
  """

  import Ecto.Query, warn: false
  alias Domoapi.Repo
  alias Domoapi.Intercoms
  alias Domoapi.Place.House
  alias Domoapi.Intercoms.Intercom

  @doc """
  Returns the list of houses.

  ## Examples

      iex> list_houses()
      [%House{}, ...]

  """

  def list_houses(%{"page" => page, "company_id" => company_id, "page_size" => page_size}) do
    House
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_houses(%{"page" => page, "company_id" => company_id}) do
    House
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page)
  end
  def list_houses(_attrs) do
    {:error, :incorrect_data}
  end

  def preload_house(house) do
    Repo.preload(house, [:apartments, :intercoms])
  end

  @doc """
  Gets a single house.

  Raises `Ecto.NoResultsError` if the House does not exist.

  ## Examples

      iex> get_house!(123)
      %House{}

      iex> get_house!(456)
      ** (Ecto.NoResultsError)

  """
  def get_house!(id), do: Repo.get!(House, id)

  @doc """
  Creates a house.

  ## Examples

      iex> create_house(%{field: value})
      {:ok, %House{}}

      iex> create_house(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_house(attrs \\ %{}) do
    %House{}
    |> House.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a house.

  ## Examples

      iex> update_house(house, %{field: new_value})
      {:ok, %House{}}

      iex> update_house(house, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_house(%House{} = house, attrs) do
    house
    |> House.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a House.

  ## Examples

      iex> delete_house(house)
      {:ok, %House{}}

      iex> delete_house(house)
      {:error, %Ecto.Changeset{}}

  """
  require Logger

  def delete_house(%House{} = house) do
    house_preload = preload_house(house)
    house_preload.intercoms
    |> Enum.map(&Intercoms.delete_intercom/1)
    house_preload.apartments
    |> Enum.map(&delete_apartment/1)
    house
    |> House.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking house changes.

  ## Examples

      iex> change_house(house)
      %Ecto.Changeset{source: %House{}}

  """
  def change_house(%House{} = house) do
    House.changeset(house, %{})
  end

  alias Domoapi.Place.IntercomsApartments

  @doc """
  Returns the list of intercoms_apartments.

  ## Examples

      iex> list_intercoms_apartments()
      [%intercoms_apartments{}, ...]

  """
  def list_intercoms_apartments(%{"intercom_id" => intercom_id, "apartment_id" => apartment_id}) do
    query = from c in IntercomsApartments,
    where: c.intercom_id == ^intercom_id,
    where: c.apartment_id == ^apartment_id
    Repo.all(query)
  end
  def list_intercoms_apartments(%{"intercom_id" => intercom_id, "page" => page, "page_size" => page_size}) do
    IntercomsApartments
    |> where([c], c.intercom_id == ^intercom_id)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_intercoms_apartments(%{"intercom_id" => intercom_id, "page" => page}) do
    IntercomsApartments
    |> where([c], c.intercom_id == ^intercom_id)
    |> Repo.paginate(page: page)
  end
  def list_intercoms_apartments(%{"apartment_id" => apartment_id}) do
    query = from c in IntercomsApartments,
    where: c.apartment_id == ^apartment_id
    Repo.all(query)
  end
  def list_intercoms_apartments(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single intercoms_apartments.

  Raises `Ecto.NoResultsError` if the intercoms_apartments does not exist.

  ## Examples

      iex> get_intercoms_apartments!(123)
      %intercoms_apartments{}

      iex> get_intercoms_apartments!(456)
      ** (Ecto.NoResultsError)

  """
  def get_intercoms_apartments(%{:apartment_id => apartment_id, :intercom_id => intercom_id}) do
    IntercomsApartments
    |> where([i], i.apartment_id == ^apartment_id)
    |> where([i], i.intercom_id == ^intercom_id)
    |> Repo.one
  end
  def get_intercoms_apartments(%{"apartment_id" => apartment_id, "intercom_id" => intercom_id}) do
    IntercomsApartments
    |> where([i], i.apartment_id == ^apartment_id)
    |> where([i], i.intercom_id == ^intercom_id)
    |> Repo.one
  end
  def get_intercoms_apartments(_attrs) do
    {:error, :incorrect_data}
  end


  @doc """
  Creates a intercoms_apartments.

  ## Examples

      iex> create_intercoms_apartments(%{field: value})
      {:ok, %intercoms_apartments{}}

      iex> create_intercoms_apartments(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  alias Domoapi.Intercoms

  def create_intercoms_apartments(%{"apartment_id" => apartment_id, "intercom_id" => intercom_id} = attrs \\ %{})
  when not is_nil(apartment_id) and apartment_id != "" do
    apartment = get_apartment!(apartment_id)
    intercom = Intercoms.get_intercom(intercom_id)
    if intercom.house_id == apartment.house_id do
      %IntercomsApartments{}
    |> IntercomsApartments.changeset(attrs)
    |> Repo.insert()
    else
      {:error, :incorrect_data}
    end
  end
  def create_intercoms_apartments(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Updates a intercoms_apartments.

  ## Examples

      iex> update_intercoms_apartments(intercoms_apartments, %{field: new_value})
      {:ok, %intercoms_apartments{}}

      iex> update_intercoms_apartments(intercoms_apartments, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_intercoms_apartments(%IntercomsApartments{} = intercoms_apartments, attrs) do
    intercoms_apartments
    |> IntercomsApartments.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a intercoms_apartments.

  ## Examples

      iex> delete_intercoms_apartments(intercoms_apartments)
      {:ok, %intercoms_apartments{}}

      iex> delete_intercoms_apartments(intercoms_apartments)
      {:error, %Ecto.Changeset{}}

  """

  def delete_intercoms_apartments(%IntercomsApartments{} = intercoms_apartments) do
    Repo.delete(intercoms_apartments)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking intercoms_apartments changes.

  ## Examples

      iex> change_intercoms_apartments(intercoms_apartments)
      %Ecto.Changeset{source: %intercoms_apartments{}}

  """
  def change_intercoms_apartments(%IntercomsApartments{} = intercoms_apartments) do
    IntercomsApartments.changeset(intercoms_apartments, %{})
  end

  alias Domoapi.Place.Apartment

  @doc """
  Returns the list of apartments.

  ## Examples

      iex> list_apartments()
      [%Apartment{}, ...]

  """
  def list_apartments(%{"house_id" => house_id, "company_id" => company_id, "page" => page, "page_size" => page_size}) do
    Apartment
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.house_id == ^house_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_apartments(%{"house_id" => house_id, "company_id" => company_id, "page" => page}) do
    Apartment
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.house_id == ^house_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page)
  end
  def list_apartments(%{"intercom_serial_key" => intercom_serial_key}) do
    Apartment
    |> join(:inner, [i], ia in IntercomsApartments, on: ia.apartment_id == i.id)
    |> join(:inner, [i, ia], z in Intercom, on: ia.intercom_id == z.id)
    |> where([i, ia, z], z.serial_key == ^intercom_serial_key)
    |> where([i, ia, z], i.deleted == false)
    |> Repo.all
  end
  def list_apartments(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single apartment.

  Raises `Ecto.NoResultsError` if the Apartment does not exist.

  ## Examples

      iex> get_apartment!(123)
      %Apartment{}

      iex> get_apartment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_apartment!(id), do: Repo.get!(Apartment, id)

  @doc """
  Creates a apartment.

  ## Examples

      iex> create_apartment(%{field: value})
      {:ok, %Apartment{}}

      iex> create_apartment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_apartment(attrs \\ %{}) do
    %Apartment{}
    |> Apartment.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a apartment.

  ## Examples

      iex> update_apartment(apartment, %{field: new_value})
      {:ok, %Apartment{}}

      iex> update_apartment(apartment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_apartment(%Apartment{} = apartment, attrs) do
    apartment
    |> Apartment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Apartment.

  ## Examples

      iex> delete_apartment(apartment)
      {:ok, %Apartment{}}

      iex> delete_apartment(apartment)
      {:error, %Ecto.Changeset{}}

  """
  alias Domoapi.People

  def delete_apartment(%Apartment{} = apartment) do
    Logger.info(inspect(apartment))
    apartment_preload = preload_apartment(apartment)
    apartment_preload.tenants
    |> Enum.map(&People.delete_tenant/1)
    apartment_preload.intercoms_apartments
    |> Enum.map(&delete_intercoms_apartments/1)
    apartment_preload.apartment_settings
    |> Enum.map(&delete_apartment_setting/1)
    apartment
    |> Apartment.changeset(%{deleted: true})
    |> Repo.update()
  end

  def preload_apartment(apartment) do
    Repo.preload(apartment, [:tenants, :intercoms_apartments, :apartment_settings])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking apartment changes.

  ## Examples

      iex> change_apartment(apartment)
      %Ecto.Changeset{source: %Apartment{}}

  """
  def change_apartment(%Apartment{} = apartment) do
    Apartment.changeset(apartment, %{})
  end

  alias Domoapi.Place.Contract

  @doc """
  Returns the list of contracts.

  ## Examples

      iex> list_contracts()
      [%Contract{}, ...]

  """
  def list_contracts(%{"page" => page, "page_size" => page_size, "company_id" => company_id, "apartment_id" => apartment_id}) do
    Contract
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.apartment_id == ^apartment_id)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_contracts(%{"page" => page, "page_size" => page_size, "company_id" => company_id, "tenant_id" => tenant_id}) do
    Contract
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.tenant_id == ^tenant_id)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_contracts(%{"page" => page, "page_size" => page_size, "company_id" => company_id}) do
    Contract
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_contracts(%{"page" => page, "company_id" => company_id, "apartment_id" => apartment_id}) do
    Contract
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.apartment_id == ^apartment_id)
    |> Repo.paginate(page: page)
  end
  def list_contracts(%{"page" => page, "company_id" => company_id, "tenant_id" => tenant_id}) do
    Contract
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.tenant_id == ^tenant_id)
    |> Repo.paginate(page: page)
  end
  def list_contracts(%{"page" => page, "company_id" => company_id}) do
    Contract
    |> where([c], c.deleted == false)
    |> where([c], c.company_id == ^company_id)
    |> Repo.paginate(page: page)
  end
  def list_contracts(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single contract.

  Raises `Ecto.NoResultsError` if the Contract does not exist.

  ## Examples

      iex> get_contract!(123)
      %Contract{}

      iex> get_contract!(456)
      ** (Ecto.NoResultsError)

  """
  def get_contract!(id), do: Repo.get!(Contract, id)

  @doc """
  Creates a contract.

  ## Examples

      iex> create_contract(%{field: value})
      {:ok, %Contract{}}

      iex> create_contract(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_contract(attrs \\ %{}) do
    %Contract{}
    |> Contract.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a contract.

  ## Examples

      iex> update_contract(contract, %{field: new_value})
      {:ok, %Contract{}}

      iex> update_contract(contract, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_contract(%Contract{} = contract, attrs) do
    contract
    |> Contract.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Contract.

  ## Examples

      iex> delete_contract(contract)
      {:ok, %Contract{}}

      iex> delete_contract(contract)
      {:error, %Ecto.Changeset{}}

  """
  def delete_contract(%Contract{} = contract) do
    contract
    |> Contract.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking contract changes.

  ## Examples

      iex> change_contract(contract)
      %Ecto.Changeset{source: %Contract{}}

  """
  def change_contract(%Contract{} = contract) do
    Contract.changeset(contract, %{})
  end

  alias Domoapi.Place.ArchiveVisit

  @doc """
  Returns the list of archive_visits.

  ## Examples

      iex> list_archive_visits()
      [%ArchiveVisit{}, ...]

  """
  def list_archive_visits do
    Repo.all(ArchiveVisit)
  end

  @doc """
  Gets a single archive_visit.

  Raises `Ecto.NoResultsError` if the Archive visit does not exist.

  ## Examples

      iex> get_archive_visit!(123)
      %ArchiveVisit{}

      iex> get_archive_visit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_archive_visit!(id), do: Repo.get!(ArchiveVisit, id)

  @doc """
  Creates a archive_visit.

  ## Examples

      iex> create_archive_visit(%{field: value})
      {:ok, %ArchiveVisit{}}

      iex> create_archive_visit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_archive_visit(attrs \\ %{}) do
    %ArchiveVisit{}
    |> ArchiveVisit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a archive_visit.

  ## Examples

      iex> update_archive_visit(archive_visit, %{field: new_value})
      {:ok, %ArchiveVisit{}}

      iex> update_archive_visit(archive_visit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_archive_visit(%ArchiveVisit{} = archive_visit, attrs) do
    archive_visit
    |> ArchiveVisit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a ArchiveVisit.

  ## Examples

      iex> delete_archive_visit(archive_visit)
      {:ok, %ArchiveVisit{}}

      iex> delete_archive_visit(archive_visit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_archive_visit(%ArchiveVisit{} = archive_visit) do
    Repo.delete(archive_visit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking archive_visit changes.

  ## Examples

      iex> change_archive_visit(archive_visit)
      %Ecto.Changeset{source: %ArchiveVisit{}}

  """
  def change_archive_visit(%ArchiveVisit{} = archive_visit) do
    ArchiveVisit.changeset(archive_visit, %{})
  end

  alias Domoapi.Place.ApartmentSetting

  @doc """
  Returns the list of apartment_settings.

  ## Examples

      iex> list_apartment_settings()
      [%ApartmentSetting{}, ...]

  """
  def list_apartment_settings(%{"apartment_id" => apartment_id}) do
    ApartmentSetting
    |> where([a], a.id == ^apartment_id)
    |> Repo.all
  end
  def list_apartment_settings(%{"intercom_serial_key" => intercom_serial_key}) do
    ApartmentSetting
    |> join(:inner, [i], ia in Apartment, on: ia.id == i.apartment_id)
    |> join(:inner, [i, ia], b in IntercomsApartments, on: b.apartment_id == ia.id)
    |> join(:inner, [i, ia, b], z in Intercom, on: b.intercom_id == z.id)
    |> where([i, ia, b, z], z.serial_key == ^intercom_serial_key)
    |> where([i, ia, b, z], i.deleted == false)
    |> select([i, ia, b, z], %{
      settings: %{
          clean: i.clean,
          enabled: i.enabled,
          min_threshold: i.min_threshold,
          max_threshold: i.max_threshold,
          codec_rx_vol: i.codec_rx_vol,
          codec_tx_vol: i.codec_tx_vol,
          codec_internet_tx_vol: i.codec_internet_tx_vol,
          codec_internet_rx_vol: i.codec_internet_rx_vol,
          codec_agc_tx_enable: i.codec_agc_tx_enable,
          codec_agc_tx_target_level: i.codec_agc_tx_target_level,
          codec_agc_tx_max_gain: i.codec_agc_tx_max_gain,
          codec_agc_rx_enable: i.codec_agc_rx_enable,
          codec_agc_rx_target_level: i.codec_agc_rx_target_level,
          codec_agc_rx_max_gain: i.codec_agc_rx_max_gain,
          codec_agc_internet_tx_enable: i.codec_agc_internet_tx_enable,
          codec_agc_internet_tx_target_level: i.codec_agc_internet_tx_target_level,
          codec_agc_internet_tx_max_gain: i.codec_agc_internet_tx_max_gain,
          codec_agc_internet_rx_enabled: i.codec_agc_internet_rx_enabled,
          codec_agc_internet_rx_target_level: i.codec_agc_internet_rx_target_level,
          codec_agc_internet_rx_max_gain: i.codec_agc_internet_rx_max_gain
        }, apartment_number: ia.apartment_number
      })
    |> Repo.all
  end

  @doc """
  Gets a single apartment_setting.

  Raises `Ecto.NoResultsError` if the Apartment setting does not exist.

  ## Examples

      iex> get_apartment_setting!(123)
      %ApartmentSetting{}

      iex> get_apartment_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_apartment_setting!(id), do: Repo.get!(ApartmentSetting, id)

  @doc """
  Creates a apartment_setting.

  ## Examples

      iex> create_apartment_setting(%{field: value})
      {:ok, %ApartmentSetting{}}

      iex> create_apartment_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_apartment_setting(%{"apartment_id" => apartment_id} = attrs \\ %{}) do
    %ApartmentSetting{}
      |> ApartmentSetting.changeset(attrs)
      |> Repo.insert()
  end


  def cast_setting_task(host, setting, serial_key, count)do
    setting = Map.drop(setting, [:id, :apartment_id])
    with {:ok, setting_json} <- Jason.encode(setting) do
      request_intercom_cast_room_setting(host, setting_json, serial_key, count)
    end
  end

  def request_intercom_cast_room_setting(_host, _setting_json, _serial_key, count) when count < 1 do
    {:error, :no_connection}
  end

  def request_intercom_cast_room_setting(host, setting_json, serial_key, count)do
    with {:ok, response} <- HTTPoison.post("http://#{host}/settings/room", '#{setting_json}', ["Authorization": "Token #{serial_key}"])do
      if response.status_code != 200 do
        request_intercom_cast_room_setting(host, setting_json, serial_key, count-1)
      end
    else
      {:error, message} -> request_intercom_cast_room_setting(host, setting_json, serial_key, count - 1)
    end
  end


  def request_intercom_delete_room_setting(_host, _apartment_id, _serial_key, count) when count < 1 do
    {:error, :no_connection}
  end

  def request_intercom_delete_room_setting(host, apartment_id, serial_key, count)do
    with {:ok, response} <- HTTPoison.delete("http://#{host}/settings/room", '{"apartment_id" #{apartment_id}}', ["Authorization": "Token #{serial_key}"])do
      if response.status_code != 200 do
        request_intercom_cast_room_setting(host, apartment_id, serial_key, count-1)
      end
    else
      {:error, message} -> request_intercom_cast_room_setting(host, apartment_id, serial_key, count - 1)
    end
  end

  @doc """
  Updates a apartment_setting.

  ## Examples

      iex> update_apartment_setting(apartment_setting, %{field: new_value})
      {:ok, %ApartmentSetting{}}

      iex> update_apartment_setting(apartment_setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_apartment_setting(%ApartmentSetting{} = apartment_setting, %{"apartment_id" => apartment_id} = attrs) do
    apartment_setting
      |> ApartmentSetting.changeset(attrs)
      |> Repo.update()
  end

  @doc """
  Deletes a ApartmentSetting.

  ## Examples

      iex> delete_apartment_setting(apartment_setting)
      {:ok, %ApartmentSetting{}}

      iex> delete_apartment_setting(apartment_setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_apartment_setting(%ApartmentSetting{} = apartment_setting) do
      apartment_setting
      |> ApartmentSetting.changeset(%{deleted: true})
      |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking apartment_setting changes.

  ## Examples

      iex> change_apartment_setting(apartment_setting)
      %Ecto.Changeset{source: %ApartmentSetting{}}

  """
  def change_apartment_setting(%ApartmentSetting{} = apartment_setting) do
    ApartmentSetting.changeset(apartment_setting, %{})
  end
end
