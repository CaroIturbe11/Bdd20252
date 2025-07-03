---/ PRACTICA 3 "Servidores vinculados y Particionamiento" PARTE 1
---/ 1.- se generan los archivos MDF Y NDF que contienen por separado los datos de la base de datos principal (4 grupos)
---/ 2.- se generan tablas vacias con la misma estrucutra que las de origen
---/ 3.- se insertan los datos a las tablas que a su vez estan en regiones fisicas separadas; para su distribucion

---SCRIPT DE CONSULTAS

----------------------------------------CONSULTA 3:-----------------------------------------------------------
WITH DatosUnificados AS (
    SELECT diabetes, obesidad, hipertension, clasificacion_final
    FROM [192.168.229.2].[P3_servVin_Part].[dbo].[reg_sur]

    UNION ALL

    SELECT diabetes, obesidad, hipertension, clasificacion_final
    FROM [192.168.229.3].[P3_servVin_Part].[dbo].[reg_centro]

    UNION ALL

    SELECT diabetes, obesidad, hipertension, clasificacion_final
    FROM P3_servVin_Part.dbo.reg_norte
)

SELECT
    Morbilidad,
    CAST(SUM(Casos) * 100.0 / NULLIF(SUM(TotalCasos), 0) AS DECIMAL(5, 2)) AS Porcentaje
FROM (
    SELECT 
        'Diabetes' AS Morbilidad,
        SUM(CASE WHEN diabetes = 1 AND clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END) AS Casos,
        SUM(CASE WHEN clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END) AS TotalCasos
    FROM DatosUnificados

    UNION ALL

    SELECT 
        'Obesidad',
        SUM(CASE WHEN obesidad = 1 AND clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END),
        SUM(CASE WHEN clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END)
    FROM DatosUnificados

    UNION ALL

    SELECT 
        'Hipertension',
        SUM(CASE WHEN hipertension = 1 AND clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END),
        SUM(CASE WHEN clasificacion_final IN ('1', '2', '3') THEN 1 ELSE 0 END)
    FROM DatosUnificados
) AS Morbilidades
GROUP BY Morbilidad
----------------------------------------CONSULTA 4:-----------------------------------------------------------
WITH DatosUnificados2 AS (
    SELECT Entidad_Res, Municipio_res, CLASIFICACION_FINAL, HIPERTENSION, OBESIDAD, diabetes, TABAQUISMO
    FROM [192.168.229.2].[P3_servVin_Part].[dbo].[reg_sur]

    UNION ALL

    SELECT Entidad_Res, Municipio_res, CLASIFICACION_FINAL, HIPERTENSION, OBESIDAD, diabetes, TABAQUISMO
    FROM [192.168.229.3].[P3_servVin_Part].[dbo].[reg_centro]

    UNION ALL

    SELECT Entidad_Res, Municipio_res, CLASIFICACION_FINAL, HIPERTENSION, OBESIDAD, diabetes, TABAQUISMO
    FROM P3_servVin_Part.dbo.reg_norte
)

SELECT DISTINCT 
    Entidad_Res, 
    Municipio_res
FROM DatosUnificados2
WHERE 
    CLASIFICACION_FINAL NOT IN (1, 2, 3)
    AND HIPERTENSION = 1 
    AND OBESIDAD = 1 
    AND diabetes = 1 
    AND TABAQUISMO = 1
----------------------------------------CONSULTA 5:-----------------------------------------------------------
WITH CasosRecuperados AS (
    -- Reg Sur
    SELECT 
        ENTIDAD_RES,
        COUNT(*) AS num_casos_recuperados_con_neumonia
    FROM [192.168.229.2].[P3_servVin_Part].[dbo].[reg_sur]
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND FECHA_DEF = '9999-99-99' 
          AND NEUMONIA = '1' 
    GROUP BY ENTIDAD_RES

    UNION ALL

    -- Reg Centro
    SELECT 
        ENTIDAD_RES,
        COUNT(*) AS num_casos_recuperados_con_neumonia
    FROM [192.168.229.3].[P3_servVin_Part].[dbo].[reg_centro]
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND FECHA_DEF = '9999-99-99' 
          AND NEUMONIA = '1' 
    GROUP BY ENTIDAD_RES

    UNION ALL

    -- Reg Norte
    SELECT 
        ENTIDAD_RES,
        COUNT(*) AS num_casos_recuperados_con_neumonia
    FROM P3_servVin_Part.dbo.reg_norte
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND FECHA_DEF = '9999-99-99' 
          AND NEUMONIA = '1' 
    GROUP BY ENTIDAD_RES
)

SELECT TOP 3 
    ENTIDAD_RES,
    num_casos_recuperados_con_neumonia
FROM CasosRecuperados
ORDER BY num_casos_recuperados_con_neumonia DESC;
----------------------------------------CONSULTA 7:-----------------------------------------------------------
WITH CasosPorMes AS (
    -- Reg Sur
    SELECT 
        ENTIDAD_RES, 
        YEAR(FECHA_INGRESO) AS Año, 
        MONTH(FECHA_INGRESO) AS Mes, 
        COUNT(*) AS total_casos
    FROM [192.168.229.2].[P3_servVin_Part].[dbo].[reg_sur]
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3', '6') 
          AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY ENTIDAD_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)

    UNION ALL

    -- Reg Centro
    SELECT 
        ENTIDAD_RES, 
        YEAR(FECHA_INGRESO) AS Año, 
        MONTH(FECHA_INGRESO) AS Mes, 
        COUNT(*) AS total_casos
    FROM [192.168.229.3].[P3_servVin_Part].[dbo].[reg_centro]
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3', '6') 
          AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY ENTIDAD_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)

    UNION ALL

    -- Reg Norte
    SELECT 
        ENTIDAD_RES, 
        YEAR(FECHA_INGRESO) AS Año, 
        MONTH(FECHA_INGRESO) AS Mes, 
        COUNT(*) AS total_casos
    FROM P3_servVin_Part.dbo.reg_norte
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3', '6') 
          AND YEAR(FECHA_INGRESO) IN (2020, 2021)
    GROUP BY ENTIDAD_RES, YEAR(FECHA_INGRESO), MONTH(FECHA_INGRESO)
),
Ranking AS (
    SELECT 
        ENTIDAD_RES, Año, Mes, total_casos,
        ROW_NUMBER() OVER (PARTITION BY ENTIDAD_RES, Año ORDER BY total_casos DESC) AS ranking
    FROM CasosPorMes
)
SELECT 
    CasospM.ENTIDAD_RES, 
    CasospM.Año, 
    CasospM.Mes, 
    CasospM.total_casos
FROM 
    Ranking CasospM
WHERE 
    CasospM.ranking = 1 
ORDER BY 
    CasospM.Año;
