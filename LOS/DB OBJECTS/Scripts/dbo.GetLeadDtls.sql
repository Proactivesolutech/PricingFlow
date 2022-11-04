IF OBJECT_ID('GetLeadDtls','P') IS NOT NULL
	DROP PROC GetLeadDtls
GO
CREATE PROC GetLeadDtls
(
	@LedNm VARCHAR(100)
)
AS
BEGIN 
	SET NOCOUNT ON
	DECLARE @LeadTbl TABLE
	(
		LedId VARCHAR(50), LeadPk BIGINT, Name VARCHAR(100), Loan_Amount VARCHAR(100), Branch VARCHAR(100), 
		Product VARCHAR(100), Product_Group VARCHAR(100), Purpose_of_Loan VARCHAR(100)
	)
	
	INSERT		INTO @LeadTbl
	SELECT		LedId 'LedId',LedPk 'LeadPk', LedNm 'Name' ,dbo.GefgCurFormat(LedLnAmt,3) 'Loan_Amount',ISNULL(GeoNm,'') 'Branch',
				ISNULL(PrdNm,'') 'Product', ISNULL(GrpNm,'') 'Product_Group', 
				CASE WHEN ISNULL(LedPNI,'') = 'Y' THEN 'Property Not identified' 
					 WHEN ISNULL(LedBT,'') = 'Y' THEN 'Exiting Loan transfer along with Additional finance'
					 ELSE 'Property Identified' END
	FROM		LosLead(NOLOCK) 
	LEFT JOIN	GenGeoMas(NOLOCK) ON LedBGeoFk = GeoPk AND GeoDelid = 0
	LEFT JOIN	GenLvlDefn(NOLOCK) ON LedPGrpFk = GrpPk AND GrpDelid = 0 
	LEFT JOIN	GenPrdMas(NOLOCK) ON LedPrdFk = PrdPk AND PrdDelid = 0
	WHERE		LedNm LIKE '%' + @LedNm + '%' AND LedDelid = 0
	
	IF @@ROWCOUNT = 0
		PRINT 'NO MATCH FOUND'
	ELSE
		SELECT * FROM @LeadTbl
	
	SET NOCOUNT OFF
END



