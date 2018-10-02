defmodule Talent.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:password, :string)
      add(:role, :string)

      add(:first_name, :string)
      add(:middle_initial, :string)
      add(:last_name, :string)

      timestamps(type: :utc_datetime)
    end

    create(unique_index(:users, [:email]))
  end
end
