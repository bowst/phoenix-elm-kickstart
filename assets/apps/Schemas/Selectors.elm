module Schemas.Selectors exposing (fullname, userRole)

import String.Extra exposing (humanize)


fullname : { b | firstName : String, lastName : String } -> String
fullname { firstName, lastName } =
    firstName ++ " " ++ lastName


userRole : { b | role : String } -> String
userRole { role } =
    humanize role
