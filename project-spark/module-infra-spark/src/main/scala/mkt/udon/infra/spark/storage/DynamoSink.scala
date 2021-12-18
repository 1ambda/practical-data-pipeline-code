package mkt.udon.infra.spark.storage

import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder
import com.amazonaws.services.dynamodbv2.document.{DynamoDB, Item, Table}
import mkt.udon.core.common.TimeUtil
import org.apache.spark.sql.Dataset
import org.json4s.jackson.JsonMethods.parse
import org.json4s.jackson.Serialization.write
import org.json4s.{DefaultFormats, Extraction, FieldSerializer, Formats, JLong, JObject}

import java.time.Instant

object DynamoSink {

  def writePartition[T](dynamoTable: String,
                        dynamoRegion: String,
                        expireDays: Int,
                        dsTarget: Dataset[T],
                        expireFieldName: String = "expireTtl",
                        updateFieldName: String = "updatedAt"
                       )(implicit m: Manifest[T]): Unit = {

    dsTarget.foreachPartition((iter: Iterator[T]) => {
      val dynamoClient = AmazonDynamoDBClientBuilder.standard().withRegion(dynamoRegion).build();
      val dynamoDB = new DynamoDB(dynamoClient)
      val client = dynamoDB.getTable(dynamoTable)

      while (iter.hasNext) {
        val cur = iter.next()
        implicit val default: Formats = DefaultFormats.preservingEmptyValues + FieldSerializer[T]()

        val updatedAt = Instant.now().toEpochMilli
        val expireTtl = TimeUtil.getExpireEpochSeconds(expireDays)

        val json = Extraction.decompose(cur)
          .merge(JObject(updateFieldName -> JLong(updatedAt)))
          .merge(JObject(expireFieldName -> JLong(expireTtl)))
          .snakizeKeys

        val stringified = write(json)
        val request = Item.fromJSON(stringified)

        client.putItem(request)
      }
    })
  }

  def putItem[A](dynamoClient: Table,
                 item: A,
                 expireDays: Int,
                 expireFieldName: String = "expireTtl",
                 updateFieldName: String = "updatedAt")(implicit m: Manifest[A]): Unit = {

    // FieldSerializer 는 `private` 필드 사용시 패키지 명 까지 필드 이름에 포함되므로 사용에 유의
    // Scala Enum 값 변환을 위해서는 EnumNameSerializer 가 필요하나 저장용 Case Class 에서 일반적으로 String 으로 사용
    implicit val default: Formats = DefaultFormats.preservingEmptyValues + FieldSerializer[A]()

    val updatedAt = Instant.now().toEpochMilli
    val expireTtl = TimeUtil.getExpireEpochSeconds(expireDays)

    val json = Extraction.decompose(item)
      .merge(JObject("updatedAt" -> JLong(updatedAt)))
      .merge(JObject("expireTtl" -> JLong(expireTtl)))
      .camelizeKeys

    val stringified = write(json)
    val request = Item.fromJSON(stringified)

    dynamoClient.putItem(request)
  }

  def getItem[A](dynamoClient: Table,
                 keyName: String, keyValue: String)(implicit m: Manifest[A]): Option[A] = {

    val responseItem = dynamoClient.getItem(keyName, keyValue)

    if (responseItem == null) None
    else {
      implicit val format = DefaultFormats.preservingEmptyValues
      val raw = responseItem.toJSON
      val parsed = parse(raw).camelizeKeys
      val converted = parsed.extract[A]
      Some(converted)
    }
  }

  def buildClient(dynamoTable: String, dynamoRegion: String): Table = {
    val dynamoClient = AmazonDynamoDBClientBuilder.standard().withRegion(dynamoRegion).build();
    val dynamoDB = new DynamoDB(dynamoClient)
    val client = dynamoDB.getTable(dynamoTable)
    return client
  }

}
