--EXEC PrcShflgetDeviationData 5022
ALTER PROC PrcShflgetDeviationData(
	@LeadPk		BIGINT			=	NULL	
)
AS
BEGIN
SET NOCOUNT ON	
	BEGIN TRY
		
		DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT

		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN								

		CREATE TABLE #ApplDet(PKVAL BIGINT IDENTITY(1,1),ApplName VARCHAR(500), ApplRel VARCHAR(100), IncConsider VARCHAR(100), PropOwner VARCHAR(200), 
		AgeatLogin VARCHAR(100), MaturityAge  VARCHAR(100), Cibil VARCHAR(10), LapFk VARCHAR(100),Actor INT ,income NUMERIC(27,2) , obligations NUMERIC(27,2) , 
		incometype VARCHAR(2) , isAgeDeviation VARCHAR(2),AgeDeviation INT,BusinessAvg NUMERIC(27,2), CashAvg NUMERIC(27,2),SalIncome NUMERIC(27,2))

		CREATE TABLE #TempCrediTable(CreditPk BIGINT, LnAttrPk BIGINT , AttrCode VARCHAR(50) , Value NUMERIC(27,7) , AttrPK BIGINT)
	
		DECLARE @NETINCOME NUMERIC(27,2) , @FOIR NUMERIC(27,2) , @IIR NUMERIC(27,2) , @LTV NUMERIC(27,2),
				@TenureInYear INT ,@ApprovedBy TINYINT , @BusinessAvg NUMERIC(27,2)	, @BT_AMT NUMERIC(27,2),
				@TOPUP_AMT NUMERIC(27,2) , @BT_LTV NUMERIC(27,2),@TOPUP_LTV NUMERIC(27,2),@MARGIN_VAL NUMERIC(27,7)
				
		DECLARE @AppCount INT , @Loopcount INT = 0,@Age INT ,@AgeMature INT, @income NUMERIC(27,2) , @IncomeType CHAR(2) , @Financier CHAR(5),@LapFk BIGINT,
				@isAgeDeviation CHAR(1) , @AgeDeviation INT,@ArrAgeVAL INT,
				@isIncomeDeviation CHAR(1) , @incomeDeviation NUMERIC(27,2), 
				@isIIRDeviation CHAR(1) , @IIRDeviation NUMERIC(27,2),
				@isFOIRDeviation CHAR(1) , @FOIRDeviation NUMERIC(27,2),
				@isLTVDeviation CHAR(1) , @LTVDeviation NUMERIC(27,2),
				@ProductCode VARCHAR(50)

		DECLARE @IsProof TINYINT , @AppFk BIGINT

		SELECT @IsProof = AppSalPrf,@AppFk = AppPk FROM LosApp (NOLOCK) WHERE AppLedFk = @LeadPk AND AppDelId = 0		
	
		/* ---------------------------- App Details ----------------------------- */

	
		INSERT INTO #ApplDet(ApplName,ApplRel,IncConsider,PropOwner,AgeatLogin,MaturityAge,Cibil,LapFk,Actor,incometype)
		SELECT DISTINCT	CASE	WHEN C.LapTitle = 0 THEN 'Mr. '
						WHEN	C.LapTitle = 1 THEN 'Ms. '
						WHEN	C.LapTitle = 2 THEN 'Mrs. '
						ELSE	'' 
				END + ISNULL(C.LapFstNm,'') +' ' + ISNULL(C.LapMdNm,'') + ' ' + ISNULL(C.LapLstNm,''),
				ISNULL(NULLIF(RTRIM(C.LapRelation),''),'-') ,  
				CASE	WHEN ISNULL(RTRIM(E.LioLapFk),'') <> '' THEN 'YES'
						ELSE 'NA'
				END,
				CASE	WHEN ISNULL(RTRIM(D.LpoPK),'') <> '' THEN 'YES'
						ELSE 'NA'
				END,
				RTRIM(CASE	WHEN DATEADD(YEAR, DATEDIFF (YEAR, C.LapDOB, GETDATE()), C.LapDOB) > GETDATE()
								THEN DATEDIFF(YEAR, C.LapDOB, GETDATE()) - 1
								ELSE DATEDIFF(YEAR, C.LapDOB, GETDATE()) 
						END) , 
				ROUND(RTRIM(CASE	WHEN DATEADD(YEAR, DATEDIFF (YEAR, C.LapDOB, GETDATE()), C.LapDOB) > GETDATE()
								THEN DATEDIFF(YEAR, C.LapDOB, GETDATE()) - 1
								ELSE DATEDIFF(YEAR, C.LapDOB, GETDATE()) 
						END) + @TenureInYear,0)  , C.LapCibil , C.LapPk , C.LapActor,
				CASE	WHEN C.LapEmpTyp = 0 THEN 'S'
						WHEN C.LapEmpTyp = 1 THEN 'SE'
						ELSE '-'
				END				
		FROM	LosLead (NOLOCK)		A
		JOIN	LosApp (NOLOCK)			B	ON B.AppLedFk = A.LedPk AND B.AppDelId = 0
		JOIN	LosAppProfile(NOLOCK)	C	ON C.LapLedFk = A.LedPk AND C.LapDelId = 0
		LEFT OUTER JOIN LosPropOwner (NOLOCK) D ON D.LpoLapFk = C.LapPk AND D.LpoDelId = 0
		LEFT OUTER JOIN	LosAppIncObl (NOLOCK) E ON E.LioLapFk = C.LapPk AND E.LioDelId = 0 AND E.LioType NOT IN ('OB') AND E.LioIncExc = 0
		WHERE	A.LedPk = @LeadPk AND A.LedDelId = 0 	

		SELECT CONVERT(NUMERIC(27,0),ROUND(SUM(LioSumAmt),0)) 'income',LioLapFk 'LapFk'
		INTO #incometemp
		FROM		LosAppProfile (NOLOCK)
		LEFT OUTER JOIN		LosAppIncObl (NOLOCK) ON LioLapFk =  LapPk AND LioDelId = 0
		WHERE		LapLedFk = @LeadPk AND LioType <> 'OB' AND LapDelId = 0 
		GROUP BY	LioLapFk

		SELECT CONVERT(NUMERIC(27,0),ROUND(SUM(LioSumAmt),0)) 'obligation',LioLapFk 'LapFk'
		INTO #Obligationtemp
		FROM		LosAppProfile (NOLOCK)
		LEFT OUTER JOIN		LosAppIncObl (NOLOCK) ON LioLapFk =  LapPk AND LioDelId = 0
		WHERE		LapLedFk = @LeadPk AND LioType = 'OB' AND LapDelId = 0 
		GROUP BY	LioLapFk

		UPDATE	A 
		SET		A.income = ISNULL(B.income,0)
		FROM	#ApplDet A
		JOIN	#incometemp B ON B.LapFk = A.LapFk 

		UPDATE	A 
		SET		A.obligations = ISNULL(B.obligation,0)
		FROM	#ApplDet A
		JOIN	#Obligationtemp B ON B.LapFk = A.LapFk 		

		SELECT	ISNULL(AVG(LbiVal),0) 'AvgIncome',LbiLapFk 'LapFk'
		INTO	#TempBusiTable
		FROM	LosAppBusiInc (NOLOCK) 
		WHERE	LbiYr = '-1' AND LbiAddless =  3 AND LbiLedFk = @LeadPk
		GROUP BY LbiLapFk		
				
		IF EXISTS(SELECT 'X' FROM #TempBusiTable)
		BEGIN
			UPDATE	A
			SET		A.BusinessAvg = ISNULL(AvgIncome,0)
			FROM	#ApplDet A
			JOIN	#TempBusiTable B ON B.LapFk = A.LapFk
		END	
		ELSE
		BEGIN
			UPDATE #ApplDet	SET	BusinessAvg = 0
		END	



		SELECT	ISNULL(SUM(LioSumAmt),0) 'AvgIncome',LioLapFk 'LapFk'
		INTO	#TempSalaryTable
		FROM	LosAppIncObl (NOLOCK) 
		WHERE	LioLedFk = @LeadPk AND LioDelId = 0 AND LioType = 'S' 
		GROUP BY LioLapFk						

		UPDATE	A
		SET		A.SalIncome = ISNULL(AvgIncome,0)
		FROM	#ApplDet A
		JOIN	#TempSalaryTable B ON B.LapFk = A.LapFk

			
		SELECT	ISNULL(AVG(LioSumAmt),0) 'AvgIncome',LioLapFk 'LapFk'
		INTO	#TempCashTable
		FROM	LosAppIncObl (NOLOCK) 
		WHERE	LioLedFk = @LeadPk AND LioDelId = 0 AND LioType = 'C' 
		GROUP BY LioLapFk
	

		UPDATE	A
		SET		A.CashAvg = ISNULL(AvgIncome,0)
		FROM	#ApplDet A
		JOIN	#TempCashTable B ON B.LapFk = A.LapFk
				



		-- SELECT DETAILS 

		SELECT * FROM #ApplDet

		IF @Trancount = 1 AND @@TRANCOUNT = 1
			COMMIT TRAN		
	END	TRY

	BEGIN CATCH
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
				
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		

		RETURN

	END CATCH	
END



