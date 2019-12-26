defmodule Domoapi.People do
  @moduledoc """
  The People context.
  """
  use Timex
  import Ecto.Query, warn: false
  alias Domoapi.Repo
  alias Domoapi.Place
  alias Domoapi.People.Tenant
  alias Domoapi.People.Device
  alias Domoapi.People.Photo
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Place.Apartment
  alias Domoapi.Place.IntercomsApartments

  @doc """
  Returns the list of tenants.

  ## Examples

      iex> list_tenants()
      [%Tenant{}, ...]

  """
  def list_tenants(%{"apartment_id" => apartment_id, "company_id" => company_id}) do
    query = from c in Tenant,
    where: c.apartment_id == ^apartment_id,
    where: c.company_id == ^company_id,
    where: c.deleted == false
    Repo.all(query)
  end

  def list_tenants(%{"intercom_serial_key" => intercom_serial_key}) do
    Tenant
    |> join(:inner, [i], ia in Apartment, on: ia.id == i.apartment_id)
    |> join(:inner, [i, ia], b in IntercomsApartments, on: b.apartment_id == ia.id)
    |> join(:inner, [i, ia, b], z in Intercom, on: b.intercom_id == z.id)
    |> where([i, ia, b, z], z.serial_key == ^intercom_serial_key)
    |> where([i, ia, b, z], i.deleted == false)
    |> Repo.all
  end

  def list_tenants(_attrs) do
    {:error, :incorrect_data}
  end

  def preload_tenants(tenants) do
    Repo.preload(tenants, [:photos, :devices])
  end

  @doc """
  Gets a single tenant.

  Raises `Ecto.NoResultsError` if the Tenant does not exist.

  ## Examples

      iex> get_tenant!(123)
      %Tenant{}

      iex> get_tenant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tenant!(id), do: Repo.get!(Tenant, id)

  def get_tenant_of_number(%{"phone_number" => phone_number}) do
    tenant = Tenant
    |> where([b], b.phone_number == ^phone_number)
    |> Repo.one
    {:ok, tenant}
  end

  def get_tenant_of_number!(phone_number) do
    Tenant
    |> where([b], b.phone_number == ^phone_number)
    |> Repo.one
  end

  def get_tenant_auth(id) do
    tenant = Tenant
    |> where([b], b.id == ^id)
    |> Repo.one
  end

  def get_tenant_of_number(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Creates a tenant.

  ## Examples

      iex> create_tenant(%{field: value})
      {:ok, %Tenant{}}

      iex> create_tenant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tenant(attrs \\ %{}) do
    %Tenant{}
    |> Tenant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tenant.

  ## Examples

      iex> update_tenant(tenant, %{field: new_value})
      {:ok, %Tenant{}}

      iex> update_tenant(tenant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tenant(%Tenant{} = tenant, attrs) do
    tenant
    |> Tenant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Tenant.

  ## Examples

      iex> delete_tenant(tenant)
      {:ok, %Tenant{}}

      iex> delete_tenant(tenant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tenant(%Tenant{} = tenant) do
    tenant_preload = preload_tenants(tenant)
    tenant_preload.photos
    |> Enum.map(&delete_photo/1)
    tenant_preload.devices
    |> Enum.map(&delete_device/1)
    tenant
    |> Tenant.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tenant changes.

  ## Examples

      iex> change_tenant(tenant)
      %Ecto.Changeset{source: %Tenant{}}

  """
  def change_tenant(%Tenant{} = tenant) do
    Tenant.changeset(tenant, %{})
  end

  @doc """
  Returns the list of devices.

  ## Examples

      iex> list_devices()
      [%Device{}, ...]

  """
  def list_devices(%{"tenant_id" => tenant_id}) do
    query = from b in Device,
    where: b.tenant_id == ^tenant_id,
    where: b.deleted == false
    Repo.all(query)
  end
  def list_devices(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single device.

  Raises `Ecto.NoResultsError` if the Device does not exist.

  ## Examples

      iex> get_device!(123)
      %Device{}

      iex> get_device!(456)
      ** (Ecto.NoResultsError)

  """
  def get_device!(id), do: Repo.get!(Device, id)

  def get_device_by_serial_key(serial_key) do
    Device
    |> where([b], b.serial_key == ^serial_key)
    |> Repo.one
  end

  @doc """
  Creates a device.

  ## Examples

      iex> create_device(%{field: value})
      {:ok, %Device{}}

      iex> create_device(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_device(attrs \\ %{}) do
    %Device{}
    |> Device.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a device.

  ## Examples

      iex> update_device(device, %{field: new_value})
      {:ok, %Device{}}

      iex> update_device(device, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_device(%Device{} = device, attrs) do
    device
    |> Device.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Device.

  ## Examples

      iex> delete_device(device)
      {:ok, %Device{}}

      iex> delete_device(device)
      {:error, %Ecto.Changeset{}}

  """
  def delete_device(%Device{} = device) do
    device
    |> Device.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking device changes.

  ## Examples

      iex> change_device(device)
      %Ecto.Changeset{source: %Device{}}

  """
  def change_device(%Device{} = device) do
    Device.changeset(device, %{})
  end


  @doc """
  Returns the list of photos.

  ## Examples

      iex> list_photos()
      [%Photo{}, ...]

  """

  def list_photos(%{"tenant_id" => tenant_id, "page" => page, "page_size" => page_size}) do
    Photo
    |> where([b], b.tenant_id == ^tenant_id)
    |> where([b], b.deleted == false)
    |> Repo.paginate(page: page, page_size: page_size)
  end
  def list_photos(%{"tenant_id" => tenant_id, "page" => page}) do
    Photo
    |> where([b], b.tenant_id == ^tenant_id)
    |> where([b], b.deleted == false)
    |> Repo.paginate(page: page)
  end
  def list_photos(%{"intercom_serial_key" => intercom_serial_key, "apartment_number" => apartment_number}) do
    Photo
    |> join(:inner, [e], t in Tenant, on: t.id == e.tenant_id)
    |> join(:inner, [e, t], ia in Apartment, on: ia.id == t.apartment_id)
    |> join(:inner, [e, t, ia], b in IntercomsApartments, on: b.apartment_id == ia.id)
    |> join(:inner, [e, t, ia, b], z in Intercom, on: b.intercom_id == z.id)
    |> where([e, t, ia, b, z], z.serial_key == ^intercom_serial_key)
    |> where([e, t, ia, b, z], e.deleted == false)
    |> where([e, t, ia, b, z], ia.apartment_number == ^apartment_number)
    |> Repo.all
  end
  def list_photos(_attrs) do
    {:error, :incorrect_data}
  end

  @doc """
  Gets a single photo.

  Raises `Ecto.NoResultsError` if the Photo does not exist.

  ## Examples

      iex> get_photo!(123)
      %Photo{}

      iex> get_photo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_photo!(id), do: Repo.get!(Photo, id)

  @doc """
  Creates a photo.

  ## Examples

      iex> create_photo(%{field: value})
      {:ok, %Photo{}}

      iex> create_photo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_photo(attrs \\ %{}) do
    %Photo{}
    |> Photo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a photo.

  ## Examples

      iex> update_photo(photo, %{field: new_value})
      {:ok, %Photo{}}

      iex> update_photo(photo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_photo(%Photo{} = photo, attrs) do
    photo
    |> Photo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Photo.

  ## Examples

      iex> delete_photo(photo)
      {:ok, %Photo{}}

      iex> delete_photo(photo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_photo(%Photo{} = photo) do
    photo
    |> Photo.changeset(%{deleted: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking photo changes.

  ## Examples

      iex> change_photo(photo)
      %Ecto.Changeset{source: %Photo{}}

  """
  def change_photo(%Photo{} = photo) do
    Photo.changeset(photo, %{})
  end
end
