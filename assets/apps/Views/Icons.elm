module Views.Icons exposing (icon, iconWithSize, brandIcon, brandIconWithSize)

import Html exposing (Html, i, text)
import Html.Attributes exposing (class)


iconWithSize : String -> String -> Html msg
iconWithSize faIcon size =
    i [ class ("fas fa-" ++ faIcon ++ " fa-" ++ size) ] []


brandIconWithSize : String -> String -> Html msg
brandIconWithSize faIcon size =
    i [ class ("fab fa-" ++ faIcon ++ " fa-" ++ size) ] []


icon : String -> Html msg
icon faIcon =
    iconWithSize faIcon "sm"


brandIcon : String -> Html msg
brandIcon faIcon =
    brandIconWithSize faIcon "sm"
