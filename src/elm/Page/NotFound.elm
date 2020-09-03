module Page.NotFound exposing(view)


import Html exposing (..)


view : { title : String, content : Html msg }
view =
    { title = "NotFound"
    , content = text "Page not found."
    }
