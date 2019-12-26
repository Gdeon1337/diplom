defmodule RelayWeb.StreamController do
    require Logger
    use RelayWeb, :controller

    def stream(conn, %{"camera_id" => camera_id}) do
        read(conn, camera_id, [length: 512, read_length: 512])
        text conn, "ok"
    end

    defp read(conn, camera_id, opts) do
        case Plug.Conn.read_body(conn, opts) do
          {:ok, binary, conn} ->
            Registry.VideoSession
            |> Registry.dispatch(camera_id, fn viewers ->
                Enum.each(viewers, fn {pid, _} ->
                    Process.send(pid, binary, [])
                end)
            end)
            {:ok, conn}
          {:more, binary, conn} ->
            Registry.VideoSession
            |> Registry.dispatch(camera_id, fn viewers ->
                Enum.each(viewers, fn {pid, _} ->
                    Process.send(pid, binary, [])
                end)
            end)
            read(conn, camera_id, opts)
          {:error, term} ->
            Logger.error(IO.inspect(term))
            {:error, term}
          error ->
            Logger.error(IO.inspect(error))
        end
    end

    # defp broadcast(chunk, camera_id) do
    #     Registry.VideoSession
    #     |> Registry.dispatch(camera_id, fn(entries) ->
    #         for {pid, _} <- entries do
    #           Process.send(pid, chunk, [])
    #         end
    #       end
    #     end)
    # end
end