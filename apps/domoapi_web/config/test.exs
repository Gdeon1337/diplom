use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :domoapi_web, DomoapiWeb.Endpoint,
  http: [port: 4002],
  server: false

config :logger, level: :debug
