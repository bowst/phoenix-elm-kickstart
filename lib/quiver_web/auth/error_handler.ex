defmodule QuiverWeb.Auth.ErrorHandler do
  import Plug.Conn
  use Phoenix.Controller
  alias QuiverWeb.ErrorView

  @doc """
  Handle when a user is trying to access an anonymous only page (e.g. login, etc.)

  In this case, we'll just redirect them back to the dashboard page
  """
  def auth_error(conn, {:already_authenticated, _reason}, _opts) do
    conn
    |> Phoenix.Controller.redirect(to: "/")
  end

  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    next_path = current_path(conn)

    conn
    |> redirect(to: "/login?next=" <> next_path)
  end

  def auth_error(conn, {type, _reason}, _opts) do
    IO.inspect(type)

    body = to_string(type)

    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(401, body)
  end
end
