defmodule QuiverWeb.Auth.CurrentUser do
  import Plug.Conn
  alias Quiver.Auth.Guardian, as: QuiverGuardian

  def load_current_user(conn, _) do
    conn
    |> assign(:current_user, QuiverGuardian.Plug.current_resource(conn))
  end
end
