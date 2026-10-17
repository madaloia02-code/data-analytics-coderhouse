-- Pre-entrega 4: Consultas SQL de negocio
-- Autor: Matías Agustín D'aloia
-- Fecha: 16/10/2026
-- Base: Ventas_Tech_DB, la misma que arme en el M3.
-- Trabajo solo sobre la tabla ventas. Los nombres de producto y cliente los
-- traigo en el M5 cruzando con JOIN, por ahora van los IDs.
-- El total de cada venta siempre lo calculo como cantidad*precio_unitario.

USE Ventas_Tech_DB;
GO

-- CONSULTA 1 - Resumen ejecutivo mensual
-- Total facturado, cantidad de pedidos y ticket promedio.
SELECT
YEAR(fecha_venta) AS anio,
MONTH(fecha_venta) AS mes,
sum(cantidad*precio_unitario) AS total_facturado,
count(*) AS cantidad_pedidos,
avg(cantidad*precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta) -- agrupo por los dos juntos, sino marzo de 2024 y marzo de 2025 caerian en la misma fila
ORDER BY anio, mes;
-- esperado: 1 fila (2024 / 3 / 6444.00 / 10 / 644.40)


-- CONSULTA 2 - Ranking de productos (Top 5 por facturacion)
SELECT TOP 5
id_producto,
--nombre_producto, -- esto recien lo puedo traer en el M5 con el JOIN a productos
sum(cantidad) AS unidades_vendidas,
sum(cantidad*precio_unitario) AS total_generado
FROM ventas
GROUP BY id_producto
ORDER BY total_generado DESC;
-- esperado: 5 filas -> productos 1, 3, 5, 6 y 2. El 4 queda afuera por 20 pesos (360 contra 380)


-- CONSULTA 3 - Clientes recurrentes
-- Los que compraron mas de una vez. El filtro va en HAVING y no en WHERE
-- porque count(*) recien existe despues de agrupar.
SELECT
id_cliente,
count(*) AS cantidad_pedidos,
sum(cantidad*precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING count(*) > 1
ORDER BY total_gastado DESC;
-- esperado: 5 filas, los 5 clientes compraron 2 veces cada uno


-- CONSULTA 4 - Meses por encima o por debajo del promedio
-- Primero armo el total por mes en una subconsulta y despues comparo cada mes
-- contra el promedio de esos totales. La subconsulta del promedio me queda
-- repetida en los dos WHEN, es medio feo pero funciona.
SELECT
anio,
mes,
total_facturado,
CASE
WHEN total_facturado > (SELECT avg(total_mes) FROM (SELECT sum(cantidad*precio_unitario) AS total_mes FROM ventas GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)) AS t) THEN 'Por encima'
WHEN total_facturado < (SELECT avg(total_mes) FROM (SELECT sum(cantidad*precio_unitario) AS total_mes FROM ventas GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)) AS t) THEN 'Por debajo'
ELSE 'En el promedio'
END AS comparacion
FROM (
SELECT
YEAR(fecha_venta) AS anio,
MONTH(fecha_venta) AS mes,
sum(cantidad*precio_unitario) AS total_facturado
FROM ventas
GROUP BY YEAR(fecha_venta), MONTH(fecha_venta)
) AS ventas_mes
ORDER BY anio, mes;
-- esperado: 1 fila (2024 / 3 / 6444.00 / En el promedio)
-- Ojo con esto: todas las ventas que cargue son de marzo 2024, asi que queda un
-- solo mes y ese mes ES el promedio. Por eso sume la etiqueta 'En el promedio',
-- sino me devolvia 'Por debajo' y estaria mal. Con mas meses cargados anda igual.


-- HALLAZGOS
-- 1) La Laptop Pro 15 (producto 1) se lleva mas de la mitad de la facturacion:
--    3600 de 6444 con 3 unidades de las 29 que se vendieron. Todo el mes depende
--    de un solo producto, asi que si se queda sin stock se cae la facturacion.
-- 2) El mouse (producto 2) es el caso inverso: 13 unidades, casi la mitad del
--    volumen, pero deja 364. Mueve cantidad, no plata. Lo veo mas para vender
--    junto con una laptop o un monitor que por si solo.
-- 3) Los 5 clientes compraron 2 veces cada uno, pero entre el 1 y el 5 juntan
--    4740 de 6444. La recurrencia esta, el problema es que el gasto se concentra
--    en dos clientes y los otros tres compran mucho menos.

-- Para acordarme: WHERE filtra filas antes de agrupar, HAVING filtra grupos
-- despues. Si la condicion usa sum() o count() va si o si en HAVING.
