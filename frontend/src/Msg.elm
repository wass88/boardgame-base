module Msg exposing (..)

import Http
import Model exposing (..)
import Select


type Msg
    = Hello
    | ApiMsg ApiMsg
    | NewTransactionFormMsg NewTransactionFormMsg


type ApiMsg
    = GotCoins (Result Http.Error Coins)
    | GotTransactions (Result Http.Error Transactions)
    | CompletePostTransaction (Result Http.Error ())


type NewTransactionFormMsg
    = ChangeNewUser (Maybe User)
    | NewSelect (Select.Msg User)
    | ChangeUser Int (Maybe User)
    | Select Int (Select.Msg User)
    | InputPay Int String
    | InputResult Int String
    | Submit
    | ChangeGame String
