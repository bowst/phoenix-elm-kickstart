module Api.Query exposing
    ( ListStatus(..)
    , Params
    , QueryData(..)
    , map
    , params
    , send
    , toListStatus
    , toMaybe
    , withDefault
    , withParam
    , withRequiredParam
    )

import Dict exposing (Dict)
import GraphQL.Client.Http exposing (Error, sendQuery)
import GraphQL.Request.Builder exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var exposing (NonNull, Variable, VariableSpec)
import Html exposing (Html, div, li, text, ul)
import Html.Attributes exposing (class)
import String.Extra as String
import String.Interpolate exposing (interpolate)
import Task exposing (Task)



-- Query Helpers


type QueryData a
    = NotRequested
    | Loading (Maybe a)
    | Loaded a
    | QueryError


type ListStatus a
    = LoadingList
    | ListData (List a)
    | Empty
    | ListError


withDefault : a -> QueryData a -> a
withDefault default queryData =
    case queryData of
        Loaded data ->
            data

        Loading (Just data) ->
            data

        _ ->
            default


map : (a -> b) -> QueryData a -> QueryData b
map func start =
    case start of
        Loaded data ->
            Loaded (func data)

        Loading (Just data) ->
            Loading (Just <| func data)

        Loading Nothing ->
            Loading Nothing

        NotRequested ->
            NotRequested

        QueryError ->
            QueryError


toMaybe : QueryData a -> Maybe a
toMaybe queryData =
    case queryData of
        Loaded data ->
            Just data

        Loading (Just data) ->
            Just data

        _ ->
            Nothing


toListStatus : QueryData (List a) -> ListStatus a
toListStatus queryData =
    case queryData of
        NotRequested ->
            Empty

        Loaded [] ->
            Empty

        Loaded data ->
            ListData data

        Loading (Just data) ->
            ListData data

        Loading _ ->
            LoadingList

        QueryError ->
            ListError


send : Document Query a vars -> (QueryData a -> msg) -> vars -> Cmd msg
send query toMsg vars =
    request vars query
        |> sendQuery "/graphql"
        |> Task.attempt (fromQueryResult >> toMsg)


fromQueryResult : Result Error a -> QueryData a
fromQueryResult result =
    case result of
        Err error ->
            QueryError

        Ok x ->
            Loaded x


type alias Params source =
    List ( String, Arg.Value source )


params : Params source
params =
    []


withParam : VariableSpec NonNull a -> String -> (source -> Maybe a) -> List ( String, Arg.Value source ) -> List ( String, Arg.Value source )
withParam toVar name selector =
    (::) ( name, Arg.variable <| Var.required name selector (Var.nullable toVar) )


withRequiredParam : VariableSpec NonNull a -> String -> (source -> a) -> List ( String, Arg.Value source ) -> List ( String, Arg.Value source )
withRequiredParam toVar name selector =
    (::) ( name, Arg.variable <| Var.required name selector toVar )
