module Backdraft.Login.UI where

import Prelude
import Control.Monad.Trans.Class (lift)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

import Firebase.DSL (FirebaseDSL, login)

type State = Boolean

data QueryL a = Login a

type Output = Void

type Monad = FirebaseDSL

ui :: H.Component HH.HTML QueryL Output Monad
ui = H.component { initialState, render, eval }
  where

  initialState = true

  render :: State -> H.ComponentHTML QueryL
  render _ = HH.div_
    [ HH.button
      [ HP.title "Login with Google"
      , HE.onClick (HE.input_ Login)
      ]
      [ HH.text "Login with Google" ]
    ]

  eval :: QueryL ~> H.ComponentDSL State QueryL Output Monad
  eval = case _ of
    Login next -> do
      lift $ login
      pure next
