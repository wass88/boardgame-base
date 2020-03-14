module Model exposing (..)

import Array
import Dict
import Select


type alias Coins =
    Dict.Dict String Int


type alias PayMount =
    { mount : Int, result : String }


type alias Transaction =
    { pay : Dict.Dict String PayMount
    , game : String
    , createdAt : String
    }


type alias Transactions =
    List Transaction


type alias User =
    { id : String, label : String }


type alias MountForm =
    { user : String
    , pay : Int
    , result : String
    , select : Select.State
    }


type alias NewTransactionForm =
    { mountForm : Array.Array MountForm
    , newForm : Select.State
    , game : String
    }


type alias Model =
    { coins : Coins
    , transactions : Transactions
    , newTransactionForm : NewTransactionForm
    }
