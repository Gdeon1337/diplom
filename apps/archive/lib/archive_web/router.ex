defmodule ArchiveWeb.Router do
  use ArchiveWeb, :router

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

  scope "/", ArchiveWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/add_child", VisorController, :add_cameras_visor
    post "/remove_camera_visor", VisorController, :remove_camera_visor
  end

  # Other scopes may use custom stacks.
  # scope "/api", ArchiveWeb do
  #   pipe_through :api
  # end
end
