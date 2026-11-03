# RetailPro — Proyecto de Data Analytics

Proyecto integrador del curso de Data Analytics de Coderhouse. RetailPro es una empresa
ficticia que vende tecnología (computación, accesorios, audio y almacenamiento). A lo largo
del curso armé la base de datos, la consulté con SQL y después llevé los datos a Power BI.

Autor: Matías Agustín D'aloia.

## Herramientas

- **Microsoft SQL Server** (T-SQL), ejecutado desde **SQL Server Management Studio (SSMS)**.
  Hace falta SQL Server 2016 o superior, porque los scripts usan `DROP TABLE IF EXISTS`.
- **Power BI Desktop**, con Power Query (lenguaje M) para la limpieza y DAX para las medidas.

## Contenido del repositorio

| Carpeta / archivo | Qué es |
|---|---|
| `modulo-3/ventas_tech_db.sql` | Crea la base `Ventas_Tech_DB`, las 4 tablas con sus claves y carga los datos iniciales (M3) |
| `modulo-3/m4_consultas_negocio.sql` | Consultas de negocio con `GROUP BY`, `HAVING` y `CASE` (M4) |
| `modulo-3/m5_consultas_joins.sql` | Consultas con `INNER JOIN`, `LEFT JOIN` y `UNION ALL` (M5) |
| `modulo-8/` | Modelo de Power BI: relaciones, tabla calendario y medidas DAX (M8) |

## Modelo de datos

`Ventas_Tech_DB` está normalizada en tercera forma normal:

- **categorias** (`id_categoria`) → tiene muchos **productos**
- **clientes** (`id_cliente`) → hace muchas **ventas**
- **productos** (`id_producto`, con `id_categoria` como FK) → aparece en muchas **ventas**
- **ventas** (`id_venta`, con `id_cliente` e `id_producto` como FK) guarda cantidad,
  precio unitario y fecha. El precio se guarda en la venta para conservar el que se cobró,
  aunque después cambie el de lista.

## Cómo ejecutar los scripts en SSMS

1. Descargá los archivos de la carpeta `modulo-3` (o el repositorio entero con *Code → Download ZIP*).
2. Abrí SSMS y conectate a tu servidor. No hace falta elegir una base.
3. Abrí y ejecutá **primero `ventas_tech_db.sql`** (F5). Crea la base y deja 4, 5, 6 y 10 filas
   en categorias, clientes, productos y ventas.
4. Después ejecutá `m4_consultas_negocio.sql` y `m5_consultas_joins.sql`. Cada consulta tiene
   abajo un comentario `-- esperado:` con el resultado que tiene que dar.

Ojo con un detalle: `m5_consultas_joins.sql` agrega 2 clientes y 2 productos sin ventas, que
necesitan las consultas de "sin ventas". No toca la tabla ventas, así que los totales del M4 no
cambian. Si querés volver a los datos originales, ejecutá otra vez `ventas_tech_db.sql`.

## Power BI

La parte de Power BI trabaja sobre el dataset del curso (`Pipeline_ETL_Dataset.xlsx`), que tiene
las mismas 4 tablas con más registros. En Power Query limpié duplicados y nulos y armé
`Dim_Clientes`, `Dim_Productos`, `Dim_Categorias` y `Fact_Ventas` (M6). En el M8 sumé las
relaciones 1:N, la tabla calendario `Dim_Fechas` y una tabla `_Medidas` con 5 medidas DAX.
