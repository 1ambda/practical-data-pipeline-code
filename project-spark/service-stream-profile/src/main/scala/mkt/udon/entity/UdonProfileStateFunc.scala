package mkt.udon.entity

import mkt.udon.config.UdonProfileStreamConfig
import mkt.udon.core.entity.{UserEvent, UserProfile}
import mkt.udon.infra.spark.storage.DynamoSink

object UdonProfileStateFunc {

  def handlePartition(config: UdonProfileStreamConfig, iter: Iterator[UserEvent]): Unit = {
    // Dynamo Client 생성 (@ThreadSafe)
    val dynamoClient = DynamoSink.buildClient(dynamoTable = config.dynamoTable, dynamoRegion = config.dynamoRegion)

    // 사용자 마다 그룹화 해 사용자별로 이벤트 시간순 정렬을 할 수 있도록 합니다.
    val groupedByUser = iter.toList.groupBy(u => u.userId)
    groupedByUser.foreach(kv => {
      val userId = kv._1
      val userEvents = kv._2.sortBy(x => -x.eventTime) // 시간순 내림차순 정렬

      // 사용자 Profile 을 Dynamo 에서 가져오고 없을 경우 만듭니다
      val existing = DynamoSink.getItem[UserProfile](dynamoClient, keyName = "specifier", userId)
        .getOrElse(UserProfile.buildEmpty(userId))

      /**
       * 추가적으로 더 해볼 수 있는 최적화는, 사용자 이벤트 숫자를 미리 필터링 하는 것입니다.
       * 사용자 이벤트 100개 -> config.maxCount 에 의해 미리 필터링해 existing.update 호출 수를 제한할 수 있습니다.
       * 다만 사용자 이벤트에 따른 분기가 미리 일어나는 등 관련 로직을 작성해야 합니다
       */
      userEvents.foreach(event => {
        existing.update(userEvent = event, maxCountView = config.maxCountView, maxCountOrder = config.maxCountOrder)
      })

      /**
       * Stream 이나 Batch 가 여러개일 경우 Dynamo 테이블이 많아지면 API 입장에서 Dynamo Call 을 여러번해야 해 문제가 될 수 있습니다.
       * 이 때, 같은 성격의 데이터라면 Dynamo Table 을 공유하고 컬럼을 다르게 적재할 수 있습니다.
       *
       * 예를 들어, User Profile Table 내에는
       * - Kafka 에서 당겨오는 User Event 를 바탕으로 적재하는 Stream User Profile 컬럼과
       * - 배치 기반으로 Segment 를 만들어 사용자의 Segment List 를 적재하는 Batch 용 User Profile 컬럼을 만들 수 있습니다.
       * - 이 때, Dynamo 1 개의 Row 사이즈에는 제한이 있으므로 너무 많은 컬럼으로 인해 데이터 사이즈가 넘치지 않도록 주의해야 합니다.
       *
       * 만약 다른 컬럼이 다른 스트림이나 배치에서 업데이트 된다면 Put 대신에 Dynamo Update (Upsert) 를 이용할 수 있습니다.
       * - https://docs.aws.amazon.com/amazondynamodb/latest/APIReference/API_UpdateItem.html
       */
      DynamoSink.putItem(dynamoClient, existing, config.dynamoExpireDays)
    })

  }
}
