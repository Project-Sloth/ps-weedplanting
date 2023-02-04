CREATE TABLE IF NOT EXISTS `weedplants` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `coords` longtext NOT NULL CHECK (json_valid(`coords`)),
  `growth` int(255) NOT NULL DEFAULT 0,
  `nutrition` int(255) NOT NULL DEFAULT 0,
  `water` int(255) NOT NULL DEFAULT 0,
  `health` int(255) NOT NULL DEFAULT 100,
  `gender` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
)