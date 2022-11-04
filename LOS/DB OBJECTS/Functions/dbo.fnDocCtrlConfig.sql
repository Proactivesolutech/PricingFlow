--SELECT * FROM dbo.fnDocCtrlConfig(1,4,'','','','')

ALTER FUNCTION [dbo].[fnDocCtrlConfig]
(
	@BGeoFk		BIGINT,
	@DocTypFk	BIGINT,
	@PrdFk		BIGINT,
	@Custm1		VARCHAR(MAX),
	@Custm2		VARCHAR(MAX),
	@Custm3		VARCHAR(MAX)
)
RETURNS @ReturnLoanTable TABLE (
	DOC_NO	VARCHAR(100),
	LASTNO	INT
)
AS
BEGIN	
		DECLARE @DocumentType VARCHAR(100) , @DocGenNo VARCHAR(150) ,@MaxSDocNo  BIGINT,
		@Prefix VARCHAR(100) , @Suffix VARCHAR(100)

		

		SELECT	@MaxSDocNo = (CONVERT(BIGINT,DfgLstNo + 1)) , @Prefix = RTRIM(DfgPrefix) , @Suffix =RTRIM(DfgSuffix)
		FROM	GenDocCtrlConfig(NOLOCK) 
		JOIN	GenMas (NOLOCK) ON MasPk = DfgDocTypFk AND MasDelId = 0
		WHERE	DfgDocTypFk = @DocTypFk AND DfgBGeoFk = @BGeoFk AND DfgDelid = 0

		IF ISNULL(@MaxSDocNo,0) = 0 
			SET @MaxSDocNo =  1;
		
		SELECT	@DocGenNo = @Prefix + '' + dbo.gefgGetPadZero(5,(ISNULL(@MaxSDocNo,0))) + '' + @Suffix
		

		INSERT INTO	@ReturnLoanTable(DOC_NO,LASTNO)
		SELECT		@DocGenNo,@MaxSDocNo

	RETURN;
END
GO


