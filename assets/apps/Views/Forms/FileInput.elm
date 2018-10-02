port module Views.Forms.FileInput exposing (File, UploadStatus(..), UploadType(..), fileGroup, selected, uploadStatus)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode exposing (Value)
import Views.Icons exposing (icon, iconWithSize)


type UploadStatus
    = UploadNotStarted
    | UploadPending
    | UploadSuccess File
    | UploadFailure


type UploadType
    = Image
    | Document


type alias UploadPayload =
    { id : String
    , path : String
    , userId : Maybe String
    }


type alias UploadResponse =
    { id : String
    , ok : Bool
    , uri : String
    , url : String
    }


type alias File =
    { uri : String
    , url : String
    }


port fileSelected : Value -> Cmd msg


port fileUploadStatus : (Value -> msg) -> Sub msg


selected : UploadPayload -> Cmd msg
selected payload =
    let
        value =
            Encode.object
                [ ( "id", Encode.string payload.id )
                , ( "path", Encode.string payload.path )
                , ( "userId", payload.userId |> Maybe.map Encode.string |> Maybe.withDefault Encode.null )
                ]
    in
    fileSelected value


uploadStatus : (String -> UploadStatus -> msg) -> Sub msg
uploadStatus toMsg =
    let
        conversion value =
            case Decode.decodeValue decodeUploadResponse value of
                Ok response ->
                    if response.ok then
                        toMsg response.id (UploadSuccess { uri = response.uri, url = response.url })

                    else
                        toMsg response.id UploadFailure

                Err error ->
                    let
                        reporting =
                            Debug.log "Error decoding upload response: " error
                    in
                    toMsg "" UploadFailure
    in
    fileUploadStatus conversion


decodeUploadResponse : Decode.Decoder UploadResponse
decodeUploadResponse =
    Decode.map4 UploadResponse
        (Decode.field "id" Decode.string)
        (Decode.field "ok" Decode.bool)
        (Decode.field "uri" Decode.string)
        (Decode.field "url" Decode.string)


fileGroup : UploadType -> String -> String -> (String -> msg) -> (String -> UploadStatus -> msg) -> UploadStatus -> Html msg
fileGroup uploadType label_ id_ onChange onUpdate status =
    let
        control =
            case status of
                UploadNotStarted ->
                    case uploadType of
                        Image ->
                            div [ class "photo" ]
                                [ a [ class "btn btn-orange", attribute "data-target-id" id_, id <| "trigger-" ++ id_ ]
                                    [ text "Choose File" ]
                                , input
                                    [ id id_
                                    , type_ "file"
                                    , on "change" (Decode.succeed <| onChange id_)
                                    , accept ".jpg,.jpeg,.png"
                                    ]
                                    []
                                ]

                        Document ->
                            input
                                [ id id_
                                , type_ "file"
                                , on "change" (Decode.succeed <| onChange id_)
                                , accept ".pdf"
                                ]
                                []

                UploadPending ->
                    case uploadType of
                        Image ->
                            div [ class "photo" ]
                                [ i [ class "fas fa-circle-notch fa-spin fa-3x" ] []
                                ]

                        Document ->
                            div [] [ text "Uploading..." ]

                UploadSuccess response ->
                    case uploadType of
                        Image ->
                            div [ class "photo" ]
                                [ img [ src response.url ]
                                    []
                                , span [ class "close", onClick <| onUpdate id_ UploadNotStarted ]
                                    [ icon "times"
                                    ]
                                ]

                        Document ->
                            span []
                                [ a [ class "remove", onClick <| onUpdate id_ UploadNotStarted ] [ text "Remove" ]
                                , a [ href response.url, target "_blank" ] [ text <| getFilenameFromUri response.uri ]
                                ]

                UploadFailure ->
                    div [] [ text "Upload Failed" ]
    in
    div
        [ class "form-group upload-file" ]
        [ label [ class "control-label" ] [ text label_ ]
        , div []
            [ control ]
        ]


getFilenameFromUri : String -> String
getFilenameFromUri uri =
    String.split "/" uri
        |> List.reverse
        |> List.head
        |> Maybe.withDefault "Uploaded File"
