use covidHistorico
select* from datoscovid
/*****************************************
1.- Listar el top 5 de las entidades con más casos confirmados por cada uno de los años registrados en la base de datos.
 Requisitos:
 Significado de los valores de los catálogos.
 Responsable de la consulta: Pérez Iturbe Carolina
 Comentarios: 
-ROW_NUMBER(): Enumera los resultados de un conjunto de resultados. Concretamente, devuelve el número secuencial de una fila dentro de una 
partición de un conjunto de resultados, empezando por 1 para la primera fila de cada partición.
-OVER: Define una ventana o un conjunto especificado por el usuario de filas dentro de un conjunto de resultados de consulta.
-PARTITION BY: Divide el conjunto de resultados de la consulta en particiones. La función se aplica a cada partición por separado y el cálculo
se reinicia para cada partición.

*****************************************/ 

WITH Ranking AS (
    SELECT 
        ENTIDAD_RES, 
        YEAR(FECHA_INGRESO) AS año, 
        COUNT(*) AS num_casos_confirmados,
        ROW_NUMBER() OVER (PARTITION BY YEAR(FECHA_INGRESO) ORDER BY COUNT(*) DESC) AS rank
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3')
    GROUP BY ENTIDAD_RES, YEAR(FECHA_INGRESO)
)
SELECT ENTIDAD_RES, año, num_casos_confirmados
FROM Ranking
WHERE rank <= 5
ORDER BY año, rank;


/*****************************************
2.-Listar el municipio con mas casos confirmados recuperados por estado y por año.
Requisitos:
Significado de los valores de los catálogos.
Responsable de la consulta: Pérez Iturbe Carolina
Comentarios:
-ROW_NUMBER(): Enumera los resultados de un conjunto de resultados. Concretamente, devuelve el número secuencial de una fila dentro de una 
partición de un conjunto de resultados, empezando por 1 para la primera fila de cada partición.
-OVER: Define una ventana o un conjunto especificado por el usuario de filas dentro de un conjunto de resultados de consulta.
-PARTITION BY: Divide el conjunto de resultados de la consulta en particiones. La función se aplica a cada partición por separado y el 
cálculo se reinicia para cada partición.
*****************************************/ 
WITH CasosRecuperados AS (
    SELECT 
        YEAR(FECHA_INGRESO) AS año,
        ENTIDAD_RES,
        MUNICIPIO_RES,
        COUNT(*) AS num_casos_recuperados
    FROM datoscovid
    WHERE CLASIFICACION_FINAL IN ('1', '2', '3') 
          AND FECHA_DEF = '9999-99-99'  -- Pacientes recuperados
    GROUP BY YEAR(FECHA_INGRESO), ENTIDAD_RES, MUNICIPIO_RES
),
Ranking AS (
    SELECT 
        año,
        ENTIDAD_RES,
        MUNICIPIO_RES,
        num_casos_recuperados,
        ROW_NUMBER() OVER (PARTITION BY año, ENTIDAD_RES ORDER BY num_casos_recuperados DESC) AS rn
    FROM CasosRecuperados
)
SELECT año, ENTIDAD_RES, MUNICIPIO_RES, num_casos_recuperados
FROM Ranking
WHERE rn = 1;


3.-
4.-
5.-

/*****************************************
 6.- Listar el total de casos confirmados/sospechosos por estado en cada uno de los años registrados en la base de datos.
 Requisitos:
 Significado de los valores de los catálogos.
 Responsable de la consulta: Pérez Iturbe Carolina
 Comentarios: Sin comentarios
*****************************************/ 
select year(FECHA_INGRESO) as año, count(*) num_casos, ENTIDAD_RES
from datoscovid
where CLASIFICACION_FINAL in ('1', '2','3','7') 
group by year(FECHA_INGRESO), ENTIDAD_RES
order by año, ENTIDAD_RES asc
7.-



/***************************************** 
Número de consulta. 12. Listar total de casos negativos por estado en los años 2020 y 2021. 
Requisitos:  
Significado de los valores de los catálogos. 
Responsable de la consulta.  
Comentarios: -- aquí, explicar las instrucciones adicionales  
Utilizadas y no explicadas en clase.    
*****************************************/  

  
/***************************************** 
Número de consulta.	 13. Listar porcentajes de casos confirmados por género en el rango de edades de 20 a 30 años, 
						de 31 a 40 años, de 41 a 50 años, de 51 a 60 años y mayores a 60 años a nivel nacional. 
Requisitos:  ninguno
Significado de los valores de los catálogos; RESULTADO_LAB = '1' = POSITIVO A SARS-COV-2 , FECHA_DEF = '9999-99-99' = No murio
Responsable de la consulta.  oscar daniel de jesus lucio
Comentarios: -- CAST =
				DECIMAL = 
				THEN =
				CASE =
*****************************************/ 
SELECT 
    -- Promedios por grupo de edad y género
    CAST(hombre_edad_20_30 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_H_20_30,
    CAST(hombre_edad_31_40 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_H_31_40,
    CAST(hombre_edad_41_50 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_H_41_50,
    CAST(hombre_edad_51_60 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_H_51_60,
    CAST(hombre_edad_mayor_60 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_H_mayor_60,	
    CAST(mujer_edad_20_30 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_M_20_30,
    CAST(mujer_edad_31_40 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_M_31_40,
    CAST(mujer_edad_41_50 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_M_41_50,
    CAST(mujer_edad_51_60 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_M_51_60,
    CAST(mujer_edad_mayor_60 * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_M_mayor_60, 

    -- Sumas de hombres, mujeres y total de casos
    hombre_total,
    mujer_total,
    total_casos,

    -- Promedio de cada grupo sobre el total
    CAST(hombre_total * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_Hombres,
    CAST(mujer_total * 1.0 / total_casos AS DECIMAL(4,2)) AS Prom_Mujeres

FROM (
    SELECT 
        -- Conteo de hombres por grupo de edad
        COUNT(CASE WHEN edad BETWEEN 20 AND 30 AND SEXO = '1' THEN 1 END) AS hombre_edad_20_30,
        COUNT(CASE WHEN edad BETWEEN 31 AND 40 AND SEXO = '1' THEN 1 END) AS hombre_edad_31_40,
        COUNT(CASE WHEN edad BETWEEN 41 AND 50 AND SEXO = '1' THEN 1 END) AS hombre_edad_41_50,
        COUNT(CASE WHEN edad BETWEEN 51 AND 60 AND SEXO = '1' THEN 1 END) AS hombre_edad_51_60,
        COUNT(CASE WHEN edad > 60 AND SEXO = '1' THEN 1 END) AS hombre_edad_mayor_60,

        -- Conteo de mujeres por grupo de edad
        COUNT(CASE WHEN edad BETWEEN 20 AND 30 AND SEXO = '2' THEN 1 END) AS mujer_edad_20_30,
        COUNT(CASE WHEN edad BETWEEN 31 AND 40 AND SEXO = '2' THEN 1 END) AS mujer_edad_31_40,
        COUNT(CASE WHEN edad BETWEEN 41 AND 50 AND SEXO = '2' THEN 1 END) AS mujer_edad_41_50,
        COUNT(CASE WHEN edad BETWEEN 51 AND 60 AND SEXO = '2' THEN 1 END) AS mujer_edad_51_60,
        COUNT(CASE WHEN edad > 60 AND SEXO = '2' THEN 1 END) AS mujer_edad_mayor_60,

        -- Suma total de hombres y mujeres
        COUNT(CASE WHEN SEXO = '1' THEN 1 END) AS hombre_total,
        COUNT(CASE WHEN SEXO = '2' THEN 1 END) AS mujer_total,

        -- Total de casos (hombres + mujeres)
        COUNT(*) AS total_casos

    FROM datoscovid
) AS T;

/***************************************** 
Número de consulta.	 14 
Requisitos:  ninguno
Significado de los valores de los catálogos; RESULTADO_LAB = '1' = POSITIVO A SARS-COV-2 , FECHA_DEF = '9999-99-99' = No murio
Responsable de la consulta.  oscar daniel de jesus lucio
Comentarios: -- WHIT =
				UNION = 
				UNION ALL =
*****************************************/ 

WITH conteo AS (
    SELECT 
        'TODOS' AS Rangos_de_edad, COUNT(*) AS casos FROM datoscovid 
        WHERE FECHA_INGRESO < '2022-01-01' AND RESULTADO_LAB = '1' AND FECHA_DEF != '9999-99-99'
    UNION ALL
    SELECT 'infantes', COUNT(*) FROM datoscovid 
        WHERE EDAD < 12 AND FECHA_INGRESO < '2022-01-01' AND [CLASIFICACION_FINAL] = '1' AND FECHA_DEF != '9999-99-99'
    UNION ALL
    SELECT 'adolescencia', COUNT(*) FROM datoscovid 
        WHERE EDAD BETWEEN 13 AND 18 AND FECHA_INGRESO < '2022-01-01' AND [CLASIFICACION_FINAL] = '1' AND FECHA_DEF != '9999-99-99'
    UNION ALL
    SELECT 'adultez_joven', COUNT(*) FROM datoscovid 
        WHERE EDAD BETWEEN 19 AND 39 AND FECHA_INGRESO < '2022-01-01' AND [CLASIFICACION_FINAL] = '1' AND FECHA_DEF != '9999-99-99'
    UNION ALL
    SELECT 'madurez', COUNT(*) FROM datoscovid 
        WHERE EDAD BETWEEN 40 AND 49 AND FECHA_INGRESO < '2022-01-01' AND [CLASIFICACION_FINAL] = '1' AND FECHA_DEF != '9999-99-99'
    UNION ALL
    SELECT 'adultez_tardia', COUNT(*) FROM datoscovid 
        WHERE EDAD BETWEEN 50 AND 79 AND FECHA_INGRESO < '2022-01-01' AND [CLASIFICACION_FINAL] = '1' AND FECHA_DEF != '9999-99-99'
    UNION ALL
    SELECT 'vejez', COUNT(*) FROM datoscovid 
        WHERE EDAD > 80 AND FECHA_INGRESO < '2022-01-01' AND [CLASIFICACION_FINAL] = '1' AND FECHA_DEF != '9999-99-99'
)
SELECT * FROM conteo
ORDER BY casos DESC;

