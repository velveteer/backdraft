module Firebase.DSL where

import Prelude
import Control.Monad.Free (Free, liftF)
import Data.Maybe (Maybe())
import Firebase (Firebase)
import Firebase.Authentication (User)

data FirebaseDSLF a
  = Ask (Firebase -> a)
  | Login a
  | Logout a
  | OnAuthChange (Maybe User -> a)

type FirebaseDSL = Free FirebaseDSLF

getFirebase :: FirebaseDSL Firebase
getFirebase = liftF $ Ask id

login :: FirebaseDSL Unit
login = liftF $ Login unit

logout :: FirebaseDSL Unit
logout = liftF $ Logout unit

onAuthChange :: FirebaseDSL (Maybe User)
onAuthChange = liftF $ OnAuthChange id
