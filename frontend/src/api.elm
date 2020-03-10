module Api exposing (..)

import Dict
import Http


type alias Coins =
    Dict.Dict String Int
