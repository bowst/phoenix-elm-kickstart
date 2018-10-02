module App.Session exposing (Msg, Session, init, subscriptions, update)

import Browser.Navigation exposing (Key)
import Schemas.Types exposing (User)
import Task
import Time exposing (Posix)


type alias Session =
    { user : User
    , now : Posix
    , navKey : Key
    }


init : Key -> User -> ( Session, Cmd Msg )
init key user =
    let
        nextModel =
            { user = user
            , now = Time.millisToPosix 0
            , navKey = key
            }
    in
    ( nextModel, Task.perform Tick Time.now )


type Msg
    = Tick Posix


update : Msg -> Session -> Session
update msg model =
    case msg of
        Tick time ->
            { model | now = time }


subscriptions : Session -> Sub Msg
subscriptions model =
    Time.every (60 * 1000) Tick
