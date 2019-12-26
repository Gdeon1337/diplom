defmodule Archive.VideoDynamicSupervisor do
    use DynamicSupervisor
    alias Domoapi.Intercoms
    alias Archive.VideoVisor
    require Logger

    def start_link(_init_arg) do
        DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
    end

    @impl true
    def init(:ok) do
        DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 150, max_seconds: 1)
    end


    def add_child(camera) do
        root_dir = Application.get_env(:archive, :root_dir)
        spec = VideoVisor.child_spec(camera.url, camera.id, root_dir)
        DynamicSupervisor.start_child(__MODULE__, spec)
    end

    def remove_camera(camera_id) do
        case Registry.lookup(Registry.VideoCam, camera_id) do
            []  -> nil
            [{pid, _}] -> DynamicSupervisor.terminate_child(__MODULE__, pid)
        end
    end
end