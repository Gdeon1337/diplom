defmodule DomoapiUserWeb.IntercomController do
    use DomoapiUserWeb, :controller
    use PhoenixSwagger
    import Plug
    alias Domoapi.People
    alias Domoapi.People.Tenant
    alias Domoapi.Place
    alias Domoapi.Intercoms
    alias DomoapiUser.Guardian.Plug, as: GPlug
    require HTTPoison
    action_fallback DomoapiUserWeb.FallbackController

    def open_door(conn, params) do
        tenant = GPlug.current_resource(conn)
        params = Map.put(params, "tenant_id", tenant.id)
        with %Domoapi.Intercoms.Intercom{} = intercom <- Intercoms.get_intercom(params) do
          host = intercom.host_name
          with {:ok, pid} <- Task.start(fn -> open_door_task(host, intercom.serial_key) end) do
            json(conn, %{})
          end
        end
    end

    def open_door_task(host, serial_key)do
        HTTPoison.post("http://#{host}/door/open", '{}', ["Authorization": "Token #{serial_key}"]) 
    end
    

end
