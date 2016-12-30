module Backdraft.Login.UI where

import Prelude
import Control.Monad.Eff.Exception (message)
import Control.Monad.Trans.Class (lift)
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Debug.Trace (traceAnyA)
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.HTML.Properties as HP

import Firebase.Authentication (User, ProviderType(..))
import Firebase.DSL (FirebaseDSL, oAuthLoginRedirect)

type State = { user :: Maybe User
             , error :: Maybe String }

data QueryL a = Login ProviderType a

type Output = Void

type Monad = FirebaseDSL

ui :: H.Component HH.HTML QueryL Output Monad
ui = H.component { initialState, render, eval }
  where

  initialState = { user: Nothing, error: Nothing }

  render :: State -> H.ComponentHTML QueryL
  render _ = HH.div_
    [ HH.button
      [ HP.title "Login with Google"
      , HE.onClick (HE.input_ $ Login Google)
      ]
      [ HH.text "Login with Google" ]
    , HH.button
      [ HP.title "Login with Github"
      , HE.onClick (HE.input_ $ Login Github)
      ]
      [ HH.text "Login with Github" ]
    ]


  eval :: QueryL ~> H.ComponentDSL State QueryL Output Monad
  eval = case _ of
    Login p next -> do
      result <- lift $ oAuthLoginRedirect p
      case result of
        Left e -> H.put { user: Nothing, error: Just (message e) }
        Right u -> H.put { user: Just u, error: Nothing }
      H.get >>= traceAnyA
      pure next
