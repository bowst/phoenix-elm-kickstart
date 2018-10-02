defmodule QuiverWeb.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :Quiver,
    error_handler: QuiverWeb.Auth.ErrorHandler,
    module: Quiver.Auth.Guardian

  import QuiverWeb.Auth.CurrentUser

  # If there is a session token, validate it
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  # If there is an authorization header, validate it
  plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
  # Load the user if either of the verifications worked
  plug(Guardian.Plug.LoadResource, allow_blank: true)
  # Add user to conn
  plug(:load_current_user)
end
