module Container where

import Prelude
import Control.Monad.Free (Free, liftF)
import Control.Monad.Trans.Class (lift)
import Control.Monad.Aff (Aff)
import Data.Const (Const)
import Data.Functor.Coproduct (Coproduct, left, right)
import Data.Lazy (defer)
import Data.Maybe (Maybe(..))
import Halogen as H
import Halogen.HTML as HH
import Halogen.Component.ChildPath (type (\/), type (<\/>))
import Halogen.Component.ChildPath as CP

import Debug.Trace (traceAnyA)
import Firebase as F
import Login as Login
import Home as Home

data State = Authenticated | NotAuthenticated

data Query a = Init a

type Output = Void

type ChildQuery = Login.QueryL <\/> Home.QueryH <\/> Const Void
type ChildSlot = Unit \/ Unit \/ Void

type Monad eff = Free (Coproduct (Aff ( firebase :: F.FIREBASE | eff )) F.FirebaseDSL)

component :: forall eff. H.Component HH.HTML Query Output (Monad eff)
component = H.lifecycleParentComponent { initialState, render, eval, initializer, finalizer }
  where

  initialState = NotAuthenticated

  -- Render Home screen if authenticated, otherwise render Login screen
  render :: State -> H.ParentHTML Query ChildQuery ChildSlot (Monad eff)
  render NotAuthenticated = HH.slot' CP.cp1 unit (defer \_ -> H.hoist (liftF <<< right) Login.ui) absurd
  render Authenticated = HH.slot' CP.cp2 unit (defer \_ -> H.hoist (liftF <<< right) Home.ui) absurd

  eval :: Query ~> H.ParentDSL State Query ChildQuery ChildSlot Output (Monad eff)
  eval = case _ of

    Init next -> do
      app <- lift $ (liftF <<< right) F.getFirebase
      user <- lift $ (liftF <<< left) $ F.onAuthStateChanged app
      case user of
        Just u -> H.put Authenticated
        Nothing -> H.put NotAuthenticated
      traceAnyA user
      pure next

  initializer = Just $ H.action Init

  finalizer = Nothing
