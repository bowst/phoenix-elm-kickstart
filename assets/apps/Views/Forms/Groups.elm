module Views.Forms.Groups exposing (GroupBuilder, checkboxGroup, dateGroup, formGroup, multiGroup, multiSelect, multiSelectGrouped, multiSelectToValue, numberGroup, onEnter, radioButtonGroup, radioButtonGroupLike, radioGroup, selectGroup, selectMarkup, submitTextGroup, textAreaGroup, textGroup, typeaheadGroup)

-- Core
-- Libraries
-- Project Modules
-- Libraries
-- Project Modules

import Dict exposing (Dict)
import Form exposing (FieldState, Form, InputType(..), Msg(..))
import Form.Error as Error exposing (Error, ErrorValue(..))
import Form.Field as Field exposing (Field, FieldValue(..))
import Form.Input as Input exposing (Input)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Json
import Json.Encode as Encode
import Views.Forms.Errors exposing (..)
import Views.Forms.Typeahead exposing (..)
import Views.Icons exposing (icon)


onEnter : msg -> Attribute msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg

            else
                Json.fail "not ENTER"
    in
    on "keydown" (Json.andThen isEnter keyCode)


type alias GroupBuilder a =
    String -> Html Form.Msg -> FieldState () a -> Html Form.Msg


formGroup : Html Form.Msg -> String -> Maybe (ErrorValue a) -> List (Html Form.Msg) -> Html Form.Msg
formGroup label_ classes maybeError inputs =
    div
        [ class ("field " ++ errorClass maybeError ++ " " ++ classes) ]
        [ label [ class "label" ] [ label_ ]
        , div [] inputs
        , div [] [ errorMessage maybeError ]
        ]


multiGroup : List (Attribute Form.Msg) -> List (Html Form.Msg) -> Html Form.Msg
multiGroup attr content =
    div ([ class "flex-layout" ] ++ attr) content


textGroup : GroupBuilder String
textGroup classes label_ state =
    formGroup label_
        classes
        state.liveError
        [ Input.textInput state
            [ value (Maybe.withDefault "" state.value)
            , class "input"
            ]
        ]


submitTextGroup : GroupBuilder String
submitTextGroup classes label_ state =
    formGroup label_
        classes
        state.liveError
        [ Input.textInput state
            [ value (Maybe.withDefault "" state.value)
            , onEnter Form.Submit
            , class "input"
            ]
        ]


numberGroup : GroupBuilder String
numberGroup classes label_ state =
    formGroup label_
        classes
        state.liveError
        [ Input.baseInput "number"
            Field.String
            Form.Text
            state
            [ value (Maybe.withDefault "" state.value)
            ]
        ]


dateGroup : GroupBuilder String
dateGroup classes label_ state =
    formGroup label_
        classes
        state.liveError
        [ Input.baseInput "date"
            Field.String
            Form.Text
            state
            [ value (Maybe.withDefault "" state.value)
            , placeholder "yyyy-mm-dd"
            ]
        ]


textAreaGroup : GroupBuilder String
textAreaGroup classes label_ state =
    formGroup label_
        classes
        state.liveError
        [ Input.textArea state
            [ value (Maybe.withDefault "" state.value)
            ]
        ]


checkboxGroup : GroupBuilder Bool
checkboxGroup classes label_ state =
    formGroup (text "")
        classes
        state.liveError
        [ div
            [ class "checkbox" ]
            [ label []
                [ Input.checkboxInput state []
                , label_
                ]
            ]
        ]



-- Typeahead


typeaheadGroup : String -> GroupBuilder String
typeaheadGroup apiUrl classes label_ state =
    let
        typeaheadValue =
            case state.value of
                Just value ->
                    case Json.decodeString decodeTypeaheadValue value of
                        Ok decoded ->
                            decoded

                        Err err ->
                            { id = "", name = "" }

                Nothing ->
                    { id = "", name = "" }
    in
    formGroup label_
        classes
        state.liveError
        [ Html.node "type-ahead"
            [ property "typeaheadValue" (encodeTypeaheadValue typeaheadValue)
            , property "apiUrl" (Encode.string apiUrl)
            , onFocus (Focus state.path)
            , onBlur (Blur state.path)
            , on "autocompleteChanged" (Json.map (String >> Input state.path Select) decodeTypeaheadChangeEvent)
            ]
            []
        ]


selectGroup : List ( String, String ) -> GroupBuilder String
selectGroup options classes label_ state =
    let
        onChange =
            Json.map (Input state.path Select << String) targetValue

        markup =
            selectMarkup onChange state.path (Maybe.withDefault "" state.value) options
    in
    formGroup label_ classes state.liveError [ markup ]


multiSelect : List ( String, String ) -> GroupBuilder String
multiSelect options classes label_ state =
    let
        getOption id =
            options
                |> Dict.fromList
                |> Dict.get id

        currentValue =
            case state.value of
                Just val ->
                    String.split "," val

                Nothing ->
                    []

        onInput =
            String >> Input state.path Select

        onAdd =
            targetValue
                |> Json.map
                    (\v ->
                        currentValue
                            ++ [ v ]
                            |> String.join ","
                            |> onInput
                    )

        removeItem item =
            currentValue
                |> List.filter ((/=) item)
                |> String.join ","
                |> onInput

        availableOptions =
            options
                |> List.filter (\( v, item ) -> not (List.member v currentValue))

        dropdown =
            selectMarkup onAdd state.path "" availableOptions

        selectedItems =
            currentValue
                |> List.filterMap
                    (\v ->
                        getOption v
                            |> Maybe.map (\item -> ( v, item ))
                    )
                |> List.map
                    (\( v, item ) ->
                        span
                            [ class "typeahead-item" ]
                            [ text item
                            , i
                                [ class "fas fa-times"
                                , onClick (removeItem v)
                                ]
                                []
                            ]
                    )
    in
    formGroup label_ classes state.liveError (dropdown :: selectedItems)


selectMarkup : Json.Decoder Form.Msg -> String -> String -> List ( String, String ) -> Html Form.Msg
selectMarkup onChange path val options =
    let
        buildOption ( k, v ) =
            option [ value k, selected (val == k) ] [ text v ]
    in
    div [ class "select" ]
        [ select
            [ onFocus (Focus path)
            , onBlur (Blur path)
            , on "change" onChange
            , value val
            ]
            (option [ value "" ] [ text "-- Select --" ] :: List.map buildOption options)
        ]


filterGroupedOptions : List ( String, List ( String, String ) ) -> List String -> List ( String, List ( String, String ) )
filterGroupedOptions groupedOptions currentValue =
    groupedOptions
        |> List.map
            (\( lbl, opts ) ->
                let
                    filteredOpts =
                        opts
                            |> List.filter (\( v, item ) -> not (List.member v currentValue))
                in
                ( lbl, filteredOpts )
            )


multiSelectGrouped : List ( String, List ( String, String ) ) -> GroupBuilder String
multiSelectGrouped groupedOptions classes label_ state =
    let
        flattenedOptionList =
            groupedOptions
                |> List.concatMap
                    (\( lbl, opts ) ->
                        opts
                    )

        getOption id =
            flattenedOptionList
                |> Dict.fromList
                |> Dict.get id

        currentValue : List String
        currentValue =
            case state.value of
                Just val ->
                    String.split "," val

                Nothing ->
                    []

        onInput =
            String >> Input state.path Select

        onAdd =
            targetValue
                |> Json.map
                    (\v ->
                        currentValue
                            ++ [ v ]
                            |> String.join ","
                            |> onInput
                    )

        removeItem item =
            currentValue
                |> List.filter ((/=) item)
                |> String.join ","
                |> onInput

        filteredOptions =
            filterGroupedOptions groupedOptions currentValue

        dropdown =
            selectMarkupGrouped onAdd state.path "" filteredOptions

        selectedItems =
            currentValue
                |> List.filterMap
                    (\v ->
                        getOption v
                            |> Maybe.map (\item -> ( v, item ))
                    )
                |> List.map
                    (\( v, item ) ->
                        span
                            [ class "typeahead-item" ]
                            [ text item
                            , i
                                [ class "fas fa-times"
                                , onClick (removeItem v)
                                ]
                                []
                            ]
                    )
    in
    formGroup label_ classes state.liveError (dropdown :: selectedItems)


selectMarkupGrouped : Json.Decoder Form.Msg -> String -> String -> List ( String, List ( String, String ) ) -> Html Form.Msg
selectMarkupGrouped onChange path val groupedOptions =
    let
        buildOption ( k, v ) =
            option [ value k, selected (val == k) ] [ text v ]

        buildOptionGroup ( lbl, opts ) =
            optgroup [ attribute "label" lbl ] <|
                List.map buildOption opts
    in
    div [ class "styled-select" ]
        [ select
            [ onFocus (Focus path)
            , onBlur (Blur path)
            , on "change" onChange
            , value val
            ]
            (option [ value "" ] [ text "-- Select --" ] :: List.map buildOptionGroup groupedOptions)
        , icon "chevron-down"
        ]


multiSelectToValue : (entity -> String) -> List entity -> Field
multiSelectToValue toValue entities =
    entities
        |> List.map toValue
        |> String.join ","
        |> Field.string


radioGroup : List ( String, String ) -> GroupBuilder String
radioGroup options classes label_ state =
    let
        item ( v, l ) =
            label
                [ class "radio-inline" ]
                [ Input.radioInput v state []
                , text l
                ]
    in
    formGroup label_
        classes
        state.liveError
        (List.map item options)


radioButtonGroup : List ( String, String ) -> GroupBuilder String
radioButtonGroup options classes label_ state =
    let
        generateMsg =
            String >> Input state.path Select

        onInput item =
            if Just item == state.value then
                generateMsg ""

            else
                generateMsg item

        buttons =
            options
                |> List.map
                    (\( itemId, name ) ->
                        a
                            [ classList [ ( "selected", state.value == Just itemId ) ]
                            , onClick (onInput itemId)
                            ]
                            [ span []
                                [ text name ]
                            ]
                    )
                |> span [ class "action-icons" ]
    in
    formGroup label_ classes state.liveError [ buttons ]



-- Select Multiple


radioButtonGroupLike : GroupBuilder Bool
radioButtonGroupLike classes label_ state =
    let
        onInput bool =
            if Just bool == state.value then
                Input state.path Select EmptyField

            else
                Input state.path Select (Bool bool)

        buttons =
            [ div
                [ classList [ ( "selected", state.value == Just True ) ]
                , onClick <| onInput True
                , class "yes-no"
                ]
                [ div [ class "radio" ]
                    [ i [ class "far fa-thumbs-up" ] []
                    ]
                ]
            , div
                [ classList [ ( "selected", state.value == Just False ) ]
                , onClick <| onInput False
                , class "yes-no"
                ]
                [ div [ class "radio" ]
                    [ i [ class "far fa-thumbs-down" ] []
                    ]
                ]
            ]
    in
    formGroup label_ "yes-no-wrap" state.liveError buttons
