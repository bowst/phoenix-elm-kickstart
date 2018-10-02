module Views.Forms.Helpers exposing (addStringField)

import Form.Field as Field exposing (Field)


addStringField : String -> Maybe String -> List ( String, Field ) -> List ( String, Field )
addStringField name maybeVal fields =
    case maybeVal of
        Just val ->
            ( name, Field.string val ) :: fields

        Nothing ->
            fields
