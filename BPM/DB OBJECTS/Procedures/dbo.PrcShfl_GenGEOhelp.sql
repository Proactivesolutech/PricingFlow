USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShfl_GenGEOhelp]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShfl_GenGEOhelp]
(
@Geoname VARCHAR(MAX)	= NULL,
@brnch VARCHAR(MAX)	= NULL
)
AS
BEGIN 

	IF ISNULL(@Geoname,'0') = '0'
	BEGIN
	SELECT	GeoNm 'RoleName',GeoLvlNo 'Level',GeoPk 'Pk'
	FROM	GenGeoMas (NOLOCK) 
	WHERE	GeoDelId = 0 
	END
	ELSE
	BEGIN
    SELECT	GeoNm 'RoleName',GeoLvlNo 'Level',GeoPk 'Pk'
	FROM	GenGeoMas (NOLOCK) 
	WHERE	GeoDelId = 0  AND GeoNm LIKE  '%' + @Geoname + '%'
	END

END


















GO
