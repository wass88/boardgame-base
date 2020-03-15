module Api exposing (..)

import Array
import Dict
import Http
import Iso8601
import Json.Decode as D
import Json.Encode as E
import Model exposing (..)
import Msg exposing (ApiMsg(..), Msg)


sendRequest : String -> String -> Http.Body -> Http.Expect msg -> Cmd msg
sendRequest method path body except =
    Http.request
        { method = method
        , headers =
            [ Http.header "Accept" "application/json"
            , Http.header "Content-Type" "application/json"
            ]
        , url = "http://localhost:18080/" ++ path
        , expect = except
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }


update : ApiMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotCoins (Ok coins) ->
            Debug.log "GotCoins"
                ( { model | coins = coins }, Cmd.none )

        GotTransactions (Ok transactions) ->
            Debug.log "GotTransactions"
                ( { model | transactions = transactions }, Cmd.none )

        CompletePostTransaction (Ok ()) ->
            Debug.log "PostTransactions"
                ( model, Cmd.batch [ Cmd.map Msg.ApiMsg fetchTransactions, Cmd.map Msg.ApiMsg fetchCoins ] )

        GotCoins (Err err) ->
            Debug.log (Debug.toString err)
                ( model, Cmd.none )

        GotTransactions (Err err) ->
            Debug.log (Debug.toString err)
                ( model, Cmd.none )

        CompletePostTransaction (Err err) ->
            Debug.log (Debug.toString err)
                ( model, Cmd.none )


coinsDecoder : D.Decoder Coins
coinsDecoder =
    D.field "coins" (D.dict D.int)


fetchCoins : Cmd ApiMsg
fetchCoins =
    sendRequest "GET"
        "api/coins"
        Http.emptyBody
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
        (D.field "created_at" Iso8601.decoder)


transactionsDecoder : D.Decoder Transactions
transactionsDecoder =
    D.list transactionDecoder


fetchTransactions : Cmd ApiMsg
fetchTransactions =
    sendRequest "GET"
        "api/transactions"
        Http.emptyBody
        (Http.expectJson GotTransactions transactionsDecoder)


transactionEncoder : Model -> E.Value
transactionEncoder model =
    let
        form =
            model.newTransactionForm
    in
    let
        paydict =
            Array.toList form.mountForm
                |> List.map (\u -> ( u.user, E.object [ ( "mount", E.int u.pay ), ( "result", E.string u.result ) ] ))
    in
    E.object
        [ ( "game", E.string form.game )
        , ( "pay", E.object paydict )
        ]


submitTransaction : Model -> Cmd ApiMsg
submitTransaction model =
    sendRequest "POST"
        "api/transaction"
        (Http.jsonBody (transactionEncoder model))
        (Http.expectWhatever CompletePostTransaction)
