package mkt.udon.core.entity

import mkt.udon.core.common.TimeUtil
import org.json4s.{DefaultFormats, Formats}
import org.json4s.jackson.Serialization

case class UserEvent(eventTime: Long, eventType: String, userId: String, productId: String, price: Double) {
  def convertToUserEventView(): UserEventView = {
    UserEventView(eventTime, productId)
  }

  def convertToUserEventOrder(): UserEventOrder = {
    UserEventOrder(eventTime, productId, price)
  }
}

case class UserEventRaw(event_time: String, event_type: String, product_id: String, price: Double, user_id: String) {
  def convert(): UserEvent = {
    val eventTime = TimeUtil.convertStringToEpochMillis(event_time)
    UserEvent(eventTime = eventTime, eventType = event_type, userId = user_id, productId = product_id, price = price)
  }
}

object UserEvent {
  def convertFromRaw(raw: String): UserEvent = {
    implicit val default: Formats = DefaultFormats.preservingEmptyValues
    val parsed = Serialization.read[UserEventRaw](raw)
    parsed.convert()
  }
}

