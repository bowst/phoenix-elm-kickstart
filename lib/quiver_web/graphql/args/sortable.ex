defmodule QuiverWeb.GraphQL.Args.Sortable do
  use Absinthe.Schema.Notation

  defmacro sortable_args() do
    quote do
      arg(:sort_by, :string)
      arg(:sort_desc, :boolean)
    end
  end
end
