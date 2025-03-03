{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}
{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TypeApplications #-}
{-# OPTIONS_GHC -Wno-deprecations #-}
{-# OPTIONS_GHC -Wno-orphans #-}

module Lib.Scheduler.JobStorageType.SchedulerType where

import qualified Data.ByteString as BS
import qualified Data.Map as M
import Data.Singletons
import Kernel.Beam.Functions (FromTType'')
import Kernel.Prelude
import Kernel.Tools.Metrics.CoreMetrics.Types
import Kernel.Types.Id
import Kernel.Utils.Common
import Kernel.Utils.Time ()
import Lib.Scheduler.Environment
import Lib.Scheduler.JobStorageType.DB.Queries as DBQ
import qualified Lib.Scheduler.JobStorageType.DB.Table as BeamST
import qualified Lib.Scheduler.JobStorageType.Redis.Queries as RQ
import Lib.Scheduler.Types

createJob :: forall t (e :: t) m r. (JobFlow t e, JobCreator r m) => Int -> JobContent e -> m ()
createJob maxShards jobData = do
  schedulerType <- asks (.schedulerType)
  let jobType = show $ fromSing (sing :: Sing e)
  case schedulerType of
    RedisBased -> do
      longRunning <- isLongRunning jobType
      logDebug $ "LONG RUNNING " <> show longRunning
      if longRunning
        then do
          DBQ.createJob @t @e maxShards jobData
          RQ.createJob @t @e maxShards jobData
        else do
          RQ.createJob @t @e maxShards jobData
    DbBased -> do
      logDebug "DB BASED JOB "
      DBQ.createJob @t @e maxShards jobData

createJobIn :: forall t (e :: t) m r. (JobFlow t e, JobCreator r m) => NominalDiffTime -> Int -> JobContent e -> m ()
createJobIn inTime maxShards jobData = do
  schedulerType <- asks (.schedulerType)
  let jobType = show $ fromSing (sing :: Sing e)
  case schedulerType of
    RedisBased -> do
      longRunning <- isLongRunning jobType
      logDebug $ "LONG RUNNING " <> show longRunning
      if longRunning
        then do
          DBQ.createJobIn @t @e inTime maxShards jobData
          RQ.createJobIn @t @e inTime maxShards jobData
        else do
          RQ.createJobIn @t @e inTime maxShards jobData
    DbBased -> do
      logDebug "DB BASED JOB "
      DBQ.createJobIn @t @e inTime maxShards jobData

isLongRunning :: (JobCreator r m) => Text -> m Bool
isLongRunning jType = do
  jobInfoMap <- asks (.jobInfoMap)
  logDebug $ "jobInfoMap : " <> show jobInfoMap
  let jobInfoMapping = jobInfoMap
  pure $ fromMaybe False (M.lookup jType jobInfoMapping)

createJobByTime :: forall t (e :: t) m r. (JobFlow t e, JobCreator r m) => UTCTime -> Int -> JobContent e -> m ()
createJobByTime byTime maxShards jobData = do
  schedulerType <- asks (.schedulerType)
  let jobType = show $ fromSing (sing :: Sing e)
  case schedulerType of
    RedisBased -> do
      longRunning <- isLongRunning jobType
      logDebug $ "LONG RUNNING " <> show longRunning
      if longRunning
        then do
          DBQ.createJobByTime @t @e byTime maxShards jobData
          RQ.createJobByTime @t @e byTime maxShards jobData
        else do
          RQ.createJobByTime @t @e byTime maxShards jobData
    DbBased -> do
      logDebug "DB BASED JOB "
      DBQ.createJobByTime @t @e byTime maxShards jobData

findAll :: forall t m r. (FromTType'' BeamST.SchedulerJob (AnyJob t), JobExecutor r m, JobProcessor t) => m [AnyJob t]
findAll = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> RQ.findAll
    DbBased -> DBQ.findAll

findById :: forall t m r. (FromTType'' BeamST.SchedulerJob (AnyJob t), JobExecutor r m, JobProcessor t) => Id AnyJob -> m (Maybe (AnyJob t))
findById id = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> RQ.findById id
    DbBased -> DBQ.findById id

getTasksById :: forall t m r. (FromTType'' BeamST.SchedulerJob (AnyJob t), JobExecutor r m, JobProcessor t) => [Id AnyJob] -> m [AnyJob t]
getTasksById jobs = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> RQ.getTasksById jobs
    DbBased -> DBQ.getTasksById jobs

getReadyTasks ::
  forall t m r.
  (FromTType'' BeamST.SchedulerJob (AnyJob t), JobExecutor r m, JobProcessor t, HasField "version" r DeploymentVersion) =>
  Maybe Int ->
  m [(AnyJob t, BS.ByteString)]
getReadyTasks mbMaxShards = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> RQ.getReadyTasks mbMaxShards
    DbBased -> DBQ.getReadyTasks mbMaxShards

updateStatus :: forall m r. (JobExecutor r m, HasField "jobInfoMap" r (M.Map Text Bool)) => Text -> JobStatus -> Id AnyJob -> m ()
updateStatus jobType status id = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> do
      bool
        ( RQ.updateStatus status id
        )
        ( do
            DBQ.updateStatus status id
            RQ.updateStatus status id
        )
        =<< isLongRunning jobType
    DbBased -> DBQ.updateStatus status id

markAsComplete :: forall m r. (JobExecutor r m, HasField "jobInfoMap" r (M.Map Text Bool)) => Text -> Id AnyJob -> m ()
markAsComplete jobType id = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> do
      bool
        ( RQ.markAsComplete id
        )
        ( do
            DBQ.markAsComplete id
            RQ.markAsComplete id
        )
        =<< isLongRunning jobType
    DbBased -> DBQ.markAsComplete id

markAsFailed :: forall m r. (JobExecutor r m, HasField "jobInfoMap" r (M.Map Text Bool)) => Text -> Id AnyJob -> m ()
markAsFailed jobType id = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> do
      bool
        ( RQ.markAsFailed id
        )
        ( do
            DBQ.markAsFailed id
            RQ.markAsFailed id
        )
        =<< isLongRunning jobType
    DbBased -> DBQ.markAsFailed id

updateErrorCountAndFail :: forall m r. (JobExecutor r m, HasField "jobInfoMap" r (M.Map Text Bool), Forkable m, CoreMetrics m) => Text -> Id AnyJob -> Int -> m ()
updateErrorCountAndFail jobType id errorCount = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> do
      bool
        ( RQ.updateErrorCountAndFail id errorCount
        )
        ( do
            DBQ.updateErrorCountAndFail id errorCount
            RQ.updateErrorCountAndFail id errorCount
        )
        =<< isLongRunning jobType
    DbBased -> DBQ.updateErrorCountAndFail id errorCount

reSchedule :: forall m r t. (JobExecutor r m, HasField "jobInfoMap" r (M.Map Text Bool)) => Text -> AnyJob t -> UTCTime -> m ()
reSchedule jobType job@(AnyJob x) time = do
  let id = x.id
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> do
      bool
        ( RQ.reSchedule job time
        )
        ( do
            DBQ.reSchedule id time
            RQ.reSchedule job time
        )
        =<< isLongRunning jobType
    DbBased -> DBQ.reSchedule id time

updateFailureCount :: forall m r. (JobExecutor r m, HasField "jobInfoMap" r (M.Map Text Bool)) => Text -> Id AnyJob -> Int -> m ()
updateFailureCount jobType id failureCount = do
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> do
      bool
        ( RQ.updateFailureCount id failureCount
        )
        ( do
            DBQ.updateFailureCount id failureCount
            RQ.updateFailureCount id failureCount
        )
        =<< isLongRunning jobType
    DbBased -> DBQ.updateFailureCount id failureCount

reScheduleOnError :: forall m r t. (JobExecutor r m, HasField "jobInfoMap" r (M.Map Text Bool)) => Text -> AnyJob t -> Int -> UTCTime -> m ()
reScheduleOnError jobType job@(AnyJob x) newCountValue time = do
  let id = x.id
  schedulerType <- asks (.schedulerType)
  case schedulerType of
    RedisBased -> do
      bool
        ( RQ.reScheduleOnError job newCountValue time
        )
        ( do
            DBQ.reScheduleOnError id newCountValue time
            RQ.reScheduleOnError job newCountValue time
        )
        =<< isLongRunning jobType
    DbBased -> DBQ.reScheduleOnError id newCountValue time
