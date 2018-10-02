defmodule QuiverWeb.GraphQL.Middleware.Authorize do
  @behaviour Absinthe.Middleware

  alias Quiver.Auth

  # Default options for the middleware
  @defaults %{
    role: nil,
    exact_role: false,
    match_user_id_on_arg: nil,
    match_user_for_roles: nil
  }

  def call(
        %{arguments: arguments, context: %{current_user: current_user}} = resolution,
        opts \\ []
      ) do
    options = Enum.into(opts, @defaults)

    with true <- check_role(current_user, options.role, options.exact_role),
         true <-
           check_user_id(
             current_user,
             options.match_user_id_on_arg,
             options.match_user_for_roles,
             arguments
           ) do
      resolution
    else
      # Any failure results in not authorized
      _ ->
        resolution
        |> Absinthe.Resolution.put_result({:error, "not authorized"})
    end
  end

  # Fall back for unauthorized, as no user is authenticated
  def call(resolution, _opts) do
    resolution
    |> Absinthe.Resolution.put_result({:error, "unauthenticated"})
  end

  # Check the user's role parameters
  defp check_role(user, nil, _exact_role), do: true
  defp check_role(user, role, true = exact_role), do: user.role == role
  defp check_role(user, role, false = exact_role), do: Auth.is_role_or_above(user.role, role)

  # Check whether the user_id matches the argument provided
  defp check_user_id(_user, nil, _roles, _args), do: true
  defp check_user_id(user, arg, nil, arguments), do: Integer.to_string(user.id) == arguments[arg]

  defp check_user_id(user, arg, roles, arguments) do
    if Enum.member?(roles, user.role) do
      check_user_id(user, arg, nil, arguments)
    else
      true
    end
  end
end
