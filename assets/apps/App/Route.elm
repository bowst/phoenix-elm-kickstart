module App.Route exposing (Route(..), fromUrl, href, replaceUrl)

import App.Pages.Users as User
import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, oneOf, s, string)
import Url.Parser.Query as Query


type Route
    = Dashboard
    | UserRoute User.Route


parser : Parser (Route -> a) a
parser =
    s "app" </> routeParser


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ Parser.map Dashboard Parser.top
        , Parser.map UserRoute (s "users" </> User.parser)
        ]



-- PUBLIC HELPERS --


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    -- We treat the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    -- { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    Parser.parse parser url



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let
        ( pieces, query ) =
            case page of
                Dashboard ->
                    ( [], "" )

                UserRoute subRoute ->
                    User.routeToParts subRoute
                        |> Tuple.mapFirst ((::) "users")
    in
    "/app/" ++ String.join "/" pieces
