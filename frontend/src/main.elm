module Main exposing (..)

import Api
import Browser
import Browser.Navigation
import Dict
import Html exposing (Html, text)
import Html.Events exposing (onClick)
import Model exposing (Model)
import Msg exposing (..)
import Url exposing (Url)
import View


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = onUrlChange
        , onUrlRequest = onUrlRequest
        }


initModel : Model
initModel =
    { coins = Dict.empty }


initCmd : Cmd Msg
initCmd =
    Cmd.batch
        [ Cmd.map ApiMsg Api.fetchCoins
        ]


init : flags -> Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    ( initModel, initCmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


onUrlChange : Url -> Msg
onUrlChange url =
    Hello


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest req =
    Hello


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Hello ->
            ( model, Cmd.none )

        ApiMsg (Api.GotCoins (Ok coins)) ->
            ( { model | coins = coins }, Cmd.none )

        ApiMsg (Api.GotCoins (Err err)) ->
            Debug.log (Debug.toString err)
                ( model, Cmd.none )
