defmodule DomoapiUserWeb.Router do
  use DomoapiUserWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :unauthorized do
    plug :fetch_session
  end

  pipeline :authorized do
    plug :fetch_session
    plug Guardian.Plug.Pipeline, module: DomoapiUser.Guardian,
      error_handler: DomoapiUserWeb.FallbackController
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.VerifyHeader, realm: "Bearer"
    plug Guardian.Plug.LoadResource
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/users/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :domoapi_user, swagger_file: "swagger.json", disable_validator: true
  end
  
  scope "/", DomoapiUserWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/users", DomoapiUserWeb do
    pipe_through :api

    scope "/" do
      pipe_through :unauthorized
      post "/sign_in", SessionController, :create
      post "/verify_device", AddDeviceController, :add_device
    end

    scope "/" do
      pipe_through :authorized
      post "/sign_out", SessionController, :delete
      get "/me", SessionController, :show
      get "/open_door", IntercomController, :open_door
      resources "/photos", PhotoController, only: [:index, :create, :update, :delete, :show]
      resources "/devices", DeviceController, only: [:index, :create, :delete, :show]
      resources "/cameras", CameraController, only: [:index]
      put "/tenant", TenantController, :update
      post "/send_candidate", SessionController, :send_candidate
    end
  end


  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "DomoApiUser",
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
  # Other scopes may use custom stacks.
  # scope "/api", DomoapiUserWeb do
  #   pipe_through :api
  # end
end
