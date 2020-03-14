module NewTransactionForm exposing (initNewTransactionForm, newTransaction, update)

import Api
import Array
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model exposing (..)
import Msg exposing (..)
import Select
import Simple.Fuzzy


filter : (a -> String) -> String -> List a -> Maybe (List a)
filter toLabel query items =
    items
        |> Simple.Fuzzy.filter toLabel query
        |> Just


userFormConfig : (Maybe User -> Msg) -> Select.Config Msg User
userFormConfig m =
    Select.newConfig
        { onSelect = m
        , toLabel = .label
        , filter = filter .label
        }
        |> Select.withEmptySearch True
        |> Select.withClear False


newUserFormConfig : Select.Config Msg User
newUserFormConfig =
    userFormConfig (\u -> NewTransactionFormMsg (ChangeNewUser u))


subUserFormConfig : Int -> Select.Config Msg User
subUserFormConfig id =
    userFormConfig (\u -> NewTransactionFormMsg (ChangeUser id u))


candidates : Model -> List User
candidates model =
    let
        subform =
            model.newTransactionForm.mountForm
    in
    let
        selected =
            List.map .user (Array.toList subform)
    in
    let
        users =
            Dict.keys model.coins
    in
    List.filter (\u -> not (List.member u selected)) users
        |> List.map (\u -> { id = u, label = u })


incrementalForm : Model -> NewTransactionForm -> Html Msg
incrementalForm model tf =
    let
        forms =
            Array.indexedMap
                (\id f ->
                    div []
                        [ Select.view
                            (subUserFormConfig id)
                            f.select
                            ({ label = f.user, id = f.user } :: candidates model)
                            [ { label = f.user, id = f.user } ]
                            |> Html.map (\m -> NewTransactionFormMsg (Select id m))
                        , input [ onInput (\m -> NewTransactionFormMsg (InputPay id m)), value (String.fromInt f.pay), type_ "number" ] []
                        , input [ onInput (\m -> NewTransactionFormMsg (InputResult id m)), value f.result ] []
                        ]
                )
                tf.mountForm
    in
    let
        new =
            div []
                [ Select.view
                    newUserFormConfig
                    model.newTransactionForm.newForm
                    (candidates model)
                    [ { label = "追加", id = "" } ]
                    |> Html.map (\m -> NewTransactionFormMsg (NewSelect m))
                , input [ disabled True ] []
                , input [ disabled True ] []
                ]
    in
    div [] (Array.toList forms ++ [ new ])


readyTransaction : NewTransactionForm -> Bool
readyTransaction tf =
    Array.length tf.mountForm
        > 1
        && sumTransaction tf
        == 0
        && tf.game
        /= ""


initNewTransactionForm : NewTransactionForm
initNewTransactionForm =
    { game = ""
    , mountForm = Array.empty
    , newForm = Select.newState "Orignal"
    }


sumTransaction : NewTransactionForm -> Int
sumTransaction tf =
    Array.foldl (\f i -> f.pay + i) 0 tf.mountForm


newTransaction : Model -> NewTransactionForm -> Html Msg
newTransaction model tf =
    div []
        [ text ("合計: " ++ String.fromInt (sumTransaction model.newTransactionForm))
        , button
            [ disabled (not (readyTransaction model.newTransactionForm))
            , onClick (NewTransactionFormMsg Submit)
            ]
            [ text "送信" ]
        , text "ゲーム"
        , input [ value tf.game, onInput (\m -> NewTransactionFormMsg (ChangeGame m)) ] []
        , incrementalForm model tf
        ]


addUser : Maybe User -> Model -> Model
addUser u m =
    case u of
        Just user ->
            let
                form =
                    m.newTransactionForm
            in
            let
                selectId =
                    "added" ++ String.fromInt (Array.length m.newTransactionForm.mountForm)
            in
            let
                addform =
                    { user = user.id
                    , pay = 0
                    , result = ""
                    , select = Select.newState selectId
                    }
            in
            { m | newTransactionForm = { form | mountForm = Array.push addform form.mountForm } }

        Nothing ->
            m


updateTF_ : Model -> (NewTransactionForm -> NewTransactionForm) -> ( Model, Cmd Msg )
updateTF_ m f =
    ( { m | newTransactionForm = f m.newTransactionForm }, Cmd.none )


updateTF : Model -> (NewTransactionForm -> ( NewTransactionForm, Cmd Msg )) -> ( Model, Cmd Msg )
updateTF m f =
    let
        ( fm, cmd ) =
            f m.newTransactionForm
    in
    ( { m | newTransactionForm = fm }, cmd )


updateMountFormID_ : Model -> Int -> (MountForm -> MountForm) -> ( Model, Cmd Msg )
updateMountFormID_ model id f =
    updateTF_ model
        (\form ->
            case Array.get id form.mountForm of
                Nothing ->
                    Debug.log "Unknown Select" form

                Just subform ->
                    { form | mountForm = Array.set id (f subform) form.mountForm }
        )


parseNumber : String -> Int
parseNumber num =
    let
        purify h ( s, f ) =
            if f && h == '-' then
                ( "-", False )

            else
                case String.toInt (String.fromChar h) of
                    Nothing ->
                        ( "", False )

                    Just _ ->
                        ( s ++ String.fromChar h, False )
    in
    let
        ( pure, _ ) =
            String.foldl purify ( "", True ) num
    in
    case String.toInt pure of
        Nothing ->
            0

        Just n ->
            n


update : NewTransactionFormMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeNewUser t ->
            Debug.log "New"
                ( addUser t model, Cmd.none )

        NewSelect m ->
            updateTF model
                (\form ->
                    let
                        ( updated, cmd ) =
                            Select.update newUserFormConfig m form.newForm
                    in
                    ( { form | newForm = updated }, cmd )
                )

        ChangeUser id t ->
            case t of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    updateMountFormID_ model
                        id
                        (\subform ->
                            { subform | user = user.id }
                        )

        Select id m ->
            updateMountFormID_ model
                id
                (\subform ->
                    let
                        ( updated, _ ) =
                            Select.update (subUserFormConfig id) m subform.select
                    in
                    { subform | select = updated }
                )

        InputPay id number ->
            updateMountFormID_ model
                id
                (\form ->
                    { form | pay = parseNumber number }
                )

        InputResult id result ->
            ( model, Cmd.none )

        Submit ->
            updateTF model
                (\_ ->
                    ( initNewTransactionForm, Cmd.map ApiMsg (Api.submitTransaction model) )
                )

        ChangeGame game ->
            updateTF_ model
                (\form ->
                    { form | game = game }
                )
