module App.Pages.Users.Detail exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.Query as Query exposing (QueryData(..))
import Api.Views.Error as Error
import App.Session as Session exposing (Session)
import Browser.Navigation exposing (back, replaceUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Schemas.Queries as Queries
import Schemas.Selectors as Select
import Schemas.Types exposing (User)



-- MODEL


type alias Model =
    { user : QueryData User
    }


init : Session -> String -> ( Model, Cmd Msg )
init session id =
    let
        nextModel =
            { user = Loading Nothing
            }
    in
    ( nextModel, queryUser id )



--- VIEW --


view : Session -> Model -> Html Msg
view session model =
    let
        renderPage =
            viewPage model
    in
    case model.user of
        Loading Nothing ->
            div [] [ text "Loading page..." ]

        QueryError ->
            div [] [ text "Error loading page." ]

        Loading (Just user) ->
            renderPage user

        Loaded user ->
            renderPage user

        NotRequested ->
            div [] []


viewPage : Model -> User -> Html Msg
viewPage model user =
    section [ class "page" ]
        [ div [ class "level" ]
            [ h3 [ class "title is-3" ] [ text <| Select.fullname user ]
            , div [ class "level-right" ]
                [ a [ class "button is-link", href <| "/app/users/" ++ user.id ++ "/edit" ] [ text "Edit" ]
                , a [ class "button is-text", href <| "/app/users/" ++ user.id ++ "/remove" ] [ text "Remove" ]
                ]
            ]
        , p [] [ text "User Detail" ]
        ]



-- UPDATE --


type Msg
    = UserQueryResponse (QueryData User)


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        UserQueryResponse response ->
            ( { model | user = response }, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []



-- API Helpers


queryUser : String -> Cmd Msg
queryUser userId =
    Query.send Queries.userDetail UserQueryResponse { id = userId }
