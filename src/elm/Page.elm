module Page exposing( Page(..)
                    , initHome
                    , initPublicArticles
                    , initDraftArticles
                    , initNewEditor
                    , initModifyEditor
                    , updateHome
                    , updateArticles
                    , updateEditor
                    )


import Page.Home as Home
import Page.Articles as Articles exposing(Mode(..))
import Page.Editor as Editor
import Context exposing(Context)


type Page
  = Home Home.Model
  | Articles Articles.Model
  | Editor Editor.Model
  | NotFound


initHome : Context -> (Home.Msg -> msg) -> (Page, Cmd msg)
initHome context parentMsg =
  Home.init
    |> Tuple.mapBoth
      (\model -> Home model)
      (\cmd -> Cmd.map parentMsg cmd)


initPublicArticles : Context -> (Articles.Msg -> msg) -> (Page, Cmd msg)
initPublicArticles context parentMsg =
  Articles.init context Articles.Public
    |> Tuple.mapBoth
      (\model -> Articles model)
      (\cmd -> Cmd.map parentMsg cmd)


initDraftArticles : Context -> (Articles.Msg -> msg) -> (Page, Cmd msg)
initDraftArticles context parentMsg =
  Articles.init context Articles.Draft
    |> Tuple.mapBoth
      (\model -> Articles model)
      (\cmd -> Cmd.map parentMsg cmd)


initNewEditor : Context -> (Editor.Msg -> msg) -> (Page, Cmd msg)
initNewEditor context parentMsg =
  Editor.init context Nothing
    |> Tuple.mapBoth
      (\model -> Editor model)
      (\cmd -> Cmd.map parentMsg cmd)


initModifyEditor : Context -> String -> (Editor.Msg -> msg) -> (Page, Cmd msg)
initModifyEditor context uid parentMsg =
  Editor.init context (Just uid)
    |> Tuple.mapBoth
      (\model -> Editor model)
      (\cmd -> Cmd.map parentMsg cmd)


updateHome : Home.Model -> Home.Msg -> ( Home.Model, Cmd Home.Msg )
updateHome model msg =
  Home.update msg model


updateArticles : Articles.Model -> Articles.Msg -> ( Articles.Model, Cmd Articles.Msg )
updateArticles model msg =
  Articles.update msg model


updateEditor : Editor.Model -> Editor.Msg -> ( Editor.Model, Cmd Editor.Msg )
updateEditor model msg =
  Editor.update msg model
