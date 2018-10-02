# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Quiver.Repo.insert!(%Quiver.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Quiver.{Auth}

kynan =
  Auth.create_user!(%{
    email: "kynan@bowst.com",
    first_name: "Kynan",
    last_name: "Delorey",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })

heather =
  Auth.create_user!(%{
    email: "heather@bowst.com",
    first_name: "Heather",
    last_name: "Corey",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })

jack =
  Auth.create_user!(%{
    email: "sobojack@bowst.com",
    first_name: "Jack",
    last_name: "Sobo",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })

johnny =
  Auth.create_user!(%{
    email: "johnny@bowst.com",
    first_name: "Johnny",
    last_name: "Hoell",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })

alex =
  Auth.create_user!(%{
    email: "alex@bowst.com",
    first_name: "Alex",
    last_name: "Vallejo",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })

marcus =
  Auth.create_user!(%{
    email: "marcus@bowst.com",
    first_name: "Marcus",
    last_name: "Freeman",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })

adam =
  Auth.create_user!(%{
    email: "adam@bowst.com",
    first_name: "Adam",
    last_name: "Vicinus",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })

drew =
  Auth.create_user!(%{
    email: "drew@bowst.com",
    first_name: "Drew",
    last_name: "Trafton",
    password: "password",
    password_confirmation: "password",
    role: "admin"
  })
