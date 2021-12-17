package mkt.udon.core

import pureconfig._
import pureconfig.generic.ProductHint

import scala.reflect.ClassTag

object Environment {
  /** deployment */
  private val LOCAL = "LOCAL"
  private val DEVELOPMENT = "DEV"
  private val STAGING = "STAGE"
  private val PRODUCTION = "PROD"

  /** testing */
  private val UNIT = "UNIT"
  private val INTEGRATION = "INTEGRATION"

  private val mode = {
    var env: String = LOCAL

    val extractedEnv = System.getenv("PIPELINE_MODE")
    if (extractedEnv != null) {
      env = extractedEnv.toLowerCase()
    }

    env
  }

  def isLocalMode(): Boolean = {
    mode == LOCAL
  }

  /**
   * pureconfig 내에서 camel-case 사용을 위한 implicit 변수 생성
   * - https://pureconfig.github.io/docs/overriding-behavior-for-case-classes.html#field-mappings
   */
  def buildConfigHint[T](): ProductHint[T] = {
    return ProductHint[T](ConfigFieldMapping(CamelCase, CamelCase))
  }

  /**
   * 모드에 따라 다른 설정값 로딩하기 위한 함수
   */
  def getConfigOrThrow[T: ClassTag : ConfigReader]()(implicit productHint: ProductHint[T]): T = {
    val config = ConfigSource.default.at(mode).loadOrThrow[T]
    config
  }

}
