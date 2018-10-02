module Api.Views.Error exposing (view, viewWithOverrides)

import Api.Mutation exposing (ErrorMessage, MutationStatus(..))
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import String.Extra exposing (humanize)


view : MutationStatus spec -> Html msg
view result =
    case result of
        MutationError errors ->
            mutationErrorView Dict.empty errors

        RequestError ->
            div [] [ text "An error occurred processsing your request." ]

        _ ->
            text ""


viewWithOverrides : Dict String String -> MutationStatus spec -> Html msg
viewWithOverrides overrides result =
    case result of
        MutationError errors ->
            mutationErrorView overrides errors

        RequestError ->
            div [] [ text "An error occurred processsing your request." ]

        _ ->
            text ""


mutationErrorView : Dict String String -> List ErrorMessage -> Html msg
mutationErrorView overrides errors =
    let
        getErrorText error =
            getReadableFieldName overrides error.field
                ++ " - "
                ++ error.message

        renderError error =
            li [] [ text (getErrorText error) ]

        renderedErrors =
            List.map renderError errors
    in
    ul
        [ class "form-errors" ]
        renderedErrors


getReadableFieldName : Dict String String -> String -> String
getReadableFieldName overrides field =
    case Dict.get field overrides of
        Just override ->
            override

        Nothing ->
            humanize field
