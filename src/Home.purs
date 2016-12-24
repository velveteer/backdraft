module Home where

import Prelude
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

type State = String
data QueryH a = Logout a
data Output = LoggingOut

component :: forall m. H.Component HH.HTML QueryH Output m
component = H.component { initialState, render, eval }
  where

  initialState = "Hello world"

  render :: State -> H.ComponentHTML QueryH
  render _ = HH.div_
    [ HH.button
      [ HP.title "Logout"
      , HE.onClick (HE.input_ Logout)
      ]
      [ HH.text "Logout" ]
    ]

  eval :: QueryH ~> H.ComponentDSL State QueryH Output m
  eval (Logout next) = do
    H.raise LoggingOut
    pure next

