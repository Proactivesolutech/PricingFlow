--EXEC PrcShflCAM N'Load',N'[{"LeadPk":497}]'
IF ISNULL('P','PrcShflCAM') IS NOT NULL
	DROP PROC PrcShflCAM
GO
CREATE PROCEDURE PrcShflCAM
(
    @Action			VARCHAR(100)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,
	@UsrNm			VARCHAR(MAX)		=	NULL 
)
AS
BEGIN

	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE  @CurDt DATETIME,@RowId VARCHAR(40),@UsrDispNm VARCHAR(100),@LeadPk BIGINT,@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			 @Error INT, @RowCount INT, @agt_JobDt VARCHAR(100),@agt_DocFk VARCHAR(100),@RefFk BIGINT ,  @LajServType BIGINT,@AgtFk BIGINT,@MaxJobNo VARCHAR(100),
			 @LajFk BIGINT, @RptPath VARCHAR(MAX),@GeoFk BIGINT, @PrdFk BIGINT, @DocPk BIGINT,@PrpPk BIGINT,@PrpTechPk BIGINT

	
	CREATE TABLE #GlobalDtls
	(
		xx_id BIGINT,LeadPk BIGINT,LeadId VARCHAR(100),LeadNm VARCHAR(100),AppNo VARCHAR(100), GeoFk BIGINT, BranchNm VARCHAR(100),UsrDispNm VARCHAR(100),
		PrdFk BIGINT,PrdNm VARCHAR(100),AgtFk BIGINT
	)
	CREATE TABLE #AppDtls
	(
		Applicant VARCHAR(100),ApplName VARCHAR(300), BuisCat VARCHAR(50), EmpTyp INT,LapFk BIGINT, dob VARCHAR(20), age VARCHAR(3), CibilScr VARCHAR(10),PrdCd VARCHAR(20)
	)
	
	CREATE TABLE #TempCredit (AttrCode VARCHAR(200), Value VARCHAR(200),OrgProductCode VARCHAR(200))

	CREATE TABLE #BuisDtls
	(
		LapRef BIGINT,BuisNm VARCHAR(100), BusiNat VARCHAR(100), OrgTyp VARCHAR(100), BusiPeriod VARCHAR(10), 
		TotExp VARCHAR(10), Design VARCHAR(100) , EmpType CHAR(1) 		
	)

	-- EmpType O - Office , B - business 

	CREATE TABLE #SalarySUmmary (LeadPk BIGINT, LapFk BIGINT , Salary NUMERIC(27,7) , Percentage NUMERIC(27,7) , addless TINYINT )
	CREATE TABLE #BnkBal(LeadPk BIGINT, LapFk BIGINT , Salary NUMERIC(27,7) , Percentage NUMERIC(27,7) , addless TINYINT , Pk BIGINT)

	CREATE TABLE #ObligationSummary (LeadPk BIGINT , LapFk BIGINT , Obligation NUMERIC(27,7))

	CREATE TABLE #INCOMEOBL(LeadPk BIGINT ,LapFk BIGINT , Income NUMERIC(27,7), Obligation NUMERIC(27,7))


	SELECT @CurDt = GETDATE(), @RowId = NEWID()	

	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN	
		
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'FwdDataPk,LeadId,LeadNm,AppNo,GeoFk,BranchNm,UsrNm,PrdFk,PrdNm,AgtFk'

		SELECT	@LeadPk = LeadPk, @UsrDispNm = UsrDispNm, 
				@PrdFk = PrdFk, @GeoFk = GeoFk, @AgtFk = AgtFk
		FROM	#GlobalDtls

	END
	
	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN

				IF @Action = 'GEN_CAM'
				BEGIN
					INSERT	INTO #AppDtls( Applicant,ApplName,BuisCat,EmpTyp,LapFk,dob,age,CibilScr,PrdCd )
					SELECT  
							CASE LapActor 
							WHEN 1 THEN 'CoApplicant' 
							WHEN 2 THEN 'Guarantor' 
							ELSE 'Applicant' END,
							
							CASE ISNULL(LapTitle,-1) 
							WHEN 0 THEN 'Mr.' 
							WHEN 1 THEN 'Ms.' 
							WHEN 2 THEN 'Mrs.' 
							ELSE '' END + ISNULL(LapFstNm,'') + ' ' +ISNULL(LapMdNm,'') + ' ' + ISNULL(LapLstNm,''),
							
							CASE ISNULL(LapEmpTyp,-1) 
							WHEN 0 THEN 'Salaried' 
							WHEN 1 THEN 'Self Employed' 
							WHEN 2 THEN 'House Wife' 
							WHEN 3 THEN 'Pensioner' 
							WHEN 4 THEN 'Student' 
							ELSE 'NA' END , 
							ISNULL(LapEmpTyp,-1), LapPk , dbo.gefgDMY(LapDOB) ,
							DATEDIFF(YEAR, LapDOB, @CurDt),ISNULL(LapCibil,0),PrdCd
					FROM	LosApp A(NOLOCK) 
					LEFT OUTER JOIN GenPrdMas (NOLOCK) ON PrdPk =  A.AppPrdFk  AND PrdDelId = 0 
					JOIN	LosAppProfile B (NOLOCK) ON A.AppPk = B.LapAppFk AND B.LapDelid = 0
					WHERE	A.AppLedFk = @LeadPk AND A.AppDelid = 0		

					INSERT INTO #BuisDtls(LapRef,BuisNm, BusiNat, OrgTyp, BusiPeriod, TotExp, Design, EmpType)
					SELECT	
							LapFk,ISNULL(NULLIF(LabNm,''),'NA'), ISNULL(NULLIF(LabNat,''),'NA'), 
							CASE ISNULL(LabOrgTyp,-1) 
							WHEN 0 THEN 'Public' 
							WHEN 1 THEN 'Private' 
							WHEN 2 THEN 'State' 
							WHEN 3 THEN 'Central' 
							WHEN 4 THEN 'Semi Government' 
							ELSE 'NA' END ,
							ISNULL(LabBusiPrd,0), ISNULL(ISNULL(LabBusiPrd,LabCurBusiPrd),0) ,'Self Employed' , 'B'
					FROM	#AppDtls A
					JOIN	LosAppBusiProfile B(NOLOCK) ON A.LapFk = B.LabLapFk AND B.LabDelid = 0
					WHERE	EmpTyp = 1
	
			
					INSERT INTO #BuisDtls(LapRef,BuisNm, BusiNat, OrgTyp, BusiPeriod, TotExp, Design, EmpType)
					SELECT	
							LapFk, ISNULL(NULLIF(LaeNm,''),'NA'), ISNULL(NULLIF(LaeNat,''),'NA') , 
							CASE ISNULL(LaeTyp,-1) 
							WHEN 0 THEN 'Public' 
							WHEN 1 THEN 'Private' 
							WHEN 2 THEN 'State' 
							WHEN 3 THEN 'Central' 
							WHEN 4 THEN 'Semi Government' 
							ELSE 'NA' END ,
							ISNULL(LaeExp,0) , ISNULL(LaeTotExp,0) ,ISNULL(LaeDesig,'NA') , 'O'
					FROM	#AppDtls A
					JOIN	LosAppOffProfile B(NOLOCK) ON A.LapFk = B.LaeLapFk AND B.LaeDelid = 0
					WHERE	EmpTyp = 0
			
					INSERT INTO #BuisDtls(LapRef,BuisNm, BusiNat, OrgTyp, BusiPeriod, TotExp, Design, EmpType)
					SELECT	LapFk,'NA','NA','NA','NA','NA',BuisCat,''
					FROM	#AppDtls A
					WHERE	EmpTyp NOT IN (0,1)
				
					-- 1 Applicant Details
					SELECT	Applicant,ApplName, dob, age, CibilScr, BuisNm , BusiNat , OrgTyp , BusiPeriod , 
							TotExp , Design ,ISNULL(@UsrDispNm,'admin') 'UsrNm' , PrdCd 'productcode',EmpType
					FROM	#AppDtls A
					JOIN	#BuisDtls B ON A.LapFk = B.LapRef
			
					-- 2 Expected Loan Details
					SELECT	ISNULL(LedLnAmt,0) 'LnAmt', LedROI 'ROI', LedTenure 'Tenure', LedId 'LeadNo'
					FROM	LosLead(NOLOCK)
					WHERE	LedPk = @LeadPk
			
					-- 3 Loan Credit Details
					SELECT  * 			
					FROM
					(
						SELECT	LnaCd 'AttrCode',ISNULL(LcaVal,0) 'Value',PrdCd 'OrgProductCode'
						FROM	LosCreditAttr (NOLOCK) A
						JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
						JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
						LEFT OUTER JOIN GenPrdMas (NOLOCK) ON PrdPk =  LcrPrdFk  AND PrdDelId = 0 
						WHERE	B.LcrLedFk = @LeadPk AND A.LcaDelId = 0  AND LcrDocRvsn = 1 					
					)
					PIVOTTABLE
					PIVOT(MAX(Value) FOR AttrCode IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
									ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI) )
					AS PIVOTTABLE						

					-- 4 Business Income Select
					SELECT	B.LcmNm 'CompName' ,A.LbiYr 'AvgType' , B.LcmAddLess 'AddLess' , A.LbiLapFk 'LapFk' , 
							A.LbiAppFk 'AppFk' , ISNULL(A.LbiVal,0) 'Amount',A.LbiName 'IncName', A.LbiPerc 'Perc',
							C.LapActor 'Actor' , ISNULL(C.LapPrefNm,C.LapFstNm) 'UsrNm' , LbiName 'incomeName'
					FROM	LosAppBusiInc (NOLOCK) A
					JOIN	LosComp (NOLOCK) B ON B.LcmPk = A.LbiLcmFk AND B.LcmDelId = 0 
					JOIN	LosAppProfile (NOLOCK) C ON C.LapPk = A.LbiLapFk AND LapDelId = 0
					WHERE	A.LbiLedFk = @LeadPk AND A.LbiDelId = 0
			
					-- 5 salary income select 
					SELECT	B.LcmNm 'CompName' ,A.LsiMon 'AvgType' , B.LcmAddLess 'AddLess' , A.LsiLapFk 'LapFk' , 
							A.LsiAppFk 'AppFk' , ISNULL(A.LsiVal,0) 'Amount', A.LsiName 'IncName', A.LsiPerc 'Perc',C.LapActor 'Actor', ISNULL(C.LapPrefNm,C.LapFstNm) 'UsrNm'
							, LsiName 'incomeName'
					FROM 	LosAppSalInc (NOLOCK) A
					JOIN	LosComp (NOLOCK) B ON B.LcmPk = A.LsiLcmFk AND B.LcmDelId = 0 
					JOIN	LosAppProfile (NOLOCK) C ON C.LapPk = A.LsiLapFk AND LapDelId = 0
					WHERE	A.LsiLedFk = @LeadPk AND A.LsiDelId = 0
			
					-- 6 cash income select 
					SELECT	B.LcmNm 'CompName' , A.LciYr 'AvgType' , B.LcmAddLess 'AddLess' , A.LciLapFk 'LapFk' , 
							A.LciAppFk 'AppFk' , ISNULL(A.LciVal,0) 'Amount' , A.LciName 'IncName', A.LciPerc 'Perc',
							C.LapActor 'Actor', ISNULL(C.LapPrefNm,C.LapFstNm) 'UsrNm', LciName 'incomeName'
					FROM	LosAppCshInc (NOLOCK) A
					JOIN	LosComp (NOLOCK) B ON B.LcmPk = A.LciLcmFk AND B.LcmDelId = 0 
					JOIN	LosAppProfile (NOLOCK) C ON C.LapPk = A.LciLapFk AND LapDelId = 0
					WHERE	A.LciLedFk = @LeadPk AND A.LciDelId = 0
			

					--7  Other income select 
					SELECT	LoiDesc 'CompName' , 1 'AddLess' , LoiLapFk 'LapFk' , LoiAppFk 'AppFk' , ISNULL(ISNULL(NULLIF(LoiPerc,0),100)/ 100 * LoiAmt,0) 'Amount', 
							LoiName 'IncName', 100 'Perc',LapActor 'Actor', ISNULL(LapPrefNm,LapFstNm) 'UsrNm', LoiName 'incomeName'
					FROM	LosAppOthInc (NOLOCK) 
					JOIN	LosAppProfile (NOLOCK) ON LapPk = LoiLapFk AND LapDelId = 0
					WHERE	LoiLedFk = @LeadPk AND LoiDelId = 0
				 
					--8  bAnk balance select
					SELECT	'On ' + RTRIM(LbbDay) + 'th' AS 'CompName' , Lbbday 'AvgType' , CASE WHEN LbbDay = '-1' THEN '-1' ELSE  '4' END 'AddLess' , 
							LbbLapFk 'LapFk' , LbbAppFk 'AppFk' , ISNULL(LbbVal,0) 'Amount', LbbBnkNm 'IncName', 100 'Perc'
							,LapActor 'Actor', ISNULL(LapPrefNm,LapFstNm) 'UsrNm', LbbName 'incomeName'
					FROM	LosAppBnkBal(NOLOCK)
					JOIN	LosAppProfile (NOLOCK) ON LapPk = LbbLapFk AND LapDelId = 0
					WHERE	LbbLedFk = @LeadPk AND LbbDelId = 0 
					
					-- 9 Obligation details
					SELECT	LaoEMI 'OblEmi', 							
							CASE	WHEN LaoTyp = 0 THEN 'Auto Loan' 
									WHEN LaoTyp = 1 THEN 'Car Loan' 
									WHEN LaoTyp = 2 THEN 'Twowheeler Loan' 
									WHEN LaoTyp = 3 THEN 'Bank' 
									WHEN LaoTyp = 4 THEN 'Loan Against Property' 
									WHEN LaoTyp = 5 THEN 'Gold Loan' 
									WHEN LaoTyp = 6 THEN 'Personal Loan'
									WHEN LaoTyp = 7 THEN 'Business Loan' 
									WHEN LaoTyp = 8 THEN 'Term Loan'
									WHEN LaoTyp = 9 THEN 'Consumer Loan'
								ELSE 'Others' END AS 'Type' , 
								CASE 
									WHEN LapActor = 0 THEN 'Applicant' 
									WHEN LapActor = 1 THEN 'Co Applicant' 
									WHEN LapActor = 1 THEN 'Guarantor' 
								ELSE 'Applicant' END 'Actor',
								LapActor 'actorFlg'
					FROM	LosAppObl (NOLOCK) A 
					JOIN	LosAppProfile (NOLOCK) ON LapPk = LaoLapFk AND LapDelId = 0
					WHERE	LaoLedFk = @LeadPk AND LaoDelId = 0 	AND LoaIsIncl = 0	

					INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage , addless)
					SELECT		LbiLedFk,LbiLapFk,
								CASE WHEN LbiAddLess = 2 THEN (-LbiVal/12) ELSE (LbiVal/12) END ,LbiPerc	,LbiAddLess
					FROM		LosAppBusiInc (NOLOCK)
					WHERE		LbiLedFk = @LeadPk AND LbiDelId = 0 AND LbiAddLess = 3 AND LbiYr = '-1'	
			
					INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage, addless)
					SELECT		LsiLedFk,LsiLapFk,
								CASE WHEN LsiAddLess = 2 THEN -LsiVal ELSE LsiVal END ,LsiPerc	, LsiAddLess
					FROM		LosAppSalInc (NOLOCK)
					WHERE		LsiLedFk = @LeadPk AND LsiDelId = 0 AND LsiAddLess = 3 AND LsiMon = '-1'

			
					INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage,addless)
					SELECT		LciLedFk,LciLapFk,
								CASE WHEN LciAddLess = 2 THEN -LciVal ELSE LciVal END,LciPerc	, LciAddLess
					FROM		LosAppCshInc (NOLOCK)
					WHERE		LciLedFk = @LeadPk AND LciDelId = 0 AND LciAddLess = 3 AND LciYr = '-1'
			

					INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage,addless)
					SELECT		ISNULL(LoiLedFk,0),ISNULL(LoiLapFk,0), 
								CASE WHEN LoiPeriod = 0 THEN  ISNULL(ISNULL(NULLIF(LoiPerc,0),100) / 100 * LoiAmt,0) / 12 
								ELSE ISNULL(ISNULL(NULLIF(LoiPerc,0),100) / 100 * LoiAmt,0) END  , ISNULL(LoiPerc	,100),1
					FROM		LosAppOthInc (NOLOCK)
					WHERE		LoiLedFk = @LeadPk AND LoiDelId = 0 		

					INSERT INTO #BnkBal (LeadPk, LapFk, Salary , Percentage,addless,Pk)
					SELECT		LbbLedFk,LbbLapFk,ISNULL(LbbVal,0),ISNULL(LbbPerc	,100), 1,LbbPk
					FROM		LosAppBnkBal (NOLOCK)
					WHERE		LbbLedFk = @LeadPk AND LbbDelId = 0 AND LbbDay = '-1' 

					INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage,addless)
					SELECT		LeadPk, LapFk, Salary , Percentage,addless 
					FROM		#BnkBal WHERE Pk = (SELECT MAX(Pk) FROM #BnkBal) 


					INSERT INTO #INCOMEOBL(LeadPk ,LapFk , Income)
					SELECT		LeadPk ,LapFk ,  SUM(Salary) sal 
					FROM		#SalarySUmmary GROUP BY LapFk,LeadPk				

					INSERT INTO #ObligationSummary (LeadPk,LapFk,Obligation)
					SELECT		LaoLedFk,LaoLapFk,SUM(LaoEMI) 
					FROM		LosAppObl (NOLOCK) A 
					WHERE		LaoLedFk = @LeadPk AND LaoDelId = 0 AND LoaIsIncl = 0
					GROUP BY	LaoLedFk,LaoLapFk						

					IF EXISTS(SELECT 'X' FROM #INCOMEOBL)
					BEGIN
						UPDATE	T  SET T.Obligation = A.Obligation
						FROM	#INCOMEOBL  T
						JOIN	#ObligationSummary A ON A.LapFk = T.LapFk AND A.LeadPk = T.LeadPk
					END
					ELSE
					BEGIN
						INSERT INTO #INCOMEOBL(LeadPk ,LapFk , Obligation)
						SELECT		LaoLedFk,LaoLapFk,SUM(LaoEMI) FROM LosAppObl (NOLOCK) A 
						WHERE		LaoLedFk = @LeadPk AND LaoDelId = 0 
						GROUP BY	LaoLedFk,LaoLapFk
					END

					-- 10 Income obligation 
					SELECT	LeadPk 'LeadPk',LapFk 'LapFk',ISNULL(Income,0) 'inc', ISNULL(Obligation,0) 'obl',
							CASE WHEN LapActor = 0 THEN 'Applicant' ELSE 'Co-Applicant' END 'Actor'
					FROM	#INCOMEOBL
					JOIN	LosAppProfile (NOLOCK) ON LapPk = LapFk AND LapLedFk = @LeadPk


					-- 11 Technical valuation of Properties
					SELECT	LptPrpFk 'PropFk',LptRptDt 'RptDt',LptSts 'RptSts',LptMktVal 'MktVal',LptPrpValRmks 'Rmks',LptPrpTyp 'PrpType'
					FROM	LosPropTechnical WHERE LptLedFk = @LeadPk AND LptDelId = 0

					--12 Min value
					SELECT	ISNULL(Min(LptMktVal),0) 'MinMktVal'
					FROM	LosPropTechnical WHERE LptLedFk = @LeadPk AND LptDelId = 0
				END			

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

