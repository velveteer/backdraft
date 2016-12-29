module Backdraft.Home.UI where

import Prelude
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

import Firebase.DSL (FirebaseDSL, logout)

type State = Maybe String

data QueryH a = Logout a

type Output = Void

type Monad = FirebaseDSL

ui :: H.Component HH.HTML QueryH Output Monad
ui = H.component { initialState, render, eval }
  where

  initialState = Nothing

  render :: State -> H.ComponentHTML QueryH
  render _ = HH.div_
    [ HH.button
      [ HP.title "Logout"
      , HE.onClick (HE.input_ Logout)
      ]
      [ HH.text "Logout" ]
    ]

  eval :: QueryH ~> H.ComponentDSL State QueryH Output Monad
  eval (Logout next) = do
    lift $ logout
    pure next
