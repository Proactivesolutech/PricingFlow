IF OBJECT_ID('PrcShflLeadDetailshelp','P') IS NOT NULL
DROP PROC PrcShflLeadDetailshelp
GO
CREATE PROCEDURE PrcShflLeadDetailshelp
(
@Leadname VARCHAR(MAX)	= NULL,
@Lead VARCHAR(MAX)	= NULL
)
AS 
BEGIN 
    IF ISNULL(@Leadname,'0') = '0'
	BEGIN
	SELECT	LedId  'LeadId', LedNm 'LeadName' ,LedPk 'LeadPk' ,GeoNm 'Branchname'
	FROM	LosLead (NOLOCK) 
	JOIN    GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
	WHERE	LedDelId = 0 
	END
	ELSE
	BEGIN
	SELECT	LedId  'LeadId', LedNm 'LeadName' ,LedPk 'LeadPk' ,GeoNm 'Branchname'
	FROM	LosLead (NOLOCK) 
	JOIN    GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
	WHERE	LedDelId = 0  AND LedNm LIKE  '%' + @Leadname + '%' 
	END
END