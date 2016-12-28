module Home where

import Prelude
import Control.Monad.Trans.Class (lift)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

import Firebase as F

type State = Maybe F.Firebase

type Monad = F.FirebaseDSL

data QueryH a = Logout a

type Output = Void

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
    lift $ F.logout
    pure next
