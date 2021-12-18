package mkt.udon.entity

import mkt.udon.core.entity.{ProductPool, ProductPoolElement}
import org.apache.spark.sql.expressions.Window
import org.apache.spark.sql.functions._
import org.apache.spark.sql.{DataFrame, Dataset, SparkSession}

object UdonProductPoolEntity {

  val EVENT_VIEW = "view"
  val EVENT_CART = "cart"
  val EVENT_ORDER = "purchase"

  def convert(session: SparkSession, dfUserEvent: DataFrame,
              maxElementCount: Int): Dataset[ProductPool] = {

    import session.implicits._

    val dfFiltered = dfUserEvent.selectExpr("product_id", "user_id", "user_session")
      .where(col("event_type").isInCollection(List(EVENT_VIEW)))

    /**
     * 상품과 상품들을 연관짓기 위해 사용자 Session 을 사용합니다. 이 방법의 기본적인 가정은
     * - 사용자가 의도를 가진 채로 상품을 탐색하는 하나의 Session 동안에는 '연관된 상품' 을 보았을 거라 가정하고
     * - 하나의 세션 내에서 같이 본 상품은 사용자 관점에서 유의미 하게 비슷할거라는 가설을 가지고 있습니다.
     *
     * 서비스에 나가는 추천들은 실제로는 더 복잡한 모델을 이용하고 정제되어 있는 많은 Feature 를 이용하지만,
     * 여기에서는 가장 기본적인 데이터 가공을 통해 상품 Pool 을 구성하기 위해 위에서 언급한 방법을 이용합니다.
     *
     * 이 방법을 응용하면 Search Together, View Together, Cart Together, Order Together 와 같은 상품 Pool 을 만들 수 있습니다.
     * 혹은 각각의 Unique Session ID 혹은 Unique User ID, 단순 Count 등을 Feature 로 삼아 통계적으로 각 Feature 의 비율을 조합해 내보낼 수도 있습니다.
     *
     * 사용자의 행위 기반 외에도 도메인이 숙박이라면 상품 메타 정보 (거리, 가격) 등의 메트릭 유사도를 추가할 수 있습니다.
     */
    val dfJoined = dfFiltered.alias("L")
      .join(
        dfFiltered.alias("R"),
        col("L.user_session") === col("R.user_session") &&
          col("L.product_id") =!= col("R.product_id"),
        "inner"
      )
      .selectExpr(
        "L.product_id as product_id",
        "R.product_id as product_id_other",
        "L.user_session"
      )

    // 순위 생성 및 maxElementCount 를 이용해 필터링
    val windowRank = Window.partitionBy(col("product_id")).orderBy(col("count_session_uniq").desc)
    val dfGrouped = dfJoined
      .groupBy("product_id", "product_id_other")
      .agg(countDistinct("user_session").as("count_session_uniq"))
      .withColumn("rank", row_number().over(windowRank))
      .where(col("rank") <= lit(maxElementCount))

    // 배열로 만들기 위해 UDF 를 통해 Case Class 로 변경
    // 주의사항: Spark 의 'collect_list' 는 순서를 보존하지 않으므로 Rank 값 없이 리스트화 하면 상품의 순서가 보존되지 않을 수 있습니다.
    val udfElementize = udf((id: String, rank: Long) =>
      ProductPoolElement(id = id, rank = rank))
    val dfConverted = dfGrouped
      .withColumn("element", udfElementize(col("product_id_other"), col("rank")))
      .groupBy("product_id")
      .agg(collect_list("element").as("elements"), count("*").as("element_count"))


    return dfConverted.selectExpr("product_id as specifier", "elements", "element_count as elementCount").as[ProductPool]
  }

}
