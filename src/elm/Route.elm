module Route exposing (Route(..), urlToRoute)


import Url
import Url.Parser as Parser exposing (oneOf, s, top, (</>), string)


type Route
  = Home
  | PublicArticles
  | DraftArticles
  | CreateArticle
  | EditArticle String


urlToRoute : Url.Url -> Maybe Route
urlToRoute url =
  let
    parser =
      oneOf
        [ Parser.map Home top
        , Parser.map PublicArticles (s "articles" </> s "public")
        , Parser.map DraftArticles (s "articles" </> s "draft")
        , Parser.map CreateArticle (s "editor")
        , Parser.map EditArticle (s "editor" </> string)
        ]
  in
  Parser.parse parser url
