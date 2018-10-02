defmodule QuiverWeb.GraphQL.Args.Pagination do
  use Absinthe.Schema.Notation

  defmacro pagination_args() do
    quote do
      arg(:page, :integer, default_value: 0)
      arg(:page_size, :integer, default_value: 10)
    end
  end

  defmacro pagination_object(payload_name, result_object_name) do
    quote location: :keep do
      object unquote(payload_name) do
        field(:page_number, non_null(:integer), description: "Page number.")

        field(
          :page_size,
          non_null(:integer),
          description: "Number of entries per page."
        )

        field(
          :total_entries,
          non_null(:integer),
          description: "Total number of entries."
        )

        field(
          :total_pages,
          non_null(:integer),
          description: "Total number of pages in result set."
        )

        field(
          :entries,
          list_of(unquote(result_object_name)),
          description: "Paginated list of entries."
        )
      end
    end
  end
end
