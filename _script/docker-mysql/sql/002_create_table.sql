CREATE TABLE `ListingMeta`
(
    -- primary key
    `listing_id`      BIGINT UNSIGNED NOT NULL PRIMARY KEY,
    `listing_name`    VARCHAR(240) NULL,
    `listing_desc`    TEXT NULL,
    `listing_summary` TEXT NULL,
    `listing_url`     TEXT NULL,

    -- FK columns

    -- common
    `created_at`      datetime DEFAULT CURRENT_TIMESTAMP NOT NULL

) ENGINE = InnoDB
  DEFAULT CHARSET = utf8mb4
  COLLATE = utf8mb4_unicode_ci;
