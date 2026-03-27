CREATE TABLE IF NOT EXISTS `toy7_match_skill_usage` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `match_id` INT UNSIGNED NOT NULL,
  `char_id` INT UNSIGNED NOT NULL,
  `team` TINYINT UNSIGNED NOT NULL,
  `skill_id` SMALLINT UNSIGNED NOT NULL,
  `skill_name` VARCHAR(100) NOT NULL DEFAULT '',
  `uses` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_match_char_team_skill` (`match_id`,`char_id`,`team`,`skill_id`),
  KEY `idx_match_team_uses` (`match_id`,`team`,`uses`),
  KEY `idx_match_skill` (`match_id`,`skill_id`),
  KEY `idx_char_match` (`char_id`,`match_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
