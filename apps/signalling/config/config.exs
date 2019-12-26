# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :signalling, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: SignallingWeb.Router,     # phoenix routes will be converted to swagger paths
    ]
  }

# Configures the endpoint
config :signalling, SignallingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "QbYUrrjFN0Riyga9S+fzwVIOzV9huX5roR8nCd2Py1QXjvP4xxmSIuPidPSkL+aJ",
  render_errors: [view: SignallingWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Signalling.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :pigeon, :fcm,
  fcm_default: %{
    key: "AAAASYDPe2g:APA91bFpsIZ-G1M1C5Z0-djgbei6BQ8RaCLRO7PkaYAlJ_sFvpRDfEzGBB4Gyg1CH1OV0WQV93fBsoieYj3FiwTkt72EvW_-H427dbG5ucXmVCMHnGy4K6hI4zxhfutGrQIOirzxs4kQ"
  }

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
