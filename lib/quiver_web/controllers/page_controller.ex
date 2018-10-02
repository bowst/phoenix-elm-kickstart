defmodule QuiverWeb.PageController do
  use QuiverWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def app(%{assigns: %{current_user: current_user}} = conn, _params) do
    user = QuiverWeb.AuthView.render("show.json", %{user: current_user})

    app_name = "elm"

    conn
    |> put_layout("app.html")
    |> render("app.html", app_name: app_name, user: user)
  end

  def health_check(conn, _params) do
    text(conn, "OK")
  end
end
