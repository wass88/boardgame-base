module View exposing (..)

import Api
import Browser
import Dict
import Html exposing (..)
import Model exposing (Model)
import Msg exposing (..)


coinTable : Api.Coins -> Html Msg
coinTable coins =
    Dict.toList coins
        |> List.map
            (\( k, v ) ->
                tr [] [ td [] [ text k, text (String.fromInt v) ] ]
            )
        |> table []


view : Model -> Browser.Document Msg
view model =
    { title = "コイン"
    , body =
        [ h1 [] [ text "コイン獲得数" ]
        , coinTable model.coins
        ]
    }
