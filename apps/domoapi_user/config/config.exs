# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :domoapi_user,
  ecto_repos: [Domoapi.Repo],
  generators: [context_app: :domoapi]

# Configures the endpoint
config :domoapi_user, DomoapiUserWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "luzga7DdpB46XmM4h5AYlvAs77NA6uHsptQ4VKt3K4/Qg9aUt+UiPiXsbgXHDiul",
  render_errors: [view: DomoapiUserWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DomoapiUser.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :domoapi_user, DomoapiUser.Guardian,
  issuer: "domoapi_user",
  secret_key: "V9d0sMkhVea/zY9cl14syHxaLGKlaQZ16NzpmiFnpThqoEVEeTQEQ3z1KbKNhxnF"

config :domoapi_user, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: DomoapiUserWeb.Router,     # phoenix routes will be converted to swagger paths
      endpoint: DomoapiUserWeb.Endpoint  # (optional) endpoint config used to set host, port and https schemes.
    ]
  }
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
