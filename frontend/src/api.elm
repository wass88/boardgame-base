module Api exposing (..)

import Dict
import Http
import Json.Decode as D


type alias Coins =
    Dict.Dict String Int


type Msg
    = GotCoins (Result Http.Error Coins)


coinsDecoder : D.Decoder Coins
coinsDecoder =
    D.field "Coins" (D.dict D.int)


fetchCoins : Cmd Msg
fetchCoins =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://localhost:18080/api/coins"
        , expect = Http.expectJson GotCoins coinsDecoder
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }
