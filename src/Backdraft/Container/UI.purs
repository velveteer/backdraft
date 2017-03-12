module Backdraft.Container.UI where

import Prelude
import Control.Monad.Trans.Class (lift)
import Data.Const (Const)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.Component.ChildPath (type (\/), type (<\/>))
import Halogen.Component.ChildPath as CP

import Firebase.DSL (FirebaseDSL, onAuthChange)
import Backdraft.Login.UI as Login.UI
import Backdraft.Home.UI as Home.UI

data State = Authenticated | NotAuthenticated | Loading

data Query a = Init a

type Input = Unit

type Output = Void

type ChildQuery = Login.UI.QueryL <\/> Home.UI.QueryH <\/> Const Void
type ChildSlot = Unit \/ Unit \/ Void

type Monad = FirebaseDSL

ui :: H.Component HH.HTML Query Input Output Monad
ui = H.lifecycleParentComponent
  { initialState: const initialState
  , render
  , eval
  , initializer
  , finalizer
  , receiver: const Nothing
  }
  where

  initialState = Loading

  -- Render Home screen if authenticated, otherwise render Login screen
  render :: State -> H.ParentHTML Query ChildQuery ChildSlot Monad
  render NotAuthenticated = HH.slot' CP.cp1 unit Login.UI.ui unit absurd
  render Authenticated = HH.slot' CP.cp2 unit Home.UI.ui unit absurd
  render Loading = HH.div_ [ HH.text "Loading..." ]

  eval :: Query ~> H.ParentDSL State Query ChildQuery ChildSlot Output Monad
  eval = case _ of

    Init next -> do
      user <- lift $ onAuthChange
      H.put Loading
      case user of
        Just _ -> H.put Authenticated
        Nothing -> H.put NotAuthenticated
      pure next

  initializer = Just $ H.action Init

  finalizer = Nothing
