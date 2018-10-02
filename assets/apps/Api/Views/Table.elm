module Api.Views.Table exposing
    ( Column
    , Config
    , PaginateConfig
    , Props
    , basicColumn
    , paginatedView
    , view
    )

import Api.Query as Query exposing (ListStatus(..), QueryData(..))
import Api.Query.Pagination exposing (PaginationResult)
import Api.Query.Sortable as Sort exposing (Sort(..), getSortBy, reverseSort)
import Api.Views.Paginator as Paginator
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Set exposing (Set)
import Views.Icons exposing (icon)



-- Config


type alias Column entity msg =
    { label : String
    , toHtml : entity -> Html msg
    , cellClass : String
    }


basicColumn : String -> (entity -> Html msg) -> Column entity msg
basicColumn label toHtml =
    { label = label
    , toHtml = toHtml
    , cellClass = ""
    }


type alias BaseConfig a entity msg =
    { a
        | columns : List (Column entity msg)
        , onSort : Maybe (Sort -> msg)
        , onRowsSelected : Maybe (Set String -> msg)
        , rowToId : entity -> String
        , tableClass : String
    }


type alias Config entity msg =
    BaseConfig {} entity msg


type alias PaginateConfig entity msg =
    BaseConfig
        { goToPage : Int -> msg
        }
        entity
        msg



-- State


type alias Props =
    { sort : Sort
    , selected : Set String
    }



-- View


view : Config entity msg -> Props -> QueryData (List entity) -> Html msg
view config props entities =
    tableView config props entities


paginatedView : PaginateConfig entity msg -> Props -> QueryData (PaginationResult entity) -> Html msg
paginatedView config props entities =
    let
        footer =
            entities
                |> Query.map (\unwrapped -> [ viewTableFooter <| generatePaginationConfig config unwrapped ])
                |> Query.withDefault []

        listEntities =
            entities
                |> Query.map .entries
    in
    div []
        ([ tableView config props listEntities
         ]
            ++ footer
        )


tableView : BaseConfig a entity msg -> Props -> QueryData (List entity) -> Html msg
tableView config props entities =
    let
        listEntities =
            entities
                |> Query.withDefault []
    in
    table [ class config.tableClass ]
        [ viewTableHeader config props listEntities
        , viewTableBody config props entities
        ]



-- HEADER


viewTableHeader : BaseConfig a entity msg -> Props -> List entity -> Html msg
viewTableHeader config props entities =
    let
        checkCell =
            case config.onRowsSelected of
                Just onRowsSelected ->
                    let
                        allIds =
                            List.map config.rowToId entities
                                |> Set.fromList

                        ( allSelected, toggleMsg ) =
                            if allIds == props.selected then
                                ( True, onRowsSelected Set.empty )

                            else
                                ( False, onRowsSelected allIds )
                    in
                    [ th [ style "text-align" "center" ] [ viewCheck allSelected toggleMsg ] ]

                Nothing ->
                    []

        headerCells =
            List.map (viewHeaderCell config props) config.columns
                ++ checkCell
    in
    headerCells
        |> tr []
        |> (\row -> thead [] [ row ])


viewHeaderCell : BaseConfig a entity msg -> Props -> Column entity msg -> Html msg
viewHeaderCell config props column =
    let
        sortAttributes =
            case config.onSort of
                Just toSortMsg ->
                    let
                        sortMsg =
                            if getSortBy props.sort == Just column.label then
                                toSortMsg (reverseSort props.sort)

                            else
                                toSortMsg (Asc column.label)
                    in
                    [ onClick sortMsg ]

                Nothing ->
                    []

        sortIcon =
            if getSortBy props.sort == Just column.label then
                case props.sort of
                    Asc _ ->
                        text "ASC"

                    Desc _ ->
                        text "DESC"

                    _ ->
                        text ""

            else
                text ""
    in
    th
        ([ class column.cellClass ] ++ sortAttributes)
        [ text column.label
        , sortIcon
        ]


viewCheck : Bool -> msg -> Html msg
viewCheck selected changeMsg =
    input [ type_ "checkbox", onCheck (always changeMsg), checked selected ] []



-- BODY


viewTableBody : BaseConfig a entity msg -> Props -> QueryData (List entity) -> Html msg
viewTableBody config props entities =
    let
        body =
            case entities of
                NotRequested ->
                    [ td [ colspan 12 ] [ text "No data loaded." ] ]

                Loaded [] ->
                    [ td [ colspan 12 ] [ text "No results found." ] ]

                Loaded data ->
                    List.map (viewTableRow config props) data

                Loading (Just data) ->
                    List.map (viewTableRow config props) data

                Loading _ ->
                    [ td [ colspan 12 ] [ text "Loading..." ] ]

                QueryError ->
                    [ td [ colspan 12 ] [ text "Error loading data." ] ]
    in
    tbody [] body


viewTableRow : BaseConfig a entity msg -> Props -> entity -> Html msg
viewTableRow config props entity =
    let
        checkCell =
            case config.onRowsSelected of
                Just onRowSelected ->
                    let
                        entityId =
                            config.rowToId entity

                        ( toggleMsg, isSelected ) =
                            if Set.member entityId props.selected then
                                ( onRowSelected <| Set.remove entityId props.selected, True )

                            else
                                ( onRowSelected <| Set.insert entityId props.selected, False )
                    in
                    [ td [ style "text-align" "center" ] [ viewCheck isSelected toggleMsg ] ]

                Nothing ->
                    []
    in
    List.map (viewTableCell entity) config.columns
        ++ checkCell
        |> tr []


viewTableCell : entity -> Column entity msg -> Html msg
viewTableCell entity column =
    td
        [ class column.cellClass ]
        [ column.toHtml entity ]



-- FOOTER


viewTableFooter : Paginator.Config msg -> Html msg
viewTableFooter =
    Paginator.paginationFooter



-- Pagination Helpers


generatePaginationConfig : PaginateConfig entity msg -> PaginationResult entity -> Paginator.Config msg
generatePaginationConfig config data =
    { goToPage = config.goToPage
    , pageNumber = data.pageNumber
    , pageSize = data.pageSize
    , totalEntries = data.totalEntries
    }
