package mkt.udon.infra.spark.storage

import com.amazonaws.regions.{Region, Regions}
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder
import com.amazonaws.services.dynamodbv2.document.{DynamoDB, Item}
import com.amazonaws.services.dynamodbv2.model.PutItemRequest
import mkt.udon.core.TimeUtil
import org.apache.spark.sql.{DataFrame, Dataset}
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

  def putItem(dynamoTable: String,
              keyName: String,
              keyValue: String,
              expireDays: Int,
              expireFieldName: String,
              updateFieldName: String,
              dfTarget: DataFrame): Unit = {


  }

}
