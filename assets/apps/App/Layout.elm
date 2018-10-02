module App.Layout exposing (sidebar, toolbar)

import App.Pages.Users as User
import App.Route as Route exposing (Route(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Schemas.Selectors as Select
import Schemas.Types exposing (User)


toolbar : User -> Html msg
toolbar user =
    nav [ class "navbar is-primary" ]
        [ div [ class "navbar-brand" ]
            [ a [ class "navbar-item", href "#" ]
                [ text "Quiver"
                ]
            ]
        , div [ class "navbar-end" ]
            [ div [ class "navbar-item has-dropdown is-hoverable" ]
                [ a [ class "navbar-link" ]
                    [ text <| Select.fullname user ]
                , div [ class "navbar-dropdown is-right" ]
                    [ a [ class "navbar-item", href "/logout" ]
                        [ text "Logout" ]
                    ]
                ]
            ]
        ]


sidebar =
    aside [ class "menu " ]
        [ p [ class "menu-label" ]
            [ text "General" ]
        , ul [ class "menu-list" ]
            [ li []
                [ a [ Route.href <| Dashboard ]
                    [ text "Dashboard" ]
                ]
            ]
        , p [ class "menu-label" ]
            [ text "Admin" ]
        , ul [ class "menu-list" ]
            [ li []
                [ a [ Route.href <| UserRoute (User.listRoute Nothing) ]
                    [ text "Users" ]
                ]
            ]
        ]
