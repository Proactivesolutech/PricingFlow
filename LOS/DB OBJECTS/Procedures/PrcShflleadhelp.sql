ALTER PROCEDURE PrcShflleadhelp
(
@LeadID	 VARCHAR(MAX)		=	NULL,
@lead		 VARCHAR(MAX)		=	NULL,
@GlobalRole  VARCHAR(MAX)		=	NULL
)
AS 
BEGIN 
   

   CREATE TABLE #TEMP(XX_id BIGINT,Branchfk BIGINT)

   IF @GlobalRole != '' AND @GlobalRole != '[]'
   BEGIN
      INSERT INTO #TEMP
      EXEC PrcParseJSON @GlobalRole,'BrnchFk'	  
   END

IF ISNULL(@LeadID,'') <> ''
BEGIN
               SELECT		LedId 'LeadId',LedNm 'LeadNm',LedPk 'hdnLeadPk',GeoPk 'hdnGeoPk',GeoNm 'BranchNm',
									GrpCd 'hdnPCd',GrpPk 'hdnPrdPk',GrpNm 'ProductNm'
						FROM		LosLead(NOLOCK)	
						JOIN		GenGeoMas(NOLOCK) ON GeoPk = LedBGeoFk AND GeoDelId = 0
						JOIN		GenLvlDefn(NOLOCK) ON GrpPk = LedPGrpFk AND GrpDelId = 0
						WHERE		LedDelid = 0 AND LedId LIKE  '%' + @LeadID + '%'
						AND         EXISTS(SELECT 'X'FROM #TEMP(NOLOCK) WHERE LedBGeoFk=Branchfk)
						ORDER BY	LedPk DESC

 END
ELSE
  BEGIN
               SELECT		LedId 'LeadId',LedNm 'LeadNm',LedPk 'hdnLeadPk',GeoPk 'hdnGeoPk',GeoNm 'BranchNm',
									GrpCd 'hdnPCd',GrpPk 'hdnPrdPk',GrpNm 'ProductNm'
						FROM		LosLead(NOLOCK)	
						JOIN		GenGeoMas(NOLOCK) ON GeoPk = LedBGeoFk AND GeoDelId = 0
						JOIN		GenLvlDefn(NOLOCK) ON GrpPk = LedPGrpFk AND GrpDelId = 0						
						WHERE		LedDelid = 0
						AND         EXISTS(SELECT 'X'FROM #TEMP(NOLOCK) WHERE LedBGeoFk=Branchfk)
						ORDER BY	LedPk DESC

	END
END
