defmodule DomoapiWeb.ContractController do
  use DomoapiWeb, :controller
  use PhoenixSwagger
  alias Domoapi.Place
  alias Domoapi.Place.Contract
  alias PhoenixSwagger.Schema
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController


  def swagger_definitions do
    %{
      OutputContract:
        swagger_schema do
          title("output contract")
          properties do
            id(:string, "contract ID")
            number_contracts(:integer, "Number Contract") 
            intercom_service(:boolean, "Contract Intercom Service") 
            video_service(:boolean, "Contract Video Service") 
            recognition_service(:boolean, "Contract Face Recognition Service") 
            docs(%Schema{type: :string} |> Schema.format(:binary), "Binary data docs") 
            datetime_video(%Schema{type: :string} |> Schema.format(:datetime), "datetime contract video") 
            datetime_intercom(%Schema{type: :string} 
            |> Schema.format(:datetime), "datetime contract intercom") 
            datetime_recognition(%Schema{type: :string}
             |> Schema.format(:datetime), "datetime contract recognition") 
            datetime_contract(%Schema{type: :string}
             |> Schema.format(:datetime), "datetime contract") 
            tenant_id(:string, "tenant ID") 
            apartment_id(:string, "apartment id")
        end
      end,
      InputContract:
        swagger_schema do
          title("input contract")
          properties do
            number_contracts(:integer, "Number Contract") 
            intercom_service(:boolean, "Contract Intercom Service") 
            video_service(:boolean, "Contract Video Service") 
            recognition_service(:boolean, "Contract Face Recognition Service") 
            docs(%Schema{type: :string} 
            |> Schema.format(:binary), "Binary data docs")
            datetime_video(%Schema{type: :string}
            |> Schema.format(:datetime), "datetime contract video")
            datetime_intercom(%Schema{type: :string}
            |> Schema.format(:datetime), "datetime contract intercom")
            datetime_recognition(%Schema{type: :string}
            |> Schema.format(:datetime), "datetime contract recognition")
            datetime_contract(%Schema{type: :string}
            |> Schema.format(:datetime), "datetime contract")
            tenant_id(:string, "tenant ID")
            apartment_id(:string, "apartment id")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/contracts")
    security [%{Bearer: []}]
    summary("List contracts")
    description("List all house in the database")
    produces("application/json")
    
    parameters do
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
      apartment_id :query, :string, "apartment id"
      tenant_id :query, :string, "tenant id"
    end
    response(200, "OK", 
    %Schema{type: :object}
      |> Schema.property(:contracts, Schema.array(:OutputContract), "List contract")
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
    contracts = Place.list_contracts(params)
    json(conn, %{
      contracts: contracts.entries,
      page_number: contracts.page_number,
      page_size: contracts.page_size,
      total_pages: contracts.total_pages,
      total_entries: contracts.total_entries
      })
  end

  swagger_path(:create) do
    post("/api/contracts")
    security [%{Bearer: []}]
    summary("create contract")
    description("create contract in the database")
    produces("application/json")
    
    parameter(:contract, :body, Schema.ref(:InputContract), "The contract details")
    response(201, "OK", Schema.ref(:OutputContract))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def create(conn, contract_params) do
    company_id = conn.assigns[:company_id]
    contract_params = Map.put(contract_params, "company_id", company_id)
    with {:ok, %Contract{} = contract} <- Place.create_contract(contract_params) do
      conn
      |> put_status(:created)
      |> json(contract)
    end
  end

  swagger_path(:show) do
    summary("Show contract")
    security [%{Bearer: []}]
    description("Show a contract by ID")
    produces("application/json")
    parameter(:id, :path, :string, "contract ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputContract))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    contract = Place.get_contract!(id)
    json(conn, contract)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/contracts/{id}")
    summary("Update contract")
    description("Update attributes of a contract")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "contract ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:contract, :body, %Schema{type: :object}
    |> Schema.property(:contract, Schema.ref(:InputContract), "The contract details"),
     "The contract details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputContract))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "contract" => contract_params}) do
    contract = Place.get_contract!(id)

    with {:ok, %Contract{} = contract} <- Place.update_contract(contract, contract_params) do
      json(conn, contract)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/contracts/{id}")
    security [%{Bearer: []}]
    summary("Delete contract")
    description("Delete a contract by ID")
    parameter(:id, :path, :string, "contract ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    contract = Place.get_contract!(id)

    with {:ok, %Contract{}} <- Place.delete_contract(contract) do
      json(conn, %{})
    end
  end
end
