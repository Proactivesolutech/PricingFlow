IF OBJECT_ID('PrcShflleadBranchhelp','P') IS NOT NULL
DROP PROC PrcShflleadBranchhelp
GO
CREATE PROCEDURE PrcShflleadBranchhelp
(
@Branchname VARCHAR(MAX)	= NULL,
@brnch VARCHAR(MAX)	= NULL
)
AS
BEGIN 

	IF ISNULL(@Branchname,'0') = '0'
	BEGIN
	SELECT	Distinct GeoNm 'Location',GeoPk 'BranchPk' 
	FROM	GenGeoMas (NOLOCK) 
    JOIN    GenUsrBrnDtls ON UbdGeoFk = GeoPk AND UbdDelId =0
	WHERE	GeoLvlNo = 1 AND GeoDelid = 0
	END
	ELSE
	BEGIN
	SELECT	Distinct GeoNm 'Location',GeoPk 'BranchPk' 
	FROM	GenGeoMas (NOLOCK) 
    JOIN    GenUsrBrnDtls ON UbdGeoFk = GeoPk AND UbdDelId =0
	WHERE	GeoLvlNo = 1 AND GeoDelid = 0 AND GeoNm LIKE  '%' + @Branchname + '%'	
	END

END
