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
config :domoapi_intercom, DomoapiIntercomWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Dx6JLzTYIJt4LKJXm0ZT0/UI78DR1/OYNNM7TksqM8Z8kWi6LeCKw4Jxtxo7V/ht",
  render_errors: [view: DomoapiIntercomWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DomoapiIntercom.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
