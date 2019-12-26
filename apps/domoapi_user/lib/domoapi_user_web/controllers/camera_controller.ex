defmodule DomoapiUserWeb.CameraController do
    use DomoapiUserWeb, :controller
    use PhoenixSwagger
    import Plug
    alias Domoapi.People
    alias Domoapi.People.Tenant
    alias Domoapi.Place
    alias Domoapi.Intercoms
    alias DomoapiUser.Guardian.Plug, as: GPlug
    action_fallback DomoapiUserWeb.FallbackController

    def index(conn, params) do
        tenant = GPlug.current_resource(conn)
        params = Map.put(params, "tenant_id", tenant.id)
        cameras = Intercoms.list_cameras(params)
        json(conn, cameras)
    end

end
