module Firebase.DSL.Interpret.Firebase where

import Prelude
import Control.Monad.Aff (Aff(), attempt)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Free (foldFree)
import Firebase (Firebase, FIREBASE)
import Firebase.Authentication.Aff (onAuthStateChanged, signInWithPopup, signInWithRedirect, signOut)
import Firebase.Authentication (OAuthLoginType(..), getProvider)
import Firebase.DSL (FirebaseDSLF(..), FirebaseDSL)

runFirebaseDSL :: forall eff. Firebase -> FirebaseDSL ~> Aff (firebase :: FIREBASE | eff)
runFirebaseDSL = foldFree <<< runFirebaseDSLF

runFirebaseDSLF :: forall eff. Firebase -> FirebaseDSLF ~> Aff (firebase :: FIREBASE | eff)
runFirebaseDSLF fb (Ask a) = pure (a fb)
runFirebaseDSLF fb (EmailLogin _ _ a) = do
  pure a
runFirebaseDSLF fb (OAuthLogin p Redirect a) = do
  provider <- liftEff $ getProvider p
  result <- attempt $ signInWithRedirect fb provider
  pure $ a result
runFirebaseDSLF fb (OAuthLogin p Popup a) = do
  provider <- liftEff $ getProvider p
  result <- attempt $ signInWithPopup fb provider
  pure $ a result
runFirebaseDSLF fb (Logout a) = do
  signOut fb
  pure a
runFirebaseDSLF fb (OnAuthChange a) = do
  user <- onAuthStateChanged fb
  pure $ a user
