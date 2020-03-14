module NewTransactionForm exposing (initNewTransactionForm, newTransaction, update)

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


newUserFormConfig : Select.Config Msg User
newUserFormConfig =
    userFormConfig (\u -> NewTransactionFormMsg (ChangeNewUser u))


subUserFormConfig : Int -> Select.Config Msg User
subUserFormConfig id =
    userFormConfig (\u -> NewTransactionFormMsg (ChangeUser id u))


userOptions : Model -> List User
userOptions m =
    Dict.toList
        m.coins
        |> List.map (\( u, _ ) -> { id = u, label = u })


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
                            (userOptions model)
                            [ { label = f.user, id = f.user } ]
                            |> Html.map (\m -> NewTransactionFormMsg (Select id m))
                        , input [ value (String.fromInt f.pay), type_ "number" ] []
                        , input [ value f.result ] []
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
                    (userOptions model)
                    []
                    |> Html.map (\m -> NewTransactionFormMsg (NewSelect m))
                , input [ disabled True ] []
                , input [ disabled True ] []
                ]
    in
    div [] (Array.toList forms ++ [ new ])


initNewTransactionForm : NewTransactionForm
initNewTransactionForm =
    { mountForm = Array.empty
    , newForm = Select.newState "Orignal"
    }


newTransaction : Model -> NewTransactionForm -> Html Msg
newTransaction model tf =
    div []
        [ text "入力フォーム"
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


changeUser : Int -> Maybe User -> Model -> Model
changeUser id u model =
    case u of
        Nothing ->
            model

        Just user ->
            let
                form =
                    model.newTransactionForm
            in
            case Array.get id form.mountForm of
                Nothing ->
                    model

                Just subform ->
                    let
                        updated =
                            { subform | user = user.id }
                    in
                    { model | newTransactionForm = { form | mountForm = Array.set id updated form.mountForm } }


update : NewTransactionFormMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.ChangeNewUser t ->
            ( addUser t model, Cmd.none )

        Msg.NewSelect m ->
            let
                form =
                    model.newTransactionForm
            in
            let
                ( updated, cmd ) =
                    Select.update newUserFormConfig m form.newForm
            in
            ( { model | newTransactionForm = { form | newForm = updated } }, cmd )

        Msg.ChangeUser id t ->
            ( changeUser id t model, Cmd.none )

        Msg.Select id m ->
            let
                form =
                    model.newTransactionForm
            in
            case Array.get id form.mountForm of
                Nothing ->
                    Debug.log "Unknown Select"
                        ( model, Cmd.none )

                Just subform ->
                    let
                        ( updated, cmd ) =
                            Select.update (subUserFormConfig id) m subform.select
                    in
                    let
                        subformUpdated =
                            { subform | select = updated }
                    in
                    ( { model
                        | newTransactionForm =
                            { form | mountForm = Array.set id subformUpdated form.mountForm }
                      }
                    , cmd
                    )
