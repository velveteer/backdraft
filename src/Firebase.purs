module Firebase (
  appInit,
  getCurrentUser,
  mkConfig,
  onAuthStateChanged,
  googleAuthProvider,
  signInWithRedirect,
  signInWithPopup,
  signOut,
  FIREBASE,
  Firebase,
  FirebaseConfig,
  Provider,
  User
) where

import Prelude
import Control.Monad.Eff (Eff())
import Data.Foreign (Foreign())
import Data.Generic (class Generic, gShow)
import Data.Maybe (Maybe(..))

foreign import data FIREBASE :: !
foreign import data Firebase :: *

foreign import appInit :: forall eff. FirebaseConfig -> Eff ( firebase :: FIREBASE | eff ) Firebase

newtype FirebaseConfig = FirebaseConfig { apiKey :: String
                                        , authDomain :: String
                                        , databaseURL :: String
                                        , storageBucket :: String }

mkConfig
  :: { apiKey :: String
     , authDomain :: String
     , databaseURL :: String
     , storageBucket :: String }
     -> FirebaseConfig
mkConfig r = FirebaseConfig r

-- Auth
type Provider = Foreign

newtype User = User { displayName :: String
                    , email :: String
                    , photoURL :: String
                    , uid :: String }

derive instance genericUser :: Generic User
instance showUser :: Show User where
  show = gShow

foreign import getCurrentUserImpl :: forall a eff. (a -> Maybe a) -> Maybe a -> Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
getCurrentUser :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
getCurrentUser app = getCurrentUserImpl Just Nothing app

foreign import onAuthStateChangedImpl
  :: forall eff
   . (User -> Maybe User)
   -> Maybe User
   -> Firebase
   -> (Maybe User -> Eff ( firebase :: FIREBASE | eff ) Unit)
   -> Eff ( firebase :: FIREBASE | eff ) Unit

onAuthStateChanged
  :: forall eff
  . Firebase
  -> (Maybe User -> Eff ( firebase :: FIREBASE | eff ) Unit)
  -> Eff ( firebase :: FIREBASE | eff ) Unit
onAuthStateChanged app callback = onAuthStateChangedImpl Just Nothing app callback

foreign import googleAuthProvider :: forall eff. Eff ( firebase :: FIREBASE | eff ) Provider
foreign import signInWithRedirect :: forall eff. Firebase -> Provider -> Eff ( firebase :: FIREBASE | eff ) Unit
foreign import signInWithPopup :: forall eff. Firebase -> Provider -> Eff ( firebase :: FIREBASE | eff ) Unit
foreign import signOut :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) Unit
