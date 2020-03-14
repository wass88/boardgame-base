module Api exposing (..)

import Http
import Json.Decode as D
import Model exposing (Coins, Model, PayMount, Transaction, Transactions)
import Msg exposing (ApiMsg(..), Msg)


sendRequest : String -> String -> Http.Expect msg -> Cmd msg
sendRequest method path except =
    Http.request
        { method = method
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://localhost:18080/" ++ path
        , expect = except
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


update : ApiMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotCoins (Ok coins) ->
            ( { model | coins = coins }, Cmd.none )

        GotTransactions (Ok transactions) ->
            ( { model | transactions = transactions }, Cmd.none )

        GotCoins (Err err) ->
            Debug.log (Debug.toString err)
                ( model, Cmd.none )

        GotTransactions (Err err) ->
            Debug.log (Debug.toString err)
                ( model, Cmd.none )


coinsDecoder : D.Decoder Coins
coinsDecoder =
    D.field "coins" (D.dict D.int)


fetchCoins : Cmd ApiMsg
fetchCoins =
    sendRequest "GET"
        "api/coins"
        (Http.expectJson GotCoins coinsDecoder)


payMountDecoder : D.Decoder PayMount
payMountDecoder =
    D.map2 (\x y -> { mount = x, result = y })
        (D.field "mount" D.int)
        (D.field "result" D.string)


transactionDecoder : D.Decoder Transaction
transactionDecoder =
    D.map3 (\x y z -> { game = x, pay = y, createdAt = z })
        (D.field "game" D.string)
        (D.field "pay" (D.dict payMountDecoder))
        (D.field "created_at" D.string)


transactionsDecoder : D.Decoder Transactions
transactionsDecoder =
    D.list transactionDecoder


fetchTransactions : Cmd ApiMsg
fetchTransactions =
    sendRequest "GET"
        "api/transactions"
        (Http.expectJson GotTransactions transactionsDecoder)
