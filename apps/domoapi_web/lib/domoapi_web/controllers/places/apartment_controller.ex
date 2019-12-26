defmodule DomoapiWeb.ApartmentController do
  use DomoapiWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.Place
  alias Domoapi.Place.Apartment
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController

  def swagger_definitions do
    %{
      OutputApartments:
        swagger_schema do
          title("output aprtment")
          properties do
            id(:string, "Apartment ID")
            apartment_number(:integer, "Numbert apartment")
            house_id(:string, "House ID")
        end
      end,
      InputApartments:
      swagger_schema do
        title("input aprtment")
        properties do
          apartment_number(:integer, "Numbert apartment")
          house_id(:string, "House ID")
      end
    end
  }
  end

  swagger_path(:index) do
    get("/api/apartments")
    security [%{Bearer: []}]
    summary("List apartment")
    description("List all apartment in the database")
    produces("application/json")
    
    parameters do
      house_id :query, :string, "house ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f"
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
    end
    response(201, "OK", 
    %Schema{type: :object}
      |> Schema.property(:apartments, Schema.array(:OutputApartments), "List Apartments")
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
    apartments = Place.list_apartments(params)
    json(conn, %{
      apartments: apartments.entries,
      page_number: apartments.page_number,
      page_size: apartments.page_size,
      total_pages: apartments.total_pages,
      total_entries: apartments.total_entries
      })
  end

  swagger_path(:create) do
    post("/api/apartments")
    security [%{Bearer: []}]
    summary("create apartment")
    description("create apartment in the database")
    produces("application/json")
    
    parameter(:apartment, :body, Schema.ref(:InputApartments), "The apartment details")
    response(200, "OK", Schema.ref(:OutputApartments))
    response(401, "Error", 
    %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error")) 
  end
  def create(conn, apartment_params) do
    company_id = conn.assigns[:company_id]
    apartment_params = Map.put(apartment_params, "company_id", company_id)
    with {:ok, %Apartment{} = apartment} <- Place.create_apartment(apartment_params) do
      conn
        |> put_status(:created)
        |> json(apartment)
    end
  end

  swagger_path(:show) do
    summary("Show apartment")
    security [%{Bearer: []}]
    description("Show a apartment by ID")
    produces("application/json")
    parameter(:id, :path, :string, "apartment ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputApartments))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    apartment = Place.get_apartment!(id)
    json(conn, apartment)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/apartments/{id}")
    summary("Update apartment")
    description("Update attributes of a apartment")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "apartment ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:apartment, :body, %Schema{type: :object}
    |> Schema.property(:apartment, Schema.ref(:InputApartments), "The apartment details"), "The apartment details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputApartments))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "apartment" => apartment_params}) do
    apartment = Place.get_apartment!(id)

    with {:ok, %Apartment{} = apartment} <- Place.update_apartment(apartment, apartment_params) do
      json(conn, apartment)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/apartments/{id}")
    security [%{Bearer: []}]
    summary("Delete apartment")
    description("Delete a apartment by ID")
    parameter(:id, :path, :string, "apartment ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    apartment = Place.get_apartment!(id)

    with {:ok, %Apartment{}} <- Place.delete_apartment(apartment) do
      json(conn, %{})
    end
  end

end
