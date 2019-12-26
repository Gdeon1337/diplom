defmodule DomoapiIntercomWeb.Router do
  use DomoapiIntercomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :custom_authorized do
    plug DomoapiIntercomWeb.Plugs.Authorization, error_handler: DomoapiIntercomWeb.FallbackController
  end

  scope "/intercoms/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :domoapi_intercom, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "DomoApi Intercom",
        host: "localhost"
      },
      schemes: [
        "http",
        "https"
      ],
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          in: "header",
          name: "authorization"
        }
      }
    }
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DomoapiIntercomWeb do
    pipe_through :browser

    get "/", PageController, :index
  end


  scope "/intercoms", DomoapiIntercomWeb do
    pipe_through :api
    pipe_through :custom_authorized
    get "/apartments", IntercomController, :index_apartments
    get "/keys", IntercomController, :index_keys
    get "/global_settings", IntercomController, :index_global_settings
    get "/room_settings", IntercomController, :index_room_settings
    get "/tenants", IntercomController, :index_tenants
    get "/tenant_photos", IntercomController, :index_tenant_photo
    post "/update_host", IntercomController, :update_host
  end

  # Other scopes may use custom stacks.
  # scope "/api", DomoapiIntercomWeb do
  #   pipe_through :api
  # end
end
