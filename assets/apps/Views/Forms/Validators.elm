module Views.Forms.Validators exposing (afterDate, afterOrEqualDate, beforeDate, beforeOrEqualDate, containsMinItems, date, greaterThanFloat, greaterThanInt, numericString, positiveFloat, positiveInt, validateMultiSelect, validateRequiredMultiSelect)

-- Core
-- Libraries

import Date exposing (Date)
import Date.Extra as Date
import Form exposing (Form)
import Form.Error as Error exposing (Error, ErrorValue(..))
import Form.Field as Field exposing (Field, FieldValue(..))
import Form.Validate as Vd exposing (Validation)
import Regex
import Result exposing (Result(..))


validateMultiSelect : Validation e (List String)
validateMultiSelect v =
    case Field.asString v of
        Just s ->
            if String.isEmpty s then
                Ok []

            else
                -- Filter out empty values
                String.split "," s
                    |> List.filter ((/=) "")
                    |> Ok

        Nothing ->
            Ok []


validateRequiredMultiSelect : Validation e (List String)
validateRequiredMultiSelect v =
    case Field.asString v of
        Just s ->
            if String.isEmpty s then
                Ok []

            else
                -- Filter out empty values
                String.split "," s
                    |> List.filter ((/=) "")
                    |> Ok

        Nothing ->
            Err <| Error.value Empty


containsMinItems : Int -> List a -> Validation e (List a)
containsMinItems i v field =
    if List.length v >= i then
        Ok v

    else
        Err (Error.value Empty)


positiveFloat : Validation e Float
positiveFloat =
    greaterThanFloat 0


greaterThanFloat : Float -> Validation e Float
greaterThanFloat num =
    Vd.customValidation Vd.float
        (\val ->
            if val > num then
                Ok val

            else
                Err <| Error.value <| SmallerOrEqualFloatThan 0
        )


positiveInt : Validation e Int
positiveInt =
    greaterThanInt 0


greaterThanInt : Int -> Validation e Int
greaterThanInt num =
    Vd.customValidation Vd.int
        (\val ->
            if val > num then
                Ok val

            else
                Err <| Error.value <| SmallerOrEqualIntThan 0
        )



-- This validator is different from the built-in Form.Validate.date validation.
-- This uses Date.Extra.fromIsoString which will return a Date object at 00:00 on the date supplied
-- The native Date.fromString method will assume, without a time, that the date passed is UTC+0 at 00:00
-- It then will subtract hours based on your current locale (impure). Since we are UTC-4, this results
-- in a day being subtracted


date : Validation e Date
date fieldValue =
    case Field.asString fieldValue of
        Just s ->
            Date.fromIsoString s
                |> Result.mapError (always (Error.value InvalidDate))

        Nothing ->
            Err (Error.value InvalidDate)


afterOrEqualDate : Maybe Date -> Validation e Date
afterOrEqualDate toCompare =
    Vd.customValidation date
        (\val ->
            case toCompare of
                Just dateCompare ->
                    if Date.compare val dateCompare == LT then
                        Err (Error.value InvalidDate)

                    else
                        Ok val

                Nothing ->
                    Err (Error.value InvalidDate)
        )


afterDate : Maybe Date -> Validation e Date
afterDate toCompare =
    Vd.customValidation date
        (\val ->
            case toCompare of
                Just dateCompare ->
                    if Date.compare val dateCompare == GT then
                        Ok val

                    else
                        Err (Error.value InvalidDate)

                Nothing ->
                    Err (Error.value InvalidDate)
        )


beforeOrEqualDate : Maybe Date -> Validation e Date
beforeOrEqualDate toCompare =
    Vd.customValidation date
        (\val ->
            case toCompare of
                Just dateCompare ->
                    if Date.compare val dateCompare == GT then
                        Err (Error.value InvalidDate)

                    else
                        Ok val

                Nothing ->
                    Err (Error.value InvalidDate)
        )


beforeDate : Maybe Date -> Validation e Date
beforeDate toCompare =
    Vd.customValidation date
        (\val ->
            case toCompare of
                Just dateCompare ->
                    if Date.compare val dateCompare == LT then
                        Ok val

                    else
                        Err (Error.value InvalidDate)

                Nothing ->
                    Err (Error.value InvalidDate)
        )


numericString : Validation e String
numericString =
    Vd.customValidation Vd.string
        (\val ->
            let
                exp =
                    Regex.regex "^[0-9]{1,}\\b"
            in
            if Regex.contains exp val then
                Ok val

            else
                Err <| Error.value InvalidString
        )
