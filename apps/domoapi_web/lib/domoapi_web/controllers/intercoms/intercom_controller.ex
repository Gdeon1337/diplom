defmodule DomoapiWeb.IntercomController do
  use DomoapiWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.Intercoms
  alias Domoapi.Place
  alias Domoapi.Intercoms.Intercom
  alias Domoapi.Place.IntercomsApartments
  require HTTPoison
  require Logger
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController


  def swagger_definitions do
    %{
      OutputIntercoms:
        swagger_schema do
          title("output intercoms")
          properties do
            id(:string, "Intercoms ID")
            title(:string, "Название домофона")
            enabled(:boolean, "состояние")
            serial_key(:string, "серийный ключ")
            hardware_version(:string, "аппаратная версия")
            software_version(:string, "версия софта")
            host_name(:string, "ip адрес")
            house_id(:string, "id дома")
        end
      end,
      InputIntercoms:
        swagger_schema do
          title("input intercoms")
          properties do
            title(:string, "Название домофона")
            enabled(:boolean, "состояние")
            serial_key(:string, "серийный ключ")
            hardware_version(:string, "аппаратная версия")
            software_version(:string, "версия софта")
            host_name(:string, "ip адрес")
            house_id(:string, "id дома")
        end
      end,
      OutputIntercomsApartments:
      swagger_schema do
        title("output intercoms_apartments")
        properties do
          apartment_id(:string, "apartment id")
          intercom_id(:string, "intercom_id")
      end
    end
    }
  end

  swagger_path(:index) do
    get("/api/intercoms")
    security [%{Bearer: []}]
    summary("List intercoms")
    description("List all intercoms in the database")
    produces("application/json")
    
    parameters do
      house_id :query, :string, "House ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f"
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
    end
    response(200, "OK", 
    %Schema{type: :object}
     |> Schema.property(:intercoms, Schema.array(:OutputIntercoms), "List intercoms")
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
    intercoms = Intercoms.list_intercoms(params)
    json(conn, %{
      intercoms: intercoms.entries,
      page_number: intercoms.page_number,
      page_size: intercoms.page_size,
      total_pages: intercoms.total_pages,
      total_entries: intercoms.total_entries
      })
  end

  swagger_path(:create) do
    post("/api/intercoms")
    security [%{Bearer: []}]
    summary("create intercom")
    description("create intercom in the database")
    produces("application/json")
    parameter(:intercom, :body, Schema.ref(:InputIntercoms), "The Intercoms details")
    response(201, "OK", Schema.ref(:OutputIntercoms))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def create(conn, intercom_params) do
    company_id = conn.assigns[:company_id]
    intercom_params = Map.put(intercom_params, "company_id", company_id)
    with {:ok, %Intercom{} = intercom} <- Intercoms.create_intercom(intercom_params) do
      conn
      |> put_status(:created)
      |> json(intercom)
    end
  end

  swagger_path(:show) do
    summary("Show intercoms")
    security [%{Bearer: []}]
    description("Show a intercoms by ID")
    produces("application/json")
    parameter(:id, :path, :string, "intercoms ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:InputIntercoms))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    intercom = Intercoms.get_intercom(%{id: id, company_id: conn.assigns[:company_id]})
    json(conn, intercom)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/intercoms/{id}")
    summary("Update intercoms")
    description("Update attributes of a intercoms")
    consumes("application/json")
    produces("application/json")

    parameters do
      id(:path, :string, "intercoms ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:intercom, :body, %Schema{type: :object}
    |> Schema.property(:intercom, Schema.ref(:InputIntercoms), "The Intercoms details"),
     "The Intercoms details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputIntercoms))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "intercom" => intercom_params}) do
    intercom = Intercoms.get_intercom(%{id: id, company_id: conn.assigns[:company_id]})

    with {:ok, %Domoapi.Intercoms.Intercom{} = intercom} <- Intercoms.update_intercom(intercom, intercom_params) do
      json(conn, intercom)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/intercoms/{id}")
    security [%{Bearer: []}]
    summary("Delete intercom")
    description("Delete a intercom by ID")
    parameter(:id, :path, :string, "intercom ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    intercom = Intercoms.get_intercom(%{id: id, company_id: conn.assigns[:company_id]})

    with {:ok, %Domoapi.Intercoms.Intercom{}} <- Intercoms.delete_intercom(intercom) do
      json(conn, %{})
    end
  end

  swagger_path(:open_door) do
    PhoenixSwagger.Path.get("/api/intercoms/{intercom_id}/open_door")
    security [%{Bearer: []}]
    summary("Open door intercom")
    description("Open door intercom")
    parameter(:intercom_id, :path, :string, "intercom ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def open_door(conn, %{"intercom_id" => id}) do
    with %Domoapi.Intercoms.Intercom{} = intercom <- Intercoms.get_intercom(%{id: id, company_id: conn.assigns[:company_id]}) do
      host = intercom.host_name
      with {:ok, pid} <- Task.start(fn -> open_door_task(host, intercom.serial_key) end) do
        json(conn, %{})
      end
    end
  end

  def open_door_task(host, serial_key)do
    HTTPoison.post("http://#{host}/door/open", '{}', ["Authorization": "Token #{serial_key}"]) 
  end

  swagger_path(:bind_apartment) do
    post("/api/intercoms/{intercom_id}/bind_apartment")
    security [%{Bearer: []}]
    summary("bind apartment intercoms")
    description("bind apartment intercoms")
    produces("application/json")
    
    parameter(:apartment_id, :query, :string, "The apartment ID",required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:intercom_id, :path, :string, "intercom ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputIntercomsApartments))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def bind_apartment(conn, intercoms_apartments_params) do
    with {:ok, %IntercomsApartments{} = intercoms_apartments} <- Place.create_intercoms_apartments(intercoms_apartments_params) do
      conn
      |> put_status(:created)
      |> json(intercoms_apartments)
    end
  end

  swagger_path(:unbind_apartment) do
    PhoenixSwagger.Path.delete("/api/intercoms/{intercom_id}/unbind_apartment")
    security [%{Bearer: []}]
    summary("unbind apartment intercoms")
    description("unbind apartment intercoms")
    parameter(:apartment_id, :query, :string, "The apartment ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    parameter(:intercom_id, :path, :string, "intercom ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def unbind_apartment(conn, %{"apartment_id" => apartment_id, "intercom_id" => intercom_id}) do
    intercoms_apartments = Place.get_intercoms_apartments(%{apartment_id: apartment_id, intercom_id: intercom_id})
    
    with {:ok, %IntercomsApartments{}} <- Place.delete_intercoms_apartments(intercoms_apartments) do
      json(conn, %{})
    end
  end

  swagger_path(:bind_apartments) do
    get("/api/intercoms/{intercom_id}/bind_apartments")
    security [%{Bearer: []}]
    summary("list bind apartment intercoms")
    description("list bind apartment intercoms")
    produces("application/json")
    
    parameters do
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
    end
    parameter(:intercom_id, :path, :string, "intercom ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.array(:OutputIntercomsApartments))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def bind_apartments(conn, intercoms_apartments_params) do
    company_id = conn.assigns[:company_id]
    intercoms_apartments_params = Map.put(intercoms_apartments_params, "company_id", company_id)
    intercoms = Place.list_intercoms_apartments(intercoms_apartments_params)
    json(conn, %{
      intercoms_apartments: intercoms.entries,
      page_number: intercoms.page_number,
      page_size: intercoms.page_size,
      total_pages: intercoms.total_pages,
      total_entries: intercoms.total_entries
      })
  end
end
