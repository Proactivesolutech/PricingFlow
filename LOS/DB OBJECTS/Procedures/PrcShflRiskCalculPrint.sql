IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflRiskCalculPrint' AND [type]='P')
	DROP PROC PrcShflRiskCalculPrint
GO
CREATE PROCEDURE PrcShflRiskCalculPrint
(
@LeadPk		BIGINT = NULL
)
AS
BEGIN
       SET NOCOUNT ON
	   DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	   DECLARE @SalTyp INT, @IIRFOIR INT

BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN

				SELECT CASE WHEN LapTitle = 0 THEN 'Mr' WHEN LapTitle = 1 THEN 'Ms' WHEN LapTitle = 2 THEN 'Mrs' END+'. '+LapFstNm+' '+LapMdNm+' '+LapLstNm 'AppNm'
				FROM	LosAppProfile (NOLOCK) WHERE LapLedFk=@LeadPk AND LapDelId=0 AND LapActor = 0

				SELECT    CASE WHEN LapTitle = 0 THEN 'Mr' WHEN LapTitle = 1 THEN 'Ms' WHEN LapTitle = 2 THEN 'Mrs' END+'. '+LapFstNm+' '+LapMdNm+' '+LapLstNm 'AppMajor' 
				FROM      LosAppProfile (NOLOCK)
				JOIN      LosRiskCalc (NOLOCK) ON LapPk=LrcLapFk
				WHERE     LapLedFk=@LeadPk AND LapDelId=0 AND LrcParameter = 'S'
				
				SELECT	@SalTyp = AppSalTyp,@IIRFOIR = CASE GrpCd WHEN 'LAP' THEN 1 ELSE 0 END
				FROM    LosApp (NOLOCK)
				JOIN	GenLvlDefn(NOLOCK) ON GrpPk = AppPGrpFk AND GrpDelid = 0
				WHERE 	AppLedFk = @LeadPk AND AppDelId = 0	 
				
				SELECT	CASE @SalTyp WHEN 0 THEN 'Salaried' WHEN 1 THEN 'Self Employed' END 'profile', 
						CASE @IIRFOIR WHEN 1 THEN '<strong>NAMI</strong>(Net Adjusted Monthly Income) - All applicant' 
									  ELSE '<strong>Net Monthly Income</strong> - All applicant' END 'IncTitle',
						CASE @IIRFOIR WHEN 1 THEN 'IIR' ELSE 'FOIR' END 'IIRFOIR'
				
			SELECT  CONVERT(INT,LrcVal) 'Product' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='C' AND LrcLedFk=@LeadPk
			SELECT  CONVERT(INT,LrcVal) 'Age' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='A' AND LrcLedFk=@LeadPk
			SELECT  CONVERT(INT,LrcVal) 'TypOrg' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='O' AND LrcLedFk=@LeadPk
			SELECT  CONVERT(INT,LrcVal) 'NAMI' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='N' AND LrcLedFk=@LeadPk
			SELECT  CONVERT(INT,LrcVal) 'IIR' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='I' AND LrcLedFk=@LeadPk
			SELECT  CONVERT(INT,LrcVal) 'CIBIL' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='B' AND LrcLedFk=@LeadPk
			SELECT  CONVERT(INT,LrcVal) 'TotalScore' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='S' AND LrcLedFk=@LeadPk
			SELECT  LrcVal 'TotalPercent' FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='P' AND LrcLedFk=@LeadPk

			SELECT   CASE WHEN LrcTxtVal='V' THEN 'Very High Risk'
                       WHEN LrcTxtVal='H' THEN 'High Risk'  
					   WHEN LrcTxtVal='M' THEN 'Moderate Risk' 
					   WHEN LrcTxtVal='L' THEN 'Low Risk'
					   WHEN LrcTxtVal='N' THEN 'Very Low Risk'
					   END 'TypRisk' 
			FROM LosRiskCalc(NOLOCK) WHERE LrcParameter='R' AND LrcLedFk=@LeadPk


	IF @Trancount = 1 AND @@TRANCOUNT = 1
			COMMIT TRAN
			
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