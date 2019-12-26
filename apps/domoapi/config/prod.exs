use Mix.Config

# Configure your database
config :domoapi, Domoapi.Repo,
  username: "domoapi",
  password: "sandlabs1337",
  database: "domoapi_prod",
  hostname: "95.216.76.213",
  port: 5440,
  pool_size: 10

config :domoapi, Domoapi.Guardian,
  issuer: "domoapi",
  secret_key: "V9d0sMkhVea/zY9cl14syHxaLGKlaQZ16NzpmiFnpThqoEVEeTQEQ3z1KbKNhxnF"