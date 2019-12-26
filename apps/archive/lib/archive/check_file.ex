defmodule Archive.CheckFile do
    alias Timex
    require Logger

    def check_dir() do
        Logger.info("start check file")
        root_dir = Application.get_env(:archive, :root_dir)
        with {:ok, path_dirs} <- File.ls(root_dir) do
            path_dirs
            |> Enum.map(&get_file(&1, root_dir))
        end
    end

    def get_file(path_dir, root_dir) do
        path = root_dir <> "/" <> path_dir
        with {:ok, path_files} <- File.ls(path) do
            path_files
            |> Enum.map(&check_file(path <> "/" <> &1, &1))
        end
    end        

    def check_file(path_file, name_file) do
        name_file = String.replace(name_file, ".ts", "")
        live_time = String.to_integer(Application.get_env(:archive, :live_time))
        with {:ok, create_time} <- Timex.parse(name_file, "%Y-%m-%d_%H:%M:%S", :strftime) do
            datetime_now = Timex.now
            datetime_live_file = Timex.shift(create_time, days: live_time)
            if Timex.before?(datetime_live_file, datetime_now)do
                File.rm(path_file)
            end
        end
    end

end