defmodule QuiverWeb.Router do
  use QuiverWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :auth do
    plug(:fetch_session)
    plug(QuiverWeb.Auth.Pipeline)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  pipeline :ensure_anonymous do
    plug(Guardian.Plug.EnsureNotAuthenticated)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :graphql do
    plug(QuiverWeb.GraphQL.Context)
  end

  # Anonymous Routes
  scope "/", QuiverWeb do
    # Use the default browser stack
    pipe_through([:browser, :auth, :ensure_anonymous])

    # Auth Routes
    get("/login", AuthController, :login)
    post("/login", AuthController, :authenticate)
    get("/password/reset", AuthController, :forgot_password)
    post("/password/reset", AuthController, :send_new_password)
    get("/password/reset/:token", AuthController, :reset_password_form)

    # Register Routes
    get("/sign-up", AuthController, :signup)
    post("/sign-up", AuthController, :register_new_user)
  end

  # Authenticated Routes
  scope "/", QuiverWeb do
    pipe_through([:browser, :auth, :ensure_auth])

    # Auth Routes
    get("/logout", AuthController, :logout)

    # App Routes
    get("/app/*path", PageController, :app)
  end

  # GraphQL API
  scope "/graphql" do
    pipe_through([:auth, :graphql])

    forward("/", Absinthe.Plug, schema: QuiverWeb.GraphQL.Schema)
  end

  # GraphiQL Endpoint
  scope "/graphiql" do
    pipe_through([:auth, :graphql])
    forward("/", Absinthe.Plug.GraphiQL, schema: QuiverWeb.GraphQL.Schema)
  end

  # Health Check Endpoint
  scope "/_health", QuiverWeb do
    get("/", PageController, :health_check)
  end
end
