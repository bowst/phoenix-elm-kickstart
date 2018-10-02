module Schemas.Specs exposing (userSpec)

-- PLEASE KEEP THIS FILE IN ALPHABETICAL ORDER TO MAKE FINDING THINGS EASIER
{--
    Schema Levels

    * summary - basic info for inclusion in other models, e.g. typically just id and name
    * overview - a bit more info, for use in list views
    * detail - All schema information, used for populating the edit form
    * full - All schema information, but lots more associations.  For use on the schema detail page
--}

import GraphQL.Request.Builder as GraphQL exposing (..)
import Schemas.Types exposing (..)



-- User


userSpec : ValueSpec NonNull ObjectType User vars
userSpec =
    object User
        |> with (field "id" [] string)
        |> with (field "email" [] string)
        |> with (field "firstName" [] string)
        |> with (field "lastName" [] string)
        |> with (field "role" [] string)
