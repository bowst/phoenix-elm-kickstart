module Api.Mutation exposing
    ( ErrorMessage
    , MutationRequest
    , MutationResult
    , MutationStatus(..)
    , Payload
    , fromMutationResult
    , mutationErrorMessageSpec
    , mutationSpec
    , payload
    , send
    , toDocument
    , withOptional
    , withRequired
    , withRequiredInt
    , withRequiredString
    )

import GraphQL.Client.Http exposing (Error, sendMutation)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Task


type alias MutationRequest source =
    { name : String
    , payload : Payload source
    }


type alias Payload vars =
    List ( String, Arg.Value vars )


type MutationStatus spec
    = None
    | Pending
    | Complete spec
    | MutationError (List ErrorMessage)
    | RequestError


type alias MutationResult spec =
    { successful : Bool
    , result : Maybe spec
    , messages : List ErrorMessage
    }


type alias ErrorMessage =
    { code : String
    , field : String
    , message : String
    }


mutationSpec : ValueSpec NonNull ObjectType spec vars -> ValueSpec NonNull ObjectType (MutationResult spec) vars
mutationSpec payloadSpec =
    object MutationResult
        |> with (field "successful" [] bool)
        |> with (field "result" [] (nullable payloadSpec))
        |> with (field "messages" [] (list mutationErrorMessageSpec))


mutationErrorMessageSpec : ValueSpec NonNull ObjectType ErrorMessage vars
mutationErrorMessageSpec =
    object ErrorMessage
        |> with (field "code" [] string)
        |> with (field "field" [] string)
        |> with (field "message" [] string)


send : Document Mutation (MutationResult a) vars -> (MutationStatus a -> msg) -> vars -> Cmd msg
send doc toMsg vars =
    request vars doc
        |> sendMutation "/graphql"
        |> Task.attempt (fromMutationResult >> toMsg)


fromMutationResult : Result Error (MutationResult spec) -> MutationStatus spec
fromMutationResult result =
    case result of
        Err error ->
            RequestError

        Ok resultPayload ->
            case resultPayload.result of
                Just successResult ->
                    Complete successResult

                Nothing ->
                    MutationError resultPayload.messages



-- Mutation Payload Builder


payload : Payload source
payload =
    []


toDocument : String -> ValueSpec NonNull ObjectType spec source -> Payload source -> Document Mutation (MutationResult spec) source
toDocument name resultSpec payloadArgs =
    mutationDocument <|
        extract
            (field name payloadArgs (mutationSpec resultSpec))


withRequired : Var.VariableSpec nullability a -> String -> (source -> a) -> Payload source -> Payload source
withRequired spec name selector =
    (::) ( name, Arg.variable (Var.required name selector spec) )


withOptional : Var.VariableSpec Var.NonNull a -> String -> (source -> Maybe a) -> Payload source -> Payload source
withOptional spec name selector =
    (::) ( name, Arg.variable (Var.required name selector (Var.nullable spec)) )


withRequiredString : String -> (source -> String) -> Payload source -> Payload source
withRequiredString =
    withRequired Var.string


withRequiredInt : String -> (source -> Int) -> Payload source -> Payload source
withRequiredInt =
    withRequired Var.int
