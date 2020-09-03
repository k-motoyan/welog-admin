module Request exposing(BaseUrl(..), AccessToken(..), makeRequestBase, makeAuthRequestBase, makeMutationRequestBase, progressView)


import Html exposing(..)
import Html.Attributes exposing(..)
import RemoteData exposing(RemoteData(..))
import Graphql.Http exposing(Request)
import Graphql.Operation exposing(RootQuery, RootMutation)
import Graphql.SelectionSet exposing(SelectionSet)


type BaseUrl = BaseUrl String


unwrapBaseUrl : BaseUrl -> String
unwrapBaseUrl (BaseUrl str) = str


type AccessToken = AccessToken String


unwrapAccessToken : AccessToken -> String
unwrapAccessToken (AccessToken str) = str


makeRequestBase : BaseUrl -> SelectionSet decodesTo RootQuery -> Request decodesTo
makeRequestBase baseUrl query =
  query
    |> Graphql.Http.queryRequest (unwrapBaseUrl baseUrl)


makeAuthRequestBase : BaseUrl -> AccessToken -> SelectionSet decodesTo RootQuery -> Request decodesTo
makeAuthRequestBase baseUrl accessToken query =
  query
    |> Graphql.Http.queryRequest (unwrapBaseUrl baseUrl)
    |> Graphql.Http.withHeader "Authorization" ("Bearer " ++ (unwrapAccessToken accessToken))


makeMutationRequestBase : BaseUrl -> AccessToken -> SelectionSet decodesTo RootMutation -> Request decodesTo
makeMutationRequestBase baseUrl accessToken mutation =
  mutation
    |> Graphql.Http.mutationRequest (unwrapBaseUrl baseUrl)
    |> Graphql.Http.withHeader "Authorization" ("Bearer " ++ (unwrapAccessToken accessToken))


progressView : RemoteData e a -> Bool -> Bool -> Html msg
progressView request showSuccess showFailure =
  case (request, showSuccess, showFailure) of
    (Loading, _, _) ->
      div [ style "margin-left" "30%", style "margin-right" "30%" ]
        [ progress [ class "progress is-small is-primary" ] [] ]

    (Success _, True, _) ->
      p [ class "has-text-success has-text-centered" ] [ text "Request was successful!" ]

    (Failure _, _, True) ->
      p [ class "has-text-danger has-text-centered" ] [ text "Request failed..." ]

    _ ->
      div [] []
