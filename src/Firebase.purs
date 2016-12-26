module Firebase
( appInit
, child
, getCurrentUser
, getDatabase
, getRootRef
, mkConfig
, on
, onAuthStateChanged
, googleAuthProvider
, signInWithRedirect
, signInWithPopup
, signOut
, FIREBASE
, Firebase
, FirebaseConfig
, Provider
, Database
, Ref
, User
) where

import Prelude
import Control.Monad.Aff (Aff(), makeAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Exception (Error())
import Data.Foreign (Foreign())
import Data.Generic (class Generic, gShow)
import Data.Maybe (Maybe(..))

-- Kinds
foreign import data FIREBASE :: !
foreign import data Firebase :: *
foreign import data FirebaseErr :: *

-- Error helpers
foreign import firebaseErrToString :: FirebaseErr -> String
foreign import firebaseErrToError :: FirebaseErr -> Error

instance showFirebaseErr :: Show FirebaseErr where
    show err = firebaseErrToString err

instance eqFirebaseErr :: Eq FirebaseErr where
    eq e1 e2 = (firebaseErrToString e1) == (firebaseErrToString e2)

-- Initialize
newtype FirebaseConfig =
  FirebaseConfig { apiKey :: String
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

foreign import appInit :: forall eff. FirebaseConfig -> Eff ( firebase :: FIREBASE | eff ) Firebase

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

-- Database and References
type Database = Foreign
type Ref = Foreign
type DataSnapshot = Foreign

foreign import getDatabase :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) Database
foreign import getRootRef :: forall eff. Database -> Eff ( firebase :: FIREBASE | eff ) Ref
foreign import ref :: forall eff. String -> Database -> Eff ( firebase :: FIREBASE | eff ) Ref
foreign import child :: forall eff. String -> Ref -> Eff ( firebase :: FIREBASE | eff ) Ref

foreign import onImpl
  :: forall eff
   . Ref
  -> (DataSnapshot -> Eff ( firebase :: FIREBASE | eff ) Unit)
  -> (FirebaseErr -> Eff ( firebase :: FIREBASE | eff ) Unit)
  -> Eff ( firebase :: FIREBASE | eff ) Unit

on
  :: forall eff
   . Ref
  -> Aff (firebase :: FIREBASE | eff) DataSnapshot
on r = makeAff (\eb cb -> onImpl r cb (eb <<< firebaseErrToError))
