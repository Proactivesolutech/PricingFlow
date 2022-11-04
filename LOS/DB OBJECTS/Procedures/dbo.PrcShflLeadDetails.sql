ALTER PROCEDURE PrcShflLeadDetails
(
@Action VARCHAR(MAX)	= NULL
)
AS 
BEGIN 
    IF @Action ='Load'
	BEGIN
	SELECT	distinct LedPk 'LeadPk' ,LedNm 'Leadname',LedId 'Leadid',GeoNm 'branchname'
	FROM	LosLead (NOLOCK) 
	JOIN    GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
	WHERE	LedDelId = 0 
	END

END

