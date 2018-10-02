defmodule QuiverWeb.GraphQL.Args.Searchable do
  use Absinthe.Schema.Notation

  defmacro searchable_args() do
    quote do
      arg(:q, :string)
    end
  end
end
