defmodule DomoapiWeb.PhotoController do
  use DomoapiWeb, :controller
  use PhoenixSwagger

  alias Domoapi.People
  alias Domoapi.People.Photo
  alias Task
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController
  require Logger

  def swagger_definitions do
    %{
      InputPhotos:
        swagger_schema do
          title("input photo")
          properties do
            title(:string, "Photo name", required: true)
            photo_base64(:string, "data Photo base64", required: true)
        end
      end,
      OutputPhotos:
        swagger_schema do
          title("output photo")
          properties do
            id(:string, "Intercopms ID")
            title(:string, "Photo data")
            photo_base64(:string, "data Photo base64")
            tenant_id(:string, "Tenant ID")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/tenants/{tenant_id}/photos")
    security [%{Bearer: []}]
    summary("List photos")
    description("List all photos in the database")
    produces("application/json")
    parameters do
      tenant_id :path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f"
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
    end
    response(200, "OK", 
    %Schema{type: :object}
     |> Schema.property(:photos, Schema.array(:OutputPhotos), "List photo")
     |> Schema.property(:page_number, :integer, "Page number")
     |> Schema.property(:page_size, :integer, "Page Size")
     |> Schema.property(:total_pages, :integer, "Total pages")
     |> Schema.property(:total_entries, :integer, "Total entries")
    )
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(415, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def index(conn, params) do
    photos = People.list_photos(params)
    json(conn, %{
      photos: photos.entries,
      page_number: photos.page_number,
      page_size: photos.page_size,
      total_pages: photos.total_pages,
      total_entries: photos.total_entries
      })
  end

  swagger_path(:create) do
    post("/api/tenants/{tenant_id}/photos")
    security [%{Bearer: []}]
    summary("create photo")
    description("create photo in the database")
    produces("application/json")
    parameter(:tenant_id, :path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:photo, :body, Schema.ref(:InputPhotos), "The photo details")
    response(201, "OK", Schema.ref(:OutputPhotos))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def create(conn, photo_params) do
    with {:ok, %Photo{} = photo} <- People.create_photo(photo_params),
    {:ok, _pid} <- Task.start(fn -> publish_message(%{photo_base64: photo.photo_base64, id: photo.id}) end)
    do
      conn
      |> put_status(:created)
      |> json(photo)
    end
  end

  swagger_path(:show) do
    get("/api/tenants/{tenant_id}/photos/{id}")
    summary("Show photo")
    security [%{Bearer: []}]
    description("Show a photo by ID")
    produces("application/json")
    parameter(:tenant_id, :path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "photo ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputPhotos))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    photo = People.get_photo!(id)
    json(conn, photo)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/tenants/{tenant_id}/photos/{id}")
    summary("Update photo")
    description("Update attributes of a photo")
    consumes("application/json")
    produces("application/json")

    parameters do
      id(:path, :string, "photo ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      tenant_id(:path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:photo, :body, %Schema{type: :object}
    |> Schema.property(:photo, Schema.ref(:InputPhotos), "The photo details"),
     "The photo details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputPhotos))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "photo" => photo_params}) do
    photo = People.get_photo!(id)

    with {:ok, %Photo{} = photo} <- People.update_photo(photo, photo_params) do
      json(conn, photo)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/tenants/{tenant_id}/photos/{id}")
    security [%{Bearer: []}]
    summary("Delete photo")
    description("Delete a photo by ID")
    parameter(:tenant_id, :path, :string, "Tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "photo ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    photo = People.get_photo!(id)
    with {:ok, %Photo{}} <- People.delete_photo(photo) do
      json(conn, %{})
    end
  end

  def publish_message(%{:photo_base64 => photo_base64, :id => photo_id}) do 
    {:ok, connection} = AMQP.Connection.open host: Application.get_env(:domoapi_web, :rabbit_host), port: String.to_integer(Application.get_env(:domoapi_web, :rabbit_port)), username: Application.get_env(:domoapi_web, :rabbit_login), password: Application.get_env(:domoapi_web, :rabbit_password)
    {:ok, channel} = AMQP.Channel.open(connection)
    rabbit_queue = Application.get_env(:domoapi_web, :rabbit_queue)
    rabbit_exchange = Application.get_env(:domoapi_web, :rabbit_exchange)
    AMQP.Queue.declare(channel, rabbit_queue)
    AMQP.Exchange.declare(channel, rabbit_exchange)
    AMQP.Queue.bind(channel, rabbit_queue, rabbit_exchange)
    AMQP.Basic.publish(channel, rabbit_exchange, "", "{
      \"photo_base64\": #{photo_base64},
      \"photo_id\": #{photo_id}
    }")
    AMQP.Connection.close(connection)
  end
end
