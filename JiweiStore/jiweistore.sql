-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Creato il: Mag 25, 2023 alle 23:23
-- Versione del server: 10.4.27-MariaDB
-- Versione PHP: 8.1.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `jiweistore`
--

DELIMITER $$
--
-- Procedure
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `all_orders` (`status_code` VARCHAR(10))   BEGIN
  SELECT 
    o.id as order_id
        , o.created_at as created_date
        , o.updated_at as shipped_date
        , o.status as status
        , o.user_id as user_id
        , u.email as user_descr
    FROM orders o
    INNER JOIN user u
    ON o.user_id = u.id
  WHERE
        (status_code is NULL OR status_code = o.status)
    ORDER BY
    o.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cart_items` (`cart_identifier` INT)   BEGIN
  SELECT 
    c.id as cart_id
        , ci.id as cart_item_id
        , p.name as product_name
        , p.id as product_id
        , p.description as product_description
        , ifnull(ci.quantity, 0) as quantity
        , ifnull(p.price, 0) as single_price
        , ifnull(ci.quantity,0) * ifnull(p.price, 0) as total_price
    FROM
    cart as c
        INNER JOIN cart_item as ci
      ON c.id = ci.cart_id
        INNER JOIN product as p
      ON p.id = ci.product_id
     WHERE
    ifnull(cart_identifier, 0) = 0
        OR cart_identifier = c.id;
        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cart_total` (`cart_identifier` INT)   BEGIN
 SELECT 
  c.id as cart_id
  , c.user_id as user_id
    , SUM(ifnull(ci.quantity, 0)) as num_products
    , SUM(ifnull(ci.quantity, 0) * ifnull(p.price, 0)) as total
 FROM 
  cart as c
  INNER JOIN cart_item as ci
    ON c.id = ci.cart_id
  INNER JOIN product as p
    ON ci.product_id = p.id
  WHERE
    cart_identifier = c.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cart_to_order` (`cart_identifier` INT, `order_identifier` INT)   BEGIN
  INSERT INTO order_item (order_id, product_id, quantity)
    SELECT order_identifier, ci.product_id, ci.quantity
    FROM cart c
    INNER JOIN cart_item ci
      ON c.id = ci.cart_id
  WHERE
    c.id = cart_identifier;
        
  DELETE cart, cart_item
    FROM cart
    INNER JOIN cart_item
    ON cart.id = cart_item.cart_id
  WHERE
    cart.id = cart_identifier;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order_email` (`order_identifier` INT)   BEGIN
  SELECT u.email, u.first_name
    FROM orders as o
    INNER JOIN user as u
    ON o.user_id = u.id
  WHERE 
    o.id = order_identifier;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `order_items` (`order_identifier` INT)   BEGIN
  SELECT 
    o.id as order_id
        , o.status as order_status
        , oi.id as order_item_id
        , p.name as product_name
        , p.id as product_id
        , p.description as product_description
        , ifnull(oi.quantity, 0) as quantity
        , ifnull(p.price, 0) as single_price
        , ifnull(oi.quantity,0) * ifnull(p.price, 0) as total_price
    FROM
    orders as o
        INNER JOIN order_item as oi
      ON o.id = oi.order_id
        INNER JOIN product as p
      ON p.id = oi.product_id
     WHERE
    ifnull(order_identifier, 0) = 0
        OR order_identifier = o.id;
        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `order_total` (`order_identifier` INT)   BEGIN
 SELECT 
  o.id as order_id
  , o.user_id as user_id
    , SUM(ifnull(oi.quantity, 0)) as num_products
    , SUM(ifnull(oi.quantity, 0) * ifnull(p.price, 0)) as total
 FROM 
  orders as o
  INNER JOIN order_item as oi
    ON o.id = oi.order_id
  INNER JOIN product as p
    ON oi.product_id = p.id
  WHERE
    order_identifier = o.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `user_orders` (`user_identifier` INT, `status_code` VARCHAR(10))   BEGIN
  SELECT 
    o.id as order_id
        , o.created_at as created_date
        , o.updated_at as shipped_date
        , o.status as status
    FROM orders o
  WHERE
    o.user_id = user_identifier
        AND (status_code is NULL OR status_code = o.status)
    ORDER BY
    o.created_at DESC;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struttura della tabella `address`
--

CREATE TABLE `address` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `street` varchar(255) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `cap` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dump dei dati per la tabella `address`
--

INSERT INTO `address` (`id`, `user_id`, `street`, `city`, `cap`) VALUES
(2, 1, 'Via Admin 1', 'Roma', '00100'),
(3, 2, 'Via Regular 2', 'Roma', '00100'),
(7, 13, 'Tremana 102', 'Bergamo', '24444');

-- --------------------------------------------------------

--
-- Struttura della tabella `cart`
--

CREATE TABLE `cart` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `client_id` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dump dei dati per la tabella `cart`
--

INSERT INTO `cart` (`id`, `user_id`, `client_id`) VALUES
(69, 0, '876005ea434af330b4dd'),
(70, 1, ''),
(73, 0, 'f157dc5df58d8f9f4760'),
(77, 2, ''),
(80, 13, '');

-- --------------------------------------------------------

--
-- Struttura della tabella `cart_item`
--

CREATE TABLE `cart_item` (
  `id` int(11) NOT NULL,
  `cart_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dump dei dati per la tabella `cart_item`
--

INSERT INTO `cart_item` (`id`, `cart_id`, `product_id`, `quantity`) VALUES
(48, 19, 6, 3),
(49, 19, 14, 2),
(57, 25, 14, 20),
(58, 69, 6, 1),
(63, 70, 6, 2);

-- --------------------------------------------------------

--
-- Struttura della tabella `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dump dei dati per la tabella `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `created_at`, `updated_at`, `status`) VALUES
(4, 1, '2019-05-02 12:21:15', NULL, 'pending'),
(12, 2, '2019-05-02 14:20:31', NULL, 'pending'),
(13, 1, '2019-05-02 15:39:08', '2019-05-02 20:39:59', 'shipped'),
(24, 2, '2023-05-25 20:32:34', NULL, 'pending'),
(25, 2, '2023-05-25 20:42:01', NULL, 'pending'),
(26, 2, '2023-05-25 20:43:48', NULL, 'pending'),
(27, 13, '2023-05-25 20:45:51', NULL, 'pending'),
(28, 13, '2023-05-25 20:49:25', NULL, 'pending');

-- --------------------------------------------------------

--
-- Struttura della tabella `order_item`
--

CREATE TABLE `order_item` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dump dei dati per la tabella `order_item`
--

INSERT INTO `order_item` (`id`, `order_id`, `product_id`, `quantity`) VALUES
(70, 4, 6, 10),
(71, 4, 14, 9),
(100, 12, 6, 9),
(101, 12, 26, 6),
(102, 12, 33, 1),
(103, 12, 14, 2),
(107, 13, 14, 2),
(131, 24, 6, 1),
(132, 25, 6, 1),
(133, 26, 6, 1),
(134, 27, 6, 1),
(135, 28, 6, 1);

-- --------------------------------------------------------

--
-- Struttura della tabella `product`
--

CREATE TABLE `product` (
  `id` int(11) NOT NULL,
  `name` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `description` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `category_id` int(11) NOT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_general_ci;

--
-- Dump dei dati per la tabella `product`
--

INSERT INTO `product` (`id`, `name`, `description`, `category_id`, `price`) VALUES
(6, 'Micronde', '../shop//pages/micronde.jpg', 1, '399.99'),
(14, 'Frigorifero', '../shop//pages/frigorifero.jpg', 1, '999.00'),
(26, 'Aspirapolvere', '../shop//pages/aspirapolvere.jpg', 1, '299.99'),
(33, 'Lavastoviglie', '../shop//pages/lavastoviglie.jpg', 1, '199.99');

-- --------------------------------------------------------

--
-- Struttura della tabella `tabella_file`
--

CREATE TABLE `tabella_file` (
  `id` int(10) NOT NULL,
  `nome` varchar(255) DEFAULT NULL,
  `tipo` varchar(128) DEFAULT NULL,
  `dati` blob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struttura della tabella `user`
--

CREATE TABLE `user` (
  `id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `user_type` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dump dei dati per la tabella `user`
--

INSERT INTO `user` (`id`, `first_name`, `last_name`, `email`, `created_at`, `user_type`, `password`) VALUES
(1, 'Amministratore', 'Di Sistema', 'admin@email.com', '2019-04-26 21:26:37', 'admin', 'password'),
(2, 'Regolare', 'Utente', 'regular@email.com', '2019-05-02 16:34:56', 'regular', 'password'),
(13, 'kai', 'ji', 'jiweikai03@gmail.com', '2023-05-25 20:45:34', 'regular', 'Jiweikai2003');

--
-- Indici per le tabelle scaricate
--

--
-- Indici per le tabelle `address`
--
ALTER TABLE `address`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `cart_item`
--
ALTER TABLE `cart_item`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `order_item`
--
ALTER TABLE `order_item`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `tabella_file`
--
ALTER TABLE `tabella_file`
  ADD PRIMARY KEY (`id`);

--
-- Indici per le tabelle `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT per le tabelle scaricate
--

--
-- AUTO_INCREMENT per la tabella `address`
--
ALTER TABLE `address`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT per la tabella `cart`
--
ALTER TABLE `cart`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=81;

--
-- AUTO_INCREMENT per la tabella `cart_item`
--
ALTER TABLE `cart_item`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT per la tabella `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=29;

--
-- AUTO_INCREMENT per la tabella `order_item`
--
ALTER TABLE `order_item`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=136;

--
-- AUTO_INCREMENT per la tabella `product`
--
ALTER TABLE `product`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT per la tabella `tabella_file`
--
ALTER TABLE `tabella_file`
  MODIFY `id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT per la tabella `user`
--
ALTER TABLE `user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
