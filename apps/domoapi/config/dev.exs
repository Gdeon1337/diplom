use Mix.Config

# Configure your database
config :domoapi, Domoapi.Repo,
  username: "domoface",
  password: "381f047f-4ba0-4c94-883d-7ca5f122dffe",
  database: "domoface",
  hostname: "api.domoface.ru",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :domoapi, Domoapi.Guardian,
  issuer: "domoapi",
  secret_key: "V9d0sMkhVea/zY9cl14syHxaLGKlaQZ16NzpmiFnpThqoEVEeTQEQ3z1KbKNhxnF"
