defmodule DomoapiWeb.KeyController do
  use DomoapiWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.Intercoms
  alias Domoapi.Intercoms.Key
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController

  def swagger_definitions do
    %{
      InputKeys:
        swagger_schema do
          title("input keys")
          properties do
            title(:string, "key name")
        end
      end,
      OutputKeys:
        swagger_schema do
          title("output keys")
          properties do
            id(:string, "Key ID")
            title(:string, "key name")
            intercom_id(:string, "intercom_id")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/intercoms/{intercom_id}/keys")
    security [%{Bearer: []}]
    summary("List keys")
    description("List all keys in the database")
    produces("application/json")
    
    parameters do
      intercom_id :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f"
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
    end
    response(200, "OK", 
    %Schema{type: :object}
     |> Schema.property(:keys, Schema.array(:OutputKeys), "List intercoms")
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
    company_id = conn.assigns[:company_id]
    params = Map.put(params, "company_id", company_id)
    keys = Intercoms.list_keys(params)
    json(conn, %{
      keys: keys.entries,
      page_number: keys.page_number,
      page_size: keys.page_size,
      total_pages: keys.total_pages,
      total_entries: keys.total_entries
      })
  end

  swagger_path(:create) do
    post("/api/intercoms/{intercom_id}/keys")
    security [%{Bearer: []}]
    summary("create key")
    description("create key in the database")
    produces("application/json")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:key, :body, Schema.ref(:InputKeys), "The keys details")
    response(201, "OK", Schema.ref(:OutputKeys))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end

  def create(conn, key_params) do
    key_params = Map.put(key_params, "company_id", conn.assigns[:company_id])
    with {:ok, %Key{} = key} <- Intercoms.create_key(key_params) do
      conn
      |> put_status(:created)
      |> json(key)
    end
  end

  swagger_path(:show) do
    get("/api/intercoms/{intercom_id}/keys/{id}")
    summary("Show key")
    security [%{Bearer: []}]
    description("Show a key by ID")
    produces("application/json")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "key ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(200, "OK", Schema.ref(:OutputKeys))
  end
  def show(conn, %{"id" => id}) do
    key = Intercoms.get_key!(id)
    json(conn, key)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/intercoms/{intercom_id}/keys/{id}")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    summary("Update key")
    description("Update attributes of a key")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "key ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:key, :body, %Schema{type: :object}
    |> Schema.property(:key, Schema.ref(:InputKeys), "The key details"),
     "The key details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputKeys))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "key" => key_params}) do
    key = Intercoms.get_key!(id)

    with {:ok, %Key{} = key} <- Intercoms.update_key(key, key_params) do
      json(conn, key)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/intercoms/{intercom_id}/keys/{id}")
    security [%{Bearer: []}]
    summary("Delete key")
    description("Delete a key by ID")
    parameter(:intercom_id, :path, :string, "intercom ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:id, :path, :string, "key ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
  end
  def delete(conn, %{"id" => id}) do
    key = Intercoms.get_key!(id)

    with {:ok, %Key{}} <- Intercoms.delete_key(key) do
      json(conn, %{})
    end
  end
end
