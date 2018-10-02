module App.Pages.Users exposing (Model, Msg(..), Route(..), changeRouteTo, init, listRoute, parser, routeToParts, subscriptions, update, view)

import App.Pages.Users.Detail as DetailPage
import App.Pages.Users.Edit as EditPage
import App.Pages.Users.List as ListPage
import App.Pages.Users.Remove as RemovePage
import App.Session exposing (Session)
import Html exposing (Html)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string)



-- ROUTING


type alias Model =
    Pages


type Route
    = ListRoute ListPage.RouteParams
    | DetailRoute String
    | EditRoute (Maybe String)
    | RemoveRoute String


listRoute : Maybe ListPage.RouteParams -> Route
listRoute maybeParams =
    case maybeParams of
        Just params ->
            ListRoute params

        Nothing ->
            ListRoute ListPage.routeParams


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map ListRoute <| Parser.top <?> ListPage.routeParamsParser
        , Parser.map (EditRoute Nothing) <| s "new"
        , Parser.map (EditRoute << Just) <| string </> s "edit"
        , Parser.map DetailRoute <| string
        , Parser.map RemoveRoute <| string </> s "remove"
        ]


routeToParts : Route -> ( List String, String )
routeToParts route =
    case route of
        ListRoute params ->
            ( [], ListPage.paramsToString params )

        DetailRoute id ->
            ( [ id ], "" )

        EditRoute maybeId ->
            case maybeId of
                Just id ->
                    ( [ id, "edit" ], "" )

                Nothing ->
                    ( [ "new" ], "" )

        RemoveRoute id ->
            ( [ id, "edit" ], "" )


type Pages
    = ListPage ListPage.Model
    | DetailPage DetailPage.Model
    | EditPage EditPage.Model
    | RemovePage RemovePage.Model


type Msg
    = ListMsg ListPage.Msg
    | DetailMsg DetailPage.Msg
    | EditMsg EditPage.Msg
    | RemoveMsg RemovePage.Msg



-- INIT


init : Route -> Session -> ( Model, Cmd Msg )
init route session =
    case route of
        ListRoute params ->
            ListPage.init session params
                |> updateWith ListPage ListMsg

        DetailRoute params ->
            DetailPage.init session params
                |> updateWith DetailPage DetailMsg

        EditRoute maybeString ->
            EditPage.init session maybeString
                |> updateWith EditPage EditMsg

        RemoveRoute id ->
            RemovePage.init session id
                |> updateWith RemovePage RemoveMsg


changeRouteTo : Route -> Session -> Model -> ( Model, Cmd Msg )
changeRouteTo route session model =
    case ( route, model ) of
        ( ListRoute params, ListPage pageModel ) ->
            ListPage.update session (ListPage.HandleParamsUpdate params) pageModel
                |> updateWith ListPage ListMsg

        _ ->
            init route session



-- VIEW


view : Session -> Model -> Html Msg
view session model =
    case model of
        ListPage pageModel ->
            ListPage.view session pageModel
                |> Html.map ListMsg

        DetailPage pageModel ->
            DetailPage.view session pageModel
                |> Html.map DetailMsg

        EditPage pageModel ->
            EditPage.view session pageModel
                |> Html.map EditMsg

        RemovePage pageModel ->
            RemovePage.view session pageModel
                |> Html.map RemoveMsg



-- UPDATE


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case ( msg, model ) of
        ( ListMsg pageMsg, ListPage pageModel ) ->
            ListPage.update session pageMsg pageModel
                |> updateWith ListPage ListMsg

        ( DetailMsg pageMsg, DetailPage pageModel ) ->
            DetailPage.update session pageMsg pageModel
                |> updateWith DetailPage DetailMsg

        ( EditMsg pageMsg, EditPage pageModel ) ->
            EditPage.update session pageMsg pageModel
                |> updateWith EditPage EditMsg

        ( RemoveMsg pageMsg, RemovePage pageModel ) ->
            RemovePage.update session pageMsg pageModel
                |> updateWith RemovePage RemoveMsg

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []
