USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShfl_GenGEO_Maphelp]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShfl_GenGEO_Maphelp]
(
@Geoname VARCHAR(MAX)	= NULL,
@brnch VARCHAR(MAX)	= NULL,
@extra   INT		= NULL
)
AS
BEGIN 

	IF ISNULL(@Geoname,'0') = '0'
	BEGIN
	SELECT	GeoNm 'RoleName',GeoLvlNo 'Level',GeoPk 'Pk'
	FROM	GenGeoMas (NOLOCK) 
	WHERE	GeoDelId = 0 AND GeoLvlNo = ISNULL(@extra,'')
	END
	ELSE
	BEGIN
    SELECT	GeoNm 'RoleName',GeoLvlNo 'Level',GeoPk 'Pk'
	FROM	GenGeoMas (NOLOCK) 
	WHERE	GeoDelId = 0  AND GeoNm LIKE  '%' + @Geoname + '%' AND GeoLvlNo = ISNULL(@extra,'')
	END

END










GO
