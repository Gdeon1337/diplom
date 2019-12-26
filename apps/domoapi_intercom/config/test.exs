use Mix.Config

# Configure your database
config :domoapi_intercom, DomoapiIntercom.Repo,
  username: "postgres",
  password: "postgres",
  database: "domoapi_intercom_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :domoapi_intercom, DomoapiIntercomWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
