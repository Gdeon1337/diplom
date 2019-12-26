defmodule SignallingWeb.IntercomController do
    require Logger
    use SignallingWeb, :controller
    alias Signalling
    alias SignallingWeb.Errors
    alias Domoapi.Intercoms
    alias Domoapi.Intercoms.{
        Intercom
    }

    def init_intercom(conn, %{"intercom_serial_key" => intercom_serial_key, "host" => host_name} = params) do
        Logger.warn("Hahaha")
        case Signalling.get_intercom_by_serial_key(intercom_serial_key) do
            %Intercom{id: intercom_id} ->
                Intercoms.get_intercom!(intercom_id)
                |> Intercoms.update_intercom(%{"host_name" => host_name})
                |> Intercoms.update_all_cameras
                conn
                |> json(%{status: :success, data: %{intercom_id: intercom_id}})
            nil ->
                Logger.error("Could not init intercom because intercom was not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.intercom_not_found()})
        end
    end

    def reset_ip(conn, %{"intercom_serial_key" => intercom_serial_key, "host" => host_name} = params) do
        case Signalling.get_intercom_by_serial_key(intercom_serial_key) do
            %Intercom{id: intercom_id} ->
                Intercoms.get_intercom!(intercom_id)
                |> Intercoms.update_intercom(%{"host_name" => host_name})
                |> Intercoms.update_all_cameras
                conn
                |> json(%{status: :success, data: %{intercom_id: intercom_id}})
            nil ->
                Logger.error("Could not init intercom because intercom was not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.intercom_not_found()})
        end
    end

    def call_intercom(conn, %{"intercom_serial_key" => intercom_serial_key, "apartment_number" => apartment_number, "sdp" => sdp, "candidate" => candidate} = params) do
        case Signalling.call(intercom_serial_key, apartment_number, sdp,  candidate) do
            {:ok, audio_port} ->
                conn
                |> json(%{status: :success, data: %{audio_port: audio_port}})
            {:error, :apartment_not_found} ->
                Logger.error("Could not accept call from intercom because apartment not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.apartment_not_found()})
            {:error, :intercom_not_found} ->
                Logger.error("Could not accept call from intercom because intercom not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.intercom_not_found()})
            error ->
                Logger.error("Unknown error during receiving call from intercom: PARAMS: #{inspect(params)}, ERROR:#{inspect(error)}")
                conn
                |> put_status(:service_unavailable)
                |> json(%{status: :error, error_code: Errors.unknown_error})
        end
    end


    def sdp_intercom(conn, %{"intercom_serial_key" => intercom_serial_key, "apartment_number" => apartment_number,  "candidate" => candidate} = params) do
        case Signalling.call_sdp(intercom_serial_key, apartment_number, candidate) do
            {:ok} ->
                conn
                |> json(%{status: :success})
            {:error, :apartment_not_found} ->
                Logger.error("Could not accept call from intercom because apartment not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.apartment_not_found()})
            {:error, :intercom_not_found} ->
                Logger.error("Could not accept call from intercom because intercom not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.intercom_not_found()})
            error ->
                Logger.error("Unknown error during receiving call from intercom: PARAMS: #{inspect(params)}, ERROR:#{inspect(error)}")
                conn
                |> put_status(:service_unavailable)
                |> json(%{status: :error, error_code: Errors.unknown_error})
        end
    end


    def break_call_intercom(conn, %{"intercom_serial_key" => intercom_serial_key, "apartment_number" => apartment_number} = params) do
        case Signalling.break_call(intercom_serial_key, apartment_number) do
            :ok ->
                conn
                |> json(%{status: :success})
            {:error, :apartment_not_found} ->
                Logger.error("Could not accept call from intercom because apartment not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.apartment_not_found()})
            {:error, :intercom_not_found} ->
                Logger.error("Could not accept call from intercom because intercom not found: PARAMS: #{inspect(params)}")
                conn
                |> put_status(:not_found)
                |> json(%{status: :error, error_code: Errors.intercom_not_found()})
            error ->
                Logger.error("Unknown error during receiving call from intercom: PARAMS: #{inspect(params)}, ERROR:#{inspect(error)}")
                conn
                |> put_status(:service_unavailable)
                |> json(%{status: :error, error_code: Errors.unknown_error})
        end
    end


end
