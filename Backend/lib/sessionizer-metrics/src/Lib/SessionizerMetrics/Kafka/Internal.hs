{-
 Copyright 2022-23, Juspay India Pvt Ltd

 This program is free software: you can redistribute it and/or modify it under the terms of the GNU Affero General Public License

 as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version. This program

 is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY

 or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for more details. You should have received a copy of

 the GNU Affero General Public License along with this program. If not, see <https://www.gnu.org/licenses/>.
-}

module Lib.SessionizerMetrics.Kafka.Internal where

import Kernel.Prelude
import Kernel.Streaming.Kafka.Producer (produceMessage)
import Kernel.Streaming.Kafka.Producer.Types (KafkaProducerTools)
import Kernel.Types.Common
import Kernel.Utils.Common
import Lib.SessionizerMetrics.Kafka.Config
import Lib.SessionizerMetrics.Types.Event

streamUpdates ::
  ( MonadFlow m,
    Monad m,
    Log m,
    MonadReader r0 m,
    HasFlowEnv m r '["kafkaProducerTools" ::: KafkaProducerTools],
    ToJSON p
  ) =>
  Event p ->
  KafkaConfig ->
  m ()
streamUpdates event kcfg = do
  let topicName = kcfg.topicName
  let key = kcfg.kafkaKey
  produceMessage
    (topicName, Just (encodeUtf8 key))
    event
