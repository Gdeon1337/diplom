defmodule Domoapi.Repo do
  use Ecto.Repo,
    otp_app: :domoapi,
    adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
