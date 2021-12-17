package mkt.udon.entity

import mkt.udon.core.TimeUtil
import org.apache.spark.sql._
import org.apache.spark.sql.functions._
import org.apache.spark.sql.types._

object UdonStatEntity {

  def convert(session: SparkSession, partition: String,
              dfPropertyMeta: DataFrame,
              dfPropertySales: DataFrame,
              dfPropertyReview: DataFrame): DataFrame = {

    val partitionDate = TimeUtil.convertPartitionToDateString(partition)

    /**
     * 상품 메타
     */
    val dfMeta = dfPropertyMeta
      .selectExpr("CAST(id AS BIGINT) as property_id", "property_type", "latitude", "longitude")

    /**
     * 상품 메트릭 누적 (리뷰)
     */
    val dfMetricReviewTotal = dfPropertyMeta
      .selectExpr("CAST(id AS BIGINT) as property_id", "number_of_reviews as count_review_all", "review_scores_rating as score_review_all")

    /**
     * 상품 메트릭 델타 (리뷰)
     */
    val dfMetricReviewDelta = dfPropertyReview
      .selectExpr("CAST(listing_id AS BIGINT) as property_id", "CAST(date as DATE) as date")
      .where(col("date") === lit(partitionDate).cast(DateType))
      .groupBy("property_id")
      .agg(count("*").as("count_review"))

    /**
     * 상품 메트릭 델타 (판매)
     */
    val dfMetricSalesDelta = dfPropertySales
      .selectExpr("CAST(listing_id AS BIGINT) as property_id", "CAST(date as DATE) as date", "price as price_raw")
      .where(col("date") === lit(partitionDate).cast(DateType))
      .where(col("available") === lit("f"))
      .withColumn("price", regexp_extract(col("price_raw"), "[0-9]+.[0-9]+", 0).cast(DoubleType))
      .drop("price_raw")
      .groupBy("property_id")
      .agg(
        count("*").as("count_sales"),
        sum("price").as("price_sales")
      )

    /**
     * 결과 데이터 프레임 내 2 가지 성격의 데이터가 섞여 있습니다.
     * - 누적 데이터 (전체 기간 내 최신 값)
     * - 일별 데이터 (해당 일에 대한 변동 값)
     *
     * 이 데이터를 하나의 결과 테이블로 만드는게 맞을지 / 아니면 Spark Application 과 테이블을 분리하는게 맞을지 논의해 봅시다.
     */
    val dfJoined = dfMeta.alias("PROPERTY_META")
      .join(dfMetricReviewTotal.alias("METRIC_REVIEW_TOTAL"),
        col("PROPERTY_META.property_id") === col("METRIC_REVIEW_TOTAL.property_id"), "left")
      .join(dfMetricReviewDelta.alias("METRIC_REVIEW_DELTA"),
        col("PROPERTY_META.property_id") === col("METRIC_REVIEW_DELTA.property_id"), "left")
      .join(dfMetricSalesDelta.alias("METRIC_SALES_DELTA"),
        col("PROPERTY_META.property_id") === col("METRIC_SALES_DELTA.property_id"), "left")
      .selectExpr(
        "PROPERTY_META.property_id as property_id",
        "PROPERTY_META.property_type as property_type",
        "PROPERTY_META.latitude as lat",
        "PROPERTY_META.longitude as lng",

        "coalesce(METRIC_REVIEW_TOTAL.count_review_all, 0) as count_review_all",
        "coalesce(METRIC_REVIEW_TOTAL.score_review_all, 0.0) as score_review_all",

        "coalesce(METRIC_REVIEW_DELTA.count_review, 0) as count_review",

        "coalesce(METRIC_SALES_DELTA.count_sales, 0) as count_sales",
        "CAST(coalesce(METRIC_SALES_DELTA.price_sales, 0) AS BIGINT) as price_sales"
      )

    return dfJoined
  }

}
