module Main where

import Prelude
import Control.Monad.Aff (Aff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Aff.AVar (AVAR)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Coroutine as CR
import Control.Coroutine.Aff as CRA
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Debug.Trace (traceAnyA)
import Firebase (FIREBASE, Firebase, User, appInit, mkConfig, onAuthStateChanged, googleAuthProvider, signInWithPopup, signOut)

import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Container as C

authProducer
  :: forall eff
   . Firebase
  -> CR.Producer (Maybe User) (Aff ( avar :: AVAR, err :: EXCEPTION, firebase :: FIREBASE | eff )) Unit
authProducer app = CRA.produce \emit -> do
  onAuthStateChanged app \user -> emit $ Left user

authConsumer
  :: forall eff
   . (C.Query ~> Aff (HA.HalogenEffects eff))
  -> CR.Consumer (Maybe User) (Aff (HA.HalogenEffects eff )) Unit
authConsumer query = CR.consumer \msg -> do
  traceAnyA msg
  query $ H.action $ C.ToggleSession msg
  pure Nothing

main :: Eff ( HA.HalogenEffects ( firebase :: FIREBASE ) ) Unit
main = HA.runHalogenAff do
  body <- HA.awaitBody
  io <- runUI C.component body

  let config = mkConfig { apiKey: "AIzaSyAB_HbVU2pk9GrXLM0vD51MoyGnd5GKlEQ"
                        , authDomain: "halogen-test.firebaseapp.com"
                        , databaseURL: "https://halogen-test.firebaseio.com"
                        , storageBucket: "halogen-test.appspot.com" }
  app <- liftEff $ appInit config


  io.subscribe $ CR.consumer \msg -> do
    traceAnyA msg
    case msg of
      C.Login -> liftEff $ googleAuthProvider >>= signInWithPopup app
      C.Logout -> liftEff $ signOut app
    pure Nothing

  CR.runProcess ((authProducer app) CR.$$ authConsumer io.query)
