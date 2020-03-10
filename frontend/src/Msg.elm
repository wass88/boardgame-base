module Msg exposing (..)

import Api


type Msg
    = Hello
    | ApiMsg Api.Msg
