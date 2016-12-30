module Firebase.DSL where

import Prelude
import Control.Monad.Eff.Exception (Error)
import Control.Monad.Free (Free, liftF)
import Data.Either (Either)
import Data.Maybe (Maybe)
import Firebase (Firebase)
import Firebase.Authentication (User, ProviderType, OAuthLoginType(..))

data FirebaseDSLF a
  = Ask (Firebase -> a)
  | EmailLogin String String a
  | OAuthLogin ProviderType OAuthLoginType (Either Error User -> a)
  | Logout a
  | OnAuthChange (Maybe User -> a)

type FirebaseDSL = Free FirebaseDSLF

getFirebase :: FirebaseDSL Firebase
getFirebase = liftF $ Ask id

emailLogin :: String -> String -> FirebaseDSL Unit
emailLogin u p = liftF $ EmailLogin u p unit

oAuthLoginPopup :: ProviderType -> FirebaseDSL (Either Error User)
oAuthLoginPopup p = liftF $ OAuthLogin p Popup id

oAuthLoginRedirect :: ProviderType -> FirebaseDSL (Either Error User)
oAuthLoginRedirect p = liftF $ OAuthLogin p Redirect id

logout :: FirebaseDSL Unit
logout = liftF $ Logout unit

onAuthChange :: FirebaseDSL (Maybe User)
onAuthChange = liftF $ OnAuthChange id
