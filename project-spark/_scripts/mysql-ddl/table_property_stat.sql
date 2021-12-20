CREATE TABLE pipeline.property_stat
(
    property_id   BIGINT UNSIGNED NOT NULL,
    property_type VARCHAR(30)                        NOT NULL,
    lat DOUBLE(40, 10) NOT NULL,
    lng DOUBLE(40, 10) NOT NULL,

    count_review_all BIGINT UNSIGNED  NOT NULL,
    score_review_all DOUBLE(10, 5) NOT NULL,

    count_review BIGINT UNSIGNED  NOT NULL,
    count_sales BIGINT UNSIGNED  NOT NULL,
    price_sales BIGINT UNSIGNED  NOT NULL,

    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,

    part                  TIMESTAMP                               NOT NULL COMMENT '데이터 파티션',

  PRIMARY KEY (property_id, part),
  INDEX idx_property_stat_combined (part, property_id)

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;

