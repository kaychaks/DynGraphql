{-# LANGUAGE DataKinds          #-}
{-# LANGUAGE DeriveAnyClass     #-}
{-# LANGUAGE DeriveGeneric      #-}
{-# LANGUAGE OverloadedStrings  #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell    #-}

module Main where

import           Control.Monad.Reader       (ask)
import           Papa
-- import           Prelude                    (undefined)
import qualified Data.ByteString.Char8      as BS
import           GHC.Generics               (Generic)

import           Snap
import           Snap.Util.FileServe


import qualified GraphQL                    as GQL
import qualified GraphQL.API                as GQL
import qualified GraphQL.Internal.Execution as GQL
import qualified GraphQL.Internal.Output    as GQL

----------------------------------------


-- data Order = Order {
--   _oid     :: Int,
--   _odate   :: String,
--   _ocount  :: Int,
--   _ostatus :: String
-- } deriving (Generic, Show)
-- makeLenses ''Order

data App = App {
  _response :: Snaplet GQL.Response
}
makeLenses ''App

-- schema
type Order = GQL.Object "Order" '[] '[]


handleQuery :: Handler App GQL.Response ()
handleQuery = do
  initResp <- ask
  writeBS $ BS.pack $ show initResp

graphQLInit :: SnapletInit b GQL.Response
graphQLInit = makeSnaplet "graphql-response" "" Nothing $ do
  return $ GQL.PreExecutionFailure $ GQL.singleError GQL.NoAnonymousOperation

siteSnaplet :: SnapletInit App App
siteSnaplet = makeSnaplet "App" "" Nothing $ do
  resp <- nestSnaplet "" response $ graphQLInit
  addRoutes [
    ("graphql", with response handleQuery),
    -- ("", writeBS "hello world"),
    ("echo/:echoparam", echoHandlerSnaplet),
    ("foo", writeBS "bar"),
    ("", serveDirectory "./static/")
    ]
  return $ App resp

echoHandlerSnaplet :: Handler b v ()
echoHandlerSnaplet = do
    param <- getParam "echoparam"
    maybe (writeBS "must specify echo/param in URL")
          writeBS param


main :: IO ()
main = serveSnaplet defaultConfig siteSnaplet

-- site :: Snap ()
-- site =
--     ifTop (writeBS "hello world") <|>
--     route [ ("foo", writeBS "bar")
--           , ("echo/:echoparam", echoHandler)
--           ] <|>
--     dir "static" (serveDirectory ".")

-- echoHandler :: Snap ()
-- echoHandler = do
--     param <- getParam "echoparam"
--     maybe (writeBS "must specify echo/param in URL")
--           writeBS param


-- main :: IO ()
-- main = quickHttpServe site
