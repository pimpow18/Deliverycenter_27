CREATE database db_deliverycenter;

USE db_deliverycenter;

CREATE TABLE `db_deliverycenter`.`channels` (
  `channel_id` int DEFAULT NULL,
  `channel_name` text,
  `channel_type` text);

CREATE TABLE `db_deliverycenter`.`hubs` (
  `hub_id` int DEFAULT NULL,
  `hub_name` text,
  `hub_city` text,
  `hub_state` text,
  `hub_latitude` double DEFAULT NULL,
  `hub_longitude` double DEFAULT NULL);

CREATE TABLE `db_deliverycenter`.`stores` (
  `store_id` int DEFAULT NULL,
  `hub_id` int DEFAULT NULL,
  `store_name` text,
  `store_segment` text,
  `store_plan_price` int DEFAULT NULL,
  `store_latitude` text,
  `store_longitude` text);


CREATE TABLE `db_deliverycenter`.`drivers` (
  `driver_id` int DEFAULT NULL,
  `driver_modal` text,
  `driver_type` text);


CREATE TABLE `db_deliverycenter`.`deliveries` (
  `delivery_id` int DEFAULT NULL,
  `delivery_order_id` int DEFAULT NULL,
  `driver_id` int DEFAULT NULL,
  `delivery_distance_meters` int DEFAULT NULL,
  `delivery_status` text);


CREATE TABLE `db_deliverycenter`.`payments` (
  `payment_id` int DEFAULT NULL,
  `payment_order_id` int DEFAULT NULL,
  `payment_amount` double DEFAULT NULL,
  `payment_fee` double DEFAULT NULL,
  `payment_method` text,
  `payment_status` text);


CREATE TABLE `db_deliverycenter`.`orders` (
  `order_id` int DEFAULT NULL,
  `store_id` int DEFAULT NULL,
  `channel_id` int DEFAULT NULL,
  `payment_order_id` int DEFAULT NULL,
  `delivery_order_id` int DEFAULT NULL,
  `order_status` text,
  `order_amount` double DEFAULT NULL,
  `order_delivery_fee` int DEFAULT NULL,
  `order_delivery_cost` text,
  `order_created_hour` int DEFAULT NULL,
  `order_created_minute` int DEFAULT NULL,
  `order_created_day` int DEFAULT NULL,
  `order_created_month` int DEFAULT NULL,
  `order_created_year` int DEFAULT NULL,
  `order_moment_created` text,
  `order_moment_accepted` text,
  `order_moment_ready` text,
  `order_moment_collected` text,
  `order_moment_in_expedition` text,
  `order_moment_delivering` text,
  `order_moment_delivered` text,
  `order_moment_finished` text,
  `order_metric_collected_time` text,
  `order_metric_paused_time` text,
  `order_metric_production_time` text,
  `order_metric_walking_time` text,
  `order_metric_expediton_speed_time` text,
  `order_metric_transit_time` text,
  `order_metric_cycle_time` text);
  
select * from hubs;
select * from payments;


-- 1 Qual o número de hubs por cidade?
select count(hub_city),hub_city from hubs group by hub_city;

-- 2 Qual o número de pedidos (orders) por status?
select count(order_status),order_status from orders group by order_status;

-- 3- Qual o número de lojas (stores) por cidade dos hubs?
select avg(hub_city) from hubs;

-- 4- Qual o maior e o menor valor de pagamento (payment_amount) registrado?
select max(payment_amount),min(payment_amount) from payments;

-- 5- Qual tipo de driver (driver_type) fez o maior número de entregas?
select COUNT(driver_type), driver_type FROM drivers
GROUP BY driver_type ORDER BY max(driver_type);

-- 6- Qual a distância média das entregas por tipo de driver (driver_modal)?
SELECT AVG(delivery_distance_meters) FROM drivers AS dr
INNER JOIN deliveries AS de ON dr.driver_id = de.driver_id 
GROUP BY driver_modal limit 10;

-- 7- Qual a média de valor de pedido (order_amount) por loja, em ordem decrescente?
SELECT s.store_id,s.store_name,
AVG(o.order_amount) AS average_order_amount FROM stores s
JOIN orders o ON s.store_id = o.store_id
GROUP BY s.store_id,s.store_name
ORDER BY average_order_amount DESC;

-- 8- Existem pedidos que não estão associados a lojas? Se caso positivo, quantos?
SELECT COUNT(*) AS count_orders_without_store
FROM orders WHERE store_id is null;

-- 9- Qual o valor total de pedido (order_amount) no channel 'FOOD PLACE'?
SELECT SUM(o.order_amount) AS total_pedido FROM orders AS o 
INNER JOIN channels AS c ON o.channel_id = c.channel_id
WHERE c.channel_name = 'FOOD PLACE';

-- 10- Quantos pagamentos foram cancelados (chargeback)?
SELECT COUNT(*) AS pagamentos_cancelados
FROM payments WHERE payment_status = 'chargeback';

-- 11- Qual foi o valor médio dos pagamentos cancelados (chargeback)?
SELECT AVG(payment_amount) AS media_pagamentos_cancelados
FROM payments WHERE payment_status = 'chargeback';

-- 12- Qual a média do valor de pagamento por método de pagamento (payment_method) em ordem decrescente?
SELECT payment_method, AVG(payment_amount) AS media_pagamento_metodo
FROM payments GROUP BY payment_method
ORDER BY media_pagamento_metodo DESC;

-- 13- Quais métodos de pagamento tiveram valor médio superior a 100?
SELECT payment_method FROM payments
GROUP BY payment_method HAVING AVG(payment_amount) > 100;

-- 14- Qual a média de valor de pedido (order_amount) por estado do hub (hub_state), segmento da loja (store_segment) e tipo de canal (channel_type)?
SELECT hub_state, store_segment, channel_type, AVG(order_amount) AS average_order_amount FROM orders o
JOIN hubs h ON o.store_id = h.hub_id
JOIN stores s ON o.store_id = s.store_id
JOIN channels c ON o.channel_id = c.channel_id
GROUP BY hub_state, store_segment, channel_type;

-- 15- Qual estado do hub (hub_state), segmento da loja (store_segment) e tipo de canal (channel_type) teve média de valor de pedido (order_amount) maior que 450?
SELECT hubs.hub_state, stores.store_segment, channels.channel_type FROM hubs
LEFT JOIN stores ON hubs.hub_id = stores.hub_id
LEFT JOIN orders ON stores.store_id = orders.store_id
LEFT JOIN channels ON orders.channel_id = channels.channel_id
GROUP BY hubs.hub_state, stores.store_segment, channels.channel_type
HAVING AVG(orders.order_amount) > 450;