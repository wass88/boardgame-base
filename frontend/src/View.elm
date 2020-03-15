module View exposing (..)

import Browser
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Msg exposing (..)
import NewTransactionForm exposing (newTransaction)
import Strftime
import Time


coinTable : Coins -> Html Msg
coinTable coins =
    Dict.toList coins
        |> List.sortBy (\( _, v ) -> -v)
        |> List.map
            (\( k, v ) ->
                tr [] [ td [ class "coin-user" ] [ text k ], td [ class "coin-mount" ] [ text (String.fromInt v) ] ]
            )
        |> table [ class "coin-table" ]


payMountView : Dict.Dict String PayMount -> List (Html Msg)
payMountView dict =
    Dict.toList dict
        |> List.sortBy (\( _, pay ) -> pay.mount)
        |> List.map
            (\( user, pay ) ->
                div [ class "pay-table" ]
                    [ p [ class "pay-user" ] [ text user ]
                    , p [ class "pay-mount" ] [ text (String.fromInt pay.mount) ]
                    , p [ class "pay-result" ] [ text pay.result ]
                    ]
            )


transactionLine : Transaction -> Html Msg
transactionLine t =
    div [ class "pay-line" ]
        [ p [ class "game" ] [ text (t.game ++ " " ++ Strftime.format "%y-%m-%d %H:%M" Time.utc t.createdAt) ]
        , div [ class "pay-desc" ] (payMountView t.pay)
        ]


transactionsTable : Transactions -> Html Msg
transactionsTable transactions =
    List.reverse transactions
        |> List.map transactionLine
        |> div []


view : Model -> Browser.Document Msg
view model =
    { title = "コイン"
    , body =
        [ h1 [] [ text "ボードゲームコイン" ]
        , h2 [] [ text "コイン所持数ランキング" ]
        , coinTable model.coins
        , h2 [] [ text "取得" ]
        , newTransaction model model.newTransactionForm
        , h2 [] [ text "取得履歴" ]
        , transactionsTable model.transactions
        ]
    }
