defmodule Domoapi.Intercoms do
  @moduledoc """
  The Intercoms context.
  """

  import Ecto.Query, warn: false
  require HTTPoison
  alias Domoapi.Repo

  alias Domoapi.People.Tenant
  alias Domoapi.Place.Apartment
  alias Domoapi.Place.IntercomsApartments
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Intercoms.Setting
  alias Domoapi.Intercoms.Camera
  alias Domoapi.Intercoms.Key
  alias Domoapi.Place



  @doc """
  Returns the list of intercoms.

  ## Examples

      iex> list_intercoms()
      [%Intercom{}, ...]

  """

  def list_intercoms(%{"house_id" => house_id, "company_id" => company_id, "page" => page, "page_size" => page_size}) do
    Intercom
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.house_id == ^house_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_intercoms(%{"house_id" => house_id, "page" => page, "company_id" => company_id}) do
    Intercom
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.house_id == ^house_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page)
  end
  def list_intercoms(_attrs) do
    {:error, :incorrect_data}
  end
  @doc """
  Gets a single intercom.

  Raises `Ecto.NoResultsError` if the Intercom does not exist.

  ## Examples

      iex> get_intercom!(123)
      %Intercom{}

      iex> get_intercom!(456)
      ** (Ecto.NoResultsError)

  """
  def get_intercom(%{"id" =>  id, "company_id" => company_id}) do
     Intercom
     |> where([i], i.company_id == ^company_id)
     |> where([i], i.id == ^id)
     |> Repo.one
  end
  def get_intercom(%{:id =>  id, :company_id => company_id}) do
    Intercom
    |> where([i], i.company_id == ^company_id)
    |> where([i], i.id == ^id)
    |> Repo.one
  end
  def get_intercom(%{"tenant_id" => tenant_id}) do
    Intercom
    |> join(:inner, [i], ia in IntercomsApartments, on: ia.intercom_id == i.id)
    |> join(:inner, [i, ia], a in Apartment, on: a.id == ia.apartment_id)
    |> join(:inner, [i, ia, a], t in Tenant, on: t.apartment_id == a.id)
    |> where([i, ia, a, t], t.id == ^tenant_id)
    |> where([i, ia, a, t], i.deleted == false)
    |> Repo.one
  end
  def get_intercom!(id) do
      Intercom
      |> where([i], i.id == ^id)
      |> Repo.one
  end
  
  def check_intercom(serial_key)do
    Intercom
      |> where([i], i.serial_key == ^serial_key)
      |> Repo.one
  end


  def update_ip_by_serial_key(intercom_serial_key, host,  port) do
    intercom = Intercom
    |> where([i], i.serial_key == ^intercom_serial_key)
    |> Repo.one
    if not is_nil(intercom) do
      update_intercom(intercom, %{host_name: "http://#{host}:#{port}"})
    end
  end 

  def update_all_cameras({:ok, intercom}) do
    cameras = Camera
    |> where([c], c.intercom_id == ^intercom.id)
    |> Repo.all
    url = List.first(Regex.run(~r/(?<=\[).*?(?=\])/, intercom.host_name))
    cameras
    |> Enum.map(&update_camera(&1, %{"url" => "[" <> url <> "]"}))
  end

  def update_all_cameras(intercom) do
  cameras = Camera
  |> where([c], c.intercom_id == ^intercom.id)
  |> Repo.all
  url = List.first(Regex.run(~r/(?<=\[).*?(?=\])/, intercom.host_name)) 
  cameras
  |> Enum.map(&update_camera(&1, %{"url" => "[" <> url <> "]"}))
  end
  @doc """
  Creates a intercom.

  ## Examples

      iex> create_intercom(%{field: value})
      {:ok, %Intercom{}}

      iex> create_intercom(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_intercom(attrs \\ %{}) do
    %Intercom{}
    |> Intercom.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a intercom.

  ## Examples

      iex> update_intercom(intercom, %{field: new_value})
      {:ok, %Intercom{}}

      iex> update_intercom(intercom, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_intercom(%Intercom{} = intercom, attrs) do
    intercom
    |> Intercom.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Intercom.

  ## Examples

      iex> delete_intercom(intercom)
      {:ok, %Intercom{}}

      iex> delete_intercom(intercom)
      {:error, %Ecto.Changeset{}}

  """
  alias Domoapi.Place

  require Logger
  def delete_intercom(%Intercom{} = intercom) do
    intercom = preload_intercom(intercom)
    if not is_nil(intercom.cameras) do
      delete_camera(intercom.cameras)
    end
    if not is_nil(intercom.settings) do
      intercom.settings
      |> Enum.map(&delete_setting/1)
    end
    if not is_nil(intercom.keys) do
      intercom.keys
      |> Enum.map(&delete_key/1)
    end
    if not is_nil(intercom.intercoms_apartments) do
      intercom.intercoms_apartments
      |> Enum.map(&Place.delete_intercoms_apartments/1)
    end
    intercom
    |> Intercom.changeset(%{deleted: true})
    |> Repo.update()
  end
  def delete_intercom(_attrs) do
    {:error, :incorrect_data}
  end

  def preload_intercom(intercom) do
    Repo.preload(intercom, [:cameras, :keys, :settings, :intercoms_apartments])
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking intercom changes.

  ## Examples

      iex> change_intercom(intercom)
      %Ecto.Changeset{source: %Intercom{}}

  """
  def change_intercom(%Intercom{} = intercom) do
    Intercom.changeset(intercom, %{})
  end

  @doc """
  Returns the list of keys.

  ## Examples

      iex> list_keys()
      [%Key{}, ...]

  """

  def list_keys(%{"intercom_id" => intercom_id, "company_id" => company_id, "page" => page, "page_size" => page_size}) do
    Key
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.intercom_id == ^intercom_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_keys(%{"intercom_id" => intercom_id, "company_id" => company_id, "page" => page}) do
    Key
    |> where([c], c.company_id == ^company_id)
    |> where([c], c.intercom_id == ^intercom_id)
    |> where([c], c.deleted == false)
    |> Repo.paginate(page: page)
  end
  def list_keys(%{"intercom_serial_key" => intercom_serial_key}) do
    Key
    |> join(:inner, [i], ia in Intercom, on: ia.id == i.intercom_id)
    |> where([i, ia], ia.serial_key == ^intercom_serial_key)
    |> where([i, ia], i.deleted == false)
    |> select([i, ia], %{key: i.key_data, type: i.key_type})
    |> Repo.all
  end
  def list_keys(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single key.

  Raises `Ecto.NoResultsError` if the Key does not exist.

  ## Examples

      iex> get_key!(123)
      %Key{}

      iex> get_key!(456)
      ** (Ecto.NoResultsError)

  """
  def get_key!(id), do: Repo.get!(Key, id)

  @doc """
  Creates a key.

  ## Examples

      iex> create_key(%{field: value})
      {:ok, %Key{}}

      iex> create_key(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_key(attrs \\ %{}) do
    %Key{}
    |> Key.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a key.

  ## Examples

      iex> update_key(key, %{field: new_value})
      {:ok, %Key{}}

      iex> update_key(key, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_key(%Key{} = key, attrs) do
    key
    |> Key.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Key.

  ## Examples

      iex> delete_key(key)
      {:ok, %Key{}}

      iex> delete_key(key)
      {:error, %Ecto.Changeset{}}

  """
  def delete_key(%Key{} = key) do
    key
    |> Key.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking key changes.

  ## Examples

      iex> change_key(key)
      %Ecto.Changeset{source: %Key{}}

  """
  def change_key(%Key{} = key) do
    Key.changeset(key, %{})
  end

  @doc """
  Returns the list of settings.

  ## Examples

      iex> list_settings()
      [%Setting{}, ...]

  """


  def list_settings(%{"intercom_id" => intercom_id}) do
    query = from c in Setting,
    where: c.intercom_id == ^intercom_id,
    where: c.deleted == false
    Repo.all(query)
  end
  def list_settings(%{"intercom_serial_key" => intercom_serial_key}) do
    Setting
    |> join(:inner, [i], ia in Intercom, on: ia.id == i.intercom_id)
    |> where([i, ia], ia.serial_key == ^intercom_serial_key)
    |> where([i, ia], i.deleted == false)
    |> select([i, ia], %{
      min_threshold: i.min_threshold,
      max_threshold: i.max_threshold,
      codec_rx_vol: i.codec_rx_vol,
      codec_tx_vol: i.codec_tx_vol,
      codec_beep_vol: i.codec_beep_vol,
      codec_internet_tx_vol: i.codec_internet_tx_vol,
      codec_internet_rx_vol: i.codec_internet_rx_vol,
      codec_internet_tx_beep_vol: i.codec_internet_tx_beep_vol,
      codec_internet_beep_vol: i.codec_internet_beep_vol,
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
      codec_agc_internet_rx_max_gain: i.codec_agc_internet_rx_max_gain,
      max_ring_duration_ms: i.max_ring_duration_ms,
      max_call_duration_ms: i.max_call_duration_ms,
      door_open_time_ms: i.door_open_time_ms,
      first_room_number: i.first_room_number
      })
    |> Repo.one
  end
  def list_settings(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single setting.

  Raises `Ecto.NoResultsError` if the Setting does not exist.

  ## Examples

      iex> get_setting!(123)
      %Setting{}

      iex> get_setting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_setting!(id), do: Repo.get!(Setting, id)

  @doc """
  Creates a setting.

  ## Examples

      iex> create_setting(%{field: value})
      {:ok, %Setting{}}

      iex> create_setting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_setting(%{"intercom_id" => intercom_id} = attrs \\ %{}) do
    %Setting{}
    |> Setting.changeset(attrs)
    |> Repo.insert()
  end


  def cast_setting_task(host, setting, serial_key) do
    setting = Map.drop(setting, [:id, :intercom_id])
    with {:ok, setting_json} <- Jason.encode(setting) do
      request_intercom_cast_setting(host, setting_json, serial_key, 3)
    end
  end

  def request_intercom_cast_setting(_host, _setting_json, _serial_key, count) when count < 1 do
    {:error, :no_connection}
  end

  def request_intercom_cast_setting(host, setting_json, serial_key, count)do
    with {:ok, response} <- HTTPoison.post("http://#{host}/settings/global", '#{setting_json}', ["Authorization": "Token #{serial_key}"])do
      if response.status_code != 200 do
        request_intercom_cast_setting(host, setting_json, serial_key, count-1)
      end
    else
      {:error, message} -> request_intercom_cast_setting(host, setting_json, serial_key, count - 1)
    end
  end

  @doc """
  Updates a setting.

  ## Examples

      iex> update_setting(setting, %{field: new_value})
      {:ok, %Setting{}}

      iex> update_setting(setting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_setting(%Setting{} = setting, attrs) do
    update_setting = setting
    |> Setting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Setting.

  ## Examples

      iex> delete_setting(setting)
      {:ok, %Setting{}}

      iex> delete_setting(setting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_setting(%Setting{} = setting) do
    setting
    |> Setting.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking setting changes.

  ## Examples

      iex> change_setting(setting)
      %Ecto.Changeset{source: %Setting{}}

  """
  def change_setting(%Setting{} = setting) do
    Setting.changeset(setting, %{})
  end


  @doc """
  Returns the list of cameras.

  ## Examples

      iex> list_cameras()
      [%Camera{}, ...]

  """
  def list_cameras(%{"intercom_id" => intercom_id, "company_id" => company_id}) do
    query = from c in Camera,
    where: c.company_id == ^company_id,
    where: c.intercom_id == ^intercom_id,
    where: c.deleted == false
    Repo.all(query)
  end
  def list_cameras(%{"tenant_id" => tenant_id}) do
    Camera
    |> join(:inner, [e], i in Intercom, on: i.id == e.intercom_id)
    |> join(:inner, [e, i], ia in IntercomsApartments, on: ia.intercom_id == i.id)
    |> join(:inner, [e, i, ia], a in Apartment, on: a.id == ia.apartment_id)
    |> join(:inner, [e, i, ia, a], t in Tenant, on: t.apartment_id == a.id)
    |> where([e, i, ia, a, t], t.id == ^tenant_id)
    |> where([e, i, ia, a, t], e.deleted == false)
    |> Repo.all
  end
  def list_cameras(_attrs) do
    {:error, :incorrect_data}
  end

  def list_cameras_for_video_archiv() do
    query = from c in Camera,
    where: c.deleted == false
    Repo.all(query)
  end

  @doc """
  Gets a single camera.

  Raises `Ecto.NoResultsError` if the Camera does not exist.

  ## Examples

      iex> get_camera!(123)
      %Camera{}

      iex> get_camera!(456)
      ** (Ecto.NoResultsError)

  """
  def get_camera!(id), do: Repo.get!(Camera, id)


  def get_intercom_person(person) do
    query = from i in  Intercom,
    join: z in  IntercomsApartments,
    join: a in Apartment,
    join: p in Tenant,
    where: z.intercom_id ==  i.id,
    where: a.id == z.apartment_id,
    where: p.apartment_id == a.id,
    where: p.id == ^person.id,
    where: i.deleted == false,
    where: i.company_id == ^person.company_id
    List.first(Repo.all(query))
  end

  
  @doc """
  Creates a camera.

  ## Examples

      iex> create_camera(%{field: value})
      {:ok, %Camera{}}

      iex> create_camera(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_camera(attrs \\ %{}) do
    %Camera{}
    |> Camera.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a camera.

  ## Examples

      iex> update_camera(camera, %{field: new_value})
      {:ok, %Camera{}}

      iex> update_camera(camera, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  require Logger
  def update_camera(%Camera{} = camera, attrs) do
    Logger.info(inspect(attrs))
    camera
    |> Camera.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Camera.

  ## Examples

      iex> delete_camera(camera)
      {:ok, %Camera{}}

      iex> delete_camera(camera)
      {:error, %Ecto.Changeset{}}

  """
  def delete_camera(%Camera{} = camera) do
    camera
    |> Camera.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking camera changes.

  ## Examples

      iex> change_camera(camera)
      %Ecto.Changeset{source: %Camera{}}

  """
  def change_camera(%Camera{} = camera) do
    Camera.changeset(camera, %{})
  end
end
