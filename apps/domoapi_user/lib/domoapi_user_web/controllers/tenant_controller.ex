defmodule DomoapiUserWeb.TenantController do
  use DomoapiUserWeb, :controller
  use PhoenixSwagger
  import Plug
  alias Domoapi.People
  alias Domoapi.People.Tenant
  alias Domoapi.Place
  alias Domoapi.Intercoms
  alias DomoapiUser.Guardian.Plug, as: GPlug
  action_fallback DomoapiUserWeb.FallbackController

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


  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/users/tenants")
    summary("Update tenant")
    description("Update attributes of a tenant")
    consumes("application/json")
    produces("application/json")
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
  def update(conn, %{"tenant" => tenant_params}) do
    tenant = GPlug.current_resource(conn)
    tenant_params = Map.put(tenant_params, "tenant_id", tenant.id)
    with {:ok, %Tenant{} = tenant} <- People.update_tenant(tenant, tenant_params) do
      json(conn, tenant)
    end
  end

end
