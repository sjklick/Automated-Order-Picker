-- MySQL dump 10.16  Distrib 10.1.38-MariaDB, for Linux (x86_64)
--
-- Host: localhost    Database: model
-- ------------------------------------------------------
-- Server version	10.1.38-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `category` varchar(15) NOT NULL,
  PRIMARY KEY (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES ('cookware'),('food'),('furniture'),('symbel');
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_items` (
  `order_id` int(11) NOT NULL,
  `name` varchar(20) NOT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`order_id`,`name`),
  KEY `name` (`name`),
  CONSTRAINT `order_items_ibfk_1` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`),
  CONSTRAINT `order_items_ibfk_2` FOREIGN KEY (`name`) REFERENCES `products` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE OR REPLACE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER order_item_insert
BEFORE INSERT
ON order_items
FOR EACH ROW
BEGIN
    IF NEW.quantity>(SELECT quantity FROM products WHERE name=NEW.name) THEN
    	SIGNAL SQLSTATE '45000';
	ELSE
       	UPDATE products SET quantity=quantity-NEW.quantity WHERE name=NEW.name;
	END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `order_id` int(11) NOT NULL AUTO_INCREMENT,
  `customer` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `confirmation` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `picker_states`
--

DROP TABLE IF EXISTS `picker_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `picker_states` (
  `state` varchar(9) NOT NULL,
  PRIMARY KEY (`state`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `picker_states`
--

LOCK TABLES `picker_states` WRITE;
/*!40000 ALTER TABLE `picker_states` DISABLE KEYS */;
INSERT INTO `picker_states` VALUES ('extend'),('extricate'),('home'),('idle'),('pick'),('place'),('receive'),('retract'),('retrieve'),('ship'),('stock'),('yield');
/*!40000 ALTER TABLE `picker_states` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `picker_tasks`
--

DROP TABLE IF EXISTS `picker_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `picker_tasks` (
  `task_id` int(11) NOT NULL AUTO_INCREMENT,
  `task_type` varchar(9) DEFAULT NULL,
  `item_name` varchar(50) DEFAULT NULL,
  `bin_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`task_id`),
  KEY `fk_item_name` (`item_name`),
  KEY `fk_task_type` (`task_type`),
  KEY `fk_bin_id` (`bin_id`),
  CONSTRAINT `fk_bin_id` FOREIGN KEY (`bin_id`) REFERENCES `stock_bins` (`bin_id`),
  CONSTRAINT `fk_item_name` FOREIGN KEY (`item_name`) REFERENCES `products` (`name`),
  CONSTRAINT `fk_task_type` FOREIGN KEY (`task_type`) REFERENCES `task_types` (`task_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `picker_tasks`
--

LOCK TABLES `picker_tasks` WRITE;
/*!40000 ALTER TABLE `picker_tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `picker_tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pickers`
--

DROP TABLE IF EXISTS `pickers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pickers` (
  `picker_id` int(11) NOT NULL AUTO_INCREMENT,
  `home_row` int(11) NOT NULL,
  `home_col` int(11) NOT NULL,
  `home_dir` char(1) NOT NULL,
  `curr_row` int(11) NOT NULL,
  `curr_col` int(11) NOT NULL,
  `curr_dir` char(1) NOT NULL,
  `trgt_row` int(11) DEFAULT NULL,
  `trgt_col` int(11) DEFAULT NULL,
  `trgt_dir` char(1) DEFAULT NULL,
  `state` varchar(9) NOT NULL,
  `has_item` tinyint(1) DEFAULT '0',
  `yield_count` int(11) DEFAULT '0',
  `task_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`picker_id`),
  KEY `fk_state` (`state`),
  KEY `fk_task_id` (`task_id`),
  CONSTRAINT `fk_state` FOREIGN KEY (`state`) REFERENCES `picker_states` (`state`),
  CONSTRAINT `fk_task_id` FOREIGN KEY (`task_id`) REFERENCES `picker_tasks` (`task_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pickers`
--

LOCK TABLES `pickers` WRITE;
/*!40000 ALTER TABLE `pickers` DISABLE KEYS */;
INSERT INTO `pickers` VALUES (1,1,1,'r',1,1,'r',NULL,NULL,NULL,'idle',0,0,NULL),(2,2,1,'r',2,1,'r',NULL,NULL,NULL,'idle',0,0,NULL),(3,3,1,'r',3,1,'r',NULL,NULL,NULL,'idle',0,0,NULL);
/*!40000 ALTER TABLE `pickers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `name` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `category` varchar(15) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `image_url` varchar(255) DEFAULT NULL,
  `price` decimal(7,2) DEFAULT '0.00',
  PRIMARY KEY (`name`),
  KEY `category` (`category`),
  CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category`) REFERENCES `categories` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES ('apples','1 lb. Keeps the doctor away!','food',0,'https://source.unsplash.com/JnRgmNRNoME',2.99),('bagels','Freshly baked! 6 per package.','food',0,'https://source.unsplash.com/3QfyS7y-vyY',4.75),('bananas','1 lb. A great source of Potassium.','food',0,'https://source.unsplash.com/rxUQda-9Rkk',1.99),('beige table cloth','Cotton.','symbel',0,'https://source.unsplash.com/l9SxQSi7MGI',10.00),('bread','700 g. Freshly baked!','food',0,'https://source.unsplash.com/PvAl4A6hHh8',2.50),('candle','White. Fits standard candle holders.','symbel',0,'https://source.unsplash.com/IPmZFauMzlo',2.99),('candle holder','Made from brass.','symbel',0,'https://source.unsplash.com/CrGLasofdQY',25.75),('carrots','1 lb. Excellent in salads.','food',0,'https://source.unsplash.com/yNB8niq1qCk',1.65),('chair','Brown; made from wood.','furniture',0,'https://source.unsplash.com/9xpnmt41NKM',45.99),('cherries','1 lb. Makes for a delicious summer treat!','food',0,'https://source.unsplash.com/hgQB3ZQZS_E',8.99),('coffee maker','An essential part of every home!','cookware',0,'https://source.unsplash.com/-C47gAgVGmk',34.75),('cookies','200 g. Pairs well with milk.','food',0,'https://source.unsplash.com/ot1luip6jbk',3.50),('cup','Made from glass.','symbel',0,'https://source.unsplash.com/gh14y3gpAS4',2.00),('cutting board','Made from wood.','cookware',0,'https://source.unsplash.com/uQs1802D0CQ',12.25),('eggs','1 dozen. Large size.','food',0,'https://source.unsplash.com/ECjY3Ypyl5g',3.99),('fancy chair','Stylish wooden chair.','furniture',0,'https://source.unsplash.com/9v7UJS92HYc',75.00),('fork','Made from stainless steel.','symbel',0,'https://source.unsplash.com/Pvclb-iHHYY',1.25),('frying pan','Made from steel.','cookware',0,'https://source.unsplash.com/5o8e6wzKL6U',16.00),('garlic','Comes in packs of 3 bulbs.','food',0,'https://source.unsplash.com/oVIUvwm2dvM',0.99),('grapes','1 lb. Used to make jams, wine, etc.','food',0,'https://source.unsplash.com/F_ilCik66Hg',6.50),('ground coffee','400 g. Medium roast.','food',0,'https://source.unsplash.com/ehymerU7QFI',6.99),('ham','8 oz. Perfect for a sandwich.','food',0,'https://source.unsplash.com/1OfPse1qVLM',3.50),('honey','500 mL.','food',0,'https://source.unsplash.com/kp9UVn-PUac',12.50),('kettle','White with black handle.','cookware',0,'https://source.unsplash.com/Habx5tcthEM',17.99),('kiwi','Comes in packs of 3. Pairs well with pineapple!','food',0,'https://source.unsplash.com/WJb6U3NdD54',3.00),('knife','Made from stainless steel.','symbel',0,'https://source.unsplash.com/AeqhbbHm5zk',1.25),('milk','500 mL. Pairs well with cookies.','food',0,'https://source.unsplash.com/S1HuosAnX-Y',1.00),('mixing bowl','Ceramic. Essential for baking.','cookware',0,'https://source.unsplash.com/neu4T59mTcY',10.00),('modern table','A stylish table for a modern dining experience.','furniture',0,'https://source.unsplash.com/tleCJiDOri0',1299.00),('orange juice','2 L. From concentrate.','food',0,'https://source.unsplash.com/a2AFt1wESNc',4.75),('orange pekoe tea','20 bags.','food',0,'https://source.unsplash.com/JjvLtQcegb0',4.25),('pineapple','1 lb. A tropical treat!','food',0,'https://source.unsplash.com/Q3jYvjW4NDk',4.70),('pitcher','Holds 3.5L. Made from glass.','symbel',0,'https://source.unsplash.com/K2yKpyLMVOg',15.99),('plate','Blue; ceramic.','symbel',0,'https://source.unsplash.com/6ZidnWu4h3w',4.00),('raspberries','12 oz. Tasty and healthy!','food',0,'https://source.unsplash.com/kvRSlizNRqE',9.99),('red/white table cloth','Vinyl.','symbel',0,'https://source.unsplash.com/dALwKW85F00',8.00),('skillet','Made from cast-iron.','cookware',0,'https://source.unsplash.com/It0bkN5ClD8',35.50),('sugar','Package of 200 convenient single-gram cubes.','food',0,'https://source.unsplash.com/VoQ4kqDSFxg',2.99),('table','Light brown; wooden.','furniture',0,'https://source.unsplash.com/0FAkmy9d3Jg',450.00),('teapot','Black and red; ceramic.','cookware',0,'https://source.unsplash.com/D90_p0ZinVA',24.35),('whisk','Stainless steel.','cookware',0,'https://source.unsplash.com/a1lqnSHYBgc',5.00),('wok','Black steel.','cookware',0,'https://source.unsplash.com/r8lDTtSWGUc',39.99);
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `receiving_items`
--

DROP TABLE IF EXISTS `receiving_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `receiving_items` (
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`name`),
  CONSTRAINT `receiving_items_ibfk_1` FOREIGN KEY (`name`) REFERENCES `products` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `receiving_items`
--

LOCK TABLES `receiving_items` WRITE;
/*!40000 ALTER TABLE `receiving_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `receiving_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shipping_items`
--

DROP TABLE IF EXISTS `shipping_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shipping_items` (
  `name` varchar(50) NOT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`name`),
  CONSTRAINT `shipping_items_ibfk_1` FOREIGN KEY (`name`) REFERENCES `products` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_items`
--

LOCK TABLES `shipping_items` WRITE;
/*!40000 ALTER TABLE `shipping_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `shipping_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_bins`
--

DROP TABLE IF EXISTS `stock_bins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_bins` (
  `bin_id` int(11) NOT NULL AUTO_INCREMENT,
  `row` int(11) DEFAULT NULL,
  `col` int(11) DEFAULT NULL,
  `dir` char(1) DEFAULT NULL,
  PRIMARY KEY (`bin_id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_bins`
--

LOCK TABLES `stock_bins` WRITE;
/*!40000 ALTER TABLE `stock_bins` DISABLE KEYS */;
INSERT INTO `stock_bins` VALUES (1,2,3,'l'),(2,3,3,'l'),(3,4,3,'l'),(4,2,4,'r'),(5,3,4,'r'),(6,4,4,'r'),(7,6,3,'l'),(8,7,3,'l'),(9,6,4,'r'),(10,7,4,'r'),(11,2,6,'u'),(12,3,6,'l'),(13,4,6,'l'),(14,5,6,'l'),(15,6,6,'l'),(16,7,6,'d'),(17,2,7,'u'),(18,3,7,'r'),(19,4,7,'r'),(20,5,7,'r'),(21,6,7,'r'),(22,7,7,'d');
/*!40000 ALTER TABLE `stock_bins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stock_items`
--

DROP TABLE IF EXISTS `stock_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stock_items` (
  `bin_id` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `quantity` int(11) DEFAULT NULL,
  PRIMARY KEY (`bin_id`,`name`),
  KEY `fk_name` (`name`),
  CONSTRAINT `fk_bin` FOREIGN KEY (`bin_id`) REFERENCES `stock_bins` (`bin_id`),
  CONSTRAINT `fk_name` FOREIGN KEY (`name`) REFERENCES `products` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stock_items`
--

LOCK TABLES `stock_items` WRITE;
/*!40000 ALTER TABLE `stock_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `stock_items` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER stock_item_insert
AFTER INSERT
ON stock_items
FOR EACH ROW
UPDATE products SET quantity=quantity+NEW.quantity WHERE name=NEW.name */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER stock_item_update
AFTER UPDATE
ON stock_items
FOR EACH ROW
UPDATE products SET quantity=IF(NEW.quantity>OLD.quantity, quantity+(NEW.quantity-OLD.quantity), quantity) WHERE name=OLD.name */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `task_types`
--

DROP TABLE IF EXISTS `task_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_types` (
  `task_type` varchar(7) NOT NULL,
  PRIMARY KEY (`task_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_types`
--

LOCK TABLES `task_types` WRITE;
/*!40000 ALTER TABLE `task_types` DISABLE KEYS */;
INSERT INTO `task_types` VALUES ('receive'),('ship');
/*!40000 ALTER TABLE `task_types` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-07-14  7:24:17
