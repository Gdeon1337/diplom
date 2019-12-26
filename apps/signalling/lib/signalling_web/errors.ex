defmodule SignallingWeb.Errors do
    def unknown_error(), do: 100
    def session_is_busy(), do: 101
    def session_does_not_exists(), do: 102
    def intercom_not_found(), do: 103
    def apartment_not_found(), do: 104
    def client_does_not_own_session(), do: 105
end