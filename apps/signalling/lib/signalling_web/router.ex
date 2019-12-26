defmodule SignallingWeb.Router do
  use SignallingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/signalling/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :signalling, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "DomoApi Signalling",
        host: "localhost"
      },
      schemes: [
        "http"
      ]
    }
  end

  scope "/signaling", SignallingWeb do
    pipe_through :api

    scope "/intercom" do
      post "/sdp_intercom", IntercomController, :sdp_intercom
      post "/call", IntercomController, :call_intercom
      post "/init", IntercomController, :init_intercom
      post "/break", IntercomController, :break_call_intercom
      post "/reset_ip", IntercomController, :reset_ip
    end

    scope "/client" do
      post "/respond", ClientController, :respond
      post "/hang", ClientController, :hang
      post "/ping", ClientController, :ping
      post "/open_door", ClientController, :open_door
    end
  end
end
