module Session exposing(Session)


import Request exposing(AccessToken)


type alias Session =
  { accessToken : AccessToken
  }
