module Schemas.Types exposing (User)

-- PLEASE KEEP THIS FILE IN ALPHABETICAL ORDER TO MAKE FINDING THINGS EASIER
{--
    Schema Levels

    * summary - basic info for inclusion in other models, e.g. typically just id and name
    * overview - a bit more info, for use in list views
    * detail - All schema information, used for populating the edit form
    * full - All schema information, but lots more associations.  For use on the schema detail page
--}
-- USER


type alias User =
    { id : String
    , email : String
    , firstName : String
    , lastName : String
    , role : String
    }
