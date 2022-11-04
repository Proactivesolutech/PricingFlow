IF OBJECT_ID('ShflGeoMas','U') IS NOT NULL
	DROP TABLE ShflGeoMas
GO
CREATE TABLE ShflGeoMas
(
	GeoNm VARCHAR(100),
	GeoLvlNo INT,
	GeoPk PkId PRIMARY KEY IDENTITY(1,1),
	GeoRowId RowId,
	GeoCreatedDt DATETIME,
	GeoCreatedBy FkId,
	GeoModifiedDt DATETIME,
	GeoModifiedBy FkId,
	GeoDelFlg DelFlg,
	GeoDelId TINYINT
)

IF OBJECT_ID('ShflGeoMap','U') IS NOT NULL
	DROP TABLE ShflGeoMap
GO
CREATE TABLE ShflGeoMap
(
	GeoMGeoBFk FkId,
	GeoMGeoZFk FkId,
	GeoMGeoSFk FkId,
	GeoMGeoCFk FkId,
	GeoMPk PkId PRIMARY KEY IDENTITY(1,1),
	GeoMRowId RowId,
	GeoMCreatedDt DATETIME,
	GeoMCreatedBy FkId,
	GeoMModifiedDt DATETIME,
	GeoMModifiedBy FkId,
	GeoMDelFlg DelFlg,
	GeoMDelId TINYINT
)

IF OBJECT_ID('ShflRole','U') IS NOT NULL
	DROP TABLE ShflRole
GO
CREATE TABLE ShflRole
(
	RolNm VARCHAR(100),
	RolLvlNo INT,
	RolPk PkId PRIMARY KEY IDENTITY(1,1),
	RolRowId RowId,
	RolCreatedDt DATETIME,
	RolCreatedBy FkId,
	RolModifiedDt DATETIME,
	RolModifiedBy FkId,
	RolDelFlg DelFlg,
	RolDelId TINYINT
)

IF OBJECT_ID('ShflUsrMas','U') IS NOT NULL
	DROP TABLE ShflUsrMas
GO
CREATE TABLE ShflUsrMas
(
	UsrNm VARCHAR(50),
	UsrDispNm VARCHAR(100),
	UsrPwd VARCHAR(MAX),
	UsrPk PkId PRIMARY KEY IDENTITY(1,1),
	UsrRowId RowId,
	UsrCreatedDt DATETIME,
	UsrCreatedBy FkId,
	UsrModifiedDt DATETIME,
	UsrModifiedBy FkId,
	UsrDelFlg DelFlg,
	UsrDelId TINYINT
)

IF OBJECT_ID('ShflUsrRoleDtls','U') IS NOT NULL
	DROP TABLE ShflUsrRoleDtls
GO
CREATE TABLE ShflUsrRoleDtls
(
	UrdUsrFk FkId,
	UrdRolFk FkId,
	UrdPk PkId PRIMARY KEY IDENTITY(1,1),
	UrdRowId RowId,
	UrdCreatedDt DATETIME,
	UrdCreatedBy FkId,
	UrdModifiedDt DATETIME,
	UrdModifiedBy FkId,
	UrdDelFlg DelFlg,
	UrdDelId TINYINT
)

IF OBJECT_ID('ShflUsrBrnDtls','U') IS NOT NULL
	DROP TABLE ShflUsrBrnDtls
GO
CREATE TABLE ShflUsrBrnDtls
(
	UbdUsrFk FkId,
	UbdGeoFk FkId,
	UbdPk PkId PRIMARY KEY IDENTITY(1,1),
	UbdRowId RowId,
	UbdCreatedDt DATETIME,
	UbdCreatedBy FkId,
	UbdModifiedDt DATETIME,
	UbdModifiedBy FkId,
	UbdDelFlg DelFlg,
	UbdDelId TINYINT
)

IF OBJECT_ID('ShflPrdMas','U') IS NOT NULL
	DROP TABLE ShflPrdMas
GO
CREATE TABLE ShflPrdMas
(
	PrdCd VARCHAR(50),
	PrdNm VARCHAR(100),
	PrdPk PkId PRIMARY KEY IDENTITY(1,1),
	PrdRowId RowId,
	PrdCreatedDt DATETIME,
	PrdCreatedBy FkId,
	PrdModifiedDt DATETIME,
	PrdModifiedBy FkId,
	PrdDelFlg DelFlg,
	PrdDelId TINYINT
)
