defmodule DomoapiWeb.Settings.UserController do
    use DomoapiWeb, :controller
    use PhoenixSwagger
    alias Domoapi.Users
    alias Domoapi.Users.User
    plug DomoapiWeb.Plugs.CustomAuthorization
    action_fallback DomoapiWeb.FallbackController

    def swagger_definitions do
      %{
        OutputUsers:
          swagger_schema do
            title("output user")
            properties do
              id(:string, "User ID")
              title(:string, "Title")
              login(:string, "login user")
              company_role_id(:string, "company role id")
              role_id(:string, "role id")
          end
        end,
        InputUsers:
          swagger_schema do
            title("input user")
            properties do
              title(:string, "Title")
              login(:string, "login user")
              company_role_id(:string, "company role id")
              raw_password(:string, "password")
              role_id(:string, "role id")
          end
        end
      }
    end

    swagger_path(:index) do
      get("/api/settings/users")
      security [%{Bearer: []}]
      summary("List users")
      description("List all user in the database")
      produces("application/json")
      parameters do
        page :query, :integer, "Current page", required: true
        page_size :query, :integer, "page size"
      end
      response(200, "OK", 
      %Schema{type: :object}
        |> Schema.property(:users, Schema.array(:OutputUsers), "List users")
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
    users = Users.list_companies(params)
      json(conn, %{
        users: users.entries,
        page_number: users.page_number,
        page_size: users.page_size,
        total_pages: users.total_pages,
        total_entries: users.total_entries
        })
    end
  
    swagger_path(:create) do
      post("/api/settings/users")
      security [%{Bearer: []}]
      summary("create user")
      description("create user in the database")
      produces("application/json")
      parameter(:user, :body, Schema.ref(:InputUsers), "The user details")
      response(201, "OK", Schema.ref(:OutputUsers))
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
      response(422, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def create(conn, user_params) do
      company_id = conn.assigns[:company_id]
      user_params = Map.put(user_params, "company_id", company_id)
      with {:ok, %User{} = user} <- Users.create_user(user_params) do
        conn
        |> put_status(:created)
        |> json(user)
      end
    end
  
    swagger_path(:show) do
      summary("Show user")
      security [%{Bearer: []}]
      description("Show a user by ID")
      produces("application/json")
      parameter(:id, :path, :string, "user ID type uuid", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      response(200, "OK", Schema.ref(:OutputUsers))
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def show(conn, %{"id" => id}) do
      user = Users.get_user!(id)
      json(conn,user)
    end
  
    swagger_path(:update) do
      security [%{Bearer: []}]
      put("/api/settings/users/{id}")
      summary("Update user")
      description("Update attributes of a user")
      consumes("application/json")
      produces("application/json")
      parameters do
        id(:path, :string, "user ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      end
      parameter(:user, :body, %Schema{type: :object}
      |> Schema.property(:user, Schema.ref(:InputUsers), "The user details"), "The house details", required: true)
      response(200, "Updated Successfully", Schema.ref(:OutputUsers))
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
      response(422, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def update(conn, %{"id" => id, "user" => user_params}) do
      user = Users.get_user!(id)
  
      with {:ok, %User{} = user} <- Users.update_user(user, user_params) do
        json(conn, user)
      end
    end
  
    swagger_path(:delete) do
      PhoenixSwagger.Path.delete("/api/settings/users/{id}")
      security [%{Bearer: []}]
      summary("Delete user")
      description("Delete a user by ID")
      parameter(:id, :path, :string, "user ID", required: true, example: "9b0670e2-fa51-4dca-8c5a-0a5c9fbda22f")
      response(200, %{})
      response(401, "Error", 
      %Schema{type: :object}
      |> Schema.property(:error, :string, "Message Error"))
    end
    def delete(conn, %{"id" => id}) do
      user = Users.get_user!(id)
  
      with {:ok, %User{}} <- Users.delete_user(user) do
        send_resp(conn, :no_content, "")
      end
    end
end