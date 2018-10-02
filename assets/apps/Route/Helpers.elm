module Route.Helpers exposing (apply)

import Url.Parser.Query as Parser exposing (Parser, map2)



-- For Pipeline operations


apply : Parser a -> Parser (a -> b) -> Parser b
apply argParser funcParser =
    map2 (<|) funcParser argParser
