module Route.Helpers.Api exposing (paginationParser, partsToQuery, sortParser, stringToQueryParts, withPaginationQueryParts, withSortQueryParts)

import Api.Query.Pagination exposing (Pagination)
import Api.Query.Sortable exposing (Sort(..))
import Dict exposing (Dict)
import Url.Parser.Query exposing (..)



-- PARSERS


sortParser : Parser Sort
sortParser =
    map2 toSort
        (string "sortBy")
        (enum "sortDesc" sortDescDict)


paginationParser : Parser Pagination
paginationParser =
    map2 Pagination
        (int "pageSize")
        (int "page")



-- TO STRING


partsToQuery : List ( String, String ) -> String
partsToQuery parts =
    case parts of
        [] ->
            ""

        _ ->
            let
                fields =
                    List.map (\( name, value ) -> name ++ "=" ++ value) parts
                        |> String.join "&"
            in
            "?" ++ fields


withSortQueryParts : Sort -> List ( String, String ) -> List ( String, String )
withSortQueryParts sort =
    let
        parts =
            case sort of
                Asc sortBy ->
                    [ ( "sortBy", sortBy ), ( "sortDesc", "false" ) ]

                Desc sortBy ->
                    [ ( "sortBy", sortBy ), ( "sortDesc", "true" ) ]

                NotSorted ->
                    []
    in
    (++) parts


withPaginationQueryParts : Pagination -> List ( String, String ) -> List ( String, String )
withPaginationQueryParts pagination parts =
    let
        pageSizePart =
            pagination.pageSize
                |> Maybe.map (\pageSize -> [ ( "pageSize", String.fromInt pageSize ) ])
                |> Maybe.withDefault []

        pagePart =
            pagination.page
                |> Maybe.map (\page -> [ ( "page", String.fromInt page ) ])
                |> Maybe.withDefault []
    in
    pageSizePart ++ pagePart ++ parts


stringToQueryParts : String -> Maybe String -> List ( String, String ) -> List ( String, String )
stringToQueryParts name part =
    part
        |> Maybe.map (\v -> [ ( name, v ) ])
        |> Maybe.withDefault []
        |> (++)



-- Internal


sortDescDict : Dict String Bool
sortDescDict =
    [ ( "true", True )
    , ( "false", False )
    ]
        |> Dict.fromList


toSort : Maybe String -> Maybe Bool -> Sort
toSort maybeSortBy maybeSortDesc =
    case ( maybeSortBy, maybeSortDesc ) of
        ( Nothing, _ ) ->
            NotSorted

        ( Just sortBy, Just True ) ->
            Desc sortBy

        ( Just sortBy, _ ) ->
            Asc sortBy
