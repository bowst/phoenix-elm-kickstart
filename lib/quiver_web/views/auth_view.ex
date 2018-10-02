defmodule QuiverWeb.AuthView do
  use QuiverWeb, :view

  def render("show.json", %{user: user}) do
    %{
      id: Integer.to_string(user.id),
      firstName: user.first_name,
      lastName: user.last_name,
      email: user.email,
      role: user.role
    }
  end

  def show_notification(conn, type) do
    conn
    |> get_flash(type)
    |> flash_message(type)
  end

  def flash_message(nil, _), do: nil

  def flash_message(message, :success) do
    render("_notification.html", class: "success", message: message)
  end

  def flash_message(message, :info) do
    render("_notification.html", class: "primary", message: message)
  end

  def flash_message(message, :error) do
    IO.inspect(message)
    render("_notification.html", class: "danger", message: text_to_html(message))
  end

  def app_name(conn) do
    case conn.assigns[:app_name] do
      nil -> "app"
      name -> name
    end
  end

  def render("scripts.html", _assigns) do
    ~s{<script>require("js/vendor/validate.min.js")</script>}
    |> raw
  end
end
