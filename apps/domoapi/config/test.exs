use Mix.Config

# Configure your database
config :domoapi, Domoapi.Repo,
  username: "gdeon",
  password: "3228",
  database: "domoapi_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
