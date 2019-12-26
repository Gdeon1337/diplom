defmodule DomoapiWeb.HouseController do
  use DomoapiWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.Place
  alias Domoapi.Place.House
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController

  def swagger_definitions do
    %{
      OutputHouses:
        swagger_schema do
          title("output house")
          properties do
            id(:string, "House ID")
            title(:string, "Title")
            address(:string, "address House")
        end
      end,
      InputHouses:
        swagger_schema do
          title("input house")
          properties do
            title(:string, "Title")
            address(:string, "address House")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/houses")
    security [%{Bearer: []}]
    summary("List houses")
    description("List all house in the database")
    produces("application/json")
    
    parameters do
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
    end
    response(200, "OK", 
    %Schema{type: :object}
     |> Schema.property(:houses, Schema.array(:OutputHouses), "List houses")
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
  def index(conn, params)do
    company_id = conn.assigns[:company_id]
    params = Map.put(params, "company_id", company_id)
    houses = Place.list_houses(params)
    json(conn, %{
      houses: houses.entries,
      page_number: houses.page_number,
      page_size: houses.page_size,
      total_pages: houses.total_pages,
      total_entries: houses.total_entries
      })
  end

  swagger_path(:create) do
    post("/api/houses")
    security [%{Bearer: []}]
    summary("create house")
    description("create house in the database")
    produces("application/json")
    
    parameter(:house, :body, Schema.ref(:InputHouses), "The house details")
    response(201, "OK", Schema.ref(:OutputHouses))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def create(conn, house_params) do
    company_id = conn.assigns[:company_id]
    house_params = Map.put(house_params, "company_id", company_id)
    with {:ok, %House{} = house} <- Place.create_house(house_params) do
      conn
      |> put_status(:created)
      |> json(house)
    end
  end

  swagger_path(:show) do
    summary("Show house")
    security [%{Bearer: []}]
    description("Show a house by ID")
    produces("application/json")
    parameter(:id, :path, :string, "house ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputHouses))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
      house = Place.get_house!(id)
      json(conn, house)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/houses/{id}")
    summary("Update house")
    description("Update attributes of a house")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "house ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:house, :body, %Schema{type: :object}
    |> Schema.property(:house, Schema.ref(:InputHouses), "The house details"),
     "The house details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputHouses))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "house" => house_params}) do
    house = Place.get_house!(id)
    with {:ok, %House{} = house} <- Place.update_house(house, house_params) do
      json(conn, house)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/houses/{id}")
    security [%{Bearer: []}]
    summary("Delete houses")
    description("Delete a houses by ID")
    parameter(:id, :path, :string, "houses ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    house = Place.get_house!(id)

    with {:ok, %House{}} <- Place.delete_house(house) do
      json(conn, %{})
    end
  end
end
