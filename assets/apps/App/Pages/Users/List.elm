module App.Pages.Users.List exposing (Model, Msg(..), RouteParams, init, paramsToString, routeParams, routeParamsParser, subscriptions, update, view)

import Api.Query as Query exposing (QueryData(..))
import Api.Query.Pagination as Pagination exposing (Pagination, PaginationResult)
import Api.Query.Sortable exposing (Sort(..))
import Api.Views.Table as Table exposing (basicColumn)
import App.Session as Session exposing (Session)
import Browser.Navigation exposing (Key, replaceUrl)
import Form exposing (Form)
import Form.Field as Field exposing (Field)
import Form.Validate as Validate exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route.Helpers exposing (apply)
import Route.Helpers.Api exposing (paginationParser, partsToQuery, sortParser, stringToQueryParts, withPaginationQueryParts, withSortQueryParts)
import Schemas.Queries as Queries exposing (userQueryParams)
import Schemas.Selectors as Select
import Schemas.Types exposing (User)
import Set
import Url.Parser.Query as Parser exposing (Parser)
import Views.Forms.Groups exposing (..)
import Views.Forms.Helpers exposing (addStringField)



-- ROUTE


type alias RouteParams =
    { sort : Sort
    , pagination : Pagination
    , q : Maybe String
    }


routeParamsParser : Parser RouteParams
routeParamsParser =
    Parser.map RouteParams sortParser
        |> apply paginationParser
        |> apply (Parser.string "q")


routeParams : RouteParams
routeParams =
    { sort = NotSorted
    , pagination = Pagination.default
    , q = Nothing
    }


paramsToString : RouteParams -> String
paramsToString params =
    []
        |> withSortQueryParts params.sort
        |> withPaginationQueryParts params.pagination
        |> stringToQueryParts "q" params.q
        |> partsToQuery



-- MODEL


type alias Model =
    { users : QueryData (PaginationResult User)
    , params : RouteParams
    , form : Form () FilterForm
    }


init : Session -> RouteParams -> ( Model, Cmd Msg )
init session params =
    let
        nextModel =
            { users = Loading Nothing
            , params = params
            , form = Form.initial (emptyFields params) validateForm
            }
    in
    ( nextModel, queryUsers params )



-- VIEW


view : Session -> Model -> Html Msg
view session model =
    section [ class "page" ]
        [ div [ class "level" ]
            [ h3 [ class "title is-3" ] [ text "Users" ]
            , a [ class "button is-link", href "/app/users/new" ] [ text "Create New User" ]
            ]
        , div [ class "level" ] [ filterForm model |> Html.map FormMsg ]
        , Table.paginatedView tableConfig tableProps model.users
        ]


tableConfig : Table.PaginateConfig User Msg
tableConfig =
    { columns =
        [ basicColumn "ID" (.id >> text)
        , basicColumn "Name" (Select.fullname >> text)
        , basicColumn "Role" (Select.userRole >> text)
        , basicColumn "Actions"
            (\user ->
                div [ class "field is-grouped" ]
                    [ div [ class "control" ]
                        [ a
                            [ class "button is-text"
                            , href <| "/app/users/" ++ user.id
                            ]
                            [ text "View" ]
                        ]
                    , div [ class "control" ]
                        [ a
                            [ class "button is-text"
                            , href <| "/app/users/" ++ user.id ++ "/edit"
                            ]
                            [ text "Edit" ]
                        ]
                    , div [ class "control" ]
                        [ a
                            [ class "button is-text"
                            , href <| "/app/users/" ++ user.id ++ "/remove"
                            ]
                            [ text "Remove" ]
                        ]
                    ]
            )
        ]
    , rowToId = .id
    , goToPage = PageChange
    , onSort = Nothing
    , onRowsSelected = Nothing
    , tableClass = "table"
    }


tableProps : Table.Props
tableProps =
    { sort = NotSorted
    , selected = Set.empty
    }



-- FILTER FORM


type alias FilterForm =
    { q : Maybe String
    }


filterForm : Model -> Html Form.Msg
filterForm model =
    let
        getField str =
            Form.getFieldAsString str model.form
    in
    div []
        [ div [ class "columns" ]
            [ div [ class "column" ]
                [ submitTextGroup "" (text "Search") <| getField "q" ]
            ]
        , div [ class "field is-grouped" ]
            [ div [ class "control" ]
                [ button
                    [ class "button is-link"
                    , onClick Form.Submit
                    ]
                    [ text "Filter" ]
                ]
            , div [ class "control" ]
                [ button
                    [ class "button is-text"
                    , onClick resetForm
                    ]
                    [ text "Cancel" ]
                ]
            ]
        ]


emptyFields : RouteParams -> List ( String, Field )
emptyFields params =
    []
        |> addStringField "q" params.q


validateForm : Validation () FilterForm
validateForm =
    succeed FilterForm
        |> andMap (field "q" (maybe string))


resetForm : Form.Msg
resetForm =
    Form.Reset <| emptyFields routeParams



-- UPDATE


type Msg
    = UserQueryResponse (QueryData (PaginationResult User))
    | HandleParamsUpdate RouteParams
    | PageChange Int
    | FormMsg Form.Msg


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg ({ params } as model) =
    case msg of
        UserQueryResponse response ->
            ( { model | users = response }, Cmd.none )

        HandleParamsUpdate nextParams ->
            ( { model | params = nextParams }, queryUsers nextParams )

        PageChange nextPage ->
            let
                nextParams =
                    { params | pagination = Pagination.updatePage nextPage params.pagination }
            in
            ( { model | params = nextParams }, replaceUrl session.navKey ("/app/users" ++ paramsToString nextParams) )

        FormMsg formMsg ->
            let
                nextForm =
                    Form.update validateForm formMsg model.form

                nextCmd =
                    case ( formMsg, Form.getOutput nextForm ) of
                        ( Form.Reset _, Just values ) ->
                            updateQueryParams session.navKey <| mergeQueryParams params values

                        ( Form.Submit, Just values ) ->
                            updateQueryParams session.navKey <| mergeQueryParams params values

                        _ ->
                            Cmd.none
            in
            ( { model | form = nextForm }, nextCmd )


mergeQueryParams : RouteParams -> FilterForm -> RouteParams
mergeQueryParams params values =
    { params
        | q = values.q
    }


updateQueryParams : Key -> RouteParams -> Cmd msg
updateQueryParams navKey params =
    replaceUrl navKey <| "/app/users" ++ paramsToString params



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []



-- Queries


queryUsers : RouteParams -> Cmd Msg
queryUsers params =
    let
        requestParms =
            { userQueryParams
                | sort = params.sort
                , pagination = params.pagination
                , q = params.q
            }
    in
    Query.send Queries.userList UserQueryResponse requestParms
