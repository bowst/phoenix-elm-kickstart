module Schemas.Queries exposing (UserQueryParams, userDetail, userList, userQueryParams)

-- PLEASE KEEP THIS FILE IN ALPHABETICAL ORDER TO MAKE FINDING THINGS EASIER

import Api.Query as Query exposing (withRequiredParam)
import Api.Query.Pagination as Pagination exposing (PaginationParams, PaginationResult, paginationSpec, withPaginationParams)
import Api.Query.Searchable exposing (SearchQueryParams, withSearchParams)
import Api.Query.Sortable exposing (Sort(..), SortableQueryParams, withSortableParams)
import GraphQL.Request.Builder as GraphQL exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Schemas.Specs exposing (..)
import Schemas.Types exposing (..)



-- USERS


type alias UserQueryParams =
    PaginationParams (SearchQueryParams (SortableQueryParams {}))


userQueryParams : UserQueryParams
userQueryParams =
    { pagination = Pagination.default
    , q = Nothing
    , sort = NotSorted
    }


userList : Document Query (PaginationResult User) UserQueryParams
userList =
    let
        filters =
            Query.params
                |> withSearchParams
                |> withPaginationParams
                |> withSortableParams

        field =
            GraphQL.field "users" filters (paginationSpec userSpec)
    in
    queryDocument <| extract field


userDetail : Document Query User { id : String }
userDetail =
    let
        filters =
            Query.params
                |> withRequiredParam Var.string "id" .id

        field =
            GraphQL.field "user" filters userSpec
    in
    queryDocument <| extract field
