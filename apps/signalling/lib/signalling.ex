defmodule Signalling do
  @moduledoc """
  Signalling keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  require Logger
  import Ecto.Query, warn: false
  alias Domoapi.Repo
  alias Domoapi.Intercoms.{
    Intercom
  }
  alias Domoapi.Place.{
    Apartment
  }
  alias Signalling.{
    Notifier,
    Session
  }


  def call_sdp(intercom_serial_key, apartment_number, candidate) do
    Logger.warn("HOP 1567")
    with {:ok, %Apartment{id: apartment_id, tenants: tenants}} <- get_called_apartment(intercom_serial_key, apartment_number),
          _ <- Logger.warn("HOP 7")  do
          Logger.info("Starting notification...")
          Notifier.sdp_call(tenants, {candidate})
          :ok
    end
  end



  def call(intercom_serial_key, apartment_number, sdp, candidate) do
    session_id = UUID.uuid4()
    audio_input = get_available_port()
    audio_output = get_available_port()
    Logger.warn("HOP 1")
    with {:ok, %Apartment{id: apartment_id, tenants: tenants}} <- get_called_apartment(intercom_serial_key, apartment_number),
          _ <- Logger.warn("HOP 2"),
          {:ok, _pid} <- Session.start(session_id, intercom_serial_key, audio_input, audio_output),
          _ <- Logger.warn("HOP 3") do
          Logger.info("Starting notification...")
          Notifier.notify_tenants_about_call({session_id, audio_input, apartment_id, sdp, candidate}, tenants)
          {:ok, audio_output}
    end
  end

  def break_call(intercom_serial_key, apartment_number) do
    Logger.warn("HOP 1337")
    with {:ok, %Apartment{id: apartment_id, tenants: tenants}} <- get_called_apartment(intercom_serial_key, apartment_number), _ <- Logger.warn("HOP 2") do
          Logger.info("HOP break call")
          Notifier.notify_tenant_about_break_call(tenants)
          :ok
    end
  end

  def get_intercom_by_serial_key(intercom_serial_key) do
    Repo.one(from(i in Intercom, where: i.serial_key == ^intercom_serial_key, limit: 1))
  end

  defp get_called_apartment(intercom_serial_key, apartment_number) do
    apartment_query = apartment_by_number_query(apartment_number)
    intercom_query = from(
      i in Intercom,
      where: i.serial_key == ^intercom_serial_key,
      preload: [apartments: ^apartment_query]
    )
    case Repo.one(intercom_query) do
      %Intercom{apartments: [called_apartment]} -> {:ok, called_apartment}
      %Intercom{apartments: []} = test -> {:error, :apartment_not_found}
      nil -> {:error, :intercom_not_found}
    end
  end

  def respond(intercom_host_name, sdp, serial_key, candidate) do
    Task.start(fn ->
      body = Jason.encode!(
        %{sdp: sdp, candidate: candidate}
      )
      HTTPoison.post("http://#{intercom_host_name}/call/start", body, ["Authorization": "Token #{serial_key}"])
    end)
  end

  def hang(intercom_host_name, serial_key) do
    Task.start(fn -> HTTPoison.post("http://#{intercom_host_name}/call/end", '', ["Authorization": "Token #{serial_key}"]) end)
  end

  def open_door(intercom_host_name, serial_key) do
    Logger.info(inspect(serial_key))
    Task.start(fn -> HTTPoison.post("http://#{intercom_host_name}/door/open", "", ["Authorization": "Token #{serial_key}"]) end)
  end

  defp apartment_by_number_query(apartment_number), do: from(
    a in Apartment,
    where: a.apartment_number == ^apartment_number,
    preload: [
      tenants: [:devices]
    ]
  )

  defp get_available_port() do
    {:ok, port} = :gen_tcp.listen(0, [])
    {:ok, port_number} = :inet.port(port)
    true = Port.close(port)
    port_number
  end

end
