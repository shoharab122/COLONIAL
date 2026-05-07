-- MySQL dump 10.13  Distrib 9.3.0, for macos15.2 (arm64)
--
-- Host: localhost    Database: amoura_db
-- ------------------------------------------------------
-- Server version	9.3.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(50) NOT NULL,
  `discount_type` enum('percentage','fixed') DEFAULT 'percentage',
  `discount_value` decimal(10,2) NOT NULL,
  `min_order_amount` decimal(10,2) DEFAULT '0.00',
  `valid_from` date DEFAULT NULL,
  `valid_to` date DEFAULT NULL,
  `usage_limit` int DEFAULT '1',
  `used_count` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupons`
--

LOCK TABLES `coupons` WRITE;
/*!40000 ALTER TABLE `coupons` DISABLE KEYS */;
INSERT INTO `coupons` VALUES (1,'WELCOME10','percentage',10.00,1000.00,'2026-04-18','2026-05-18',100,0,1),(2,'SAVE200','fixed',200.00,1500.00,'2026-04-18','2026-05-03',50,0,1),(3,'FREESHIP','fixed',100.00,800.00,'2026-04-18','2026-04-25',20,0,1);
/*!40000 ALTER TABLE `coupons` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text,
  `total_orders` int DEFAULT '0',
  `total_spent` decimal(10,2) DEFAULT '0.00',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES (1,'demo@amoura.com','Demo User','01700000000','Dhaka, Bangladesh',0,0.00,'2026-04-17 22:11:41'),(6,'sajid','sajid','111',NULL,3,6950.00,'2026-04-18 04:52:15'),(9,'l','l','l',NULL,1,1550.00,'2026-04-18 15:46:34'),(10,'shoharab chy','SSSS','SSW',NULL,3,10650.00,'2026-04-19 11:17:04'),(13,'k','j','lp',NULL,1,3000.00,'2026-04-19 17:52:08'),(14,'sdfgsert','tyj','fghf',NULL,1,1550.00,'2026-04-19 17:53:29');
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_number` varchar(50) DEFAULT NULL,
  `customer_name` varchar(255) NOT NULL,
  `customer_email` varchar(255) NOT NULL,
  `customer_phone` varchar(20) DEFAULT NULL,
  `shipping_address` text,
  `total_amount` decimal(10,2) NOT NULL,
  `discount_applied` decimal(10,2) DEFAULT '0.00',
  `final_amount` decimal(10,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT 'cash_on_delivery',
  `payment_status` varchar(50) DEFAULT 'pending',
  `order_status` varchar(50) DEFAULT 'pending',
  `items` json DEFAULT NULL,
  `notes` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_number` (`order_number`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
INSERT INTO `orders` VALUES (1,'AMR-1776487935920-713','sajid','sajid','111','111',3100.00,0.00,3100.00,'cash_on_delivery','pending','pending','[{\"id\": 12, \"name\": \"Tailored Trousers\", \"price\": 1550, \"quantity\": 2}]',NULL,'2026-04-18 04:52:15'),(6,'AMR-1776597424453-582','SSSS','shoharab chy','SSW','SS',2950.00,0.00,2950.00,'cash_on_delivery','pending','pending','[{\"id\": 16, \"name\": \"Leather Ankle Boots\", \"price\": \"2950.00\", \"quantity\": 1}]',NULL,'2026-04-19 11:17:04'),(7,'AMR-1776598155870-990','z','shoharab chy','z','z',5500.00,0.00,5500.00,'cash_on_delivery','pending','pending','[{\"id\": 12, \"name\": \"Tailored Trousers\", \"price\": \"1650.00\", \"quantity\": 2}, {\"id\": 13, \"name\": \"Linen Blazer\", \"price\": \"2200.00\", \"quantity\": 1}]',NULL,'2026-04-19 11:29:15'),(8,'AMR-1776598663608-389','e','shoharab chy','e','e',2200.00,0.00,2200.00,'cash_on_delivery','pending','pending','[{\"id\": 13, \"name\": \"Linen Blazer\", \"price\": \"2200.00\", \"quantity\": 1}]',NULL,'2026-04-19 11:37:43'),(9,'AMR-1776621128853-658','j','k','lp','l',3000.00,0.00,3000.00,'cash_on_delivery','pending','pending','[{\"id\": 11, \"name\": \"Cashmere Turtleneck\", \"price\": 3000, \"quantity\": 1}]',NULL,'2026-04-19 17:52:08'),(10,'AMR-1776621209694-120','tyj','sdfgsert','fghf','dusty',1550.00,0.00,1550.00,'cash_on_delivery','pending','pending','[{\"id\": 12, \"name\": \"Tailored Trousers\", \"price\": 1550, \"quantity\": 1}]',NULL,'2026-04-19 17:53:29');
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_variants`
--

DROP TABLE IF EXISTS `product_variants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_variants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `product_id` int NOT NULL,
  `size` varchar(20) DEFAULT NULL,
  `color` varchar(50) DEFAULT NULL,
  `color_code` varchar(20) DEFAULT NULL,
  `stock` int DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `product_id` (`product_id`),
  CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_variants`
--

LOCK TABLES `product_variants` WRITE;
/*!40000 ALTER TABLE `product_variants` DISABLE KEYS */;
INSERT INTO `product_variants` VALUES (1,1,'S','Black','#000000',5),(2,1,'M','Black','#000000',10),(3,1,'L','Black','#000000',8),(4,1,'M','Gray','#9ca3af',6),(5,1,'M','Camel','#b45309',4),(6,1,'S','Black','#000000',5),(7,1,'M','Black','#000000',10),(8,1,'L','Black','#000000',8),(9,1,'M','Gray','#9ca3af',6),(10,1,'M','Camel','#b45309',4),(11,1,'S','Black','#000000',5),(12,1,'M','Black','#000000',10),(13,1,'L','Black','#000000',8),(14,1,'M','Gray','#9ca3af',6),(15,1,'M','Camel','#b45309',4),(16,1,'S','Black','#000000',5),(17,1,'M','Black','#000000',10),(18,1,'L','Black','#000000',8),(19,1,'M','Gray','#9ca3af',6),(20,1,'M','Camel','#b45309',4),(21,1,'S','Black','#000000',5),(22,1,'M','Black','#000000',10),(23,1,'L','Black','#000000',8),(24,1,'M','Gray','#9ca3af',6),(25,1,'M','Camel','#b45309',4),(26,1,'S','Black','#000000',5),(27,1,'M','Black','#000000',10),(28,1,'L','Black','#000000',8),(29,1,'M','Gray','#9ca3af',6),(30,1,'M','Camel','#b45309',4);
/*!40000 ALTER TABLE `product_variants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `price` decimal(10,2) NOT NULL COMMENT 'Original price in BDT',
  `discount_amount` decimal(10,2) DEFAULT '0.00' COMMENT 'Discount in BDT (fixed amount)',
  `category` varchar(100) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT '/placeholder.jpg',
  `badge` varchar(50) DEFAULT NULL,
  `materials` text,
  `colors` text,
  `care` varchar(255) DEFAULT NULL,
  `stock` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
INSERT INTO `products` VALUES (1,'Oversized Wool Coat','Premium wool blend coat with relaxed silhouette.',2890.00,200.00,'Coats','/placeholder.jpg','New',NULL,NULL,NULL,15,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(2,'Silk Midi Dress','Elegant silk dress perfect for evening events.',1950.00,0.00,'Dresses','/placeholder.jpg',NULL,NULL,NULL,NULL,10,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(3,'Cashmere Turtleneck','Luxurious cashmere turtleneck for ultimate comfort.',3500.00,500.00,'Knitwear','/placeholder.jpg','-500 BDT',NULL,NULL,NULL,8,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(4,'Tailored Trousers','Sharp tailored trousers for modern professionals.',1650.00,100.00,'Trousers','/placeholder.jpg',NULL,NULL,NULL,NULL,20,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(5,'Linen Blazer','Breathable linen blazer for warm days.',2200.00,150.00,'Coats','/placeholder.jpg',NULL,NULL,NULL,NULL,12,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(6,'Pleated Skirt','Flowing pleated skirt with elegant movement.',1450.00,0.00,'Skirts','/placeholder.jpg',NULL,NULL,NULL,NULL,15,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(7,'Structured Bag','Architectural leather bag for daily sophistication.',3800.00,300.00,'Accessories','/placeholder.jpg','Limited',NULL,NULL,NULL,5,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(8,'Leather Ankle Boots','Classic leather boots with modern sole.',2950.00,250.00,'Footwear','/placeholder.jpg',NULL,NULL,NULL,NULL,10,1,'2026-04-17 22:11:41','2026-04-17 22:11:41'),(11,'Cashmere Turtleneck','Luxurious cashmere turtleneck for ultimate comfort.',3500.00,500.00,'Knitwear','/placeholder.jpg','-500 BDT',NULL,NULL,NULL,7,1,'2026-04-18 04:06:15','2026-04-19 17:52:08'),(12,'Tailored Trousers','Sharp tailored trousers for modern professionals.',1650.00,100.00,'Trousers','/placeholder.jpg',NULL,NULL,NULL,NULL,13,1,'2026-04-18 04:06:15','2026-04-19 17:53:29'),(13,'Linen Blazer','Breathable linen blazer for warm days.',2200.00,150.00,'Coats','/placeholder.jpg',NULL,NULL,NULL,NULL,9,1,'2026-04-18 04:06:15','2026-04-19 11:37:43'),(14,'Pleated Skirt','Flowing pleated skirt with elegant movement.',1450.00,0.00,'Skirts','/placeholder.jpg',NULL,NULL,NULL,NULL,15,1,'2026-04-18 04:06:15','2026-04-18 04:06:15'),(15,'Structured Bag','Architectural leather bag for daily sophistication.',3800.00,300.00,'Accessories','/placeholder.jpg','Limited',NULL,NULL,NULL,5,1,'2026-04-18 04:06:15','2026-04-18 04:06:15'),(16,'Leather Ankle Boots','Classic leather boots with modern sole.',2950.00,250.00,'Footwear','/placeholder.jpg',NULL,NULL,NULL,NULL,9,1,'2026-04-18 04:06:15','2026-04-19 11:17:04'),(18,'Cropped Shirt','Unisex',1599.99,0.00,'Cropped Shirt','/Users/md.shoharabchowdury/Downloads/1000049971.jpg',NULL,'Cotton','blue',NULL,10,1,'2026-04-19 11:52:01','2026-04-19 11:52:24');
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `role` enum('admin','customer') DEFAULT 'customer',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `google_id` varchar(255) DEFAULT NULL,
  `avatar` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`),
  UNIQUE KEY `google_id` (`google_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'admin@amoura.com','$2b$10$NWz0don41PgczwVApvZ3WOp.K.DHJVbnc5tcpTzHiU.yykiBQxO5W','Admin User','admin','2026-04-18 04:21:37',NULL,NULL),(2,'customer@amoura.com','$2b$10$.FbzuyWAGSlI5vkE4fV/Cu/OGDJb4O89AHG8OdU8RoUYZaj..D7nq','Test Customer','customer','2026-04-18 04:21:37',NULL,NULL),(5,'shoharabchy@gmail.com','$2b$10$og2LOO6jQqHPv3/y5dbYjOJT8dZia/Nf7YzIHEuyrbdliJUQvWLx6','Shoharab','customer','2026-04-18 04:37:21',NULL,NULL),(6,'shoharab','$2b$10$gtXoL1DO3sqX3Ub2BcA59Omz22b7A8hkW02hx5.AZGUJEnZcYQ1FG','Shoharab','customer','2026-04-18 04:49:53',NULL,NULL),(7,'sajid','$2b$10$ycfEB4YqYSujRgySysq0WukXPjsdznJY5dlj15lxBoDYvWAgF.Saa','sajid','customer','2026-04-18 04:50:52',NULL,NULL),(9,'shoharab chy','$2b$10$Jes5ywUTYisQ2qLfgg1ryOcoeQPX7ZmbS.Am1gLdHhuEhQUhh9hCO','shoharab','customer','2026-04-19 11:16:43',NULL,NULL),(10,'sdfgsert','$2b$10$wBjxeqq3rL0Rvm9seVnNZesugk5cqGO2sw4irC9z9G2XJn9SAq9JS','ew4t','customer','2026-04-19 17:53:01',NULL,NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-04 11:58:01
