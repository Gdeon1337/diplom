defmodule DomoapiWeb.Plugs.Authorization do
    import Plug.Conn
    require Logger
    
    alias Domoapi.Repo
    alias Ecto.Query
    alias Domoapi.Users

    def init(_params) do
    end
  
    def call(conn, _params) do
        with {:ok, token} <- extract_token(conn),
        {:ok, token} <- Base.decode64(token),
        [login, password] <- String.split(token, ":"),
        user <- Users.check_user(login, password) do
            conn
            |> assign(:company_id, user.company_id)
            |> assign(:company_role_id, user.company_role_id)
            |> assign(:role, user.role_id)
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