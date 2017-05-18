module Firebase.Authentication where

import Prelude
import Control.Monad.Eff (Eff())
import Data.Foreign.Generic (genericDecode, defaultOptions)
import Data.Foreign.Class (class Decode)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Firebase (Firebase, FIREBASE)

foreign import data Provider :: Type -- firebase.auth.AuthProvider

data ProviderType
  = Google
  | Facebook
  | Twitter
  | Github

data OAuthLoginType = Redirect | Popup

getProvider :: forall eff. ProviderType -> Eff (firebase :: FIREBASE | eff) Provider
getProvider Google = googleAuthProvider
getProvider Facebook = facebookAuthProvider
getProvider Twitter = twitterAuthProvider
getProvider Github = githubAuthProvider

-- TODO: Handle possible null values
newtype User =
  User { displayName :: String
       , email :: String
       , photoURL :: String
       , providerID :: String
       , uid :: String }

derive instance genericUser :: Generic User _

instance showUser :: Show User where
  show = genericShow

instance decodeUser :: Decode User where
  decode = genericDecode defaultOptions

foreign import currentUserImpl :: forall a eff. (a -> Maybe a) -> Maybe a -> Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
currentUser :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
currentUser fb = currentUserImpl Just Nothing fb

foreign import facebookAuthProvider :: forall eff. Eff ( firebase :: FIREBASE | eff ) Provider
foreign import googleAuthProvider :: forall eff. Eff ( firebase :: FIREBASE | eff ) Provider
foreign import githubAuthProvider :: forall eff. Eff ( firebase :: FIREBASE | eff ) Provider
foreign import twitterAuthProvider :: forall eff. Eff ( firebase :: FIREBASE | eff ) Provider
