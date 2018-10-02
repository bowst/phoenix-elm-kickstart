# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :quiver, ecto_repos: [Quiver.Repo]

# Configures the endpoint
config :quiver, QuiverWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "vmTbC3Un/UIFs1JsobgKEm+V0vc3vygr83EdCP4f5jNOSwS4BImc6EeVll0YMovG",
  render_errors: [view: QuiverWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Quiver.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

config :quiver, Quiver.Auth.Guardian,
  issuer: "Bowst",
  secret_key: "S/r3PThDMPMc2Kp1a069bRaOXPz+bfUZHgGd0IrsWN7vlroB3958g3+VEDMYcwW/"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
