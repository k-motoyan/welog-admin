module Main exposing(..)


import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Dict
import Task exposing(Task)
import Time exposing(Zone, customZone, getZoneName)
import TimeZone exposing(Error(..), zones)
import Page exposing (Page(..), initHome, initPublicArticles, initDraftArticles, initNewEditor, initModifyEditor, updateHome, updateArticles, updateEditor)
import Page
import Page.Home as Home
import Page.Articles as Articles
import Page.Editor as Editor
import Page.NotFound as NotFound
import Route exposing(Route(..), urlToRoute)
import Context exposing(Context)
import Config exposing(Config)
import Session exposing(Session)
import Request exposing(BaseUrl(..), AccessToken(..))


-- MAIN


main : Program Flags Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }



-- MODEL


type alias Model =
  { key : Nav.Key
  , page : Page
  , context : Context
  }


type alias Flags =
  { blogTitle : String
  , apiUrl : String
  , idToken : String
  }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  let
    initCmd =
      getTimeZone
        |> Task.map (\zone -> (url, zone))
        |> Task.perform InitializeApp

    config = Config flags.blogTitle (BaseUrl flags.apiUrl)

    session = Session (AccessToken flags.idToken)

    model = Model key NotFound (Context Time.utc config session)
  in
  ( model, initCmd )


getTimeZone : Task Never Zone
getTimeZone =
  Time.getZoneName
    |> Task.andThen
      (\nameOrOffset ->
        case nameOrOffset of
          Time.Name zoneName ->
            case Dict.get zoneName zones of
              Just zone ->
                Task.succeed (zone ())

              Nothing ->
                Task.succeed (customZone 0 []) -- UTC

          Time.Offset offset ->
            Task.succeed (customZone offset [])
      )


initPage : Url.Url -> Context -> (Page, Cmd Msg)
initPage url context =
  case urlToRoute url of
    Just Route.Home ->
      initHome context HomeMsg

    Just Route.PublicArticles ->
      initPublicArticles context ArticlesMsg

    Just Route.DraftArticles ->
      initDraftArticles context ArticlesMsg

    Just Route.CreateArticle ->
      initNewEditor context EditorMsg

    Just (Route.EditArticle uid) ->
      initModifyEditor context uid EditorMsg

    Nothing ->
      ( Page.NotFound, Cmd.none )


-- UPDATE


type Msg
  = InitializeApp (Url.Url, Time.Zone)
  | LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | HomeMsg Home.Msg
  | ArticlesMsg Articles.Msg
  | EditorMsg Editor.Msg
  | Nop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    InitializeApp (url, timeZone) ->
      let
        context = model.context
        context_ = { context | timeZone = timeZone }       

        (page, cmd) = initPage url context_
      in
      ( { model | page = page, context = context_ }, cmd )

    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

    UrlChanged url ->
      let
        ( page, cmd ) = initPage url model.context
      in
      ( { model | page = page }, cmd )

    HomeMsg msg_ ->
      case model.page of
        Page.Home model_ ->
          let
            (model__, cmd_) = updateHome model_ msg_
          in
          ( { model | page = Page.Home model__ }, Cmd.map HomeMsg cmd_ )

        _ ->
          ( model, Cmd.none )

    ArticlesMsg msg_ ->
      case model.page of
        Page.Articles model_ ->
          let
            (model__, cmd_) = updateArticles model_ msg_
          in
          ( { model | page = Page.Articles model__ }, Cmd.map ArticlesMsg cmd_ )

        _ ->
          ( model, Cmd.none )

    EditorMsg msg_ ->
      case model.page of
        Page.Editor model_ ->
          let       
            (model__, cmd_) = updateEditor model_ msg_
          in
          ( { model | page = Page.Editor model__ }, Cmd.map EditorMsg cmd_ )

        _ ->
          ( model, Cmd.none )

    Nop ->
      ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  case model.page of
    Editor model_ ->
      Editor.subscriptions model_
        |> Sub.map (\msg -> EditorMsg msg)

    _ ->
      Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
  let
    pageView =
      case model.page of
        Page.Home _ ->
          let
            view_ = Home.view
          in
          { title = view_.title, content = view_.content |> Html.map (\msg -> HomeMsg msg) }

        Page.Articles model_ ->
          let
            view_ = Articles.view model_
          in
          { title = view_.title, content = view_.content |> Html.map (\msg -> ArticlesMsg msg) }

        Page.Editor model_ ->
          let
            view_ = Editor.view model_
          in
          { title = view_.title, content = view_.content |> Html.map (\msg -> EditorMsg msg) }

        Page.NotFound ->
          let
            view_ = NotFound.view
          in
          { title = view_.title, content = view_.content |> Html.map (\_ -> Nop) }

    mainTitle = model.context.config.title ++ " Admin"

    docTitle = mainTitle ++ " : " ++ pageView.title
  in
  { title = docTitle
  , body =
      [ header [ class "hero is-light" ]
        [ div [ class "hero-body"]
          [ div [ class "container" ]
            [ h1 [ class "title" ] [ text mainTitle ]
            ]
          ]
        ]
      , section [ class "section" ]
        [ div [ class "columns" ]
          [ div [ class "column" ] [ menu ]
          , div [ class "column is-three-quarters" ] [ pageView.content ]
          ]
        ]
      ]
  }


menu : Html msg
menu =
  nav [ class "navbar", attribute "role" "navigation", attribute "aria-label" "main navigation" ]
    [ div [ class "menu navbar-menu is-active" ]
      [ aside [ class "menu" ]
        [ p [ class "menu-label" ] [ text "Menu" ]
        , ul [ class "menu-list" ]
          [ viewLink "Home" "/"
          , viewLink "Public Articles" "/articles/public"
          , viewLink "Draft Articles" "/articles/draft"
          , viewLink "Create" "/editor"
          ]
        ]
      ]
    ]


viewLink : String -> String -> Html msg
viewLink title path =
  li [] [ a [ href path ] [ text title ] ]
