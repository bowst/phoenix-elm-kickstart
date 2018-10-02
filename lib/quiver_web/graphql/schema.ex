defmodule QuiverWeb.GraphQL.Schema do
  use Absinthe.Schema

  # App Contexts
  alias Quiver.{Auth}

  import Absinthe.Resolution.Helpers

  # Libraries
  import_types(Absinthe.Type.Custom)
  import_types(Kronky.ValidationMessageTypes)

  # Types and Fields (e.g. queries and mutations)
  import_types(QuiverWeb.GraphQL.Fields.User)

  query do
    import_fields(:user_queries)
  end

  mutation do
    import_fields(:user_mutations)
  end

  # Context Callbacks
  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Auth, Auth.data())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end
end
