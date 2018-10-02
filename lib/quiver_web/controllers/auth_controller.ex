defmodule QuiverWeb.AuthController do
  use QuiverWeb, :controller
  alias Quiver.Auth
  alias Quiver.Auth.Schemas.User

  require IEx

  plug(:put_layout, "app.html")

  def login(conn, _params) do
    changeset = Auth.change_user(%User{})

    conn
    |> render("login.html", app_name: "login", changeset: changeset)
  end

  def authenticate(conn, %{"user" => %{"email" => email, "password" => password}} = params) do
    case Auth.authenticate_user(email, password) do
      {:ok, user} ->
        redirect_url = Map.get(params, "next", "/")

        conn
        |> Quiver.Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: redirect_url)

      {:error, _error} ->
        changeset = Auth.change_user(%User{email: email})

        conn
        |> put_status(401)
        |> put_flash(:error, "Incorrect username and/or password.  Please try again.")
        |> render(
          "login.html",
          app_name: "login",
          changeset: changeset,
          action: auth_path(conn, :authenticate)
        )
    end
  end

  def logout(conn, _) do
    conn
    |> Quiver.Auth.Guardian.Plug.sign_out()
    |> put_flash(:success, "You have successfully signed out.")
    |> redirect(to: auth_path(conn, :login))
  end

  @doc """
  Forgot password form
  """
  def forgot_password(conn, _params) do
    changeset = Auth.change_user(%User{})

    conn
    |> render(
      "forgot-password.html",
      changeset: changeset,
      action: auth_path(conn, :send_new_password)
    )
  end

  @doc """
  Send reset password
  """
  def send_new_password(conn, %{"user" => %{"email" => email}}) do
    with {:ok, user} <- Auth.get_user_by_email(email),
         {:ok, token, _claims} <- Auth.generate_password_reset_token(user) do
      IO.inspect(token)
    else
      error -> IO.inspect(error)
    end

    conn
    |> render("reset-password-complete.html")
  end

  @doc """
  Reset Password Form
  """
  def reset_password_form(conn, %{"token" => token}) do
    case Auth.verify_password_reset_token(token) do
      {:ok, user, _claims} ->
        conn
        |> render("reset-password-complete.html")

      error ->
        conn
        |> render("reset-password-complete.html")
    end
  end

  @doc """
  Initial sign-up form
  """
  def signup(conn, _params) do
    changeset = User.changeset(%User{})

    conn
    |> render(
      "register.html",
      changeset: changeset,
      action: auth_path(conn, :register_new_user)
    )
  end

  def formatErrorFieldString(str),
    do:
      str
      |> Atom.to_string()
      |> String.replace("_", " ")
      |> String.split()
      |> Enum.map(&String.capitalize/1)
      |> Enum.join(" ")

  @doc """
  Registers a new user
  """
  def register_new_user(conn, user_params) do
    params = Map.put(user_params, "role", "Quiver")

    case Auth.create_user(params) do
      {:ok, %{Quiver_profile: Quiver_profile, user: user}} ->
        redirect_url = Map.get(params, "next", "/register#/contact-information")

        conn
        |> Quiver.Auth.Guardian.Plug.sign_in(user)
        |> redirect(to: redirect_url)

      {:error, :user, changeset, _} ->
        # Generate error message based on changeset errors
        start_message =
          "There was problem register your accont.  Please check the following fields: \n\n"

        message =
          changeset.errors
          |> Keyword.keys()
          |> Enum.reduce(start_message, fn key, acc ->
            acc <> "\n\n" <> formatErrorFieldString(key)
          end)

        conn
        |> put_status(401)
        |> put_flash(:error, message)
        |> render(
          "register.html",
          changeset: changeset,
          action: auth_path(conn, :register_new_user)
        )

      {:error, :Quiver_profile, changeset, _} ->
        conn
        |> put_status(400)
        |> put_flash(:error, "There was a problem registering your account.")
        |> render(
          "register.html",
          changeset: changeset,
          action: auth_path(conn, :register_new_user)
        )
    end
  end
end
