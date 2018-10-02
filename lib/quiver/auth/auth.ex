defmodule Quiver.Auth do
  @moduledoc """
  The Auth context.
  """

  import Ecto.Query, warn: false
  alias Quiver.Repo
  alias Ecto.Multi

  alias Quiver.Auth.Schemas.User
  alias Quiver.Auth.Guardian

  import Quiver.Auth.Query

  alias Comeonin.Bcrypt

  require IEx

  # Data loader Config
  def data() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(User = queryable, params) do
    queryable
    |> exclude_roles(params)
    |> handle_search(params)
    |> handle_sort(params)
  end

  def query(queryable, _params) do
    queryable
  end

  @doc """
  Authenticates a user based on email and password
  """
  def authenticate_user(email, plain_text_password) do
    query = from(u in User, where: u.email == ^email)

    Repo.one(query)
    |> check_password(plain_text_password)
  end

  defp check_password(nil, _), do: {:error, "Incorrect username or password"}

  defp check_password(user, plain_text_password) do
    case Bcrypt.checkpw(plain_text_password, user.password) do
      true -> {:ok, user}
      false -> {:error, "Incorrect username or password"}
    end
  end

  @doc """
  Generate a password reset token for a given user
  """
  def generate_password_reset_token(user) do
    Guardian.encode_and_sign(user, %{"typ" => "password-reset"}, ttl: {1, :hour})
  end

  @doc """
  Verify a password reset token for.

  Returns a User or nil
  """
  def verify_password_reset_token(token) do
    Guardian.resource_from_token(token, %{"typ" => "password-reset"})
  end

  @doc """
  Checks to see if the role matches or has higher permissions than the target
  """
  def is_role_or_above(role, target) do
    roles = User.get_roles()

    if Enum.member?(roles, target) do
      Enum.find_index(roles, fn x -> x == role end) >=
        Enum.find_index(roles, fn x -> x == target end)
    else
      raise "Target role #{target} is not a valid role.  Valid roles are: #{
              Enum.join(roles, ", ")
            }."
    end
  end

  @doc """
  Returns the user as a map for serialization
  """
  def get_user_as_map(user) do
    user
    |> Map.from_struct()
    |> Map.drop([:password, :password_confirmation, :__meta__])
    |> Map.put(:id, Integer.to_string(user.id))
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users(params) do
    query(User, params)
    |> Repo.paginate(params)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a single user by email address.

  Returns {:ok, %User{}}` if the User exists or {:error, "Not Found"}.
  """
  def get_user_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> {:error, "Couldn't find user with that email"}
      user -> {:ok, user}
    end
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def create_user!(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end
end
