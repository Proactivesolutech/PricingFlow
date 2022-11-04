ALTER PROCEDURE PrcSHFLLosLeadSearchZonallink
(
	@LeadPk VARCHAR(MAX)	=	NULL,
	@bnk varchar(max)		=	null,
	@Extra VARCHAR(MAX)		=	NULL
)
AS
BEGIN 
	 DECLARE @BrnchFk BIGINT; 
	 CREATE TABLE #TEMP(XX_ID BIGINT,BranchFk BIGINT)

	IF @Extra != '' AND @Extra != '[]'
	 BEGIN
           INSERT INTO  #TEMP
		   EXEC PrcParseJSON @Extra,'BrnchFk'
	 END
	 
	IF ISNULL(@LeadPk,'') <> ''
	BEGIN
		SELECT		DISTINCT LedId 'LeadId',LedPk 'LeadPk', LedNm 'LeadName',GeoNm 'BranchName',
					ISNULL(PrdNm,GrpNm) 'hdnPrdNm',ISNULL(PrdIcon,GrpIconCls) 'hdnPrdIcon',ISNULL(PrdCd,GrpCd) 'hdnPrdCd'
		FROM		LosLead(NOLOCK)
		JOIN		GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
		JOIN		GenLvlDefn(NOLOCK) ON LedPGrpFk = GrpPk AND GrpDelid = 0
		LEFT JOIN	GenPrdMas(NOLOCK) ON LedPrdFk = PrdPk AND PrdDelid = 0
		WHERE		LedDelId = 0 AND LedId LIKE  '%' + @LeadPk + '%'
		AND			EXISTS(SELECT 'X'FROM #TEMP(NOLOCK) WHERE LedBGeoFk=BranchFk)
		AND			EXISTS(SELECT 'X' FROM LosCredit(NOLOCK) WHERE LcrLedFk=LedPk AND LcrDelId=0)
	END
	ELSE
	BEGIN
		SELECT		DISTINCT LedId 'LeadId',LedPk 'LeadPk', LedNm 'LeadName',GeoNm 'BranchName',
					ISNULL(PrdNm,GrpNm) 'hdnPrdNm',ISNULL(PrdIcon,GrpIconCls) 'hdnPrdIcon',ISNULL(PrdCd,GrpCd) 'hdnPrdCd'
		FROM		LosLead(NOLOCK)
		JOIN		GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
		JOIN		GenLvlDefn(NOLOCK) ON LedPGrpFk = GrpPk AND GrpDelid = 0
		LEFT JOIN	GenPrdMas(NOLOCK) ON LedPrdFk = PrdPk AND PrdDelid = 0
		WHERE		LedDelId = 0
		AND			EXISTS(SELECT 'X'FROM #TEMP(NOLOCK) WHERE LedBGeoFk=BranchFk)
		AND			EXISTS(SELECT 'X' FROM LosCredit(NOLOCK) WHERE LcrLedFk=LedPk  AND LcrDelId=0)
	END
END



