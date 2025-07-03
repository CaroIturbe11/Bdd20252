---/ PRACTICA 3 "Servidores vinculados y Particionamiento" PARTE 1
---/ 1.- se generan los archivos MDF Y NDF que contienen por separado los datos de la base de datos principal (4 grupos)
---/ 2.- se generan tablas vacias con la misma estrucutra que las de origen
---/ 3.- se insertan los datos a las tablas que a su vez estan en regiones fisicas separadas; para su distribucion

---SCRIPT SERVIDOR VINCULADO REGION NORTE: 192.168.229.2

use master create database P3_servVin_Part
use P3_servVin_Part
go
--nota; segun el catalgo de entidades
--alter database P3_servVin_Part add filegroup centro;	--01,09,11,13,14,15,17,21,22,29,30,32
alter database P3_servVin_Part add filegroup norte;		--02,03,05,08,10,16,19,23,24,25,26,28
--alter database P3_servVin_Part add filegroup sur;		--04,06,07,12,18,20,27,31
--alter database P3_servVin_Part add filegroup otros;		--36,97,98,99
go
		----///// AGREGANDO ARCHIVOS Y FILEGROUPS POR REGION
select name, physical_name,type_desc from sys.master_files where database_id = DB_ID('P3_servVin_Part');
--C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\P3_servVin_Part.mdf

alter database P3_servVin_Part add file
(
	name= [PartNorte],
	filename = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\PartNorte.ndf',
	size = 3072 KB,	
	maxsize=unlimited,
	filegrowth = 1024 KB
)to filegroup [norte]

----///// CREAR TABLAS:

create table reg_norte(
	[FECHA_ACTUALIZACION] [nvarchar](15) NULL,
	[ID_REGISTRO] [nvarchar](15) NULL,
	[ORIGEN] [int] NULL,
	[SECTOR] [int] NULL,
	[ENTIDAD_UM] [nvarchar](15) NULL,
	[SEXO] [int] NULL,
	[ENTIDAD_NAC] [nvarchar](15) NULL,
	[ENTIDAD_RES] [nvarchar](15) NULL,
	[MUNICIPIO_RES] [nvarchar](15) NULL,
	[TIPO_PACIENTE] [int] NULL,
	[FECHA_INGRESO] [nvarchar](15) NULL,
	[FECHA_SINTOMAS] [nvarchar](15) NULL,
	[FECHA_DEF] [nvarchar](15) NULL,
	[INTUBADO] [int] NULL,
	[NEUMONIA] [int] NULL,
	[EDAD] [nvarchar](7) NULL,
	[NACIONALIDAD] [int] NULL,
	[EMBARAZO] [int] NULL,
	[HABLA_LENGUA_INDIG] [int] NULL,
	[INDIGENA] [int] NULL,
	[DIABETES] [int] NULL,
	[EPOC] [int] NULL,
	[ASMA] [int] NULL,
	[INMUSUPR] [int] NULL,
	[HIPERTENSION] [int] NULL,
	[OTRA_COM] [int] NULL,
	[CARDIOVASCULAR] [int] NULL,
	[OBESIDAD] [int] NULL,
	[RENAL_CRONICA] [int] NULL,
	[TABAQUISMO] [int] NULL,
	[OTRO_CASO] [int] NULL,
	[TOMA_MUESTRA_LAB] [int] NULL,
	[RESULTADO_LAB] [int] NULL,
	[TOMA_MUESTRA_ANTIGENO] [int] NULL,
	[RESULTADO_ANTIGENO] [int] NULL,
	[CLASIFICACION_FINAL] [int] NULL,
	[MIGRANTE] [int] NULL,
	[PAIS_NACIONALIDAD] [nvarchar](50) NULL,
	[PAIS_ORIGEN] [nvarchar](50) NULL,
	[UCI] [nvarchar](50) NULL
)on norte
go
insert into reg_norte--[192.168.229.4]
select *
from covidHistorico.dbo.datoscovid
where ENTIDAD_RES in (02,03,05,08,10,16,19,23,24,25,26,28);
		--select * from reg_norte -- = 3,964,324 rows

