IF OBJECT_ID('PrcShflRiskCalc','P') IS NOT NULL
	DROP PROCEDURE PrcShflRiskCalc
GO
CREATE PROC PrcShflRiskCalc
(
	@LeadPk BIGINT = NULL,
	@UsrNm	VARCHAR(200) = NULL
)
AS 
BEGIN	
	BEGIN TRY		
		
		CREATE TABLE #RISK_TABLE (CODE CHAR(1) ,PARAM_CODE VARCHAR(50),PARAM_NAME VARCHAR(100) , SCORE NUMERIC(5,2), RISK VARCHAR(50))
		INSERT INTO #RISK_TABLE (CODE,PARAM_CODE,PARAM_NAME , SCORE )
		VALUES	('C','PRD','PRODUCT(Vanilla/Surrogate)',0),
				('A','AGE','Age',0),
				('O','ORG','Type Of Organisation',0),
				('N','NAMI','NAMI',0),
				('I','IIR_FOIR','IIR / FOIR',0),
				('B','CIBIL','Bureau score',0),
				('S','SCORE','Score earned',0),
				('P','PERC','Percentage',0),
				('R','RISK','Risk Category',0)

		DECLARE @INCOME_PROOF CHAR(1) , @MajorContributorPK BIGINT ,  @MajorContributorAge INT ,
		@SCORE INT = 1 , @NAMI NUMERIC(27,7) , @MAX_CIBIL INT  , @IIR_FOIR NUMERIC(27,7),
		@RowId VARCHAR(MAX)=  NEWID(), @CurDt DATETIME= GETDATE() , @GRPCD VARCHAR(20)

		SELECT @INCOME_PROOF =  CASE	WHEN AppSalPrf  = 0 THEN 'Y'
										WHEN AppSalPrf = 1 THEN 'N'
								END, @GRPCD = GrpCd
		FROM LosApp (NOLOCK) 
		JOIN GenPrdMas  (NOLOCK) ON PrdPk = AppPrdFk AND PrdDelid =0 
		JOIN GenLvlDefn (NOLOCK) ON GrpPk = PrdGrpFk AND GrpDelid =0 
		WHERE AppLedFk = @LeadPk AND AppDelId = 0

		-- SCORE FOR INCOME PROOF 
		IF @INCOME_PROOF = 'Y'
			SET @SCORE = 5
		ELSE 
			SET @SCORE = 1

		UPDATE	#RISK_TABLE SET SCORE = @SCORE
		WHERE	PARAM_CODE = 'PRD'

		CREATE TABLE #TempIncome(LioType VARCHAR(10),LioSumAmt NUMERIC,LioLapFk BIGINT,Age INT)

		IF @GRPCD = 'LAP' 
		BEGIN
			INSERT INTO #TempIncome
			SELECT	LioType , 
						CASE	WHEN LioType = 'OB' THEN - LioSumAmt
								ELSE LioSumAmt
						END		LioSumAmt , 
						LioLapFk ,RTRIM(CASE	WHEN DATEADD(YEAR, DATEDIFF (YEAR, LapDOB, GETDATE()), LapDOB) > GETDATE()
									THEN DATEDIFF(YEAR, LapDOB, GETDATE()) - 1
									ELSE DATEDIFF(YEAR, LapDOB, GETDATE()) 
							END) Age
			FROM	LosAppIncObl (NOLOCK) 
			LEFT OUTER JOIN LosAppProfile (NOLOCK) ON LapPk = LioLapFk AND LapDelId = 0
			WHERE	LioLedFk = @LeadPk AND LioDelId = 0
		END
		ELSE
		BEGIN
			INSERT INTO #TempIncome
			SELECT	LioType , LioSumAmt , 
						LioLapFk ,RTRIM(CASE	WHEN DATEADD(YEAR, DATEDIFF (YEAR, LapDOB, GETDATE()), LapDOB) > GETDATE()
									THEN DATEDIFF(YEAR, LapDOB, GETDATE()) - 1
									ELSE DATEDIFF(YEAR, LapDOB, GETDATE()) 
							END) Age
			FROM	LosAppIncObl (NOLOCK) 
			LEFT OUTER JOIN LosAppProfile (NOLOCK) ON LapPk = LioLapFk AND LapDelId = 0
			WHERE	LioLedFk = @LeadPk AND LioDelId = 0 AND LioType <> 'OB'
		END

		SELECT	ISNULL(SUM(LioSumAmt),0) amt,LioLapFk lapfk , Age
		INTO	#TempSumInc
		FROM	#TempIncome
		GROUP	BY LioLapFk,Age
				
		SELECT	@MajorContributorPK = lapfk , @MajorContributorAge = Age
		FROM	#TempSumInc WHERE amt = (SELECT MAX(amt) FROM #TempSumInc)		

		SET @SCORE = 1
		-- SCORE FOR AGE - MAJOR CONTRIBUTOR

		IF	( @MajorContributorAge >= 18 AND @MajorContributorAge <= 27 )
			OR
			( @MajorContributorAge >= 46 AND @MajorContributorAge <= 52 )
			SET @SCORE = 3
		ELSE IF @MajorContributorAge >= 28 AND @MajorContributorAge <= 35
			SET @SCORE = 5
		ELSE IF @MajorContributorAge >= 36 AND @MajorContributorAge <= 45
			SET @SCORE = 4
		ELSE IF @MajorContributorAge > 52
			SET @SCORE = 1

		UPDATE	#RISK_TABLE SET SCORE = @SCORE
		WHERE	PARAM_CODE = 'AGE'


		-- TYPE OF ORGANISATION 
		--Type of Organization ( 0 - Public, 1 - Private, 2 - State, 3 - Central, 4 - Semi Government)
		/*
			SELECT @SCORE =  CASE WHEN LapEmpTyp = 0  THEN 
									CASE	WHEN LaeTyp = 0 OR LaeTyp = 2 OR LaeTyp = 3 OR LaeTyp = 4 THEN 5 -- Public, Govt 
											WHEN LaeTyp = 1 THEN 2 -- private									
											ELSE 0
									END
						WHEN LapEmpTyp = 1  THEN 
							CASE	WHEN LabOrgTyp = 0 OR  LabOrgTyp = 2 OR LabOrgTyp = 3 OR LabOrgTyp = 4 THEN 5
									WHEN LabOrgTyp = 1 AND LabBusiTyp = 0 THEN 5
									WHEN LabOrgTyp = 1 AND LabBusiTyp = 1 THEN 2
									ELSE 0 
							END
						ELSE 0
					END 
			FROM	LosAppProfile(NOLOCK)
			LEFT OUTER JOIN LosAppBusiProfile (NOLOCK) ON LabLapFk = LapPk AND LabDelId = 0
			LEFT OUTER JOIN LosAppOffProfile (NOLOCK) ON LaeLapFk = LapPk AND LaeDelId = 0
			WHERE LapPk = @MajorContributorPK AND LapDelId = 0
		*/
		
		SELECT @SCORE =  CASE WHEN LapEmpTyp = 0  THEN 5 
							  WHEN LapEmpTyp = 1  THEN 
								CASE	WHEN LabBusiTyp = 0 THEN 5
										ELSE 2
								END
						ELSE 2 END 
		FROM	LosAppProfile(NOLOCK)
		LEFT OUTER JOIN LosAppBusiProfile (NOLOCK) ON LabLapFk = LapPk AND LabDelId = 0
		LEFT OUTER JOIN LosAppOffProfile (NOLOCK) ON LaeLapFk = LapPk AND LaeDelId = 0
		WHERE LapPk = @MajorContributorPK AND LapDelId = 0
		
		UPDATE	#RISK_TABLE SET SCORE = @SCORE
		WHERE	PARAM_CODE = 'ORG'
		
		SELECT @NAMI = ISNULL(SUM(LioSumAmt),0) FROM #TempIncome
		
		-- NAMI SCORE
		SET @SCORE = 0 
		IF @NAMI <= 10000
			SET @SCORE  = 0
		ELSE IF @NAMI > 10000 AND @NAMI <= 15000
			SET @SCORE  = 2
		ELSE IF @NAMI > 15000 AND @NAMI <= 30000
			SET @SCORE  = 3
		ELSE IF @NAMI > 30000
			SET @SCORE  = 5


		UPDATE	#RISK_TABLE SET SCORE = @SCORE
		WHERE	PARAM_CODE = 'NAMI'

		-- IIR / FOIR
				
		SELECT	@IIR_FOIR = CASE 
					WHEN GrpCd = 'LAP' THEN ISNULL(IIR,0)
					ELSE ISNULL(FOIR,0)
				END,@MAX_CIBIL = CBL
		FROM
		(
			SELECT	LnaCd ,LcaVal,LcrPrdFk,GrpCd
			FROM	LosCreditAttr (NOLOCK) A
					JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
					JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
					LEFT OUTER JOIN	GenPrdMas C (NOLOCK) ON C.PrdPk = B.LcrPrdFk AND C.PrdDelId = 0
					LEFT OUTER JOIN	GenLvlDefn D (NOLOCK) ON D.GrpPk = C.PrdPk AND D.GrpDelId = 0
			WHERE	B.LcrLedFk = @LeadPk AND A.LcaDelId = 0  
			AND LcrDocRvsn =(SELECT MAX(X.LcrDocRvsn) FROM LosCredit (NOLOCK) X WHERE  X.LcrLedFk = @LeadPk AND X.LcrDelId = 0) AND LcrDocRvsn <> 0
		) PIVOTCredit 
		PIVOT (MAX(LcaVal) FOR  LnaCd IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
				ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,
				BT_LTV_A,TOPUP_LTV_A,BT_LTV_M,TOPUP_LTV_M ))
		AS PIVOTCredit 
		
		SET @SCORE = 0

		IF @IIR_FOIR <= 40
			SET @SCORE = 5
		ELSE IF @IIR_FOIR > 40 AND @IIR_FOIR <= 45 
			SET @SCORE = 4
		ELSE IF @IIR_FOIR > 45 AND @IIR_FOIR <= 50
			SET @SCORE = 3
		ELSE IF @IIR_FOIR > 50 AND @IIR_FOIR <= 55
			SET @SCORE = 2
		ELSE IF @IIR_FOIR > 55
			SET @SCORE = 1

		UPDATE	#RISK_TABLE SET SCORE = @SCORE
		WHERE	PARAM_CODE = 'IIR_FOIR'
		SET @SCORE = 0 
		IF @MAX_CIBIL > 0 AND @MAX_CIBIL <= 550
			SET @SCORE = 0
		ELSE IF @MAX_CIBIL > 550 AND @MAX_CIBIL <= 600
			SET @SCORE = 1
		ELSE IF @MAX_CIBIL > 600 AND @MAX_CIBIL <= 650 OR @MAX_CIBIL = 0 OR @MAX_CIBIL = -1
			SET @SCORE = 2
		ELSE IF @MAX_CIBIL > 650 AND @MAX_CIBIL <= 700
			SET @SCORE = 3
		ELSE IF @MAX_CIBIL > 700
			SET @SCORE = 5

		UPDATE	#RISK_TABLE SET SCORE = @SCORE
		WHERE	PARAM_CODE = 'CIBIL'
					
		DECLARE @TotalScore NUMERIC(10,2)

		SELECT @TotalScore = SUM(A.SCORE) 
		FROM	#RISK_TABLE A
				
		UPDATE	#RISK_TABLE SET SCORE = @TotalScore  
		WHERE	CODE = 'S'

		DECLARE @Percentage NUMERIC(5,2) = ( @TotalScore / 30  ) * 100

		UPDATE	#RISK_TABLE SET SCORE = @Percentage
		WHERE	CODE = 'P'				

		UPDATE	#RISK_TABLE SET RISK = 
				CASE	WHEN @Percentage <= 60 THEN 'V' --'Very High Risk'
						WHEN (@Percentage > 60 AND @Percentage <= 70) THEN 'H'--'High Risk'
						WHEN (@Percentage > 70 AND @Percentage <= 80) THEN 'M'--'Moderate Risk'
						WHEN (@Percentage > 80 AND @Percentage <= 90) THEN 'L' --'Low Risk'
						WHEN @Percentage > 90 THEN 'N' --'Very Low Risk'
				END
		WHERE	CODE = 'R'

		DELETE FROM LosRiskCalc WHERE LrcLedFk = @LeadPk
		
		INSERT INTO LosRiskCalc (LrcLedFk,LrcLapFk,LrcParameter,LrcVal,LrcTxtVal,LrcRowId,LrcCreatedBy,LrcCreatedDt,LrcModifiedBy,LrcModifiedDt,LrcDelFlg,LrcDelId)
		SELECT		@LeadPk,@MajorContributorPK,CODE,SCORE,RISK,@RowId , @UsrNm, @CurDt,@UsrNm, @CurDt,NULL,0
		FROM		#RISK_TABLE

		--SELECT * FROM #RISK_TABLE
		--SELECT * FROM LosRiskCalc
		--TRUNCATE TABLE  LosRiskCalc
	END TRY

	BEGIN CATCH
		SELECT ERROR_MESSAGE()
	END CATCH
	
END


--BEGIN TRAN EXEC PrcShflRiskCalc 5022 , 'admin' ROLLBACK TRAN 