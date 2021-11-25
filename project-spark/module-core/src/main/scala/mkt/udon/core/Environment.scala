package mkt.udon.core

import pureconfig._
import pureconfig.generic.auto._

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

  def getConfigOrThrow[T :ClassTag: ConfigReader](): T = {

    val config = ConfigSource.default.at(mode).loadOrThrow[T]
    config
  }

}
