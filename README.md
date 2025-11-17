# Pipeline de Streaming para Monitoreo de Puentes con Delta Live Tables

Demostración práctica de un pipeline ETL de streaming a nivel productivo utilizando Databricks Delta Live Tables (DLT). Se simulan sensores IoT en puentes importantes, se ingieren tres flujos crudos (temperatura, vibración e inclinación), se enriquecen con metadatos estáticos y se calculan métricas en ventanas de 10 minutos usando watermarks, agregaciones por ventanas y joins entre flujos y tablas estáticas.
---

## Estructura del Repositorio

- **queries.sql**  
  Contiene consultas ad hoc SQL para explorar y validar la salida de Delta Live Tables (DLT) en todas las capas

- **00_data_generator.ipynb**  
  Define `generate_stream()`: emite continuamente lecturas sintéticas de sensores en Delta paths, uno por minuto, con un pequeño retraso aleatorio de timestamp para simular retrasos en el mundo real.

- **01_bronze_processing.ipynb**  
  Capa Bronze: crea tres tablas de streaming (`01_bronze.puente_temperatura`, `01_bronze.puente_vibracion`, `01_bronze.puente_inclinacion`) que leen archivos Delta crudos tan pronto como llegan.

- **02_silver_processing.ipynb**  
  Capa Silver:  
  - `02_silver.puente_metadata`: tabla estática con los metadatos de los puentes.  
  - Tres tablas de streaming enriquecidas que unen cada flujo de bronce a la metadata estática y aplican expectativas de calidad de datos.

- **03_gold_processing.ipynb**  
  Capa Gold:  
  - Lee las tres tablas de streaming de Silver con un watermark de 2 minutos.  
  - Calcula agregados por ventana de 10 minutos:  
    - **avg_temperatura**  
    - **max_vibracion**  
    - **max_inclinacion**  
  - Joins them by `(puente_id, window_start, window_end)` into `03_gold.puente_metrics`.

---

## Prerrequisitos

- Databricks workspace con Unity Catalog enabled  
- Un cluster ejecutando un runtime de Databricks compatible con DLT  
- Python 3.8+ y dependencias de PySpark 

---

## Estructura en Unity Catalog
- Crear un catalogo gestionado llamado `bridge_monitoring`
- Crear esquemas en el catalogo llamados `00_landing`, `01_bronze`, `02_silver` y `03_gold`
- Crear un volume gestionado en el esquema `00_landing` llamado `streaming`
- En el volume `streaming` crear tres subdirectorios llamados `puente_temperatura`, `puente_vibracion` y `puente_inclinacion`

---

## Paso 1: Simular datos de sensores

1. Abrir **00_data_generator.ipynb**.  
2. Proporcionar tus Delta paths en la lista `streams`.  
3. Ejecutar el notebook; se iniciaran tres generadores en segundo plano que agregaran nuevos datos cada minuto, con un retraso aleatorio de timestamp de 0–60 s.

---

## Paso 2: Ingestión de Bronze

1. Crear una nueva pipeline DLT en Databricks, adjuntando **01_bronze_processing.ipynb** como fuente de notebook.  
2. Configurar la pipeline para usar tu esquema de Unity Catalog (por ejemplo, `bridge_monitoring.bronze`).  
3. Ejecutar—tres tablas de streaming aparecerán, capturando eventos crudos de temperatura, vibración y inclinación.

---

## Paso 3: Enriquecimiento de Silver

1. Agregar **02_silver_processing.ipynb** a la misma pipeline.  
2. Asegurarse de que los nombres de los esquemas sean `bridge_monitoring.silver`.  
3. Ejecutar—DLT materializara:  
   - `puente_metadata` (static)  
   - Tres tablas de streaming enriquecidas con `@dlt.expect_or_drop` checks y stream–static joins.

---

## Paso 4: Agregación de Gold

1. Agregar **03_gold_processing.ipynb** a la misma pipeline.  
2. Verificar el esquema de destino `bridge_monitoring.gold`.  
3. Ejecutar—DLT materializara:  
   - Aplicar 2-min watermarks  
   - Calcular 10-min tumbling avg/max metrics  
   - Realizar stream–stream joins en window bounds  
   - Publicar `puente_metrics` para análisis posteriores.

---

## Aprendizaje

- **Arquitectura DLT**: con el patrón medallion Bronze → Silver → Gold  
- **Pipelines Declarativas**: `@dlt.table`, `@dlt.expect_or_warn`, `dlt.read_stream` vs `dlt.read`  
- **Conceptos de Streaming**: watermarks, agregaciones por ventanas, stream–static and stream–stream joins  
- **Procesamiento Incremental**: como DLT solo procesa datos nuevos y maneja los reintentos automáticamente  

---

