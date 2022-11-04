IF OBJECT_ID('PrcShflDeviations','P') IS NOT NULL
	DROP PROCEDURE PrcShflDeviations
GO
CREATE PROC PrcShflDeviations(
	@LeadPk		BIGINT			=	NULL,
	@RowID		VARCHAR(MAX)	=	NULL,
	@UsrFk		BIGINT			=	NULL,
	@UsrDispNm	VARCHAR(200)	=	NULL,
	@Revision	INT				=	NULL
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
		
		DELETE T FROM 
		LosDeviation T (NOLOCK)
		JOIN LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaCd <> 'MANUALDEV' AND LnaDelId = 0 
		WHERE LdvLedFk = @LeadPk AND LdvStage = 'C'	

		CREATE TABLE #ApplDet(PKVAL BIGINT IDENTITY(1,1),ApplName VARCHAR(500), ApplRel VARCHAR(100), IncConsider VARCHAR(100), PropOwner VARCHAR(200), 
		AgeatLogin VARCHAR(100), MaturityAge  VARCHAR(100), Cibil VARCHAR(10), LapFk VARCHAR(100),Actor INT ,income NUMERIC(27,2) , obligations NUMERIC(27,2) , 
		incometype CHAR(2) , isAgeDeviation CHAR(2),AgeDeviation INT,BusinessAvg NUMERIC(27,2),CashAvg NUMERIC(27,2), SalIncome NUMERIC(27,7))

		CREATE TABLE #TempCrediTable(CreditPk BIGINT, LnAttrPk BIGINT , AttrCode VARCHAR(50) , Value NUMERIC(27,7) , AttrPK BIGINT)
	
		DECLARE @NETINCOME NUMERIC(27,2) , @FOIR NUMERIC(27,2) , @IIR NUMERIC(27,2) , @LTV NUMERIC(27,2),
				@TenureInYear INT ,@ApprovedBy TINYINT , @BusinessAvg NUMERIC(27,2), @CashAvg NUMERIC(27,2),@obligation NUMERIC(27,2), @BT_AMT NUMERIC(27,2),
				@TOPUP_AMT NUMERIC(27,2) , @BT_LTV NUMERIC(27,2),@TOPUP_LTV NUMERIC(27,2),@MARGIN_VAL NUMERIC(27,7) , @ExistLoan NUMERIC(27,7) , @IsExistLoan CHAR(1),
				@Salincome NUMERIC(27,2)
				
		DECLARE @AppCount INT , @Loopcount INT = 0,@Age INT ,@AgeMature INT, @income NUMERIC(27,2) , @IncomeType CHAR(2) , @Financier CHAR(5),@LapFk BIGINT,
				@isAgeDeviation CHAR(1) , @AgeDeviation INT,@ArrAgeVAL INT,
				@isIncomeDeviation CHAR(1) , @incomeDeviation NUMERIC(27,2), 
				@isIIRDeviation CHAR(1) , @IIRDeviation NUMERIC(27,2),
				@isFOIRDeviation CHAR(1) , @FOIRDeviation NUMERIC(27,2),
				@isLTVDeviation CHAR(1) , @LTVDeviation NUMERIC(27,2),
				@ProductCode VARCHAR(50) , @ISIIR_FOIR CHAR(1) = 'F'

		DECLARE @IsProof TINYINT , @AppFk BIGINT

		SELECT @IsProof = AppSalPrf,@AppFk = AppPk FROM LosApp (NOLOCK) WHERE AppLedFk = @LeadPk AND AppDelId = 0


		SELECT	@ProductCode = B.PrdCd
		FROM	LosCredit (NOLOCK) A
		JOIN	GenPrdMas (NOLOCK) B ON B.PrdPk = A.LcrPrdFk AND B.PrdDelId = 0
		WHERE	A.LcrLedFk = @LeadPk AND A.LcrDelId = 0 AND A.LcrDocRvsn = @Revision


		IF EXISTS (SELECT 'X' FROM	LosAppExistLn (NOLOCK)  WHERE	LelLedFk = @LeadPk AND LelDelId = 0 )
		BEGIN
			SELECT	@ExistLoan =  ISNULL(SUM(LelOutstandingAmt),0)
			FROM	LosAppExistLn (NOLOCK) 
			WHERE	LelLedFk = @LeadPk AND LelDelId = 0 

			SELECT @IsExistLoan =  'Y'
		END
		ELSE 
		BEGIN
			SELECT @IsExistLoan =  'N' , @ExistLoan = 0
		END
	

		-- CREDIT DETAILS 

		INSERT INTO #TempCrediTable
		SELECT	LcaLcrFk ,LcaLnaFk ,LnaCd ,LcaVal ,LcaPk
		FROM	LosCreditAttr (NOLOCK) A
				JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
				JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
		WHERE	B.LcrLedFk = @LeadPk  AND A.LcaDelId = 0  
				AND LcrDocRvsn = @Revision

		SELECT	@IIR  =	ISNULL(IIR,0),@NETINCOME = ISNULL(NET_INC,0), @FOIR = ISNULL(FOIR,0),
				
				@LTV  =		CASE		WHEN ISNULL(LTV,0) = 0 THEN  ISNULL(ACT_LTV,0)
										WHEN ISNULL(ACT_LTV,0) = 0 THEN  ISNULL(LTV,0)
										WHEN ISNULL(LTV,0) > ISNULL(ACT_LTV,0) THEN ISNULL(ACT_LTV,0)
										WHEN ISNULL(ACT_LTV,0) > ISNULL(LTV,0) THEN ISNULL(LTV,0)
							END, 
				
				@TenureInYear = TENUR / 12 ,
				
				@BT_AMT = ISNULL(BT_AMT,0) ,@TOPUP_AMT = ISNULL(TOPUP_AMT,0),				
				
				@BT_LTV =		CASE	WHEN ISNULL(BT_LTV_A,0) = 0 THEN  ISNULL(BT_LTV_M,0)
										WHEN ISNULL(BT_LTV_M,0) = 0 THEN  ISNULL(BT_LTV_A,0)
										WHEN ISNULL(BT_LTV_A,0) > ISNULL(BT_LTV_M,0) THEN ISNULL(BT_LTV_M,0)
										WHEN ISNULL(BT_LTV_M,0) > ISNULL(BT_LTV_A,0) THEN ISNULL(BT_LTV_A,0)
								END,
				@TOPUP_LTV =	CASE	WHEN ISNULL(TOPUP_LTV_A,0) = 0 THEN  ISNULL(TOPUP_LTV_M,0)
										WHEN ISNULL(TOPUP_LTV_M,0) = 0 THEN  ISNULL(TOPUP_LTV_A,0)
										WHEN ISNULL(TOPUP_LTV_A,0) > ISNULL(TOPUP_LTV_M,0) THEN ISNULL(TOPUP_LTV_M,0)
										WHEN ISNULL(BT_LTV_M,0) > ISNULL(TOPUP_LTV_A,0) THEN ISNULL(TOPUP_LTV_A,0)
								END
		FROM
		(
			SELECT AttrCode,Value FROM #TempCrediTable
		)
		PIVOTTABLE
		PIVOT(MAX(Value) FOR AttrCode IN(OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
				ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,
				BT_LTV_A,TOPUP_LTV_A,BT_LTV_M,TOPUP_LTV_M ))
		AS PIVOTTABLE		

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

		SELECT	ISNULL(SUM(LioSumAmt),0) 'AvgIncome',LioLapFk 'LapFk'
		INTO	#TempSalaryTable
		FROM	LosAppIncObl (NOLOCK) 
		WHERE	LioLedFk = @LeadPk AND LioDelId = 0 AND LioType = 'S' 
		GROUP BY LioLapFk
				
		SELECT	ISNULL(AVG(LioSumAmt),0) 'AvgIncome',LioLapFk 'LapFk'
		INTO	#TempCashTable
		FROM	LosAppIncObl (NOLOCK) 
		WHERE	LioLedFk = @LeadPk AND LioDelId = 0 AND LioType = 'C' 
		GROUP BY LioLapFk

		UPDATE	A
		SET		A.SalIncome = ISNULL(AvgIncome,0)
		FROM	#ApplDet A
		JOIN	#TempSalaryTable B ON B.LapFk = A.LapFk
		

		UPDATE	A
		SET		A.BusinessAvg = ISNULL(AvgIncome,0)
		FROM	#ApplDet A
		JOIN	#TempBusiTable B ON B.LapFk = A.LapFk

		UPDATE	A
		SET		A.CashAvg = ISNULL(AvgIncome,0)
		FROM	#ApplDet A
		JOIN	#TempCashTable B ON B.LapFk = A.LapFk
				
							
		/* --------------------------------- IIR DEVIATIONS -------------------------------------- */
		SET @MARGIN_VAL = 0

		IF ISNULL(@IIR,0) <> 0
		BEGIN
			SET @ISIIR_FOIR = 'I'


			IF	@NETINCOME < 10000 
			BEGIN 
				SET @MARGIN_VAL = 40			
				
				IF  @IIR <= @MARGIN_VAL
					SELECT @isIIRDeviation = 'N' 
				ELSE
					SELECT @isIIRDeviation = 'D'  
			END
			ELSE IF	(@NETINCOME >= 10000 AND @NETINCOME <= 15000)
			BEGIN 
				SET @MARGIN_VAL = 40			
				
				IF  @IIR <= @MARGIN_VAL
					SELECT @isIIRDeviation = 'N' 
				ELSE
					SELECT @isIIRDeviation = 'D'  
			END
			ELSE IF (@NETINCOME >= 15001 AND @NETINCOME <= 30000)
			BEGIN
				SET @MARGIN_VAL = 45		
				
				IF  @IIR <= @MARGIN_VAL
					SELECT @isIIRDeviation = 'N' 
				ELSE
					SELECT @isIIRDeviation = 'D' 
			END
			ELSE IF (@NETINCOME > 30000)
			BEGIN
				SET @MARGIN_VAL = 50	
				
				IF  @IIR <= @MARGIN_VAL
					SELECT @isIIRDeviation = 'N' 
				ELSE
					SELECT @isIIRDeviation = 'D' 
			END

			SET @IIRDeviation = 0

			IF @isIIRDeviation = 'D'
				SELECT @IIRDeviation = 
					CASE	
						WHEN @NETINCOME <= 15000 THEN @IIR - 40
						WHEN @NETINCOME >= 15001 AND @NETINCOME <= 30000 THEN @IIR - 45
						WHEN @NETINCOME > 30000 THEN  @IIR - 50
					END
			
			SELECT @ApprovedBy = 1

			IF @IIRDeviation <> 0 
			BEGIN 
				IF ABS(@IIRDeviation) <= 5
					SELECT @ApprovedBy = 3
				ELSE IF ABS(@IIRDeviation) > 5
					SELECT @ApprovedBy = 4
			END

			INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
						LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal)
						OUTPUT INSERTED.*
			SELECT  @LeadPk,@AppFk, @UsrFk, 'C' , LnaPk , NULL , @IIR, @IIRDeviation , '',  @isIIRDeviation, @ApprovedBy , '',
						@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0,@MARGIN_VAL
			FROM	LosLnAttributes(NOLOCK)
			WHERE	LnaCd = 'IIR'	

		END	

		/* --------------------------------- IIR DEVIATIONS -------------------------------------- */
		/*------------------------------- FOIR DEVIATIONS  --------------------------------------*/
		ELSE IF ISNULL(@FOIR,0) <> 0
		BEGIN		
			SET @ISIIR_FOIR = 'F'
			SET @MARGIN_VAL = 0

			IF		(@NETINCOME >= 0 AND @NETINCOME <= 30000)
			BEGIN
				SET @MARGIN_VAL = 50
				SET @isFOIRDeviation = 'N'
				IF @FOIR <= @MARGIN_VAL
					SELECT @isFOIRDeviation = 'N'
				ELSE
					SELECT @isFOIRDeviation = 'D'
			END
			ELSE IF (@NETINCOME > 30000)
			BEGIN			
				SET @MARGIN_VAL = 60
				SET @isFOIRDeviation = 'N'
				IF @FOIR <= @MARGIN_VAL
					SELECT @isFOIRDeviation = 'N'
				ELSE
					SELECT @isFOIRDeviation = 'D'
			END			

			SET @FOIRDeviation = 0

			IF @isFOIRDeviation = 'D'
				SELECT @FOIRDeviation = 
					CASE	
						WHEN @NETINCOME >= 0 AND @NETINCOME <= 30000 THEN @FOIR - 50
						WHEN @NETINCOME > 30000 THEN  @FOIR - 60
					END
			
			SELECT @ApprovedBy = 1			

			IF @FOIRDeviation <> 0 
			BEGIN 
				IF ABS(@FOIRDeviation) <= 5
					SELECT @ApprovedBy = 2
				ELSE IF ABS(@FOIRDeviation) <= 10
					SELECT @ApprovedBy = 3
				ELSE IF ABS(@FOIRDeviation) > 10
					SELECT @ApprovedBy = 4
			END	

			INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
						LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal)
						OUTPUT INSERTED.*
			SELECT  @LeadPk,@AppFk, @UsrFk,'C', LnaPk , NULL , @FOIR,@FOIRDeviation , '',  @isFOIRDeviation, @ApprovedBy , '',
						@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0,@MARGIN_VAL
			FROM	LosLnAttributes(NOLOCK)
			WHERE	LnaCd = 'FOIR'	
		
		END
		/*------------------------------- FOIR DEVIATIONS  --------------------------------------*/

		/*------------------------------- LTV DEVIATIONS-----------------------------*/

		DECLARE @ArrLTV NUMERIC(27,2) = 0;

		IF ISNULL(@LTV,0) <> 0
		BEGIN		
			SET @ArrLTV = @LTV;

			SELECT @LTVDeviation = 0 , @MARGIN_VAL = 0

			-- LAP
			IF @ProductCode IN ('LAPResi')
			BEGIN 
				IF @IsProof = 0 
				BEGIN
					SET @MARGIN_VAL = 60
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END 
				ELSE IF @IsProof = 1 
				BEGIN
					SET @MARGIN_VAL = 60
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D',@LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END	
			END	

			-- LAP
			IF @ProductCode IN ('LAPCom')
			BEGIN 
				IF @IsProof = 0 
				BEGIN
					SET @MARGIN_VAL = 50
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END 
				ELSE IF @IsProof = 1 
				BEGIN
					SET @MARGIN_VAL = 50
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D',@LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END	
			END	
			--PLOT
			IF @ProductCode IN ('PL')
			BEGIN 
				IF @IsProof = 0 
				BEGIN
					SET @MARGIN_VAL = 75
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END 
				ELSE IF @IsProof = 1 
				BEGIN
					SET @MARGIN_VAL = 70
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D',@LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END	
			END			
			-- NEW AND RESALE
			IF @ProductCode IN ('HLNew' , 'HLResale')
			BEGIN
				IF @IsProof = 0 
				BEGIN
					SET @MARGIN_VAL = 80
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL , @ArrLTV = @LTV;
					END
				END 
				ELSE IF @IsProof = 1 
				BEGIN
					SET @MARGIN_VAL = 70
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV- @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END																	
			END
			-- BALANCE TRANSFER
			IF @ProductCode IN ('HLBT' , 'LAPBT')
			BEGIN
				IF @IsProof = 0 
				BEGIN
					SET @MARGIN_VAL = 75
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END 
				ELSE IF @IsProof = 1 
				BEGIN
					SET @MARGIN_VAL = 70
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D',@LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END	
			END

			-- SELF CONSTRUCTION
			IF @ProductCode IN ('HLConst')
			BEGIN
				IF @IsProof = 0 
				BEGIN
					SET @MARGIN_VAL = 80
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END 
				ELSE IF @IsProof = 1 
				BEGIN
					SET @MARGIN_VAL = 70
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END	

			END
			-- PLOT + CONSTRUCTION
			IF @ProductCode IN ('HLPltConst')		
			BEGIN
				IF @IsProof = 0 
				BEGIN
					SET @MARGIN_VAL = 80
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END 
				ELSE IF @IsProof = 1 
				BEGIN
					SET @MARGIN_VAL = 70
					
					IF @LTV <= @MARGIN_VAL
					BEGIN 
						SELECT @isLTVDeviation = 'N', @LTVDeviation = 0
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
				END	
			END	


			-- TOPUP  
			IF @ProductCode IN ('HLTopup' , 'LAPTopup')
			BEGIN		
				IF	@TOPUP_LTV <= 50
				BEGIN										
					IF @IsProof = 0 
					BEGIN 
						SET @MARGIN_VAL = 75

						IF  @LTV <= @MARGIN_VAL
							SELECT @isLTVDeviation = 'N'
						ELSE
						BEGIN
							SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
						END
					END
					ELSE IF @IsProof = 1 
					BEGIN 
						SET @MARGIN_VAL = 70
						
						IF @LTV <= 70
							SELECT @isLTVDeviation = 'N'
						ELSE
						BEGIN
							SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
						END	
					END				
				END
				ELSE
				BEGIN					

					IF @IsProof = 0 
					BEGIN 
						SET @MARGIN_VAL = 75

						IF  @LTV <= @MARGIN_VAL
							SELECT @isLTVDeviation = 'N'
						ELSE
						BEGIN
							SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 75,@LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
						END
					END
					ELSE IF @IsProof = 1 
					BEGIN 
						SET @MARGIN_VAL = 70
						
						IF @LTV <= @MARGIN_VAL
							SELECT @isLTVDeviation = 'N'
						ELSE
						BEGIN
							SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
						END	
					END	

					IF @isLTVDeviation <> 'D'
						SELECT @isLTVDeviation = 'D', @MARGIN_VAL = 50 , @LTVDeviation = @TOPUP_LTV - @MARGIN_VAL, @ArrLTV = @TOPUP_LTV;
				END	
			END						
			
			-- BT + TOPUP 
			IF @ProductCode IN ('HLBTTopup' , 'LAPBTTopup')
			BEGIN
				SELECT @isLTVDeviation = 'N'

				IF @IsProof = 0
				BEGIN
					SET @MARGIN_VAL = 50
					
					IF @BT_LTV <= 50
					BEGIN
						IF @TOPUP_LTV <= 75
						BEGIN
							SELECT @isLTVDeviation = 'N'
						END
						ELSE
						BEGIN
							SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 75,@LTVDeviation = @TOPUP_LTV - @MARGIN_VAL, @ArrLTV = @TOPUP_LTV;
						END
						IF @LTV <= 75
						BEGIN
							SELECT @isLTVDeviation = 'N'
						END
						ELSE
						BEGIN
							SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 75,@LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
						END
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 50,@LTVDeviation = @BT_LTV - @MARGIN_VAL, @ArrLTV = @BT_LTV;
					END				 
				END
				ELSE IF @IsProof = 1
				BEGIN
					SET @MARGIN_VAL = 50
					
					IF @BT_LTV <= 50
					BEGIN						
						
						IF @TOPUP_LTV <= 70 
						BEGIN							
							SELECT @isLTVDeviation = 'N',@MARGIN_VAL = 50
						END
						ELSE
						BEGIN
							SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 70,@LTVDeviation = @TOPUP_LTV - @MARGIN_VAL, @ArrLTV = @TOPUP_LTV;
						END
						IF @LTV <= 70
						BEGIN
							SELECT @isLTVDeviation = 'N'
						END
						ELSE 
						BEGIN
							SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 70,@LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
						END						
					END
					ELSE
					BEGIN
						SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 50, @LTVDeviation = @BT_LTV - @MARGIN_VAL, @ArrLTV = @BT_LTV;			 
					END												
				END
			END
			-- IMPROVEMENT
			IF @ProductCode IN ('HLImp')
			BEGIN
				IF @IsExistLoan ='Y' AND @TOPUP_LTV <> 0
				BEGIN
					IF @LTV > 70 
					BEGIN					
						SELECT @isLTVDeviation = 'D', @MARGIN_VAL = 70, @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;	
					END
					IF @TOPUP_LTV > 50
					BEGIN
						SELECT @isLTVDeviation = 'D',@MARGIN_VAL = 50, @LTVDeviation = @TOPUP_LTV - @MARGIN_VAL, @ArrLTV = @TOPUP_LTV;	
					END
					ELSE
						SELECT @isLTVDeviation = 'N'	
				END 
				ELSE
				BEGIN
					SET @MARGIN_VAL = 70
					
					IF @LTV <= 70
						BEGIN 
							SELECT @isLTVDeviation = 'N'
						END
					ELSE
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL , @ArrLTV = @LTV;
				END
				
			END
			-- EXTENSION
			IF @ProductCode IN ('HLExt')
			BEGIN
				IF @IsExistLoan ='Y' AND @TOPUP_LTV <> 0
				BEGIN
					IF @LTV > 70 
					BEGIN
						SELECT @isLTVDeviation = 'D', @MARGIN_VAL = 70, @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
					END
					IF @TOPUP_LTV > 50
					BEGIN
						SELECT @isLTVDeviation = 'D', @MARGIN_VAL = 50, @LTVDeviation = @TOPUP_LTV - @MARGIN_VAL, @ArrLTV = @TOPUP_LTV;
					END
					ELSE
						SELECT @isLTVDeviation = 'N'	
				END 
				ELSE
				BEGIN
					SET @MARGIN_VAL = 70

					IF @LTV <= 70
						BEGIN 
							SELECT @isLTVDeviation = 'N' 
						END
					ELSE
						SELECT @isLTVDeviation = 'D', @LTVDeviation = @LTV - @MARGIN_VAL, @ArrLTV = @LTV;
				END
			END
					

			SELECT @ApprovedBy = 1

			IF @isLTVDeviation = 'D'
				SELECT @ApprovedBy = 4
							
			INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
						LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal)
						OUTPUT INSERTED.*
			SELECT  @LeadPk,@AppFk, @UsrFk, 'C' , LnaPk , NULL , @ArrLTV,@LTVDeviation , '',  @isLTVDeviation, @ApprovedBy , '',
						@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0 , @MARGIN_VAL
			FROM	LosLnAttributes(NOLOCK)
			WHERE	LnaCd = 'LTV'	

		END
		
		/*-------------------------------LTV DEVIATIONS-----------------------------*/
		

		SELECT @AppCount = COUNT(*) FROM #ApplDet
		DECLARE @TopCount INT;

		WHILE @AppCount > @Loopcount
		BEGIN
			SELECT @isAgeDeviation = 'N' , @AgeDeviation = 0
			-- SELECT THE ROW
			SET @TopCount = @Loopcount + 1			

			SELECT	* INTO	#TempAppTable FROM	#ApplDet WHERE PKVAL = @TopCount

			-- GET THE VALUES OF THE ROW IN VARIABLES 
			SELECT	@Age = AgeatLogin,@AgeMature = MaturityAge ,@income = income , 
					@IncomeType = incometype,@Financier = IncConsider,@LapFk= LapFk ,
					@BusinessAvg = BusinessAvg , @CashAvg = CashAvg , @obligation = obligations,@Salincome = SalIncome
			FROM	#TempAppTable

			/*-------------------- AGE DEVIATION ----------------------*/					
			SET @MARGIN_VAL = 21

			IF		(@IncomeType = 'S'	AND @Financier = 'YES'	AND @Age >= 21 AND @AgeMature <= 60)
				OR	(@IncomeType = 'S'	AND @Financier = 'NA'	AND @Age >= 18 AND @AgeMature <= 60)
				OR	(@IncomeType = 'SE' AND @Financier = 'YES'	AND @Age >= 21 AND @AgeMature <= 65)
				OR	(@IncomeType = 'SE' AND @Financier = 'NA'	AND @Age >= 18 AND @AgeMature <= 65)
				OR	(@IncomeType = '-'  AND @Age >= 18 AND @AgeMature <= 60)
			BEGIN
				SELECT @isAgeDeviation = 'N'				
			END
			ELSE
			BEGIN
				SELECT @isAgeDeviation = 'D'
			END

			SELECT @ArrAgeVAL = @Age

			IF @isAgeDeviation = 'D'
			BEGIN

				IF	(@IncomeType = 'S'	AND @Financier = 'YES')
				BEGIN
					IF @Age < 21
						SELECT @ArrAgeVAL = @Age , @MARGIN_VAL = 21
					ELSE IF @AgeMature > 60
						SELECT @ArrAgeVAL =	@AgeMature, @MARGIN_VAL = 60
				END
				IF (@IncomeType = 'S'	AND @Financier = 'NA')
				BEGIN
					IF @Age < 18
						SELECT @ArrAgeVAL = @Age  , @MARGIN_VAL = 18
					ELSE IF @AgeMature > 60
						SELECT @ArrAgeVAL =	@AgeMature, @MARGIN_VAL = 60
				END
				IF (@IncomeType = 'SE' AND @Financier = 'YES')
				BEGIN
					IF @Age < 21
						SELECT @ArrAgeVAL = @Age, @MARGIN_VAL = 21
					ELSE IF @AgeMature > 65
						SELECT @ArrAgeVAL =	@AgeMature, @MARGIN_VAL = 65
				END
				IF (@IncomeType = 'SE' AND @Financier = 'NA')
				BEGIN
					IF @Age < 18
						SELECT @ArrAgeVAL = @Age, @MARGIN_VAL = 18
					ELSE IF @AgeMature > 65
						SELECT @ArrAgeVAL =	@AgeMature, @MARGIN_VAL = 65
				END
				IF @IncomeType = '-'
				BEGIN
					IF @Age < 18
						SELECT @ArrAgeVAL = @Age, @MARGIN_VAL = 18
					ELSE IF @AgeMature > 60
						SELECT @ArrAgeVAL =	@AgeMature, @MARGIN_VAL = 60
				END
									
				SELECT @AgeDeviation = 
				CASE 
					WHEN (@IncomeType = 'S'		AND @Financier = 'YES'	AND @Age < 21)			THEN @Age - 21
					WHEN (@IncomeType = 'S'		AND @Financier = 'YES'	AND @AgeMature > 60)	THEN @AgeMature - 60
					WHEN (@IncomeType = 'S'		AND @Financier = 'NA'	AND @Age < 18)			THEN @Age - 18
					WHEN (@IncomeType = 'S'		AND @Financier = 'NA'	AND @AgeMature > 60)	THEN @AgeMature - 60
					WHEN (@IncomeType = 'SE'	AND @Financier = 'YES'	AND @Age < 21)			THEN @Age - 21
					WHEN (@IncomeType = 'SE'	AND @Financier = 'YES'	AND @AgeMature > 65)	THEN @AgeMature - 65
					WHEN (@IncomeType = 'SE'	AND @Financier = 'NA'	AND @Age < 18)			THEN @Age - 18
					WHEN (@IncomeType = 'SE'	AND @Financier = 'NA'	AND @AgeMature > 65)	THEN @AgeMature - 65
					WHEN (@IncomeType = '-' AND @Age < 18) THEN @Age - 18
					WHEN (@IncomeType = '-' AND @AgeMature > 60) THEN @Age - 60
					ELSE	0
				END
			END
			ELSE
				SELECT @ArrAgeVAL = @Age

			UPDATE	#ApplDet SET isAgeDeviation = @isAgeDeviation ,AgeDeviation = @AgeDeviation 
			WHERE	LapFk = @LapFk				

			SELECT @ApprovedBy = 1

			IF @AgeDeviation <> 0 
			BEGIN 
				IF ABS(@AgeDeviation) <= 2
					SELECT @ApprovedBy = 1
				IF ABS(@AgeDeviation) <= 5
					SELECT @ApprovedBy = 3
				IF ABS(@AgeDeviation) > 5
					SELECT @ApprovedBy = 4
			END

			INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
					LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal)
					OUTPUT INSERTED.*
			SELECT  @LeadPk,@AppFk, @UsrFk, 'C' , LnaPk , @LapFk , ABS(@ArrAgeVAL),@AgeDeviation ,'',  @isAgeDeviation, @ApprovedBy , '',
					@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0 , @MARGIN_VAL
			FROM	LosLnAttributes(NOLOCK)
			WHERE	LnaCd = 'AGE'		

			/*-------------------- AGE DEVIATION ----------------------*/		


			/*-------------------- INCOME DEVIATION ----------------------*/
			
			SET @MARGIN_VAL = 7500
						
			SELECT @isIncomeDeviation = 'N'

			IF @Financier = 'YES'
			BEGIN
				IF		(@IncomeType = 'S'	AND @ISIIR_FOIR = 'I' AND  (@Salincome - @obligation) >= 7500)
					OR  (@IncomeType = 'S'	AND @ISIIR_FOIR = 'F' AND  @Salincome >= 7500)
					OR	(@IncomeType = 'SE' AND @IsProof = 0  AND @ISIIR_FOIR = 'I' AND (@BusinessAvg-@obligation) >= 120000)
					OR	(@IncomeType = 'SE' AND @IsProof = 0  AND @ISIIR_FOIR = 'F' AND @BusinessAvg >= 120000)
					--OR	(@IncomeType = 'SE' AND @IsProof = 1 AND @ISIIR_FOIR = 'I' AND (@CashAvg-@obligation) >= 10000)
					--OR	(@IncomeType = 'SE' AND @IsProof = 1 AND @ISIIR_FOIR = 'F' AND @CashAvg >= 10000)
					OR (@IncomeType = 'SE' AND @IsProof = 1)
					OR  (@IncomeType = '-'	AND @ISIIR_FOIR = 'I' AND (@income-@obligation) >= 7500)
					OR  (@IncomeType = '-'	AND @ISIIR_FOIR = 'F' AND @income >= 7500)
					SELECT @isIncomeDeviation = 'N'
				ELSE
					SELECT @isIncomeDeviation = 'D'
								
			END	
			
			SELECT @ApprovedBy = 1

			SELECT @IncomeDeviation = 0

			IF @isIncomeDeviation = 'D'
			BEGIN
				SELECT @IncomeDeviation = 	
				CASE	WHEN @IncomeType = 'S' AND @ISIIR_FOIR = 'I' THEN (@Salincome - @obligation) - 7500
						WHEN @IncomeType = 'S' AND @ISIIR_FOIR = 'F' THEN ISNULL(@Salincome,0) - 7500		
						WHEN @IncomeType = 'SE' AND @ISIIR_FOIR = 'I' AND @IsProof = 0 THEN ISNULL(@BusinessAvg,0) - @obligation - 120000
						WHEN @IncomeType = 'SE' AND @ISIIR_FOIR = 'F' AND @IsProof = 0 THEN ISNULL(@BusinessAvg,0) - 120000
						WHEN @IncomeType = 'SE' AND @ISIIR_FOIR = 'I' AND @IsProof = 1 THEN ISNULL(@CashAvg,0) - @obligation - 10000
						WHEN @IncomeType = 'SE' AND @ISIIR_FOIR = 'F' AND @IsProof = 1 THEN ISNULL(@CashAvg,0) - 10000
						WHEN @IncomeType = '-' AND @ISIIR_FOIR = 'I'	THEN ISNULL(@income,0) - @obligation - 7500
						WHEN @IncomeType = '-' AND @ISIIR_FOIR = 'F'	THEN ISNULL(@income,0) - 7500
						ELSE 0
				END												
				SELECT  @ApprovedBy = 4
			END		

			SELECT @MARGIN_VAL = CASE	WHEN @IncomeType = 'S'	THEN  7500		
										WHEN @IncomeType = 'SE' AND @IsProof = 0 THEN 120000
										WHEN @IncomeType = 'SE' AND @IsProof = 1 THEN 10000
										WHEN @IncomeType = '-'	THEN  7500		
										ELSE 0
									END

			INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
					LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal)
					OUTPUT INSERTED.*
			SELECT  @LeadPk,@AppFk, @UsrFk, 'C' , LnaPk , @LapFk , 
					ABS(CASE	WHEN @IncomeType = 'S'	THEN ISNULL(@Salincome,0)
								WHEN @IncomeType = 'SE'	AND @IsProof = 0 THEN ISNULL(@BusinessAvg,0)
								WHEN @IncomeType = 'SE'	AND @IsProof = 1 THEN ISNULL(@CashAvg,0)
							ELSE ISNULL(@income,0)
					END),
					@IncomeDeviation , '',  @isIncomeDeviation, @ApprovedBy , '',
					@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0,@MARGIN_VAL
			FROM	LosLnAttributes(NOLOCK)
			WHERE	LnaCd = 'NET_INC'	

			/*-------------------- INCOME DEVIATION ----------------------*/
				
			TRUNCATE TABLE #TempAppTable			
			DROP TABLE #TempAppTable
			SET @Loopcount = @Loopcount + 1

		END -- WHILE LOOP END

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



