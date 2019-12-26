defmodule DomoapiWeb.TenantController do
  use DomoapiWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.People
  alias Domoapi.People.Tenant
  alias Domoapi.Place
  alias Domoapi.Intercoms
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController

  def swagger_definitions do
    %{
      InputTenants:
        swagger_schema do
          title("input tenant")
          properties do
            title(:string, "Name Tenant")
            phone_number(:string, "Number of phone")
            apartment_id(:string, "Apartment ID")
        end
      end,
      OutputTenants:
        swagger_schema do
          title("output tenant")
          properties do
            id(:string, "Tenant ID")
            title(:string, "Name Tenant")
            phone_number(:string, "Number of phone")
            apartment_id(:string, "Apartment ID")
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/tenants")
    security [%{Bearer: []}]
    summary("List tenant")
    description("List all tenant in the database")
    produces("application/json")
    
    parameters do
      apartment_id :query, :string, "Apartment ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f"
    end
    response(200, "OK", Schema.array(:OutputTenants))
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
    tenants = People.list_tenants(params)
    json(conn, tenants)
  end

  swagger_path(:create) do
    post("/api/tenants")
    security [%{Bearer: []}]
    summary("create tenant")
    description("create tenant in the database")
    produces("application/json")
    
    parameter(:tenant, :body, Schema.ref(:InputTenants), "The tenant details")
    response(201, "OK", Schema.ref(:OutputTenants))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def create(conn, tenant_params) do
    company_id = conn.assigns[:company_id]
    tenant_params = Map.put(tenant_params, "company_id", company_id)
    with {:ok, %Tenant{} = tenant} <- People.create_tenant(tenant_params) do
      conn
      |> put_status(:created)
      |> json(tenant)
    end
  end

  swagger_path(:show) do
    summary("Show tenant")
    security [%{Bearer: []}]
    description("Show a tenant by ID")
    produces("application/json")
    parameter(:id, :path, :string, "tenant ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputTenants))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    tenant = People.get_tenant!(id)
    json(conn, tenant)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/tenants/{id}")
    summary("Update tenant")
    description("Update attributes of a tenant")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "tenant ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:tenant, :body, %Schema{type: :object}
    |> Schema.property(:tenant, Schema.ref(:InputTenants), "The tenant details"),
     "The tenant details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputTenants))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "tenant" => tenant_params}) do
    tenant = People.get_tenant!(id)
    with {:ok, %Tenant{} = tenant} <- People.update_tenant(tenant, tenant_params) do
      json(conn, tenant)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/tenants/{id}")
    security [%{Bearer: []}]
    summary("Delete tenant")
    description("Delete a tenant by ID")
    parameter(:id, :path, :string, "tenant ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    tenant = People.get_tenant!(id)
    with {:ok, %Tenant{}} <- People.delete_tenant(tenant) do
      json(conn, %{})
    end
  end
end
