IF OBJECT_ID('PrcSHFLLosLeadSearch','P') IS NOT NULL
	DROP PROC PrcSHFLLosLeadSearch
GO
CREATE PROCEDURE PrcSHFLLosLeadSearch
(
	@LeadPk VARCHAR(MAX)	= NULL,
	@bnk varchar(max)=null,
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
	    SELECT*FROM(SELECT		DISTINCT LedId 'LeadId',LedPk 'LeadPk', LedNm 'LeadName',GeoNm 'BranchName',
					ISNULL(PrdNm,GrpNm) 'hdnPrdNm',ISNULL(PrdIcon,GrpIconCls) 'hdnPrdIcon',ISNULL(PrdCd,GrpCd) 'hdnPrdCd',
					ISNULL(AgtFName,'') 'hdnAgents', AgtPk 'hdnAgtFk', GeoPk 'hdnBrnchFk',LsnStsFlg 'hdnflag'
		FROM		LosLead(NOLOCK)		
		JOIN		GenAgents(NOLOCK) ON LedAgtFk = AgtPk AND AgtDelid = 0
		JOIN		GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
		JOIN		GenLvlDefn(NOLOCK) ON LedPGrpFk = GrpPk AND GrpDelid = 0
		LEFT JOIN	GenPrdMas(NOLOCK) ON LedPrdFk = PrdPk AND PrdDelid = 0
		LEFT JOIN	LosProcChrg(NOLOCK) ON LedPk=LpcLedFk
		LEFT JOIN   LosSanction(NOLOCK) ON LedPk=LsnLedFk AND LsnDelId=0
		WHERE		LedDelId = 0 AND LedId LIKE  '%' + @LeadPk + '%'
		AND			EXISTS(SELECT 'X'FROM #TEMP(NOLOCK) WHERE LedBGeoFk=BranchFk)
		AND			NOT EXISTS(SELECT 'X' FROM LosLoan A(NOLOCK) JOIN LosSanction B(NOLOCK) ON A.LlnLsnFk = B.LsnPk WHERE LlnLedFk=LedPk AND ISNULL(LpcSancNo,'') = LsnSancNo AND LlnDelId=0)) A where hdnflag = 'A' OR hdnflag IS NULL OR hdnflag = ' '
	END
	ELSE
	BEGIN
		SELECT*FROM (SELECT		DISTINCT LedId 'LeadId',LedPk 'LeadPk', LedNm 'LeadName',GeoNm 'BranchName',
					ISNULL(PrdNm,GrpNm) 'hdnPrdNm',ISNULL(PrdIcon,GrpIconCls) 'hdnPrdIcon',ISNULL(PrdCd,GrpCd) 'hdnPrdCd',
					ISNULL(AgtFName,'') 'hdnAgents', AgtPk 'hdnAgtFk', GeoPk 'hdnBrnchFk',LsnStsFlg 'hdnflag'
		FROM		LosLead(NOLOCK)		
		JOIN		GenAgents(NOLOCK) ON LedAgtFk = AgtPk AND AgtDelid = 0
		JOIN		GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
		JOIN		GenLvlDefn(NOLOCK) ON LedPGrpFk = GrpPk AND GrpDelid = 0
		LEFT JOIN	GenPrdMas(NOLOCK) ON LedPrdFk = PrdPk AND PrdDelid = 0
		LEFT JOIN	LosProcChrg(NOLOCK) ON LedPk=LpcLedFk AND LpcDelId=0
		LEFT JOIN   LosSanction(NOLOCK) ON LedPk=LsnLedFk AND LsnDelId=0
		WHERE		LedDelId = 0
		AND			EXISTS(SELECT 'X'FROM #TEMP(NOLOCK) WHERE LedBGeoFk=BranchFk)
		AND			NOT EXISTS(SELECT 'X' FROM LosLoan A(NOLOCK) JOIN LosSanction B(NOLOCK) ON A.LlnLsnFk = B.LsnPk WHERE LlnLedFk=LedPk AND ISNULL(LpcSancNo,'') = LsnSancNo AND LlnDelId=0)) A where hdnflag = 'A' OR hdnflag IS NULL OR hdnflag = ' '
	END
END