-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Schema.Blog.Mutation exposing (..)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode exposing (Decoder)
import Schema.Blog.InputObject
import Schema.Blog.Interface
import Schema.Blog.Object
import Schema.Blog.Scalar
import Schema.Blog.ScalarCodecs
import Schema.Blog.Union


type alias CreateArticleRequiredArguments =
    { title : String
    , markdown : String
    , html : String
    , draft : Bool
    }


{-|

  - title -
  - markdown -
  - html -
  - draft -

-}
createArticle :
    CreateArticleRequiredArguments
    -> SelectionSet decodesTo Schema.Blog.Object.Article
    -> SelectionSet decodesTo RootMutation
createArticle requiredArgs object_ =
    Object.selectionForCompositeField "createArticle" [ Argument.required "title" requiredArgs.title Encode.string, Argument.required "markdown" requiredArgs.markdown Encode.string, Argument.required "html" requiredArgs.html Encode.string, Argument.required "draft" requiredArgs.draft Encode.bool ] object_ identity


type alias UpdateArticleRequiredArguments =
    { uid : String
    , title : String
    , markdown : String
    , html : String
    , draft : Bool
    }


{-|

  - uid -
  - title -
  - markdown -
  - html -
  - draft -

-}
updateArticle :
    UpdateArticleRequiredArguments
    -> SelectionSet decodesTo Schema.Blog.Object.Article
    -> SelectionSet decodesTo RootMutation
updateArticle requiredArgs object_ =
    Object.selectionForCompositeField "updateArticle" [ Argument.required "uid" requiredArgs.uid Encode.string, Argument.required "title" requiredArgs.title Encode.string, Argument.required "markdown" requiredArgs.markdown Encode.string, Argument.required "html" requiredArgs.html Encode.string, Argument.required "draft" requiredArgs.draft Encode.bool ] object_ identity


type alias DeleteArticleRequiredArguments =
    { uid : String }


{-|

  - uid -

-}
deleteArticle :
    DeleteArticleRequiredArguments
    -> SelectionSet decodesTo Schema.Blog.Object.Article
    -> SelectionSet decodesTo RootMutation
deleteArticle requiredArgs object_ =
    Object.selectionForCompositeField "deleteArticle" [ Argument.required "uid" requiredArgs.uid Encode.string ] object_ identity