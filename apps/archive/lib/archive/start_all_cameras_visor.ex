defmodule Archive.StartAllCamerasVisor do
    use Task
    alias Archive.VideoDynamicSupervisor
    alias Archive.VideoVisor
    alias Domoapi.Intercoms
    require Logger
    
    def start_link(arg) do
        Task.start_link(__MODULE__, :run, [arg])
    end
    
    def run(_arg) do
        Intercoms.list_cameras_for_video_archiv()
        |> Enum.map(&VideoDynamicSupervisor.add_child/1)        
    end

end