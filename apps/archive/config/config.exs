# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :archive,
  ecto_repos: [Archive.Repo]

# Configures the endpoint
config :archive, ArchiveWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "OrDci0XQAJNuzd1pW1Fsv/ifovbfxdPyf0gkp6j+tXhVy5t7dKw68tlGwkIXC5FX",
  render_errors: [view: ArchiveWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Archive.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :archive, Archive.Scheduler,
  jobs: [
    {"@daily", fn -> Archive.CheckFile.check_dir() end}
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
