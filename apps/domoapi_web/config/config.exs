use Mix.Config

config :domoapi_web,
  ecto_repos: [Domoapi.Repo],
  generators: [context_app: :domoapi]

config :domoapi_web, DomoapiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ev62lNRCtdBr39e00iYHTrEOGGHD1c9L8fi2zWw/4vDZF0w1S3HpUxXLVMCV4atf",
  render_errors: [view: DomoapiWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DomoapiWeb.PubSub, adapter: Phoenix.PubSub.PG2]
  
import_config "#{Mix.env}.exs"
