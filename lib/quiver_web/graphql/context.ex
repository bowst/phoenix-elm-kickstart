defmodule QuiverWeb.GraphQL.Context do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  # If current_user is nil, then leave empty
  def call(%{assigns: %{current_user: nil}} = conn, _), do: conn

  def call(%{assigns: %{current_user: current_user}} = conn, _) do
    Absinthe.Plug.put_options(conn, context: %{current_user: current_user})
  end
end
