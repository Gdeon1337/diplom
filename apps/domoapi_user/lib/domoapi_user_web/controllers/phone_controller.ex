defmodule DomoapiUserWeb.DeviceController do
  use DomoapiUserWeb, :controller
  use PhoenixSwagger
  alias Domoapi.People
  alias Domoapi.People.Device
  alias DomoapiUser.Guardian.Plug, as: GPlug
  action_fallback DomoapiUserWeb.FallbackController

  def swagger_definitions do
    %{
      InputDevices:
        swagger_schema do
          title("input devices")
          properties do
            device_type(:string, "Type devices")
            token(:string, "Token")
            serial_key(:string, "Serial Key")
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

  swagger_path(:create) do
    security [%{Bearer: []}]
    post("/users/devices")
    summary("Update/create device")
    description("Update/create a device")
    consumes("application/json")
    produces("application/json")
    parameter(:device, :body, %Schema{type: :object}
    |> Schema.property(:device, Schema.ref(:InputDevices), "The device details"),
      "The device details", required: true)
    response(200, "Updated/create Successfully", Schema.ref(:OutputDevices))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))   
  end
  def create(conn, %{"serial_key" => serial_key} = device_params) do
    tenant = GPlug.current_resource(conn)
    device_params = Map.put(device_params, "tenant_id", tenant.id)
    device = People.get_device_by_serial_key(serial_key)
    if is_nil(device) do
      with {:ok, %Device{} = device} <- People.create_device(device_params) do
        json(conn,  device)
      end
    else
      with {:ok, %Device{} = device} <- People.update_device(device, device_params) do
        json(conn,  device)
      end
    end
  end

  swagger_path(:index) do
    get("/users/devices")
    security [%{Bearer: []}]
    summary("List devices")
    description("List all devices in the database")
    produces("application/json")
    
    parameter(:tenant_id, :path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.array(:OutputDevices))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index(conn, params) do
    tenant = GPlug.current_resource(conn)
    params = Map.put(params, "tenant_id", tenant.id)
    devices = People.list_devices(params)
    json(conn, devices)
  end

  swagger_path(:show) do
    get("/users/devices/{id}")
    summary("Show device")
    security [%{Bearer: []}]
    description("Show a device by ID")
    produces("application/json")
    parameter(:tenant_id, :path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "device ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputDevices))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    device = People.get_device!(id)
    json(conn, device)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/users/devices/{id}")
    summary("Update device")
    description("Update attributes of a device")
    consumes("application/json")
    produces("application/json")
    parameters do
      tenant_id(:path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      id(:path, :string, "device ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:device, :body, %Schema{type: :object}
    |> Schema.property(:device, Schema.ref(:InputDevices), "The device details"),
      "The device details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputDevices))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))   
  end
  def update(conn, %{"id" => id, "device" => device_params}) do
    device = People.get_device!(id)
    with {:ok, %Device{} = device} <- People.update_device(device, device_params) do
      json(conn,  device)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/users/devices/{id}")
    security [%{Bearer: []}]
    summary("Delete device")
    description("Delete a device by ID")
    parameter(:tenant_id, :path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "devices ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    device = People.get_device!(id)

    with {:ok, %Domoapi.People.Device{}} <- People.delete_device(device) do
      json(conn, %{})
    end
  end
end
