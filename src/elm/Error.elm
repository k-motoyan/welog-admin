module Error exposing(errorModal)


import Html exposing(..)
import Html.Attributes exposing(..)
import Html.Events exposing(..)
import Graphql.Http exposing(Error, RawError(..), HttpError(..))


errorModal : Maybe (Error ()) -> msg -> Html msg
errorModal error msg =
  case error of
    Just error_ ->
      div [ class "modal is-active" ]
        [ div [ class "modal-background", onClick msg ] []
        , div [ class "modal-content" ]
          [ article [ class "message is-danger"]
            [ div [ class "message-header" ]
              [ p [] [ text "Error occurred" ]
              , button [ class "delete", attribute "aria-label" "delete", onClick msg ] []
              ]
            , div [ class "message-body" ] [ text (gqlErrorToString error_) ]
            ]
          ]
        ]

    Nothing ->
      div [] []


gqlErrorToString : Error data -> String
gqlErrorToString error =
  case error of
    GraphqlError _ errors ->
      "Something went wrong..."

    HttpError httpError ->
      case httpError of
        BadUrl url ->
          "BadUrl: " ++ url

        Timeout ->
          "Request Timeout"

        NetworkError ->
          "Network Error"

        BadStatus metadata _ ->
          (String.fromInt metadata.statusCode) ++ " " ++ metadata.statusText

        BadPayload _ ->
          "Bad Payload"
