module Schemas.Mutations exposing (RemovePayload, UserCreatePayload, UserUpdatePayload, createUser, removeUser, updateUser)

-- PLEASE KEEP THIS FILE IN ALPHABETICAL ORDER TO MAKE FINDING THINGS EASIER

import Api.Mutation as Mutation exposing (MutationResult, withRequiredString)
import Api.Query as Query
import GraphQL.Request.Builder as GraphQL exposing (..)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Schemas.Specs exposing (..)
import Schemas.Types exposing (..)



-- USERS


type alias UserCreatePayload a =
    { a
        | firstName : String
        , lastName : String
        , email : String
        , role : String
        , password : String
        , passwordConfirmation : String
    }


type alias UserUpdatePayload a =
    { a
        | id : String
        , firstName : String
        , lastName : String
        , email : String
        , role : String
    }


type alias RemovePayload a =
    { a | id : String }


createUser : Document Mutation (MutationResult User) (UserCreatePayload a)
createUser =
    Mutation.payload
        |> withRequiredString "firstName" .firstName
        |> withRequiredString "lastName" .lastName
        |> withRequiredString "email" .email
        |> withRequiredString "role" .role
        |> withRequiredString "password" .password
        |> withRequiredString "passwordConfirmation" .passwordConfirmation
        |> Mutation.toDocument "createUser" userSpec


updateUser : Document Mutation (MutationResult User) (UserUpdatePayload a)
updateUser =
    Mutation.payload
        |> withRequiredString "id" .id
        |> withRequiredString "firstName" .firstName
        |> withRequiredString "lastName" .lastName
        |> withRequiredString "email" .email
        |> withRequiredString "role" .role
        |> Mutation.toDocument "updateUser" userSpec


removeUser : Document Mutation (MutationResult User) (RemovePayload a)
removeUser =
    Mutation.payload
        |> withRequiredString "id" .id
        |> Mutation.toDocument "removeUser" userSpec
