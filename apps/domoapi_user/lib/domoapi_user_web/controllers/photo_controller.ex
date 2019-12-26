defmodule DomoapiUserWeb.PhotoController do
  use DomoapiUserWeb, :controller
  use PhoenixSwagger
  alias Domoapi.People
  alias Domoapi.People.Photo
  alias Domoapi.Intercoms
  alias Task
  require Logger
  alias DomoapiUser.Guardian.Plug, as: GPlug
  action_fallback DomoapiWeb.FallbackController


  def swagger_definitions do
    %{
      InputPhotos:
        swagger_schema do
          title("input photo")
          properties do
            photo_base64(:string, "data Photo base64", required: true)
        end
      end,
      OutputPhotos:
        swagger_schema do
          title("output photo")
          properties do
            id(:string, "Intercopms ID")
            photo_base64(:string, "data Photo base64")
            tenant_id(:string, "Tenant ID")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/users/photos")
    security [%{Bearer: []}]
    summary("List photos")
    description("List all photos in the database")
    produces("application/json")
    
    parameters do
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
    tenant = GPlug.current_resource(conn)
    params = Map.put(params, "tenant_id", tenant.id)
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
    post("/users/photos")
    security [%{Bearer: []}]
    summary("create photo")
    description("create photo in the database")
    produces("application/json")
    
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
    tenant = GPlug.current_resource(conn)
    photo_params = Map.put(photo_params, "tenant_id", tenant.id)
    intercom = Intercoms.get_intercom(%{"tenant_id" => tenant.id})
    with {:ok, %Photo{} = photo} <- People.create_photo(photo_params),
    {:ok, pid} <- Task.start(fn -> request_intercom_add_photo(intercom.host_name, %{photo_base64: photo.photo_base64, id: photo.id}, intercom.serial_key, 3) end)
    do
      conn
      |> put_status(:created)
      |> json(photo)
    end
  end

  swagger_path(:show) do
    get("/users/photos/{id}")
    summary("Show photo")
    security [%{Bearer: []}]
    description("Show a photo by ID")
    produces("application/json")
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
    put("/users/photos/{id}")
    summary("Update photo")
    description("Update attributes of a photo")
    consumes("application/json")
    produces("application/json")

    parameters do
      id(:path, :string, "photo ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
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
    PhoenixSwagger.Path.delete("/users/photos/{id}")
    security [%{Bearer: []}]
    summary("Delete photo")
    description("Delete a photo by ID")
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

  def request_intercom_add_photo(_host, _attrs, _serial_key, count) when count < 1 do
    {:error, :no_connection}
  end

  def request_intercom_add_photo(host, %{:photo_base64 => photo_base64, :id => photo_id}, serial_key, count)do
    with {:ok, response} <- HTTPoison.post("http://#{host}/faces", "{
          \"photo_base64\": \"#{photo_base64}\",
          \"photo_id\": \"#{photo_id}\"
        }", %{"Authorization" => "Token #{serial_key}", "Content-type" => "application/json"})do
      if response.status_code != 200 do
        request_intercom_add_photo(host, %{:photo_base64 => photo_base64, :id => photo_id}, serial_key, count-1)
      end
    else
      {:error, message} -> request_intercom_add_photo(host, %{:photo_base64 => photo_base64, :id => photo_id}, serial_key, count- 1)
    end
  end
end
