IF OBJECT_ID('CustomerInfo','P') IS NOT NULL
DROP PROC CustomerInfo
GO
CREATE PROCEDURE CustomerInfo
(
@Action       VARCHAR(100)	=  NULL,
@GlobalJSON   VARCHAR(MAX)	=  NULL
)
AS
BEGIN
SET NOCOUNT ON
   DECLARE @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX)
   DECLARE @LeadPk BIGINT,@LeadID VARCHAR(100)
   CREATE TABLE #globaldtls(xx_id BIGINT,FwdDataPk BIGINT,LeadID VARCHAR(100))

	    IF  @GlobalJSON !='[]' AND @GlobalJSON !=''
		BEGIN

			INSERT INTO #globaldtls
			EXEC PrcParseJSON @GlobalJSON,'LeadFk,DocLeadID'

			SELECT @LeadPk = FwdDataPk, @LeadID = LeadID FROM #globaldtls
		END
	BEGIN TRY
            IF @@TRANCOUNT = 0
			SET @TranCount = 1

		IF @Action='SELECT'

		BEGIN
			SELECT ISNULL(LapFstNm,'') + ' ' + ISNULL(LapMdNm,'') + ' ' +ISNULL(LapLstNm,'') 'qdeNm',CASE WHEN LapGender = 0 THEN 'Male' WHEN LapGender = 1 THEN 'Female' END 'qdeGender',dbo.gefgDMY(LapDOB) 'qdeDob',LapAadhar 'qdeAdhar',LapPAN 'qdepan',LapDrvLic 'qdedrvlic',LapVotId 'qdeVotId',
				   ISNULL(LapFatherFNm,'') + ' ' + ISNULL(LapFatherMNm,'') + ' ' +ISNULL(LapFatherLNm,'') 'FatherName',LaaDoorNo 'door',ISNULL(LaaBuilding,'') 'building',LaaPlotNo 'plot',ISNULL(LaaStreet,'') 'str',ISNULL(LaaLandmark,'') 'landmark',
				   LaaArea 'city',LaaDistrict 'dist',LaaState 'state',LaaPin 'qdePin',LapMobile 'qdemob',LapPassport 'passnum',CASE WHEN LapActor = 0 THEN 'APPLICANT' WHEN LapActor = 1 THEN 'CO-APPLICANT' WHEN LapActor = 2 THEN 'GUARANTOR' END 'actor',
				   CASE WHEN LapEmpTyp = 0 THEN 'SALARIED' WHEN LapEmpTyp = 1 THEN 'SELF EMPLOYED' WHEN LapEmpTyp = 2 THEN 'HOUSE WIFE' WHEN LapEmpTyp = 3 THEN 'PENSIONER' WHEN LapEmpTyp = 4 THEN 'STUDENT' WHEN LapEmpTyp = -1 THEN '______' END 'emptyp'
			FROM   LosAppProfile (NOLOCK)
			LEFT OUTER JOIN LosAppAddress (NOLOCK) ON LaaLapFk=LapPk
			WHERE LapLedFk =  @LeadPk AND LapDelId=0 and LaaAddTyp=0

		END
		END TRY
			BEGIN CATCH

	IF @Trancount = 1 AND @@TRANCOUNT = 1
		ROLLBACK TRAN	

	SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
			@ErrSeverity = ERROR_SEVERITY()

	RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
	RETURN

	END CATCH	
END