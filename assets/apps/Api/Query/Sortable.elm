module Api.Query.Sortable exposing (Sort(..), SortableQueryParams, getSortBy, reverseSort, withSortableParams)

import Api.Query as Query exposing (Params, withParam)
import GraphQL.Request.Builder.Variable exposing (bool, string)


type alias SortableQueryParams vars =
    { vars
        | sort : Sort
    }


withSortableParams : Params (SortableQueryParams vars) -> Params (SortableQueryParams vars)
withSortableParams params =
    params
        |> withParam string "sortBy" (.sort >> getSortBy)
        |> withParam bool "sortDesc" (.sort >> getSortDesc)



-- SORT


type Sort
    = Asc String
    | Desc String
    | NotSorted


reverseSort : Sort -> Sort
reverseSort sort =
    case sort of
        Asc sortBy ->
            Desc sortBy

        Desc sortBy ->
            Asc sortBy

        NotSorted ->
            NotSorted


getSortBy : Sort -> Maybe String
getSortBy sort =
    case sort of
        Asc sortBy ->
            Just sortBy

        Desc sortBy ->
            Just sortBy

        NotSorted ->
            Nothing


getSortDesc : Sort -> Maybe Bool
getSortDesc sort =
    case sort of
        Asc _ ->
            Just False

        Desc _ ->
            Just True

        NotSorted ->
            Nothing
