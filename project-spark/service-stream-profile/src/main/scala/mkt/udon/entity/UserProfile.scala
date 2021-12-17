package mkt.udon.entity

import mkt.udon.entity.UserProfile.{EVENT_ORDER, EVENT_VIEW}

/**
 * User Profile 에 저장될 View Event 입니다.
 */
case class UserEventView(eventTime: Long, productId: String)
/**
 * User Profile 에 저장될 Order Event 입니다.
 */
case class UserEventOrder(eventTime: Long, productId: String, price: Double)

/**
 * Dynamo 등의 Storage 에 저장될 수 있는 User Profile 입니다.
 *
 * totalOrderPrice 와 같이 사용자에 대한 전체 이벤트에 집계를 수행할수도 있습니다.
 * eventOrder 등의 경우에는 List 타입이고 무한히 늘어날 수 없으므로 최근 N 개만 저장합니다.
 *
 * @param specifier  사용자 ID
 * @param eventView  최근 상품 방문 이벤트 목록
 * @param eventOrder 최근 상품 주문 이벤트 목록
 */
case class UserProfile(specifier: String,

                       var eventView: List[UserEventView] = List(),
                       var eventOrder: List[UserEventOrder] = List()) {

  def update(userEvent: UserEvent,
             maxCountView: Int, maxCountOrder: Int): UserProfile = {

    if (userEvent.eventType == EVENT_VIEW) handleView(userEvent.convertToUserEventView(), maxCountView)
    else if (userEvent.eventType == EVENT_ORDER) handleOrder(userEvent.convertToUserEventOrder(), maxCountOrder)

    return this
  }

  def handleView(eventRecent: UserEventView, maxCount: Int) = {
    val merged = (eventView :+ eventRecent)
    val sorted = merged.sortBy(x => -x.eventTime).take(maxCount)

    eventView = sorted
  }

  def handleOrder(eventRecent: UserEventOrder, maxCount: Int) = {
    val merged = (eventOrder :+ eventRecent)
    val sorted = merged.sortBy(x => -x.eventTime).take(maxCount)

    eventOrder = sorted
  }

}

object UserProfile {
  val EVENT_VIEW = "view"
  val EVENT_ORDER = "order"

  def buildEmpty(userId: String): UserProfile = {
    UserProfile(specifier = userId, eventView = List(), eventOrder = List())
  }
}