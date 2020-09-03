module Context exposing(Context)


import Time
import Config exposing(Config)
import Session exposing(Session)


type alias Context =
  { timeZone : Time.Zone
  , config : Config
  , session : Session
  }
