defmodule DomoapiWeb.CameraController do
  use DomoapiWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.Intercoms
  alias Domoapi.Intercoms.Camera
  require HTTPoison
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController

  def swagger_definitions do
    %{
      OutputCameras:
        swagger_schema do
          title("output camera")
          properties do
            id(:string, "camera ID")
            title(:string, "Название камеры")
            url(:string, "адресс камеры")
            intercom_id(:string, "ид домофона")
        end
      end,
      InputCameras:
        swagger_schema do
          title("input camera")
          properties do
            title(:string, "Название камеры")
            url(:string, "адресс камеры")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/intercoms/{intercom_id}/cameras")
    security [%{Bearer: []}]
    summary("List cameras")
    description("List all cameras in the database")
    produces("application/json")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.array(:OutputCameras))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index(conn, params) do
    company_id = conn.assigns[:company_id]
    params = Map.put(params, "company_id", company_id)
    cameras = Intercoms.list_cameras(params)
    json(conn, cameras)
  end

  swagger_path(:create) do
    post("/api/intercoms/{intercom_id}/cameras")
    security [%{Bearer: []}]
    summary("create camera")
    description("create camera in the database")
    produces("application/json")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:camera, :body, Schema.ref(:InputCameras), "The Camera details")
    response(201, "OK", Schema.ref(:OutputCameras))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    
  end
  def create(conn, camera_params) do
    company_id = conn.assigns[:company_id]
    camera_params = Map.put(camera_params, "company_id", company_id)
    with {:ok, %Camera{} = camera} <- Intercoms.create_camera(camera_params),
    {:ok, pid} <- Task.start(fn -> create_child(camera.id) end) do
      conn
      |> put_status(:created)
      |> json(camera)
    end 
  end

  swagger_path(:show) do
    get("/api/intercoms/{intercom_id}/cameras/{id}")
    summary("Show Camera")
    security [%{Bearer: []}]
    description("Show a camera by ID")
    produces("application/json")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "Camera ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputCameras))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end

  def show(conn, %{"id" => id}) do
    camera = Intercoms.get_camera!(id)
    json(conn, camera)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/intercoms/{intercom_id}/cameras/{id}")
    summary("Update Camera")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    description("Update attributes of a Camera")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "Camera ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:camera, :body, %Schema{type: :object}
    |> Schema.property(:camera, Schema.ref(:InputCameras), "The camera details"),
     "The camera details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputCameras))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end

  def update(conn, %{"id" => id, "camera" => camera_params}) do
    camera = Intercoms.get_camera!(id)
    with {:ok, %Camera{} = camera} <- Intercoms.update_camera(camera, camera_params) do
      json(conn, camera)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/intercoms/{intercom_id}/cameras/{id}")
    security [%{Bearer: []}]
    summary("Delete Camera")
    description("Delete a Camera by ID")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "Camera ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end

  def delete(conn, %{"id" => id}) do
    camera = Intercoms.get_camera!(id)
    with {:ok, %Camera{}} <- Intercoms.delete_camera(camera),
    {:ok, pid} <- Task.start(fn -> delete_child(camera.id) end) do
      json(conn, %{})
    end
  end

  def create_child(camera_id) do
    archive_url = Application.get_env(:domoapi_web, :archive_url)
    HTTPoison.post("http://#{archive_url}/add_child", '{
      "id": #{camera_id}
      }', [{"content-type", "application/json"}]) 
  end

  def delete_child(camera_id) do
    archive_url = Application.get_env(:domoapi_web, :archive_url)
    HTTPoison.post("http://#{archive_url}/add_child", '{
      "id": #{camera_id}
      }', [{"content-type", "application/json"}]) 
  end
end
