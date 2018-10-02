-- HELPERS


module Api.Specs exposing (date)

import GraphQL.Request.Builder as GraphQL exposing (..)
import Json.Decode as Decode


date : ValueSpec NonNull StringType Date vars
date =
    map toDate string
