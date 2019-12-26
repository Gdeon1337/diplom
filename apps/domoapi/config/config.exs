use Mix.Config

config :domoapi,
  ecto_repos: [Domoapi.Repo]

import_config "#{Mix.env}.exs"
