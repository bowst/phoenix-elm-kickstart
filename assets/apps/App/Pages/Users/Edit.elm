module App.Pages.Users.Edit exposing (Model, Msg(..), init, subscriptions, update, view)

import Api.Mutation as Mutation exposing (MutationStatus(..))
import Api.Query as Query exposing (QueryData(..))
import Api.Views.Error as Error
import App.Session as Session exposing (Session)
import Browser.Navigation exposing (back, replaceUrl)
import Form exposing (Form)
import Form.Field as Field exposing (Field)
import Form.Validate as Validate exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Schemas.Mutations as Mutations exposing (UserCreatePayload, UserUpdatePayload)
import Schemas.Queries as Queries
import Schemas.Selectors as Select
import Schemas.Types exposing (User)
import Views.Forms.Groups exposing (..)



-- MODEL


type alias Model =
    { user : QueryData User
    , form : Form () UserForm
    , formStatus : MutationStatus User
    }


init : Session -> Maybe String -> ( Model, Cmd Msg )
init session maybeId =
    let
        ( user, loadCmd ) =
            case maybeId of
                Just id ->
                    ( Loading Nothing, queryUser id )

                Nothing ->
                    ( NotRequested, Cmd.none )

        nextModel =
            { user = user
            , form = Form.initial [] validateCreateForm
            , formStatus = None
            }
    in
    ( nextModel, loadCmd )



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
            renderPage (Just user)

        Loaded user ->
            renderPage (Just user)

        NotRequested ->
            renderPage Nothing


viewPage : Model -> Maybe User -> Html Msg
viewPage model maybeUser =
    div [] [ Html.map FormMsg <| formView model maybeUser ]


formView : Model -> Maybe User -> Html Form.Msg
formView model maybeUser =
    let
        -- fields states
        getField name =
            Form.getFieldAsString name model.form

        errors =
            Form.getErrors model.form

        baseFields =
            [ textGroup "" (text "First Name*") <| getField "firstName"
            , textGroup "" (text "Last Name*") <| getField "lastName"
            , textGroup "" (text "Email*") <| getField "email"
            , selectGroup roleOptions "" (text "Role*") <| getField "role"
            ]

        createFields =
            case model.user of
                Loaded _ ->
                    []

                _ ->
                    [ textGroup "" (text "Password*") <| getField "password"
                    , textGroup "" (text "Confirm Password*") <| getField "passwordConfirmation"
                    ]

        title =
            case maybeUser of
                Just user ->
                    "Edit User"

                Nothing ->
                    "Create New User"

        submitText =
            case model.formStatus of
                Pending ->
                    "Saving..."

                _ ->
                    "Save"

        submitErrors =
            case model.formStatus of
                MutationError resultErrors ->
                    resultErrors

                _ ->
                    []

        disabledStatus =
            errors /= [] || (model.formStatus == Pending)
    in
    section [ class "page" ]
        [ div [ class "level" ]
            [ h3 [ class "title is-3" ] [ text title ]
            ]
        , div [] (baseFields ++ createFields)
        , br [] []
        , button
            [ onClick Form.Submit
            , class "button is-link"
            , classList [ ( "disabled", disabledStatus ) ]
            , disabled disabledStatus
            ]
            [ text submitText ]
        , Error.view model.formStatus
        ]



-- FORM


type alias UserForm =
    { id : String
    , firstName : String
    , lastName : String
    , email : String
    , role : String
    , password : String
    , passwordConfirmation : String
    }


validateCreateForm : Validation () UserForm
validateCreateForm =
    succeed UserForm
        |> andMap (succeed "")
        |> andMap (field "firstName" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "lastName" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "email" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "role" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "password" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "passwordConfirmation" (string |> Validate.andThen Validate.nonEmpty))


validateUpdateForm : Validation () UserForm
validateUpdateForm =
    succeed UserForm
        |> andMap (succeed "")
        |> andMap (field "firstName" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "lastName" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "email" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (field "role" (string |> Validate.andThen Validate.nonEmpty))
        |> andMap (succeed "")
        |> andMap (succeed "")


initialFields : User -> List ( String, Field )
initialFields user =
    [ ( "firstName", Field.string user.firstName )
    , ( "lastName", Field.string user.lastName )
    , ( "email", Field.string user.email )
    , ( "role", Field.string user.role )
    ]


roleOptions : List ( String, String )
roleOptions =
    [ ( "user", "User" )
    , ( "admin", "Admin" )
    ]



-- UPDATE --


type Msg
    = UserQueryResponse (QueryData User)
    | UserMutationResponse (MutationStatus User)
    | FormMsg Form.Msg


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        UserQueryResponse response ->
            let
                nextModel =
                    case response of
                        Loaded user ->
                            { model | form = Form.initial (initialFields user) validateUpdateForm }

                        _ ->
                            model
            in
            ( { nextModel | user = response }, Cmd.none )

        UserMutationResponse response ->
            case response of
                Complete user ->
                    ( model, back session.navKey 1 )

                _ ->
                    ( { model | formStatus = response }, Cmd.none )

        FormMsg formMsg ->
            case ( formMsg, Form.getOutput model.form ) of
                ( Form.Submit, Just formValues ) ->
                    let
                        nextCmd =
                            case Query.toMaybe model.user of
                                Just user ->
                                    updateUser { formValues | id = user.id }

                                Nothing ->
                                    createUser formValues
                    in
                    ( { model | formStatus = Pending }, nextCmd )

                _ ->
                    let
                        validator =
                            case model.user of
                                Loaded user ->
                                    validateUpdateForm

                                _ ->
                                    validateCreateForm
                    in
                    ( { model | form = Form.update validator formMsg model.form }, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []



-- API Helpers


queryUser : String -> Cmd Msg
queryUser userId =
    Query.send Queries.userDetail UserQueryResponse { id = userId }


createUser : UserCreatePayload a -> Cmd Msg
createUser =
    Mutation.send Mutations.createUser UserMutationResponse


updateUser : UserUpdatePayload a -> Cmd Msg
updateUser =
    Mutation.send Mutations.updateUser UserMutationResponse
