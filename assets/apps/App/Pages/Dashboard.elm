module App.Pages.Dashboard exposing (Model, Msg(..), init, subscriptions, update, view)

import App.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)



-- MODEL


type alias Model =
    Int


init : Session -> ( Model, Cmd Msg )
init session =
    ( 0, Cmd.none )



-- MESSAGES


type Msg
    = NoOp



-- VIEW


view : Session -> Model -> Html Msg
view session model =
    div []
        [ text "Dashboard21" ]



-- UPDATE


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []
