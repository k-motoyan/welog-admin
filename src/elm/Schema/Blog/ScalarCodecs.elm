-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Schema.Blog.ScalarCodecs exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Schema.Blog.Scalar exposing (defaultCodecs)


type alias Upload =
    Schema.Blog.Scalar.Upload


codecs : Schema.Blog.Scalar.Codecs Upload
codecs =
    Schema.Blog.Scalar.defineCodecs
        { codecUpload = defaultCodecs.codecUpload
        }
