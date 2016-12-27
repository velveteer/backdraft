module Firebase
( appInit
, child
, getCurrentUser
, getDatabase
, getRootRef
, login
, logout
, mkConfig
, on
, onAuthStateChanged
, googleAuthProvider
, runFirebaseDSL
, getFirebase
, signInWithRedirect
, signInWithPopup
, signOut
, FIREBASE
, Firebase
, FirebaseConfig
, FirebaseDSL
, FirebaseDSLF
, Provider
, Database
, DataSnapshot
, Ref
, User
) where

import Prelude
import Control.Monad.Aff (Aff(), makeAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Exception (Error())
import Control.Monad.Free (Free, liftF, foldFree)

import Data.Foreign.Generic (readGeneric, defaultOptions)
import Data.Foreign.Class (class IsForeign)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))

-- Foreign data
foreign import data FIREBASE      :: ! -- Effects -- most methods
foreign import data Firebase      :: * -- firebase.App
foreign import data Provider      :: * -- firebase.auth.AuthProvider
foreign import data Database      :: * -- firebase.database.Database
foreign import data Ref           :: * -- firebase.database.Reference
foreign import data DataSnapshot  :: * -- firebase.database.DataSnapshot

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
-- TODO: Handle possible null values
newtype User =
  User { displayName :: String
       , email :: String
       , photoURL :: String
       , uid :: String }

derive instance genericUser :: Generic User _

instance showUser :: Show User where
  show = genericShow

instance isForeignUser :: IsForeign User where
  read = readGeneric defaultOptions

foreign import getCurrentUserImpl :: forall a eff. (a -> Maybe a) -> Maybe a -> Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
getCurrentUser :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
getCurrentUser app = getCurrentUserImpl Just Nothing app

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
onAuthStateChanged app = makeAff (\eb cb -> onAuthStateChangedImpl Just Nothing app cb eb)

foreign import googleAuthProvider :: forall eff. Eff ( firebase :: FIREBASE | eff ) Provider
foreign import signInWithRedirect :: forall eff. Firebase -> Provider -> Eff ( firebase :: FIREBASE | eff ) Unit
foreign import signInWithPopup :: forall eff. Firebase -> Provider -> Eff ( firebase :: FIREBASE | eff ) Unit
foreign import signOut :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) Unit

-- Database and References
foreign import getDatabase :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) Database
foreign import getRootRef :: forall eff. Database -> Eff ( firebase :: FIREBASE | eff ) Ref
foreign import ref :: forall eff. String -> Database -> Eff ( firebase :: FIREBASE | eff ) Ref
foreign import child :: forall eff. String -> Ref -> Eff ( firebase :: FIREBASE | eff ) Ref

foreign import onImpl
  :: forall eff
   . Ref
  -> (DataSnapshot -> Eff ( firebase :: FIREBASE | eff ) Unit)
  -> (Error -> Eff ( firebase :: FIREBASE | eff ) Unit)
  -> Eff ( firebase :: FIREBASE | eff ) Unit

on
  :: forall eff
   . Ref
  -> Aff (firebase :: FIREBASE | eff) DataSnapshot
on r = makeAff (\eb cb -> onImpl r cb eb)

-- DSL

data FirebaseDSLF a
  = Ask (Firebase -> a)
  | Login Firebase a
  | Logout Firebase a

type FirebaseDSL = Free FirebaseDSLF

getFirebase :: FirebaseDSL Firebase
getFirebase = liftF $ Ask id

login :: Firebase -> FirebaseDSL Unit
login fb = liftF $ Login fb unit

logout :: Firebase -> FirebaseDSL Unit
logout fb = liftF $ Logout fb unit

runFirebaseDSL :: forall eff. Firebase -> FirebaseDSL ~> Aff (firebase :: FIREBASE | eff)
runFirebaseDSL = foldFree <<< runFirebaseDSLF

runFirebaseDSLF :: forall eff. Firebase -> FirebaseDSLF ~> Aff (firebase :: FIREBASE | eff)
runFirebaseDSLF fb (Ask a) = pure (a fb)
runFirebaseDSLF _ (Login fb a) = do
  liftEff $ signInWithPopup fb =<< googleAuthProvider
  pure a
runFirebaseDSLF _ (Logout fb a) = do
  liftEff $ signOut fb
  pure a
