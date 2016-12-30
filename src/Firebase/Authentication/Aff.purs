module Firebase.Authentication.Aff where

import Prelude
import Control.Monad.Aff (Aff(), makeAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Exception (Error())
import Data.Maybe (Maybe(..))
import Firebase (Firebase, FIREBASE)
import Firebase.Authentication (User, Provider)

foreign import onAuthStateChangedImpl
  :: forall eff
   . (User -> Maybe User)
   -> Maybe User
   -> Firebase
   -> (Maybe User -> Eff ( firebase :: FIREBASE | eff ) Unit)
   -> (Error -> Eff ( firebase :: FIREBASE | eff ) Unit)
   -> Eff ( firebase :: FIREBASE | eff ) Unit

onAuthStateChanged
  :: forall eff
   . Firebase
  -> Aff ( firebase :: FIREBASE | eff ) (Maybe User)

onAuthStateChanged fb = makeAff (\eb cb -> onAuthStateChangedImpl Just Nothing fb cb eb)

foreign import signInWithPopupImpl
  :: forall eff
   . Firebase
  -> Provider
  -> (User -> Eff (firebase :: FIREBASE | eff) Unit)
  -> (Error -> Eff (firebase :: FIREBASE | eff) Unit)
  -> Eff ( firebase :: FIREBASE | eff ) Unit

signInWithPopup :: forall eff. Firebase -> Provider -> Aff ( firebase :: FIREBASE | eff ) User
signInWithPopup fb p = makeAff (\eb cb -> signInWithPopupImpl fb p cb eb)

foreign import signInWithRedirectImpl
  :: forall eff
   . Firebase
  -> Provider
  -> (User -> Eff (firebase :: FIREBASE | eff) Unit)
  -> (Error -> Eff (firebase :: FIREBASE | eff) Unit)
  -> Eff ( firebase :: FIREBASE | eff ) Unit

signInWithRedirect :: forall eff. Firebase -> Provider -> Aff ( firebase :: FIREBASE | eff ) User
signInWithRedirect fb p = makeAff (\eb cb -> signInWithRedirectImpl fb p cb eb)

foreign import signOutImpl
  :: forall eff
   . Firebase
  -> (Unit -> Eff (firebase :: FIREBASE | eff) Unit)
  -> (Error -> Eff (firebase :: FIREBASE | eff) Unit)
  -> Eff ( firebase :: FIREBASE | eff ) Unit

signOut :: forall eff. Firebase -> Aff ( firebase :: FIREBASE | eff ) Unit
signOut fb = makeAff (\eb cb -> signOutImpl fb cb eb)
