defmodule SignallingWeb.ClientController do
    use SignallingWeb, :controller
    use PhoenixSwagger
    require Logger
    alias Signalling
    alias Signalling.{
        Session
    }
    alias SignallingWeb.Errors
    alias Domoapi.Intercoms.{
        Intercom
    }

    # preferences (Schema.new do
    #     properties do
    #       subscribe_to_mailing_list :boolean, "mailing list subscription", default: true
    #       send_special_offers :boolean, "special offers list subscription", default: true
    #     end
    #   end)
    # def swagger_definitions do
    #     %{
    #       RespondSuccess:
    #         swagger_schema do
    #           title("output camera")
    #           properties do
    #             id(:string, "camera ID")
    #             title(:string, "Название камеры")
    #             url(:string, "адресс камеры")
    #             intercom_id(:string, "ид домофона")
    #         end
    #       end,
    #       Success:
    #         swagger_schema do
    #           title("input camera")
    #           properties do
    #             title(:string, "Название камеры")
    #             url(:string, "адресс камеры")
    #             intercom_id(:string, "ид домофона")
    #         end
    #       end,
    #       IntercomNotFound:
    #         swagger_schema do
    #             title("input camera")
    #             properties do
    #                 title(:string, "Название камеры")
    #                 url(:string, "адресс камеры")
    #                 intercom_id(:string, "ид домофона")
    #         end
    #     end,
    #     }
    # end

    # swagger_path(:index) do
    #     get("/signalling/client/respond")
    #     security [%{Bearer: []}]
    #     summary("Respond to call")
    #     description("Respond to call")
    #     produces("application/json")
    #     
    #     parameter(:intercomp_id, :query, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    #     response(200, "OK", Schema.array(:OutputCameras))
    #     response(415, "Error",
    #     %Schema{type: :object}
    #     |> Schema.property(:error, :string, "Message Error"))
    #     response(401, "Error",
    #     %Schema{type: :object}
    #     |> Schema.property(:error, :string, "Message Error"))
    #   end
    def respond(conn, %{"session_id" => session_id, "client_id" => client_id, "sdp" => sdp, "candidate" => candidate}) do
        with true <- Session.session_exists?(session_id),
            {:ok, %{audio_port: audio_port}} <- Session.respond(session_id, client_id),
            %{intercom_serial_key: intercom_key} <- Session.session_info(session_id),
            %Intercom{host_name: intercom_host} <- Signalling.get_intercom_by_serial_key(intercom_key),
            _ <- Signalling.respond(intercom_host, sdp, intercom_key, candidate) do
                json(conn, %{status: :success, data: %{audio_port: audio_port}})
        else
            {:ok, :session_busy} ->
                Logger.warn("Session##{session_id} is busy")
                json(conn, %{status: :error, error_code: Errors.session_is_busy()})
            false ->
                Logger.error("Session##{session_id} does not exists")
                json(conn, %{status: :error, error_code: Errors.session_does_not_exists()})
            error ->
                Logger.error("Unknown error client response... ERROR: #{inspect(error)}")
                json(conn, %{status: :error, error_code: Errors.unknown_error()})
        end
    end

    def hang(conn, %{"session_id" => session_id, "client_id" => client_id}) do
        with true <- Session.session_exists?(session_id),
             %{intercom_serial_key: intercom_key} <- Session.session_info(session_id),
             _ <- Session.hang(session_id, client_id),
             %Intercom{host_name: intercom_host} <- Signalling.get_intercom_by_serial_key(intercom_key),
             _ <- Signalling.hang(intercom_host, intercom_key) do
                json(conn, %{status: :success, data: nil})
        else
            false ->
                Logger.error("Session##{session_id} does not exists")
                json(conn, %{status: :error, error_code: Errors.session_does_not_exists()})
            nil ->
                Logger.error("Intercom for hanging not found")
                json(conn, %{status: :error, error_code: Errors.intercom_not_found()})
            error ->
                Logger.error("Unknown error client response... ERROR: #{inspect(error)}")
                json(conn, %{status: :error, error_code: Errors.unknown_error()})
        end
    end

    def ping(conn, %{"session_id" => session_id, "client_id" => client_id}) do
        case Session.session_exists?(session_id) do
            true ->
                Session.ping(session_id, client_id)
                json(conn, %{status: :success, data: nil})
            false ->
                Logger.error("Session##{session_id} does not exists")
                json(conn, %{status: :error, error_code: Errors.session_does_not_exists()})
        end
    end

    def open_door(conn, %{"session_id" => session_id, "client_id" => client_id}) do
        with {:session_exists, true} <- {:session_exists, Session.session_exists?(session_id)},
             {:client_owns_session, true} <- {:client_owns_session, Session.caller_owns_session?(session_id, client_id)},
             %{intercom_serial_key: intercom_key} <- Session.session_info(session_id),
             %Intercom{host_name: intercom_host} <- Signalling.get_intercom_by_serial_key(intercom_key),
             _ <- Signalling.open_door(intercom_host, intercom_key) do
                json(conn, %{status: :success, data: nil})
        else
            {:session_exists, false} ->
                Logger.error("Session##{session_id} does not exists")
                json(conn, %{status: :error, error_code: Errors.session_does_not_exists()})
            {:client_owns_session, false} ->
                Logger.error("Client##{client_id} does not own session##{session_id}")
                json(conn, %{status: :error, error_code: Errors.client_does_not_own_session()})
            nil ->
                Logger.error("Intercom for open dooring not found")
                json(conn, %{status: :error, error_code: Errors.intercom_not_found()})
            error ->
                Logger.error("Unknown error client response... ERROR: #{inspect(error)}")
                json(conn, %{status: :error, error_code: Errors.unknown_error()})
        end
    end

end
