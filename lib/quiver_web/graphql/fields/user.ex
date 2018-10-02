defmodule QuiverWeb.GraphQL.Fields.User do
  use Absinthe.Schema.Notation
  import Kronky.Payload

  alias Quiver.Auth
  alias QuiverWeb.GraphQL.Middleware.Authorize

  import QuiverWeb.GraphQL.Args.{Sortable, Pagination, Searchable}

  ##########################
  # Types
  #########################

  object :user do
    field(:id, :id)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)

    # Auth Info
    field(:username, :string)
    field(:role, :string)
  end

  payload_object(:user_payload, :user)

  pagination_object(:paginated_users, :user)

  ##########################
  # Queries
  #########################

  object :user_queries do
    @desc "Get paginated list of users"
    field :users, :paginated_users do
      pagination_args()
      sortable_args()
      searchable_args()

      middleware(Authorize, role: "admin")
      resolve(&list_users/3)
    end

    @desc "Get a single user"
    field :user, :user do
      arg(:id, non_null(:id))

      middleware(Authorize, role: "admin")
      resolve(&get_user/3)
    end
  end

  ##########################
  # Mutations
  #########################

  object :user_mutations do
    @desc "Create a user"
    field :create_user, type: :user_payload do
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:email, :string)
      arg(:role, :string)
      arg(:password, :string)
      arg(:password_confirmation, :string)

      middleware(Authorize, role: "admin")
      resolve(&create_user/3)
      middleware(&build_payload/2)
    end

    @desc "Update a user"
    field :update_user, type: :user_payload do
      arg(:id, :string)
      arg(:first_name, :string)
      arg(:last_name, :string)
      arg(:email, :string)
      arg(:role, :string)
      arg(:password, :string)
      arg(:password_confirmation, :string)

      middleware(Authorize, role: "admin")
      resolve(&update_user/3)
      middleware(&build_payload/2)
    end

    @desc "Remove a user"
    field :remove_user, type: :user_payload do
      arg(:id, :string)

      middleware(Authorize, role: "admin")
      resolve(&remove_user/3)
      middleware(&build_payload/2)
    end
  end

  ##########################
  # Resolvers
  #########################

  def list_users(_parent, args, _resolution) do
    {:ok, Auth.list_users(args)}
  end

  def get_user(_parent, %{id: id} = args, _resolution) do
    case Auth.get_user(id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def create_user(_parent, args, _resolution) do
    case Auth.create_user(args) do
      {:error, %Ecto.Changeset{} = changeset} -> {:ok, changeset}
      result -> result
    end
  end

  def update_user(_parent, %{id: id} = args, _resolution) do
    case Auth.get_user(id) do
      nil ->
        {:error, :not_found}

      user ->
        case Auth.update_user(user, args) do
          {:error, %Ecto.Changeset{} = changeset} -> {:ok, changeset}
          result -> result
        end
    end
  end

  def remove_user(_parent, %{id: id} = args, _resolution) do
    case Auth.get_user(id) do
      nil ->
        {:error, :not_found}

      user ->
        case Auth.delete_user(user) do
          {:error, %Ecto.Changeset{} = changeset} -> {:ok, changeset}
          result -> result
        end
    end
  end
end
