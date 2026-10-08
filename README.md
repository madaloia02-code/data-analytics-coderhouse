# Ventas_Tech_DB — Módulo 3: Introducción a SQL y Sublenguajes

## Descripción del proyecto

Base de datos relacional para una empresa que vende productos de tecnología (computación, accesorios, audio y almacenamiento). Registra qué clientes compran, qué productos se venden, a qué categoría pertenece cada producto y el detalle de cada venta.

Este trabajo corresponde a la pre-entrega del Módulo 3 del curso de Data Analytics (Coderhouse). El script implementa el modelo relacional diseñado en el Módulo 2, normalizado hasta la Tercera Forma Normal (3FN), y carga datos iniciales de ejemplo.

## Motor de base de datos

- **Microsoft SQL Server** (dialecto T-SQL)
- **SQL Server Management Studio (SSMS)** para ejecutar el script
- Versión mínima recomendada: SQL Server 2016, porque el script usa `DROP TABLE IF EXISTS`

## Contenido del repositorio

| Archivo | Descripción |
|---|---|
| `modulo-3/ventas_tech_db.sql` | Script completo: creación de la base, tablas (DDL), carga de datos (DML) y validación |
| `README.md` | Este documento |

## Modelo de datos

La base `Ventas_Tech_DB` tiene cuatro tablas:

| Tabla | Clave primaria | Descripción | Columnas principales |
|---|---|---|---|
| `categorias` | `id_categoria` | Clasificación de los productos | `nombre_categoria`, `descripcion` |
| `clientes` | `id_cliente` | Personas que realizan compras | `nombre`, `email` (único), `ciudad`, `fecha_registro` |
| `productos` | `id_producto` | Catálogo de productos | `nombre_producto`, `id_categoria` (FK), `precio`, `stock` (default 0), `activo` (default 1) |
| `ventas` | `id_venta` | Registro de cada venta | `id_cliente` (FK), `id_producto` (FK), `cantidad`, `precio_unitario`, `fecha_venta` |

### Relaciones

- Una **categoría** tiene muchos **productos** (`productos.id_categoria` → `categorias.id_categoria`).
- Un **cliente** realiza muchas **ventas** (`ventas.id_cliente` → `clientes.id_cliente`).
- Un **producto** aparece en muchas **ventas** (`ventas.id_producto` → `productos.id_producto`).

### Decisiones de diseño

- Los montos (`precio`, `precio_unitario`) usan `DECIMAL(10,2)` y no `FLOAT`, para evitar errores de redondeo en valores monetarios.
- `precio_unitario` se guarda en `ventas` para conservar el precio vigente al momento de la compra, aunque el precio del producto cambie después.
- `email` tiene restricción `UNIQUE` para que no haya dos clientes con el mismo correo.
- `stock` y `activo` tienen valores por defecto (`0` y `1`).

## Estructura del script

El archivo `ventas_tech_db.sql` está dividido en cuatro secciones, delimitadas por comentarios:

1. **DROP:** elimina las tablas si existen, en orden inverso a sus dependencias (`ventas`, `productos`, `clientes`, `categorias`).
2. **CREATE:** crea las tablas en orden jerárquico, con sus claves primarias, foráneas y restricciones.
3. **INSERT:** carga los datos iniciales, con las columnas indicadas de forma explícita.
4. **VALIDACIÓN:** ejecuta un `SELECT *` por tabla para verificar la carga.

Antes de la sección 1, el script crea la base `Ventas_Tech_DB` si todavía no existe y se posiciona en ella. Gracias al orden del `DROP` y al `IF EXISTS`, se puede ejecutar varias veces sin errores.

## Datos de ejemplo

| Tabla | Registros |
|---|---|
| `categorias` | 4 |
| `clientes` | 5 |
| `productos` | 6 |
| `ventas` | 10 |
| **Total** | **25** |

## Cómo ejecutar el script en SSMS

1. Abrí **SQL Server Management Studio** y conectate a tu instancia de SQL Server (local o remota).
2. Descargá `modulo-3/ventas_tech_db.sql` de este repositorio.
3. En SSMS, andá a **Archivo → Abrir → Archivo...** y seleccioná `ventas_tech_db.sql`.
4. Verificá que la conexión activa sea tu servidor. No hace falta elegir una base: el script crea `Ventas_Tech_DB` y la selecciona con `USE`.
5. Presioná **Ejecutar** (o la tecla **F5**).
6. Revisá la pestaña **Resultados**: deberían aparecer cuatro tablas con 4, 5, 6 y 10 filas.

Si querés volver a empezar desde cero, volvé a ejecutar el script completo: la sección DROP elimina las tablas y se recrean con los datos iniciales.

## Autor

Matías — Curso de Análisis de Datos, Coderhouse (Módulo 3).
