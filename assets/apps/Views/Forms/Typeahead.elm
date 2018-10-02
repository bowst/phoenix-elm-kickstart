module Views.Forms.Typeahead exposing (TypeaheadValue, TypeaheadValueBase, decodeTypeaheadChangeEvent, decodeTypeaheadValue, encodeTypeaheadValue, fromTypeaheadValue, getTypeaheadValue, toTypeaheadValue, validateTypeahead)

-- Libraries

import Form exposing (FieldState, Form)
import Form.Error as Error exposing (Error, ErrorValue(..))
import Form.Field as Field exposing (Field, FieldValue(..))
import Form.Validate as Vd exposing (Validation)
import Json.Decode as Json
import Json.Encode as Encode


type alias TypeaheadValueBase a =
    { a | id : String, name : String }


type alias TypeaheadValue =
    { id : String, name : String }


decodeTypeaheadValue : Json.Decoder TypeaheadValue
decodeTypeaheadValue =
    Json.map2 TypeaheadValue
        (Json.field "id" Json.string)
        (Json.field "name" Json.string)


encodeTypeaheadValue : TypeaheadValueBase a -> Encode.Value
encodeTypeaheadValue v =
    Encode.object
        [ ( "id", Encode.string v.id )
        , ( "name", Encode.string v.name )
        ]


decodeTypeaheadChangeEvent : Json.Decoder String
decodeTypeaheadChangeEvent =
    Json.at [ "detail" ] decodeTypeaheadValue
        |> Json.map toTypeaheadValue


toTypeaheadValue : TypeaheadValueBase a -> String
toTypeaheadValue v =
    encodeTypeaheadValue v
        |> Encode.encode 0


fromTypeaheadValue : String -> String
fromTypeaheadValue value =
    Json.decodeString decodeTypeaheadValue value
        |> Result.map .id
        |> Result.withDefault ""


getTypeaheadValue : FieldState e String -> String
getTypeaheadValue fieldState =
    case fieldState.value of
        Just toDecode ->
            fromTypeaheadValue toDecode

        Nothing ->
            ""


validateTypeahead : Validation e String
validateTypeahead v =
    case Field.asString v of
        Just toDecode ->
            Json.decodeString decodeTypeaheadValue toDecode
                |> Result.map .id
                |> Result.mapError (always <| Error.value InvalidString)

        Nothing ->
            Ok ""
