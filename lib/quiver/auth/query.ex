defmodule Quiver.Auth.Query do
  @moduledoc """
  The Auth queries.
  """

  alias Quiver.Auth.Schemas.{User}

  import Ecto.Query, warn: false

  @doc """
    Exclude Roles Filter
  """
  def exclude_roles(User = queryable, %{exclude_roles: exclude_roles})
      when not is_nil(exclude_roles) do
    queryable
    |> where([q], not (q.role in ^exclude_roles))
  end

  def exclude_roles(User = queryable, _params), do: queryable

  @doc """
    Handle Search Filter
  """
  def handle_search(User = queryable, %{q: q}) when not is_nil(q) do
    search_term = "%#{q}%"

    queryable
    |> where([u], ilike(fragment("concat(?, ' ', ?)", u.first_name, u.last_name), ^search_term))
  end

  def handle_search(queryable, _params), do: queryable

  @doc """
    Handle Sort Filter
  """
  def handle_sort(User = queryable, params) do
    dir =
      if Map.get(params, :sort_desc, false) do
        :desc
      else
        :asc
      end

    column =
      case Map.get(params, :sort_by) do
        "name" ->
          :last_name

        _ ->
          :id
      end

    queryable
    |> order_by([u], [{^dir, field(u, ^column)}])
  end

  def handle_sort(queryable, _params), do: queryable
end
