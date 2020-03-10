module Main exposing (..)

import Api
import Browser
import Browser.Navigation
import Dict
import Html exposing (Html, text)
import Html.Events exposing (onClick)
import Url exposing (Url)


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }


type alias Model =
    { coins : Api.Coins
    }


init : flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( { coins = Dict.empty }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onUrlChange : Url -> Msg
onUrlChange url =
    Hello


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest req =
    Hello


type Msg
    = Hello


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = "ボドゲコイン"
    , body = [ text "hello" ]
    }
