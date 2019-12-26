defmodule RelayWeb.VideoHandler do
    @behaviour :cowboy_websocket
    require Logger

    def init(request, _state) do
    #   Logger.warn(inspect(request))
      request = :cowboy_req.set_resp_header("sec-websocket-protocol", "null", request)
      Logger.warn("#{inspect(request.path)}")
      state = %{registry_key: String.split(request.path, "/") |> List.last()}
      options = %{compress: true}

      {:cowboy_websocket, request, state, options}
    end

    def websocket_init(state) do
      Registry.VideoSession
      |> Registry.register(state.registry_key, {})

      {:ok, state}
    end

    def websocket_handle({:binary, message}, state) do
    #   payload = Jason.decode!(json)
    #   message = payload["data"]["message"]

    #   Registry.MyWebsocketApp
    #   |> Registry.dispatch(state.registry_key, fn(entries) ->
    #     for {pid, _} <- entries do
    #       if pid != self() do
    #         Process.send(pid, message, [])
    #       end
    #     end
    #   end)

      {:reply, {:text, message}, state}
    end

    def websocket_info(info, state) do
      {:reply, {:binary, info}, state}
    end
end