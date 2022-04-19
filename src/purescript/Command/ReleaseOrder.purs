module Command.ReleaseOrder where

import Prelude

import Constants (releaseFiles)
import DependencyGraph (generateAllReleaseInfo, linearizePackageDependencyOrder, useNextMajorVersion)
import Effect.Aff (Aff)
import Node.Encoding (Encoding(..))
import Node.FS.Aff (writeTextFile)

generateReleaseOrder :: Aff Unit
generateReleaseOrder = do
  { unfinishedPkgsGraph } <- generateAllReleaseInfo useNextMajorVersion
  writeTextFile UTF8 releaseFiles.releaseOrderFile
    $ linearizePackageDependencyOrder unfinishedPkgsGraph
