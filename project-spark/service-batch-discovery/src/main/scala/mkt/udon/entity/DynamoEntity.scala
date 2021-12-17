package mkt.udon.entity

case class ProductPoolElement(id: String, rank: Long)

case class ProductPool(specifier: String, elements: List[ProductPoolElement], elementCount: Long)
