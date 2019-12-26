defmodule Archive.VideoVisor do
    use GenServer, restart: :permanent
    import Exexec
    require Logger
    @hls_time 900
  

    def start(camera_url, camera_id, root_dir) do
      GenServer.start(__MODULE__, [camera_url, camera_id, root_dir])
    end

    def start_link(camera_url, camera_id, root_dir) do
      GenServer.start_link(__MODULE__, [camera_url, camera_id, root_dir], name: via_tuple(camera_id))
    end

    defp via_tuple(camera_id), do: {:via, Registry, {Registry.VideoCam, camera_id}}

    def child_spec(camera_url, camera_id, root_dir) do
      %{
        id: String.to_atom(camera_id),  
        start: {__MODULE__, :start_link, [camera_url, camera_id, root_dir]},
        restart: :permanent,
        type: :worker,
        shutdown: :brutal_kill
      }
    end


    def init([camera_url, camera_id, root_dir]) do
      Process.flag(:trap_exit, true)
      Logger.info("Video camera##{camera_url} created...")
      video_dir = create_dir(root_dir, camera_id)
      initial_state = %{
          camera_url: camera_url,
          video_dir: video_dir,
          ffmpeg_worker: spawn_ffmpeg(camera_url, video_dir)
      } 
      Logger.info("Video camera##{camera_url} successfull create")
      {:ok, initial_state}
    end

    def handle_info({:EXIT, exit_pid, :normal} = msg, %{ffmpeg_worker: %{pid: worker_pid}} = state) when exit_pid == worker_pid do
      Logger.error("Ffmpeg is dead. Terminating... EXIT_STATUS: #{inspect(msg)}, STATE: #{inspect(state)}")
      {:stop, :normal, state}
    end

    def handle_info({:EXIT, exit_pid, {:exit_status, 256}} = msg, %{ffmpeg_worker: %{pid: worker_pid}} = state) when exit_pid == worker_pid do
      Logger.error("init ffmpge is dead because camera is dead. Terminating... EXIT_STATUS: #{inspect(msg)}, STATE: #{inspect(state)}")
      {:stop, :normal, state}
    end

    def handle_info(msg, state) do
      Logger.warn("Unhandled info for call session... MSG: #{inspect(msg)}, STATE: #{inspect(state)}")
      {:noreply, state}
    end


    defp create_dir(root_dir, camera_id) do 
        with :ok <- File.cd(root_dir <> "/" <> camera_id) do
          root_dir <> "/" <> camera_id
        else
          error ->
            File.mkdir(root_dir <> "/" <> camera_id)
            root_dir <> "/" <> camera_id
        end
    end
  
    defp spawn_ffmpeg(camera_url, video_dir) do
      script_exec = "ffmpeg -i \"rtsp://#{camera_url}:8554/stream\" -c copy -map 0 -f segment -strftime 1 -segment_time #{@hls_time} -segment_format mpegts \"#{video_dir}/%Y-%m-%d %H:%M:%S.ts\""
      {:ok, pid, os_pid} = Exexec.run_link(script_exec, stdout: true)
      %{pid: pid, os_pid: os_pid}
    end
end
