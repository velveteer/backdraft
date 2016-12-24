module Container where

import Prelude
import Data.Const (Const)
import Data.Lazy (defer)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.HTML.Events as HE
import Halogen.Component.ChildPath (type (\/), type (<\/>))
import Halogen.Component.ChildPath as CP

import Firebase (User)
import Login as L
import Home as Home

data State = Authenticated | NotAuthenticated

data Query a = ToggleSession (Maybe User) a | HandleLogin L.Output a | HandleHome Home.Output a

data Output = Login | Logout

type ChildQuery = L.QueryL <\/> Home.QueryH <\/> Const Void
type ChildSlot = Unit \/ Unit \/ Void

component :: forall m. Applicative m => H.Component HH.HTML Query Output m
component = H.parentComponent { initialState, render, eval }
  where

  initialState = NotAuthenticated

  render :: State -> H.ParentHTML Query ChildQuery ChildSlot m
  render NotAuthenticated = HH.slot' CP.cp1 unit (defer \_ -> L.component) (HE.input HandleLogin)
  render Authenticated = HH.slot' CP.cp2 unit (defer \_ -> Home.component) (HE.input HandleHome)

  eval :: Query ~> H.ParentDSL State Query ChildQuery ChildSlot Output m
  eval = case _ of
    -- Queries
    ToggleSession (Just u) next -> do
      H.put Authenticated
      pure next
    ToggleSession Nothing next -> do
      H.put NotAuthenticated
      pure next

    -- Children handlers
    HandleLogin L.LoggingIn next -> do
      H.raise Login
      pure next
    HandleHome Home.LoggingOut next -> do
      H.raise Logout
      pure next
