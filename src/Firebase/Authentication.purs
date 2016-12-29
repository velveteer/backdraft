module Firebase.Authentication where

import Prelude
import Control.Monad.Eff (Eff())
import Data.Foreign.Generic (readGeneric, defaultOptions)
import Data.Foreign.Class (class IsForeign)
import Data.Generic.Rep (class Generic)
import Data.Generic.Rep.Show (genericShow)
import Data.Maybe (Maybe(..))
import Firebase (Firebase, FIREBASE)

foreign import data Provider :: * -- firebase.auth.AuthProvider

-- TODO: Handle possible null values
-- TODO: Enumerate providers and add a constructor
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

foreign import currentUserImpl :: forall a eff. (a -> Maybe a) -> Maybe a -> Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
currentUser :: forall eff. Firebase -> Eff ( firebase :: FIREBASE | eff ) (Maybe String)
currentUser fb = currentUserImpl Just Nothing fb

foreign import googleAuthProvider :: forall eff. Eff ( firebase :: FIREBASE | eff ) Provider
