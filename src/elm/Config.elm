module Config exposing(Config)


import Request exposing(BaseUrl)


type alias Config =
  { title : String
  , apiUrl : BaseUrl
  }
