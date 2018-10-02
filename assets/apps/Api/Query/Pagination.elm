module Api.Query.Pagination exposing (Pagination, PaginationParams, PaginationResult, default, paginationSpec, updatePage, withPaginationParams)

import Api.Query as Query exposing (Params, withParam)
import GraphQL.Request.Builder exposing (NonNull, ObjectType, ValueSpec, field, int, list, object, with)
import GraphQL.Request.Builder.Variable as Var


type alias Pagination =
    { pageSize : Maybe Int
    , page : Maybe Int
    }


default : Pagination
default =
    { pageSize = Nothing
    , page = Nothing
    }


updatePage : Int -> Pagination -> Pagination
updatePage nextPage pagination =
    { pagination | page = Just nextPage }


type alias PaginationParams vars =
    { vars
        | pagination : Pagination
    }


withPaginationParams : Params (PaginationParams vars) -> Params (PaginationParams vars)
withPaginationParams params =
    params
        |> withParam Var.int "pageSize" (.pagination >> .pageSize)
        |> withParam Var.int "page" (.pagination >> .page)


type alias PaginationResult entity =
    { totalPages : Int
    , totalEntries : Int
    , pageSize : Int
    , pageNumber : Int
    , entries : List entity
    }


paginationSpec : ValueSpec NonNull ObjectType spec vars -> ValueSpec NonNull ObjectType (PaginationResult spec) vars
paginationSpec querySpec =
    object PaginationResult
        |> with (field "totalPages" [] int)
        |> with (field "totalEntries" [] int)
        |> with (field "pageSize" [] int)
        |> with (field "pageNumber" [] int)
        |> with (field "entries" [] (list querySpec))
