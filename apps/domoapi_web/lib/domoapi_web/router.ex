defmodule DomoapiWeb.Router do
  use DomoapiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  pipeline :custom_authorized do
    plug DomoapiWeb.Plugs.Authorization, error_handler: DomoapiWeb.FallbackController
  end

  scope "/", DomoapiWeb do
    pipe_through :browser
    get "/", PageController, :index
  end

  scope "/api/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :domoapi_web, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "DomoApi",
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

  scope "/api", DomoapiWeb do
    pipe_through :api
    pipe_through :custom_authorized
    resources "/intercoms", IntercomController, only: [:index, :create, :update, :delete, :show] do
      resources "/cameras", CameraController, only: [:index, :create, :update, :delete, :show]
      resources "/keys", KeyController, only: [:index, :create, :update, :delete, :show]
      resources "/settings", SettingController, only: [:index, :create, :update, :delete, :show]
      get "/open_door", IntercomController, :open_door
      post "/bind_apartment", IntercomController, :bind_apartment
      delete "/unbind_apartment", IntercomController, :unbind_apartment
      get "/bind_apartments", IntercomController , :bind_apartments
    end

    resources "/apartments", ApartmentController, only: [:index, :create, :update, :delete, :show] do
      resources "/apartment_settings", ApartmentSettingContoller, only: [:index, :create, :update, :delete, :show]
    end
    
    resources "/houses", HouseController, only: [:index, :create, :update, :delete, :show]
    resources "/contracts", ContractController, only: [:index, :create, :update, :delete, :show]

    scope "/settings", Settings do
      resources "/company", CompanyController, only: [:index, :create, :update, :delete, :show]
      resources "/users", UserController, only: [:index, :create, :update, :delete, :show]
      resources "/company_roles", CompanyRolesController, only: [:index, :create, :update, :delete, :show]
    end

    resources "/tenants", TenantController, only: [:index, :create, :update, :delete, :show] do
      resources "/photos", PhotoController, only: [:index, :create, :update, :delete, :show]
      resources "/devices", DeviceController, only: [:index, :update, :delete, :show]
    end
  end

end
