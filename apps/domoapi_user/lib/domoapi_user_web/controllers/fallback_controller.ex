defmodule DomoapiUserWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use DomoapiUserWeb, :controller
  require Logger

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(DomoapiUserWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(DomoapiUserWeb.ErrorView)
    |> render(:"404")
  end
  def auth_error(conn, {type, _reason}, _opts) do
    Logger.error("auth_error")
    conn
    |> put_status(401)
    |> json(%{status: 401, error: to_string(type)})
  end
  def call(conn, {:error, :forbidden}) do
    Logger.error("error forbidden")
    conn
    |> put_status(403)
    |> json(%{status: 403, error: "forbidden"})
  end
  def call(conn, {:error, :unauthorized}) do
    Logger.error("error unauthorized")
    conn
    |> put_status(401)
    |> json(%{status: 401, error: "unauthorized"})
  end
  def call(conn, {:error, :unauthorize}) do
    Logger.error("error unauthorized")
    conn
    |> put_status(401)
    |> json(%{status: 401, error: "unauthorized"})
  end
  def call(conn, {:error, :incorrect_data}) do
    Logger.error("error incorrect_data")
    conn
    |> put_status(415)
    |> json(%{status: 415, error: "incorrect_data"})
  end
  def call(conn,  {:error, :token_is_dead}) do
    Logger.error("error token_is_dead")
    conn
    |> put_status(403)
    |> json(%{status: 403, error: "token_is_dead"})
  end
  def call(conn,  {:error, :incorrect_host}) do
    Logger.error("error bad host intercoms")
    conn
    |> put_status(403)
    |> json(%{status: 403, error: "bad host intercoms"})
  end

  def call(conn,  {:error, :no_connection}) do
    Logger.error("error no_connection")
    conn
    |> put_status(415)
    |> json(%{status: 415, error: "no_connection"})
  end

end
