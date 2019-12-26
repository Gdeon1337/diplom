use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :domoapi_web, DomoapiWeb.Endpoint,
  http: [port: 8080],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../apps/domoapi_web/assets", __DIR__)
    ]
  ]

  config :domoapi_web,
  rabbit_host: System.get_env("RABBIT_HOST"),
  rabbit_login: System.get_env("RABBIT_LOGIN"),
  rabbit_password: System.get_env("RABBIT_PASSWORD"),
  rabbit_port: System.get_env("RABBIT_PORT"),
  rabbit_exchange: System.get_env("RABBIT_ECHANGE"),
  rabbit_queue: System.get_env("RABBIT_QUEUE"),
  archive_url: System.get_env("ARCHIVE_HOST")


config :domoapi_web, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [router: DomoapiWeb.Router, endpoint: DomoapiWeb.Endpoint],
  }

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :domoapi_web, DomoapiWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/domoapi_web/{live,views}/.*(ex)$",
      ~r"lib/domoapi_web/templates/.*(eex)$"
    ]
  ]

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20
