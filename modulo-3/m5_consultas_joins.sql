-- Pre-entrega 5: Consultas con JOINs para el proyecto
-- Autor: Matías Agustín D'aloia
-- Fecha: 16/10/2026
-- Base: Ventas_Tech_DB, la misma del M3. Aca ya uso las 4 tablas.
-- Dimension geografica: clientes.ciudad. Dimension de producto: categorias.nombre_categoria.

USE Ventas_Tech_DB;
GO

-- DATOS DE EJEMPLO PARA LAS CONSULTAS 2 Y 3
-- En el M3 cargue todos los clientes y productos con ventas, asi que las
-- consultas de "sin ventas" me devolvian 0 filas. Agrego 2 clientes y 2
-- productos que no compraron ni se vendieron. No toco la tabla ventas, asi que
-- los numeros del M4 siguen dando igual.
-- El IF NOT EXISTS es por lo mismo que el DROP IF EXISTS del M3: que lo pueda
-- correr varias veces sin que explote ni me duplique registros.
IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente IN (6, 7))
    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro) VALUES
      (6, 'Sofía Díaz',    'sofia@mail.com', 'La Plata', '2024-03-18'),
      (7, 'Diego Herrera', 'diego@mail.com', 'Salta',    '2024-03-20');

IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto IN (7, 8))
    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
      (7, 'Webcam HD 1080p',    2, 65.00, 25, 1),
      (8, 'Parlante Bluetooth', 3, 75.00, 30, 1);
GO


-- CONSULTA 1 - Vista base del proyecto (INNER JOIN)
-- Una fila por venta con todo cruzado. Esta es la tabla que despues conecto a Power BI en el M6.
SELECT
v.id_venta,
v.fecha_venta,
c.id_cliente,
c.nombre AS cliente,
c.ciudad,
p.id_producto,
p.nombre_producto AS producto,
cat.nombre_categoria AS categoria,
v.cantidad,
v.precio_unitario,
v.cantidad*v.precio_unitario AS total_venta
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- esperado: 10 filas y total_venta suma 6444.00, igual que en el M4
-- Las 10 ventas cruzan sin que se pierda ninguna, asi que las FK del M3 quedaron bien.
-- Computacion se lleva 4950 de los 6444. Buenos Aires y Tucuman son las ciudades
-- que mas facturan, asi que por ahi van a ir los filtros del dashboard.


-- CONSULTA 2 - Clientes que nunca compraron (LEFT JOIN)
-- El LEFT JOIN me deja TODOS los clientes aunque no tengan venta. Los que no
-- compraron quedan con id_venta en NULL y ahi los filtro con IS NULL.
-- Ojo que va IS NULL y no = NULL, sino no devuelve nada.
SELECT
c.nombre,
c.email,
c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL
ORDER BY c.fecha_registro;
-- esperado: 2 filas (Sofía Díaz y Diego Herrera)
-- Son 2 de 7 clientes registrados. Los dos se anotaron despues del 15 de marzo,
-- que es la ultima venta que tengo cargada. Como el mail ya esta en la base, son
-- los que CRM puede trabajar con una promo de primera compra.


-- CONSULTA 3 - Productos sin ventas (LEFT JOIN)
-- Mismo criterio que la anterior. Con categorias uso LEFT y no INNER para no
-- perder un producto que no tenga la categoria cargada.
SELECT
p.nombre_producto AS producto,
cat.nombre_categoria AS categoria,
p.precio
--,p.stock -- lo probe con el stock tambien, pero la consigna pide nombre, categoria y precio
FROM productos p
LEFT JOIN ventas v ON p.id_producto = v.id_producto
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL
ORDER BY p.nombre_producto;
-- esperado: 2 filas (Parlante Bluetooth y Webcam HD 1080p)
-- 2 de 8 productos del catalogo no se vendieron nunca y entre los dos tienen 55
-- unidades en stock. A precio de lista son 3875 pesos parados en deposito. Hay
-- que decidir si se promocionan, se venden combinados o se sacan del catalogo.


-- CONSULTA 4 - Consolidado por canal (UNION ALL)
-- La base no guarda el canal de venta, asi que la columna la genero yo como
-- texto fijo adentro de cada SELECT. Separo por periodo dentro de marzo.
-- Los dos SELECT tienen que devolver la misma cantidad de columnas, en el mismo
-- orden y con tipos compatibles.
-- Va UNION ALL y no UNION porque UNION elimina duplicados, y dos ventas distintas
-- con los mismos valores se contarian una sola vez.
SELECT
canal,
sum(total) AS total_canal
FROM (
SELECT fecha_venta, cantidad*precio_unitario AS total, 'Del 1 al 10 de marzo' AS canal
FROM ventas
WHERE fecha_venta BETWEEN '2024-03-01' AND '2024-03-10'
UNION ALL
SELECT fecha_venta, cantidad*precio_unitario AS total, 'Del 11 al 31 de marzo' AS canal
FROM ventas
WHERE fecha_venta BETWEEN '2024-03-11' AND '2024-03-31'
) AS consolidado
GROUP BY canal
ORDER BY canal;
-- esperado: 2 filas (3620.00 y 2824.00). Suman 6444.00, igual que la consulta 1.
-- Los primeros 10 dias facturan mas que los 21 que quedan. Lo que mas me llama
-- la atencion es que despues del 15 de marzo no hay ninguna venta cargada: antes
-- de sacar conclusiones habria que ver si faltan datos o si la demanda cayo.

-- Para acordarme: INNER JOIN trae solo lo que matchea en las dos tablas.
-- LEFT JOIN trae todo lo de la izquierda y rellena con NULL lo que no matchea,
-- por eso sirve para buscar lo que NO esta.
