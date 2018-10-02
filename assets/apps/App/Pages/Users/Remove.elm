module App.Pages.Users.Remove exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.Mutation as Mutation exposing (MutationStatus(..))
import Api.Query as Query exposing (QueryData(..))
import Api.Views.Error as Error
import App.Session as Session exposing (Session)
import Browser.Navigation exposing (back, replaceUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Schemas.Mutations as Mutations exposing (RemovePayload)
import Schemas.Queries as Queries
import Schemas.Selectors as Select
import Schemas.Types exposing (User)



-- MODEL


type alias Model =
    { user : QueryData User
    , status : MutationStatus User
    }


init : Session -> String -> ( Model, Cmd Msg )
init session id =
    let
        nextModel =
            { user = Loading Nothing
            , status = None
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
    let
        buttonText =
            case model.status of
                Pending ->
                    "Removing..."

                _ ->
                    "Remove"
    in
    section [ class "page" ]
        [ div [ class "level" ]
            [ h3 [ class "title is-3" ] [ text "Remove User" ]
            ]
        , p []
            [ text "Are you sure you want to remove user: "
            , strong [] [ text <| Select.fullname user ]
            , text "?"
            ]
        , br [] []
        , div [ class "field is-grouped" ]
            [ div [ class "control" ]
                [ button
                    [ class "button is-danger"
                    , onClick Remove
                    ]
                    [ text buttonText ]
                ]
            , div [ class "control" ]
                [ button
                    [ class "button is-text"
                    , onClick Cancel
                    ]
                    [ text "Cancel" ]
                ]
            ]
        , br [] []
        , Error.view model.status
        ]



-- UPDATE --


type Msg
    = UserQueryResponse (QueryData User)
    | UserMutationResponse (MutationStatus User)
    | Remove
    | Cancel


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        UserQueryResponse response ->
            ( { model | user = response }, Cmd.none )

        UserMutationResponse response ->
            case response of
                Complete user ->
                    ( model, back session.navKey 1 )

                _ ->
                    ( { model | status = response }, Cmd.none )

        Remove ->
            case Query.toMaybe model.user of
                Just user ->
                    ( { model | status = Pending }, removeUser user )

                Nothing ->
                    ( model, Cmd.none )

        Cancel ->
            ( model, back session.navKey 1 )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []



-- API Helpers


queryUser : String -> Cmd Msg
queryUser userId =
    Query.send Queries.userDetail UserQueryResponse { id = userId }


removeUser : RemovePayload a -> Cmd Msg
removeUser =
    Mutation.send Mutations.removeUser UserMutationResponse
