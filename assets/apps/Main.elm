module Main exposing (main)

import App.Layout exposing (sidebar, toolbar)
import App.Pages as Pages
import App.Route as Route exposing (Route)
import App.Session as Session exposing (Session)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Schemas.Types exposing (User)
import Time exposing (Posix)
import Url exposing (Url)
import Url.Parser as UrlParser



-- MODEL


type alias Flags =
    { user : User }


type alias Model =
    { session : Session
    , page : Pages.Model
    }



-- INIT


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        ( nextSession, nextSessionCmd ) =
            Session.init navKey flags.user

        ( nextPage, nextPageCmd ) =
            Pages.init (Route.fromUrl url) nextSession

        nextModel =
            { session = nextSession
            , page = nextPage
            }

        nextCmd =
            Cmd.batch
                [ Cmd.map SessionMsg nextSessionCmd
                , Cmd.map PageMsg nextPageCmd
                ]
    in
    ( nextModel, nextCmd )



-- UPDATE


type Msg
    = SessionMsg Session.Msg
    | PageMsg Pages.Msg
    | ChangedUrl Url
    | ClickedLink Browser.UrlRequest


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SessionMsg subMsg ->
            let
                nextSession =
                    Session.update subMsg model.session
            in
            ( { model | session = nextSession }, Cmd.none )

        PageMsg subMsg ->
            let
                ( nextPage, nextPageMsg ) =
                    Pages.update model.session subMsg model.page
            in
            ( { model | page = nextPage }, Cmd.map PageMsg nextPageMsg )

        ChangedUrl url ->
            let
                ( nextPage, nextPageCmd ) =
                    Pages.changeRouteTo (Route.fromUrl url) model.session model.page
            in
            ( { model | page = nextPage }, Cmd.map PageMsg nextPageCmd )

        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.session.navKey (Url.toString url) )

                Browser.External "" ->
                    ( model, Cmd.none )

                Browser.External href ->
                    ( model, Nav.load href )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg model ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- VIEW


view : Model -> Document Msg
view model =
    let
        page =
            Pages.view model.session model.page
                |> Html.map PageMsg

        content =
            div [ class "columns" ]
                [ sidebar
                , div [ class "column has-background-light" ]
                    [ page ]
                ]

        body =
            div [ id "layout" ]
                [ toolbar model.session.user
                , content
                ]

        title =
            "Quiver | Dashboard"
    in
    { title = title
    , body = [ body ]
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map SessionMsg <| Session.subscriptions model.session
        ]



-- APPLICATIONS


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
