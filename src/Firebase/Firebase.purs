module Firebase
( app
, child
, database
, mkConfig
, on
, FIREBASE
, Firebase
, FirebaseConfig
, Database
, DataSnapshot
, Ref
) where

import Prelude
import Control.Monad.Aff (Aff(), makeAff)
import Control.Monad.Eff (Eff())
import Control.Monad.Eff.Exception (Error())

-- Foreign data
foreign import data FIREBASE      :: ! -- Eff
foreign import data Firebase      :: * -- firebase.App
foreign import data Database      :: * -- firebase.database.Database
foreign import data Ref           :: * -- firebase.database.Reference
foreign import data DataSnapshot  :: * -- firebase.database.DataSnapshot

-- Initialize
foreign import app :: forall eff. FirebaseConfig -> Eff ( firebase :: FIREBASE | eff ) Firebase

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

-- Database and References

foreign import database :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) Database
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
