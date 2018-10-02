module App.Pages exposing (Model, Msg(..), changeRouteTo, init, subscriptions, update, view)

import App.Pages.Dashboard as Dashboard
import App.Pages.Users as Users
import App.Route as Route exposing (Route(..))
import App.Session exposing (Session)
import Html exposing (Html, div, text)



-- MODEL


type alias Model =
    Page


type Page
    = Blank
    | NotFound
    | DashboardPage Dashboard.Model
    | UsersPage Users.Model


type Msg
    = DashboardMsg Dashboard.Msg
    | UsersMsg Users.Msg



-- INIT


init : Maybe Route -> Session -> ( Model, Cmd Msg )
init maybeRoute session =
    changeRouteTo maybeRoute session Blank



-- VIEW


view : Session -> Model -> Html Msg
view session page =
    case page of
        DashboardPage pageModel ->
            Dashboard.view session pageModel
                |> Html.map DashboardMsg

        UsersPage pageModel ->
            Users.view session pageModel
                |> Html.map UsersMsg

        NotFound ->
            div [] [ text "Not Found" ]

        Blank ->
            text ""



-- UPDATE


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg page =
    case ( msg, page ) of
        ( DashboardMsg pageMsg, DashboardPage pageModel ) ->
            Dashboard.update session pageMsg pageModel
                |> updateWith DashboardPage DashboardMsg

        ( UsersMsg pageMsg, UsersPage pageModel ) ->
            Users.update session pageMsg pageModel
                |> updateWith UsersPage UsersMsg

        _ ->
            ( page, Cmd.none )


changeRouteTo : Maybe Route -> Session -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute session model =
    case maybeRoute of
        Nothing ->
            ( NotFound, Cmd.none )

        Just Route.Dashboard ->
            Dashboard.init session
                |> updateWith DashboardPage DashboardMsg

        Just (Route.UserRoute userRoute) ->
            (case model of
                UsersPage subPage ->
                    Users.changeRouteTo userRoute session subPage

                _ ->
                    Users.init userRoute session
            )
                |> updateWith UsersPage UsersMsg


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
