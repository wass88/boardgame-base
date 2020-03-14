module View exposing (..)

import Browser
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Msg exposing (..)
import NewTransactionForm exposing (newTransaction)


coinTable : Coins -> Html Msg
coinTable coins =
    Dict.toList coins
        |> List.map
            (\( k, v ) ->
                tr [] [ td [] [ text k, text (String.fromInt v) ] ]
            )
        |> table []


payMountView : Dict.Dict String PayMount -> List (Html Msg)
payMountView dict =
    Dict.toList dict
        |> List.map
            (\( user, pay ) ->
                div [] [ text user, text (String.fromInt pay.mount), text pay.result ]
            )


transactionLine : Transaction -> Html Msg
transactionLine t =
    div []
        [ text t.game
        , text t.createdAt
        , div [] (payMountView t.pay)
        ]


transactionsTable : Transactions -> Html Msg
transactionsTable transactions =
    List.map transactionLine transactions
        |> div []


view : Model -> Browser.Document Msg
view model =
    { title = "コイン"
    , body =
        [ h1 [] [ text "ボードゲームコイン" ]
        , h2 [] [ text "コイン所持数ランキング" ]
        , coinTable model.coins
        , h2 [] [ text "取得履歴" ]
        , newTransaction model model.newTransactionForm
        , transactionsTable model.transactions
        ]
    }
