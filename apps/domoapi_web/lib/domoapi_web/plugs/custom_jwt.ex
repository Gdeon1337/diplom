defmodule DomoapiWeb.Plugs.CustomAuthorization do
    alias Domoapi.Users
    import Plug.Conn
    require Logger
    
    alias Domoapi.Repo
    alias Ecto.Query
    alias Domoapi.Users

    def init(_params) do
    end
  
    def call(%{:private => private, :assigns => assigns} = conn, _params) do
        role = Users.get_role!(assigns.role)
        if role.title == "user" do
            view_zone = Users.get_company_roles!(assigns.company_role_id)
            if not check_view_zone(private, view_zone) do
                conn
                    |> put_status(403)
                    |> Phoenix.Controller.json(%{})
                    |> halt()
            end
        end
        conn
    end

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.CameraController}, %{camaras_read: read, cameras_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.CameraController}, %{camaras_read: read, cameras_view: view}) when action in [:create, :unbind_apartment, :bind_apartment, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.CameraController}, %{camaras_read: read, cameras_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.IntercomController}, %{intercoms_read: read, intercoms_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.IntercomController}, %{intercoms_read: read, intercoms_view: view}) when action in [:create, :unbind_apartment, :bind_apartment, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.IntercomController}, %{intercoms_read: read, intercoms_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.KeyController}, %{keys_read: read, keys_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.KeyController}, %{keys_read: read, keys_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.KeyController}, %{keys_read: read, keys_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.SettingController}, %{settings_read: read, settings_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.SettingController}, %{settings_read: read, settings_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.SettingController}, %{settings_read: read, settings_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.BindingTokenController}, %{binding_token_read: read, binding_token_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.BindingTokenController}, %{binding_token_read: read, binding_token_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.BindingTokenController}, %{binding_token_read: read, binding_token_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.DeviceController}, %{device_read: read, device_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.DeviceController}, %{device_read: read, device_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.DeviceController}, %{device_read: read, device_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.PhotoController}, %{photos_read: read, photos_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.PhotoController}, %{photos_read: read, photos_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.PhotoController}, %{photos_read: read, photos_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.TenantController}, %{tenants_read: read, tenants_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.TenantController}, %{tenants_read: read, tenants_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.TenantController}, %{tenants_read: read, tenants_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.ApartmentController}, %{apartments_read: read, apartments_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.ApartmentController}, %{apartments_read: read, apartments_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.ApartmentController}, %{apartments_read: read, apartments_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.HouseController}, %{houses_read: read, houses_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.HouseController}, %{houses_read: read, houses_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.HouseController}, %{houses_read: read, houses_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.Settings.UserController}, %{users_read: read, users_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.Settings.UserController}, %{users_read: read, users_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.Settings.UserController}, %{users_read: read, users_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.Settings.CompanyRolesController}, %{company_roles_read: read, company_roles_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.Settings.CompanyRolesController}, %{company_roles_read: read, company_roles_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.Settings.CompanyRolesController}, %{company_roles_read: read, company_roles_view: view}), do: false


    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.ContractController}, %{contract_read: read, contract_view: view}) when action in [:index, :show] and (read or view), do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.ContractController}, %{contract_read: read, contract_view: view}) when action in [:create, :update, :delete] and read, do: true

    def check_view_zone(%{:phoenix_action => action, :phoenix_controller => DomoapiWeb.ContractController}, %{contract_read: read, contract_view: view}), do: false
end