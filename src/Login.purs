module Login where

import Prelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

type State = Boolean
data QueryL a = Login a
data Output = LoggingIn

component :: forall m. H.Component HH.HTML QueryL Output m
component = H.component { initialState, render, eval }
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

  eval :: QueryL ~> H.ComponentDSL State QueryL Output m
  eval = case _ of
    Login next -> do
      H.raise LoggingIn
      pure next
