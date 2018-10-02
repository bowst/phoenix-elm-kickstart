module Api.Views.Paginator exposing (Config, pageSizeSelect, paginationFooter)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List
import Views.Icons exposing (icon)


type alias Config msg =
    { goToPage :
        Int
        -> msg
    , pageNumber : Int
    , totalEntries : Int
    , pageSize : Int
    }


paginationFooter : Config msg -> Html msg
paginationFooter config =
    div [ class "pagination" ] (viewPageList config)


viewPageList : Config msg -> List (Html msg)
viewPageList config =
    let
        numberOfPages =
            (config.totalEntries - 1) // config.pageSize + 1

        pageNumber =
            clamp 1 numberOfPages config.pageNumber

        nextClickAttr =
            if pageNumber >= numberOfPages then
                [ attribute "disabled" "true" ]

            else
                [ onClick <| config.goToPage <| pageNumber + 1 ]

        prevClickAttr =
            if pageNumber <= 1 then
                [ attribute "disabled" "true" ]

            else
                [ onClick <| config.goToPage <| pageNumber - 1 ]

        pageLink =
            viewPageLink config.goToPage pageNumber

        firstPage =
            [ pageLink 1 ]

        lastPage =
            if numberOfPages > 1 then
                [ pageLink numberOfPages ]

            else
                []

        pages =
            if numberOfPages < 5 then
                List.range 2 (numberOfPages - 1)
                    |> List.map pageLink

            else
                let
                    firstBreak =
                        if pageNumber - 2 > 1 then
                            [ li [] [ span [ class "pagination-ellipsis" ] [ text "…" ] ] ]

                        else
                            []

                    lastBreak =
                        if pageNumber + 2 < numberOfPages then
                            [ li [] [ span [ class "pagination-ellipsis" ] [ text "…" ] ] ]

                        else
                            []

                    ( start, end ) =
                        if pageNumber <= 2 then
                            ( 2, 4 )

                        else if pageNumber >= numberOfPages - 2 then
                            ( numberOfPages - 3, numberOfPages - 1 )

                        else
                            ( pageNumber - 1, pageNumber + 1 )

                    inbetweenPages =
                        List.range start end
                            |> List.map pageLink
                in
                firstBreak ++ inbetweenPages ++ lastBreak
    in
    [ a ([ class "pagination-previous" ] ++ prevClickAttr) [ text "Previous" ]
    , a ([ class "pagination-next" ] ++ nextClickAttr) [ text "Next" ]
    , ul [ class "pagination-list" ] (firstPage ++ pages ++ lastPage)
    ]


viewPageLink : (Int -> msg) -> Int -> Int -> Html msg
viewPageLink goToPage currentPage page =
    li []
        [ a
            [ class "pagination-link"
            , classList [ ( "is-current", currentPage == page ) ]
            , onClick <| goToPage page
            ]
            [ text <| String.fromInt page ]
        ]


pageSizeSelect : (Int -> msg) -> Int -> Html msg
pageSizeSelect updatePageSize pageSize =
    let
        options =
            [ "10", "25", "50", "100" ]
                |> List.map
                    (\s ->
                        option [ value s, selected (String.fromInt pageSize == s) ] [ text s ]
                    )

        handleChange stringInt =
            case String.toInt stringInt of
                Just nextPageSize ->
                    updatePageSize nextPageSize

                Nothing ->
                    updatePageSize pageSize
    in
    div [ class "num-results" ]
        [ text "Show"
        , span [ class "styled-select" ]
            [ select [ onInput handleChange ] options
            , i [ class "fas fa-sort" ]
                []
            ]
        , text "Entries"
        ]
