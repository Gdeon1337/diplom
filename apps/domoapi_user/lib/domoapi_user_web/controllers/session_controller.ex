defmodule DomoapiUserWeb.SessionController do
  use DomoapiUserWeb, :controller
  use PhoenixSwagger

  alias DomoapiUser.Guardian.Plug, as: GPlug
  alias Domoapi.People
  alias Domoapi.Intercoms
  alias Domoapi.People.Tenant
  require HTTPoison
  require Logger
  action_fallback DomoapiUserWeb.FallbackController

  def swagger_definitions do
    %{
      TenantAuthorize:
        swagger_schema do
          title("tenant_authorize")

          properties do
            password(:string, "user password", required: true)
            number_phone(:string, "number_phone", required: true)
          end

          example(%{
            password: "admin",
            number_phone: "89126224281"
          })
        end,
      Candidate:
       swagger_schema do
        title("candidate")
          properties do
            candidate(:string, "candidat", required: true)
          end
       end
    }
  end

  def check_user(%{"password" => password, "number_phone" => number_phone}) do
    Logger.info("check_user")
    tenant = People.get_tenant_of_number!(number_phone)
    if check_pass(tenant, password) do
      {:ok, tenant}
    else
      {:error, :unauthorize}
    end
  end

  def check_user(_attrs) do
    Logger.info("error_no_param")
    {:error, :incorrect_data}
  end

  def check_pass(tenant, password) when not is_nil(tenant) do
    Logger.info("check_pass")
    Bcrypt.verify_pass(password, tenant.password)
  end

  def check_pass(_tenant, _password) do
    Logger.info("incorrect login or password")
    false
  end

  swagger_path(:create) do
    post("/users/sign_in")
    summary("authorize")
    description("authorize in api")
    produces("application/json")
    parameter(:tenant_authorize, :body, Schema.ref(:TenantAuthorize), "The TenantAuthorize details")
    response(200, "OK")
  end
  def create(conn, params) do
    Logger.info("create_session")
    case check_user(params) do
      {:ok, tenant} ->
        Logger.info("OK users")
        conn
        |> GPlug.sign_in(tenant)
        |> json(%{token: GPlug.current_token(conn)})
      {:error, :incorrect_data} ->
        {:error, :incorrect_data}
      {:error, :unauthorize} ->
        {:error, :unauthorize}
      {:error, reason} ->
        Logger.info(inspect(reason))
        {:error, :unauthorized}
    end
  end

  swagger_path(:delete) do
    post("/users/sign_out")
    summary("sign_out")
    description("sign_out in api")
    produces("application/json")
    
    response(200, "OK")
  end
  def delete(conn, _params) do
    Logger.info("delete_session")
    conn
    |> GPlug.sign_out()
    |> json(%{})
  end

  swagger_path(:show) do
    get("/users/me")
    security [%{Bearer: []}]
    summary("show me")
    description("show me")
    produces("application/json")
    
    response(200, "OK",Schema.ref(:TenantAuthorize))
  end
  def show(conn, _params) do
    Logger.info("show_me")
    user = GPlug.current_resource(conn)
    json(conn, user)
  end

  swagger_path(:send_candidate) do
    post("/users/send_candidate")
    summary("send_candidate")
    description("send_candidate intercom")
    produces("application/json")
    parameter(:candidate, :body, Schema.ref(:Candidate), "The candidate details")
    response(200, "OK")
  end
  def send_candidate(conn, %{"candidate" => candidate}) do
    tenant = GPlug.current_resource(conn)
    intercoms = Intercoms.get_intercom(%{"tenant_id" => tenant.id})
    with {:ok, pid} <- request_intercom(intercoms.host_name, candidate, intercoms.serial_key, 3) do
      json(conn, %{status: :ok})
    end
  end

  def request_intercom(_host, _attrs, _serial_key, count) when count < 1 do
    {:error, :no_connection}
  end

  def request_intercom(host, candidate, serial_key, count)do
    with {:ok, data} <- Jason.encode(%{candidate: Jason.decode!(candidate)}), {:ok, response} <- HTTPoison.post("http://#{host}/call/candidate", data, [{"Authorization", "Token #{serial_key}"}, {"Content-type", "application/json"} ]) do
      if response.status_code != 200 do
        request_intercom(host, candidate, serial_key, count-1)
      end
      {:ok, data}
    else
      {:error, _message} -> request_intercom(host, candidate, serial_key, count - 1)
    end
  end
end
