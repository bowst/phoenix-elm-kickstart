module Api.Query.Searchable exposing (SearchQueryParams, withSearchParams)

import Api.Query as Query exposing (Params, withParam)
import GraphQL.Request.Builder.Variable exposing (string)


type alias SearchQueryParams vars =
    { vars | q : Maybe String }


withSearchParams : Params (SearchQueryParams vars) -> Params (SearchQueryParams vars)
withSearchParams params =
    params
        |> withParam string "q" .q
