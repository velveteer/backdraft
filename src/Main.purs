module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Free (foldFree)
import Data.Functor.Coproduct (coproduct)
import Firebase (FIREBASE, appInit, mkConfig, runFirebaseDSL)

import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Container as C

main :: Eff ( HA.HalogenEffects ( firebase :: FIREBASE ) ) Unit
main = HA.runHalogenAff do

  let config = mkConfig { apiKey: "AIzaSyAB_HbVU2pk9GrXLM0vD51MoyGnd5GKlEQ"
                        , authDomain: "halogen-test.firebaseapp.com"
                        , databaseURL: "https://halogen-test.firebaseio.com"
                        , storageBucket: "halogen-test.appspot.com" }

  -- Initialize Firebase application
  app <- liftEff $ appInit config
  runUI (H.hoist (foldFree (coproduct id (runFirebaseDSL app))) C.component) =<< HA.awaitBody
