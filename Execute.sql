CREATE TABLE IF NOT EXISTS `rickymdt` (
  `identifier` varchar(500) NOT NULL DEFAULT '',
  `note` mediumtext DEFAULT '',
  `wanted` varchar(500) NOT NULL DEFAULT 'false',
  `crimes` mediumtext DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;


CREATE TABLE IF NOT EXISTS `rickymdt_rapporti` (
  `identifier` varchar(500) NOT NULL DEFAULT '',
  `rapporto` varchar(500) NOT NULL DEFAULT '',
  `data` varchar(500) NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

