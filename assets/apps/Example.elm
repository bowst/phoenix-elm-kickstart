module App.Pages.Users.Edit exposing (Model, Msg(..), init, subscriptions, update, view)


import Api.Query as Query exposing (QueryData(..))
import App.Session as Session exposing (Session)
import Browser.Navigation exposing (replaceUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Schemas.Queries as Queries
import Schemas.Selectors as Select
import Schemas.Types exposing (User)




-- MODEL


type alias Model =
    Int


init : Session -> Maybe String -> ( Model, Cmd Msg )
init session maybeId =
    ( 0, Cmd.none )



-- MESSAGES


type Msg
    = NoOp



-- VIEW


view : Session -> Model -> Html Msg
view session model =
    div []
        [ text (String.fromInt model) ]



-- UPDATE


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update Session -> msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []
