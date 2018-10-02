defmodule Quiver.Auth.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Comeonin.Bcrypt

  @roles ["user", "admin"]

  @fields [
    :email,
    :password,
    :password_confirmation,
    :role,
    :first_name,
    :last_name
  ]

  schema "users" do
    # Name information
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)

    field(:full_name, :string, virtual: true)

    # Auth Info
    field(:password, :string)
    field(:password_confirmation, :string, virtual: true)
    field(:role, :string)

    timestamps()
  end

  def get_roles, do: @roles

  @doc false
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @fields)
    |> validate_required([
      :email,
      :role,
      :first_name,
      :last_name
    ])
    |> validate_inclusion(:role, @roles)
    |> unique_constraint(:email)
    |> validate_confirmation(:password, message: "does not match password!")
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Bcrypt.hashpwsalt(password))
  end

  defp put_pass_hash(changeset), do: changeset
end
