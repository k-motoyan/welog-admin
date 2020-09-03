module Page.Home exposing(Model, init, Msg, update, view)


import Html exposing(..)


type alias Model = {}


init : ( Model, Cmd Msg )
init =
  ( {}, Cmd.none )



type Msg
  = Dummy


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
  case msg of
    Dummy ->
      ( model, Cmd.none )


view : { title : String, content : Html msg }
view =
    { title = "Home"
    , content = text "Home"
    }
