module Views.Forms.Errors exposing (errorClass, errorMessage, errorToString)

-- Core
-- Libraries

import Form exposing (Form)
import Form.Error as Error exposing (Error, ErrorValue(..))
import Html exposing (..)
import Html.Attributes exposing (..)


errorClass : Maybe error -> String
errorClass maybeError =
    Maybe.map (\_ -> "has-error") maybeError |> Maybe.withDefault ""


errorMessage : Maybe (ErrorValue a) -> Html Form.Msg
errorMessage maybeError =
    case maybeError of
        Just error ->
            p
                [ class "help is-danger" ]
                [ text (errorToString error) ]

        Nothing ->
            span
                [ class "help" ]
                [ text "" ]


errorToString : ErrorValue a -> String
errorToString error =
    case error of
        Empty ->
            "This field is required"

        InvalidInt ->
            "This field must be a valid integer"

        InvalidFloat ->
            "This field must be a valid number"

        InvalidFormat ->
            "This field is invalid"

        InvalidEmail ->
            "This field must be a valid email address"

        InvalidString ->
            "This field must be a valid string"

        InvalidBool ->
            "This field must be either true or false"

        LongerStringThan num ->
            "This field must not be longer than " ++ String.fromInt num ++ " characters"

        ShorterStringThan num ->
            "This field must not be shorter than " ++ String.fromInt num ++ " characters"

        SmallerFloatThan num ->
            "This field must be greater than " ++ String.fromFloat num

        SmallerIntThan num ->
            "This field must be greater than " ++ String.fromInt num

        _ ->
            "This field is invalid."
