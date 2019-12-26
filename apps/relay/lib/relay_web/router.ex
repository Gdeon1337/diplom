defmodule RelayWeb.Router do
  use RelayWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", RelayWeb do
    post "/stream/:camera_id", StreamController, :stream
    # pipe_through :api
  end
end
