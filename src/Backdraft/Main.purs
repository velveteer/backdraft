module Main where

import Prelude
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Firebase (FIREBASE, app, mkConfig)
import Firebase.DSL.Interpret.Firebase (runFirebaseDSL)

import Halogen as H
import Halogen.Aff as HA
import Halogen.VDom.Driver (runUI)
import Backdraft.Container.UI as C

main :: Eff ( HA.HalogenEffects ( firebase :: FIREBASE ) ) Unit
main = HA.runHalogenAff do
  let config = mkConfig { apiKey: "AIzaSyAB_HbVU2pk9GrXLM0vD51MoyGnd5GKlEQ"
                        , authDomain: "halogen-test.firebaseapp.com"
                        , databaseURL: "https://halogen-test.firebaseio.com"
                        , storageBucket: "halogen-test.appspot.com" }

  fb <- liftEff $ app config
  runUI (H.hoist (runFirebaseDSL fb) C.ui) =<< HA.awaitBody
