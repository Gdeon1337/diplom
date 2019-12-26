defmodule Domoapi.Umbrella.MixProject do
  use Mix.Project

  def project do
    [
      apps_path: "apps",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [
        domoapi: [
          version: "0.0.1",
          applications: [
            :runtime_tools,
            domoapi: :permanent,
            domoapi_web: :permanent,
            domoapi_user: :permanent,
            relay: :permanent,
            signalling: :permanent,
            archive: :permanent
          ]
        ]
      ]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:bcrypt_elixir, "~> 2.0"},
      {:guardian, "~> 1.0"},
      {:firebase_admin_ex, "~> 0.1.0 "},
      {:distillery, "~> 2.0"}
    ]
  end
end
