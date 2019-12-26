defmodule ArchiveWeb.VisorController do
    use ArchiveWeb, :controller
    alias Domoapi.Intercoms
    alias Archive.VideoDynamicSupervisor

    def add_cameras_visor(conn, %{"id" => id} = params) do
        camera = Intercoms.get_camera!(id)
        VideoDynamicSupervisor.add_child(camera)
        json(conn, camera)
    end

    def remove_camera_visor(conn, %{"id" => id} = params) do
        camera = Intercoms.get_camera!(id)
        VideoDynamicSupervisor.remove_camera(camera.id)
        json(conn, camera)
    end
  end