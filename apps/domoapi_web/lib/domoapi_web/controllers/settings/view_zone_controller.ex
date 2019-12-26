defmodule DomoapiWeb.Settings.CompanyRolesController do
  use DomoapiWeb, :controller
  use PhoenixSwagger

  alias Domoapi.Users
  alias Domoapi.Users.CompanyRoles
  plug DomoapiWeb.Plugs.CustomAuthorization
  action_fallback DomoapiWeb.FallbackController

  def swagger_definitions do
    %{
      OutputCompanyRoles:
        swagger_schema do
          title("output company_roles")
          properties do
            id(:string, "company role ID")
            title(:string, "Title")
            houses_view(:boolean, "access rights to the router Houses") 
            houses_read(:boolean, "access rights to the router Houses")
            intercoms_view(:boolean, "access rights to the router Intercom")
            intercoms_read(:boolean, "access rights to the router Intercom")
            apartments_view(:boolean, "access rights to the router Apartment") 
            apartments_read(:boolean, "access rights to the router Apartment") 
            cameras_view(:boolean, "access rights to the router Camara") 
            camaras_read(:boolean, "access rights to the router Camera") 
            settings_view(:boolean, "access rights to the router Setting")
            settings_read(:boolean, "access rights to the router Setting") 
            keys_view(:boolean, "access rights to the router Key") 
            keys_read(:boolean, "access rights to the router Key") 
            tenants_view(:boolean, "access rights to the router Tenant") 
            tenants_read(:boolean, "access rights to the router Tenant") 
            photos_view(:boolean, "access rights to the router Photos")
            photos_read(:boolean, "access rights to the router Photos") 
            device_view(:boolean, "access rights to the router Device") 
            device_read(:boolean, "access rights to the router Device") 
            users_view(:boolean, "access rights to the router User") 
            users_read(:boolean, "access rights to the router User") 
            company_roles_view(:boolean, "access rights to the router CompanyRoles") 
            company_roles_read(:boolean, "access rights to the router CompanyRoles") 
            binding_token_view(:boolean, "access rights to the router BindingToken")  
            binding_token_read(:boolean, "access rights to the router BindingToken") 
        end
      end,
      InputCompanyRoles:
        swagger_schema do
          title("input company_roles")
          properties do
            title(:string, "Title")
            houses_view(:boolean, "access rights to the router Houses") 
            houses_read(:boolean, "access rights to the router Houses")
            intercoms_view(:boolean, "access rights to the router Intercom")
            intercoms_read(:boolean, "access rights to the router Intercom")
            apartments_view(:boolean, "access rights to the router Apartment") 
            apartments_read(:boolean, "access rights to the router Apartment") 
            cameras_view(:boolean, "access rights to the router Camara") 
            camaras_read(:boolean, "access rights to the router Camera") 
            settings_view(:boolean, "access rights to the router Setting")
            settings_read(:boolean, "access rights to the router Setting") 
            keys_view(:boolean, "access rights to the router Key") 
            keys_read(:boolean, "access rights to the router Key") 
            tenants_view(:boolean, "access rights to the router Tenant") 
            tenants_read(:boolean, "access rights to the router Tenant") 
            photos_view(:boolean, "access rights to the router Photos")
            photos_read(:boolean, "access rights to the router Photos") 
            device_view(:boolean, "access rights to the router Device") 
            device_read(:boolean, "access rights to the router Device") 
            users_view(:boolean, "access rights to the router User") 
            users_read(:boolean, "access rights to the router User") 
            company_roles_view(:boolean, "access rights to the router CompanyRoles") 
            company_roles_read(:boolean, "access rights to the router CompanyRoles") 
            binding_token_view(:boolean, "access rights to the router BindingToken")  
            binding_token_read(:boolean, "access rights to the router BindingToken") 
        end
      end
    }
  end

  swagger_path(:index) do
    get("/api/settings/company_roles")
    security [%{Bearer: []}]
    summary("List company_roles")
    description("List all company_roles in the database")
    produces("application/json")
    
    parameters do
      page :query, :integer, "Current page", required: true
      page_size :query, :integer, "page size"
    end
    response(200, "OK", 
    %Schema{type: :object}
     |> Schema.property(:company_roles, Schema.array(:OutputCompanyRoles), "List company_roles")
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
    company_roles = Users.list_company_roles(params)
    json(conn, %{
      company_roles: company_roles.entries,
      page_number: company_roles.page_number,
      page_size: company_roles.page_size,
      total_pages: company_roles.total_pages,
      total_entries: company_roles.total_entries
      })
  end

  swagger_path(:create) do
    post("/api/settings/company_roles")
    security [%{Bearer: []}]
    summary("create company_roles")
    description("create company_roles in the database")
    produces("application/json")
    
    parameter(:user, :body, Schema.ref(:InputCompanyRoles), "The company_roles details")
    response(201, "OK", Schema.ref(:OutputCompanyRoles))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def create(conn, company_roles_params) do
    company_id = conn.assigns[:company_id]
    company_roles_params = Map.put(company_roles_params, "company_id", company_id)
    with {:ok, %CompanyRoles{} = company_roles} <- Users.create_company_roles(company_roles_params) do
      conn
      |> put_status(:created)
      |> json(company_roles)
    end
  end

  swagger_path(:show) do
    summary("Show company_roles")
    security [%{Bearer: []}]
    description("Show a company_roles by ID")
    produces("application/json")
    parameter(:id, :path, :string, "company_roles ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, "OK", Schema.ref(:OutputCompanyRoles))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def show(conn, %{"id" => id}) do
    company_roles = Users.get_company_roles!(id)
    json(conn,company_roles)
  end

  swagger_path(:update) do
    security [%{Bearer: []}]
    put("/api/settings/company_roles/{id}")
    summary("Update company_roles")
    description("Update attributes of a company_roles")
    consumes("application/json")
    produces("application/json")
    parameters do
      id(:path, :string, "company_roles ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    end
    parameter(:company_roles, :body, %Schema{type: :object}
    |> Schema.property(:company_roles, Schema.ref(:InputCompanyRoles), "The company_roles details"),
     "The house details", required: true)
    response(200, "Updated Successfully", Schema.ref(:OutputCompanyRoles))
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
    response(422, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def update(conn, %{"id" => id, "company_roles" => company_roles_params}) do
    company_roles = Users.get_company_roles!(id)

    with {:ok, %CompanyRoles{} = company_roles} <- Users.update_company_roles(company_roles, company_roles_params) do
      json(conn, company_roles)
    end
  end

  swagger_path(:delete) do
    PhoenixSwagger.Path.delete("/api/settings/company_roles/{id}")
    security [%{Bearer: []}]
    summary("Delete company_roles")
    description("Delete a company_roles by ID")
    parameter(:id, :path, :string, "company_roles ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
    response(200, %{})
    response(401, "Error", 
    %Schema{type: :object}
    |> Schema.property(:error, :string, "Message Error"))
  end
  def delete(conn, %{"id" => id}) do
    company_roles = Users.get_company_roles!(id)

    with {:ok, %CompanyRoles{}} <- Users.delete_company_roles(company_roles) do
      send_resp(conn, :no_content, "")
    end
  end
end
