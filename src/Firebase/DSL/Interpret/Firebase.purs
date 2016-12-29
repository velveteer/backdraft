module Firebase.DSL.Interpret.Firebase where

import Prelude
import Control.Monad.Aff (Aff())
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Free (foldFree)
import Firebase (Firebase, FIREBASE)
import Firebase.Authentication.Aff (onAuthStateChanged, signInWithPopup, signOut)
import Firebase.Authentication (googleAuthProvider)
import Firebase.DSL (FirebaseDSLF(..), FirebaseDSL)

runFirebaseDSL :: forall eff. Firebase -> FirebaseDSL ~> Aff (firebase :: FIREBASE | eff)
runFirebaseDSL = foldFree <<< runFirebaseDSLF

runFirebaseDSLF :: forall eff. Firebase -> FirebaseDSLF ~> Aff (firebase :: FIREBASE | eff)
runFirebaseDSLF fb (Ask a) = pure (a fb)
runFirebaseDSLF fb (Login a) = do
  signInWithPopup fb =<< (liftEff $ googleAuthProvider)
  pure a
runFirebaseDSLF fb (Logout a) = do
  signOut fb
  pure a
runFirebaseDSLF fb (OnAuthChange a) = do
  user <- (onAuthStateChanged fb)
  pure $ (a user)
