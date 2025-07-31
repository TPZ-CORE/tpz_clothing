
CREATE TABLE IF NOT EXISTS `outfits` (
  `identifier` varchar(45) NOT NULL,
  `charidentifier` int(11) DEFAULT NULL,
  `purchased` longtext NOT NULL DEFAULT '[]',
	`outfits` longtext NOT NULL DEFAULT '[]',
  PRIMARY KEY (`charidentifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin ROW_FORMAT=DYNAMIC;