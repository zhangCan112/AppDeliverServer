# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: localHost (MySQL 5.7.22)
# Database: schema
# Generation Time: 2018-04-25 10:44:16 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table androidDeliver
# ------------------------------------------------------------

DROP TABLE IF EXISTS `androidDeliver`;

CREATE TABLE `androidDeliver` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '唯一ID',
  `name` char(255) DEFAULT NULL COMMENT 'App名',
  `shortUrl` char(255) DEFAULT NULL COMMENT '短链接',
  `version` char(255) DEFAULT NULL COMMENT '版本信息',
  `packageName` char(255) DEFAULT NULL COMMENT '包名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table iOSDiliver
# ------------------------------------------------------------

DROP TABLE IF EXISTS `iOSDiliver`;

CREATE TABLE `iOSDiliver` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '唯一id',
  `name` char(255) DEFAULT NULL COMMENT 'App名',
  `version` char(255) DEFAULT NULL COMMENT '版本信息',
  `buildID` char(255) DEFAULT NULL COMMENT 'buildID',
  `archiveType` int(11) DEFAULT NULL COMMENT '打包类型',
  `downloadPlistFileUrl` char(255) DEFAULT NULL COMMENT ' 下载App的plist文件链接',
  `comment` text COMMENT '备注信息',
  `createTime` datetime DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

LOCK TABLES `iOSDiliver` WRITE;
/*!40000 ALTER TABLE `iOSDiliver` DISABLE KEYS */;

INSERT INTO `iOSDiliver` (`id`, `name`, `version`, `buildID`, `archiveType`, `downloadPlistFileUrl`, `comment`, `createTime`)
VALUES
	(1,'销售易CRM','1804.0.14','com.xiaoshouyi.ingage',0,'http://appdeliver.oss-cn-hangzhou.aliyuncs.com/plist/d08755b0-210b-4a0d-9ebc-a07f6b509dab-Info.plist','nil','2018-04-25 06:42:18');

/*!40000 ALTER TABLE `iOSDiliver` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
