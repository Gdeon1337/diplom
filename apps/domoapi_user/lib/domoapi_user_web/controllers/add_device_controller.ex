defmodule DomoapiUserWeb.AddDeviceController do
  use DomoapiUserWeb, :controller
  use PhoenixSwagger
  alias Domoapi.People
  alias Domoapi.People.Device
  alias Domoapi.People.Tenant
  require HTTPoison
  action_fallback DomoapiUserWeb.FallbackController

  def swagger_definitions do
    %{
      InputDevices:
        swagger_schema do
          title("input devices")
          properties do
            device_type(:string, "Type devices")
            token(:string, "Token")
        end
      end,
      OutputDevices:
      swagger_schema do
        title("output devices")
        properties do
          id(:string, "Intercopms ID")
          device_type(:string, "Type devices")
          token(:string, "Token")
          tenant_id(:string, "Tenant ID")
      end
    end
    }
  end

  swagger_path(:add_device) do
    post("/users/verify_device")
    summary("add_device")
    description("add_device Tenant")
    produces("application/json")
    
    parameters do
      phone_number :query, :string, "binding_token type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f"
    end
    response(201, "OK", Schema.ref(:OutputDevices))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(403, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))   
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))   
  end
  def add_device(conn, %{"phone_number" => phone_number,} = attrs) do
    with {:ok, tenant} <- People.get_tenant_of_number(attrs) do
      password = random_code()
      with {:ok, response} <- request_verify_code(phone_number, password, 3),
        {:ok, %Tenant{} = tenant} <- People.update_tenant(tenant, %{"raw_password" => password}) do
        conn
        |> json(%{status: :ok})
      end
    end
  end

  def request_verify_code(_phone, _verify_code, count) when count < 1 do
    {:error, :no_connection}
  end

  def request_verify_code(phone, verify_code, count) do
    with {:ok, response} <- HTTPoison.get("https://smsc.ru/sys/send.php?login=gdeon&psw=Wqyvm3s6dQNKNn6&phones=#{phone}&mes=#{verify_code}") do
        {:ok, response}
    else
        {:error, message} -> request_verify_code(phone, verify_code, count - 1)
    end
  end

  def random_code() do
      charset = "CDEFGHJKLMNPQRTUVWXYZ23679" |> String.split("", trim: true)
  
      random_chars = Enum.reduce((0..9), [], fn (_i, acc) ->
          [Enum.random(charset) | acc]
      end) |> Enum.join("")
  
      group_a = String.slice(random_chars, 1..3)
      group_b = String.slice(random_chars, 4..6)
  
      "#{group_a}-#{group_b}"
  end
end
