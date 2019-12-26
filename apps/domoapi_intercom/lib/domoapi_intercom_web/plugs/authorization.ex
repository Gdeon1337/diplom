defmodule DomoapiIntercomWeb.Plugs.Authorization do
    import Plug.Conn
    require Logger
    
    alias Domoapi.Intercoms

    def init(_params) do
    end
  
    def call(conn, _params) do
        with {:ok, token} <- extract_token(conn),
        intercom <- Intercoms.check_intercom(token) do
            conn
            |> assign(:intercom_serial_key, intercom.serial_key)
            |> assign(:user_signed_in?, true)
        else
            {:error, :unauthorized} ->
                conn
                |> put_status(401)
                |> Phoenix.Controller.json(%{})
                |> halt()
            nil ->
                conn
                |> put_status(401)
                |> Phoenix.Controller.json(%{})
                |> halt()
            error ->
                conn
                |> put_status(402)
                |> Phoenix.Controller.json(%{})
                |> halt()
        end
    end

    defp extract_token(conn) do
        case Plug.Conn.get_req_header(conn, "authorization") do
          [auth_header] -> get_token_from_header(auth_header)
           _ -> {:error, :unauthorized}
        end
    end

    defp get_token_from_header(auth_header) do
        {:ok, reg} = Regex.compile("Bearer\:?\s+(.*)$", "i")
        case Regex.run(reg, auth_header) do
          [_, match] -> {:ok, String.trim(match)}
          _ -> {:error, :unauthorized}
        end
      end

end