module Page.Articles exposing(Mode(..), Model, init, Msg, update, view)


import Time exposing(millisToPosix)
import Date exposing(fromPosix, format)
import Html exposing(..)
import Html.Attributes exposing(..)
import Html.Events exposing(..)
import Graphql.Http exposing(Error, mapError)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Schema.Blog.Query as Query
import Schema.Blog.Object
import Schema.Blog.Object.Article as Article
import RemoteData exposing(RemoteData(..), fromResult)
import Request exposing(BaseUrl, AccessToken, makeRequestBase, makeAuthRequestBase)
import Context exposing(Context)
import Error exposing(errorModal)


type alias ArticleData =
    { uid : String
    , title : String
    , modifiedAt : Int
    }


articleSelection : SelectionSet ArticleData Schema.Blog.Object.Article
articleSelection =
    SelectionSet.map3 ArticleData
        Article.uid
        Article.title
        Article.modified_at


fetch : BaseUrl -> AccessToken -> Mode -> Cmd Msg
fetch baseUrl accessToken mode =
  let
    query =
      case mode of
        Public -> Query.publicArticles articleSelection
        Draft -> Query.draftArticles articleSelection

    baseRequest =
      case mode of
        Public ->
          query |> makeRequestBase baseUrl

        Draft ->
          query |> makeAuthRequestBase baseUrl accessToken
  in
  baseRequest
    |> Graphql.Http.send (fromResult >> GotResponse)


type alias FetchResponse = RemoteData (Error (List ArticleData)) (List ArticleData)


type Mode = Public | Draft

type alias Model =
  { context : Context
  , mode : Mode
  , response : FetchResponse
  , error : Maybe (Error ())
  }


init : Context -> Mode -> (Model, Cmd Msg)
init context mode =
  let
    model = Model context mode Loading Nothing
    cmd = fetch context.config.apiUrl context.session.accessToken mode
  in
  ( model, cmd )


type Msg
  = GotResponse FetchResponse
  | RemoveError


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    GotResponse response ->
      case response of
        Failure error ->
          let
            error_ = mapError (\_ -> ()) error
          in
          ( { model | response = response, error = Just error_ }, Cmd.none )

        _ ->
          ( { model | response = response }, Cmd.none )

    RemoveError ->
      ( { model | error = Nothing }, Cmd.none )


view : Model -> { title : String, content : Html Msg }
view model =
  let
    title =
      case model.mode of
        Public -> "Public Articles"
        Draft  -> "Draft Articles"

    view_ =
      div []
        [ errorModal model.error RemoveError
        , h1 [ class "title" ] [ text title]
        , content model
        ]
  in
  { title = title, content = view_ }


content : Model -> Html Msg
content model =
  case model.response of
    NotAsked ->
      p [] [ text "request not yet." ]

    Loading ->
      p [] [ text "Now loading..." ]

    Failure _ ->
      div [] []

    Success articles ->
      if List.isEmpty articles then
        p [] [ text "Not posted yet." ]
      else
        let
          listItem_ = listItem model.context.timeZone
        in
        ul []
          <| List.map listItem_ articles


listItem : Time.Zone -> ArticleData -> Html Msg
listItem timeZone article =
  let
    lastModified =
      millisToPosix (article.modifiedAt * 1000)
        |> fromPosix timeZone
        |> format "y / MM / dd"
  in
  li [ class "level" ]
    [ div [ class "level-left" ]
      [ a [ class "level-item", href ("/editor/" ++ article.uid) ] [ text article.title ] ]
    , div [ class "level-right" ]
      [ span [ class "level-item has-text-grey is-size-7" ] [ text ("last modified at - " ++ lastModified) ]
      ]
    ]