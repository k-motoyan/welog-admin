port module Page.Editor exposing(Model, init, Msg, update, subscriptions, view)


import Html exposing(..)
import Html.Attributes exposing (..)
import Html.Events exposing(onInput, onClick)
import Markdown exposing(defaultOptions)
import Graphql.Http exposing(Error, mapError)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Schema.Blog.Query as Query
import Schema.Blog.Mutation as Mutation
import Schema.Blog.Object
import Schema.Blog.Object.Article as Article
import RemoteData exposing(RemoteData(..), fromResult)
import Request exposing(BaseUrl, AccessToken, makeAuthRequestBase, makeMutationRequestBase, progressView)
import Context exposing(Context)
import Error exposing(errorModal)


type alias ArticleData =
    { title : String
    , markdown : String
    , draft : Bool
    }


type alias FetchRequest = RemoteData (Error (Maybe ArticleData)) (Maybe ArticleData)


articleSelection : SelectionSet ArticleData Schema.Blog.Object.Article
articleSelection =
    SelectionSet.map3 ArticleData
        Article.title
        Article.markdown
        Article.draft


fetch : BaseUrl -> AccessToken -> String -> Cmd Msg
fetch baseUrl accessToken uid =
  Query.article { uid = uid } articleSelection
    |> makeAuthRequestBase baseUrl accessToken
    |> Graphql.Http.send (fromResult >> GotFetchRequest)


type alias MutationResponseData =
    { uid : String
    }


type alias MutationRequest = RemoteData (Error MutationResponseData) MutationResponseData


mutationSelection : SelectionSet MutationResponseData Schema.Blog.Object.Article
mutationSelection =
  SelectionSet.map MutationResponseData
    Article.uid


mutation : Model -> String -> Cmd Msg
mutation model html =
  let
    baseUrl = model.context.config.apiUrl
    accessToken = model.context.session.accessToken
  in
  case model.uid of
    Just uid ->
      mutationSelection
        |> Mutation.updateArticle { uid = uid
                                  , title = model.title
                                  , markdown = model.content
                                  , html = html
                                  , draft = model.draft
                                  }
        |> makeMutationRequestBase baseUrl accessToken
        |> Graphql.Http.send (RemoteData.fromResult >> GotMutationRequest)

    Nothing ->
      mutationSelection
        |> Mutation.createArticle { title = model.title
                                  , markdown = model.content
                                  , html = html
                                  , draft = model.draft
                                  }
        |> makeMutationRequestBase baseUrl accessToken
        |> Graphql.Http.send (RemoteData.fromResult >> GotMutationRequest)


type Mode = Edit | Preview


type alias Model =
  { context : Context
  , uid : Maybe String
  , title : String
  , content : String
  , draft : Bool
  , mode : Mode
  , fetchRequest : FetchRequest
  , mutationRequest : MutationRequest
  , error : Maybe (Error ())
  }


init : Context -> Maybe String -> ( Model, Cmd Msg )
init context uid =
  case uid of
    Just uid_ ->
      let
        model = Model context uid "" "" True Edit Loading NotAsked Nothing
        cmd = fetch context.config.apiUrl context.session.accessToken uid_
      in
      ( model, cmd  )

    Nothing ->
      let
        model = Model context uid "" "" True Edit NotAsked NotAsked Nothing
      in
      ( model, Cmd.none )


type Msg
  = MutationRequest String
  | GotFetchRequest FetchRequest
  | GotMutationRequest MutationRequest
  | UpdateTitle String
  | UpdateContent String
  | UpdateDraft
  | ToPreview
  | ToEdit
  | Submit
  | RemoveError


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    MutationRequest htmlText ->
      ( { model | mutationRequest = Loading }, mutation model htmlText )

    GotFetchRequest fetchRequest ->
      case fetchRequest of
        Success (Just article) ->
          ( { model
            | title = article.title
            , content = article.markdown
            , draft = article.draft
            , fetchRequest = fetchRequest
            }
          , Cmd.none
          )

        Failure error ->
          let
            error_ = mapError (\_ -> ()) error
          in
          ( { model | error = Just error_ }, Cmd.none )

        _ ->
          ( model, Cmd.none )

    GotMutationRequest mutationRequest ->
      case mutationRequest of
        Failure error ->
          let
            error_ = mapError (\_ -> ()) error
          in
          ( { model | mutationRequest = mutationRequest, error = Just error_ }, Cmd.none )

        _ ->
          ( { model | mutationRequest = mutationRequest }, Cmd.none )

    UpdateTitle title ->
      ( { model | title = title }, Cmd.none )

    UpdateContent content_ ->
      ( { model | content = content_ }, Cmd.none )

    UpdateDraft ->
      ( { model | draft = not model.draft }, Cmd.none )

    ToPreview ->
      ( { model | mode = Preview, fetchRequest = NotAsked, mutationRequest = NotAsked }, Cmd.none )

    ToEdit ->
      ( { model | mode = Edit }, Cmd.none )

    Submit ->
      ( model, getDocumentText "article" )

    RemoveError ->
      ( { model | error = Nothing }, Cmd.none )

-- SUBSCRIPTIONS


port getDocumentText : String -> Cmd msg


port gotDocumentText : (String -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions _ =
  gotDocumentText MutationRequest


-- VIEWS


view : Model -> { title : String, content : Html Msg }
view model =
  { title = "Write"
  , content =
    div []
      [ errorModal model.error RemoveError
      , content model
      , progressView model.mutationRequest True False
      ]
  }


content : Model -> Html Msg
content model =
  case model.mode of
    Edit ->
      editor model

    Preview ->
      preview model


editor : Model -> Html Msg
editor model =
  case model.fetchRequest of
    Loading ->
      p [] [ text "Now Loading..." ]

    _ ->
      editorView model


editorView : Model -> Html Msg
editorView model =
  let
    ( mdOptions, mdContent ) = toMarkdown model
  in
  div []
    [ div [ class "field" ]
        [ label [ class "label" ] [ text "Title" ]
        , div [ class "control" ] [ input [ class "input", type_ "text", value model.title, onInput UpdateTitle ] [] ]
        ]
    , div [ class "field" ]
      [ label [ class "label" ] [ text "Body"]
      , div [ class "control" ] [ textarea [ class "textarea", rows 15, onInput UpdateContent ] [ text model.content ] ]
      ]
    , div [ class "field has-text-right" ]
      [ div [ class "control"]
        [ label [ class "checkbox" ]
          [ input [ type_ "checkbox", checked model.draft, onClick UpdateDraft ] []
          , text " Draft"
          ]
        ]
      ]
    , div [ class "field is-grouped is-grouped-right" ]
      [ div [ class "control" ] [ button [ class "button", onClick ToPreview ] [ text "Preview" ] ]
      , div [ class "control" ] [ button [ class "button is-primary", onClick Submit ] [ text "Submit" ] ]
      ]
    , article [ class "is-hidden" ] [ Markdown.toHtmlWith mdOptions [ class "content" ] mdContent ]
    ]


preview : Model -> Html Msg
preview model =
  let
    ( mdOptions, mdContent ) = toMarkdown model
  in
  div []
    [ div [ class "field has-text-right" ]
      [ div [ class "control" ] [ button [ class "button", onClick ToEdit ] [ text "Edit" ] ] ]
    , article [] [ Markdown.toHtmlWith mdOptions [ class "content" ] mdContent ]
    ]


toMarkdown : Model -> (Markdown.Options, String)
toMarkdown model =
  let
    mdOptions =
      { defaultOptions
      | githubFlavored = Just { tables = True, breaks = False }
      }

    title =
      if String.isEmpty model.title then
        ""
      else
        "# " ++ model.title ++ "\n\n---\n\n"

    mdContent = title ++ model.content
  in
  ( mdOptions, mdContent )
