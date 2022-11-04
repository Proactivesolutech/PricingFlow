IF OBJECT_ID('PrcShflCreditOff_new','P') IS NOT NULL
	DROP PROCEDURE PrcShflCreditOff_new
GO
CREATE PROCEDURE PrcShflCreditOff_new
(
	@Action			VARCHAR(100) ,
	@GlobalJson		VARCHAR(MAX) = NULL,
	@DetailJson		VARCHAR(MAX) = NULL,
	@ChangePrdFk	VARCHAR(MAX) = NULL
)
AS
BEGIN
--RETURN
	SET NOCOUNT ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	DECLARE @DBNAME VARCHAR(50) = db_name() 

	DECLARE	 @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(200), @UsrNm VARCHAR(200),@PrdFk BIGINT,
		@AppFk BIGINT,@LapFk BIGINT, @CreditPk BIGINT,@RowId VARCHAR(MAX) , @RoleFk BIGINT , @SanctionNo VARCHAR(200) , @SanctionPk BIGINT,
		@MaxSanNo BIGINT , @AgtFk BIGINT , @PfPk BIGINT , @ApproverLvl TINYINT ,@CreditDocNo TINYINT, @LoanNo VARCHAR(200) , @MaxLoanNo BIGINT , @PrdCd VARCHAR(200),
		@LastSancNo INT, @AppPrd VARCHAR(20), @LsnRvnNo BIGINT,@IsReject CHAR(1) , @waiverROI NUMERIC(5,2) , @CurApprover TINYINT, 
		@MaxApprover TINYINT, @NumGenUNODB VARCHAR(100), @BrnCd VARCHAR(100); 

	DECLARE @PFPer NUMERIC(27,7), @WaiverAmt NUMERIC(27,7),@TotPF NUMERIC(27,7), @BTPF NUMERIC(27,7), @TopupPF NUMERIC(27,7),
			@BTWaivePercent BIGINT, @TopupWaivePercent BIGINT,@CollPF NUMERIC(27,7)

	CREATE TABLE #GlobalDtls(xx_id BIGINT,LeadPk BIGINT,  UsrPk BIGINT, UsrDispNm VARCHAR(100),UsrNm VARCHAR(100), PrdCd VARCHAR(100),
				RoleFk BIGINT, BrnchFk BIGINT, PrdNm VARCHAR(200), LeadNm VARCHAR(100), LeadID VARCHAR(100), PrdFk BIGINT, AgtNm VARCHAR(100), 
				AgtFk BIGINT, Branch VARCHAR(100), CreditPk BIGINT,EMI NUMERIC(27,7),ApproverLvl TINYINT,CreditDocNo TINYINT,TOP_EMI NUMERIC(27,7),
				SancRvnNo SMALLINT,isMoveNxt VARCHAR(20),IsReject CHAR(1),waiverROI NUMERIC(5,2), CurApprover TINYINT,MaxApprover TINYINT)

	CREATE TABLE #DetailsTbl (xx_id BIGINT, NotesJson VARCHAR(MAX),CreditJson VARCHAR(MAX),SubjectiveJSON VARCHAR(MAX) , 
				PFJson VARCHAR(MAX) , CreditInJSON VARCHAR(MAX) , ManualDeviation VARCHAR(MAX))

	DECLARE @NotesJson VARCHAR(MAX),@SubjectiveJSON VARCHAR(MAX), @CreditJson VARCHAR(MAX) , @PfJson VARCHAR(MAX), 
	@CreditInJSON  VARCHAR(MAX),@isMoveNxt VARCHAR(20),@ManualDeviation VARCHAR(MAX);

	CREATE TABLE #SalarySUmmary (LeadPk BIGINT, LapFk BIGINT , Salary NUMERIC(27,7) , Percentage NUMERIC(27,7) , addless TINYINT )

	CREATE TABLE #BnkBal(LeadPk BIGINT, LapFk BIGINT , Salary NUMERIC(27,7) , Percentage NUMERIC(27,7) , addless TINYINT , Pk BIGINT)

	CREATE TABLE #ObligationSummary (LeadPk BIGINT , LapFk BIGINT , Obligation NUMERIC(27,7))

	CREATE TABLE #INCOMEOBL(LeadPk BIGINT ,LapFk BIGINT , Income NUMERIC(27,7), Obligation NUMERIC(27,7))

	CREATE TABLE #NotesTable(xx_id BIGINT ,Attr VARCHAR(100), LnaFk  BIGINT ,Notes VARCHAR(MAX));
	
	CREATE TABLE #SubjectiveNotes(xx_id BIGINT ,dt VARCHAR(100), note VARCHAR(MAX));

	CREATE TABLE #CreditTable(xx_id BIGINT ,Attr VARCHAR(50) ,  value NUMERIC(27,7));

	CREATE TABLE #CreditINTable(xx_id BIGINT ,LTV NUMERIC(27,7), ROI NUMERIC(27,7), LOAN NUMERIC(27,7), FOIR NUMERIC(27,7),TENURE INT,TENUR_TOP INT);

	CREATE TABLE #PFtable(xx_id BIGINT ,Attr VARCHAR(100) ,  value NUMERIC(27,7) , perc NUMERIC(27,7), waiver NUMERIC(27,7))

	CREATE TABLE #TempCrediTable(CreditPk BIGINT, LnAttrPk BIGINT , AttrCode VARCHAR(50) , Value NUMERIC(27,7) , AttrPK BIGINT)

	CREATE TABLE #TempSanctionNoTable(DOC_NO VARCHAR(150) , LASTNO INT);

	CREATE TABLE #SanctionPK (SanctionPk BIGINT, ProdFk BIGINT, creditPk BIGINT);
	
	CREATE TABLE #TempCreditAttrTable (creditPk BIGINT, LoanAttrFk BIGINT, val NUMERIC(27,7));

	CREATE TABLE #TempLeadInfo(LeadId VARCHAR(300),BranchFk VARCHAR(100),BranchName VARCHAR(300),ApplicationNo VARCHAR(300),PurposeVal VARCHAR(2),ProductName VARCHAR(300),
					Purpose VARCHAR(500),ProductFk VARCHAR(100),ProductCode VARCHAR(100),customerClass VARCHAR(3),incomeClass VARCHAR(3),AppFk VARCHAR(100), 
					LoanAmt VARCHAR(300),Tenure VARCHAR(300),ROI VARCHAR(30),MrkPropValue VARCHAR(100),EMI VARCHAR(100),prdicon VARCHAR(100),ProductGrpFk VARCHAR(100),
					grpicon VARCHAR(300),grpName VARCHAR(300));
					
	CREATE TABLE #ManualDev (xx_id BIGINT , levels INT , Rmks VARCHAR(MAX))

	CREATE TABLE #AgentTmpTable(RptStatus VARCHAR(100),FBLapFk VARCHAR(100),ServiceTyp VARCHAR(100),DocPath VARCHAR(100))

	CREATE TABLE #SancTmpTbl(SancCode VARCHAR(100))

	SELECT @CurDt = GETDATE(), @RowId = NEWID()	

	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN					
	
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'FwdDataPk,UsrPk,UsrNm,UsrCd,PrdCd,Role,BrnchFk,PrdNm,LeadNm,LeadID,PrdFk,AgtNm,AgtFk,Branch,CreditPk,EMI,ApproverLvl,CreditDocNo,TOP_EMI,SancRvnNo,isMoveNxt,IsReject,waiverROI,CurApprover,MaxApprover'						 		

		-- Changes for BPM and LOS
		IF EXISTS(SELECT 'X' FROM SYSOBJECTS WHERE NAME = 'LosApp' )
		BEGIN
			SELECT	@LeadPk = LeadPk, 
					@AppFk = AppPk, 
					@UsrDispNm = G.UsrDispNm, @UsrNm = G.UsrNm , @CreditPk = CreditPk,@UsrPk = G.UsrPk , 
					@RoleFk = RoleFk,@GeoFk = BrnchFk,@AgtFk = AgtFk,@PrdFk = AppPrdFk,@ApproverLvl = ApproverLvl,
					@CreditDocNo = CreditDocNo, @AppPrd = P.PrdCd, @LsnRvnNo = SancRvnNo,@isMoveNxt = isMoveNxt,@IsReject=IsReject,
					@waiverROI = waiverROI,@CurApprover = CurApprover,@MaxApprover = MaxApprover
			FROM	#GlobalDtls G
			JOIN	LosApp (NOLOCK) ON AppLedFk = LeadPk AND AppDelId = 0
			JOIN	GenPrdMas (NOLOCK) P ON PrdPk = AppPrdFk AND PrdDelId = 0
			JOIN    LosAppProfile (NOLOCK) ON LapLedFk = AppLedFk AND LapDelId = 0				
		END
		ELSE
		BEGIN
			SELECT	@LeadPk = LeadPk, 
					@UsrDispNm = UsrDispNm, @UsrNm = UsrNm , @CreditPk = CreditPk,@UsrPk = UsrPk
			FROM	#GlobalDtls 
		END

		SELECT	@NumGenUNODB = CmpUNODB + '.dbo.GetGenNumForLOS'
		FROM	GenCmpMas(NOLOCK)

		SELECT	@BrnCd =  GeoCd FROM GenGeoMas(NOLOCK) 		
		WHERE	GeoPk = @GeoFk
	END

	IF @DetailJson != '[]' AND @DetailJson != ''
	BEGIN	
		INSERT INTO #DetailsTbl
		EXEC PrcParseJSON @DetailJSON,'NotesJson,CreditJson,SubjectiveJSON,PFJson,CreditInJSON,ManualDeviation'
		

		SELECT	@NotesJson = NotesJson , @CreditJson = CreditJson , @SubjectiveJSON = SubjectiveJSON, 
				@PFJson = PFJson , @CreditInJSON = CreditInJSON,@ManualDeviation = ManualDeviation
		FROM	#DetailsTbl

		IF @NotesJson != '[]' AND @NotesJson != ''
		BEGIN
			INSERT INTO #NotesTable
			EXEC PrcParseJSON @NotesJson, 'Attr,LnaFk,Notes'
		END
		
		IF @CreditJson != '[]' AND @CreditJson != ''
		BEGIN
			INSERT INTO #CreditTable
			EXEC PrcParseJSON @CreditJson, 'Attr,value'
		END

		IF @SubjectiveJSON != '[]' AND @SubjectiveJSON != ''
		BEGIN

			INSERT INTO #SubjectiveNotes
			EXEC PrcParseJSON @SubjectiveJSON, 'date,notes'
		END

		IF @PFJson != '[]' AND @PFJson != ''
		BEGIN
			INSERT INTO #PFtable
			EXEC PrcParseJSON @PFJson, 'Attr,value,perc,waiver'
		END
		
		IF @CreditInJSON != '[]' AND @CreditInJSON != ''
		BEGIN
			INSERT INTO #CreditINTable
			EXEC PrcParseJSON @CreditInJSON, 'LTV,ROI,LOAN,FOIR,TENURE,TENUR_TOP'
		END

		IF @ManualDeviation != '[]' AND @ManualDeviation != ''
		BEGIN
			INSERT INTO #ManualDev
			EXEC PrcParseJSON @ManualDeviation, 'level,Rmks'
		END
		

	END

	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN
			
			IF @Action = 'SELECT_SUMMARY'
			BEGIN
				-- calculation of income and obligations
				INSERT INTO #INCOMEOBL(LeadPk,LapFk,Income, Obligation)
				SELECT	@LeadPk, LioLapFk,ISNULL(SUM(LioSumAMt),0),0 
				FROM	LosAppIncObl (NOLOCK)
				WHERE	LioLedfk = @LeadPk AND LiodeLid = 0 AND LioType <> 'OB'
				GROUP BY LioLapFk


				IF EXISTS(SELECT 'X' FROM #INCOMEOBL)
				BEGIN															
					SELECT ISNULL(SUM(LioSumAMt),0) Obl,LioLapFk LapFk 
					INTO	#TempOblTable
					FROM	LosAppIncObl (NOLOCK)
					WHERE	LioLedfk = @LeadPk AND LiodeLid = 0 AND LioType = 'OB'
					GROUP BY LioLapFk

					UPDATE	T  SET T.Obligation = A.Obl
					FROM	#INCOMEOBL  T
					JOIN	#TempOblTable A ON A.LapFk = T.LapFk
				END
				ELSE
				BEGIN
					INSERT INTO #INCOMEOBL(LeadPk ,LapFk , Obligation)
					SELECT @LeadPk,LioLapFk,ISNULL(SUM(LioSumAMt),0)
					FROM	LosAppIncObl (NOLOCK)
					WHERE	LioLedfk = @LeadPk AND LiodeLid = 0 AND LioType = 'OB'
					GROUP BY LioLapFk
				END	
				
				INSERT INTO #AgentTmpTable(RptStatus,FBLapFk,ServiceTyp,DocPath)
				SELECT DISTINCT	LfjRptSts, LavLapFk, 
						CASE WHEN LfjSrvTyp = 0  THEN 'FIR' WHEN LfjSrvTyp = 1 THEN 'FIO' WHEN LfjSrvTyp = 2 THEN 'DV'
						WHEN LfjSrvTyp = 3 THEN 'CF' END,
						--ISNULL(DocPath,'') 'DocPath' 
						ISNULL(STUFF(
						 (SELECT '$$$' + DocPath 
							FROM	LosAgentFBDocs (NOLOCK) t3
							JOIN	LosDocument (NOLOCK) t1 ON t1.DocPk = t3.LfdDocFk AND t1.DocDelId = 0 
							WHERE	t1.DocPk = LfdDocFk AND t1.DocDelId = 0 AND t1.DocLedFk = @LeadPk AND t3.LfdLfjFk = LfjPk
									AND t1.DocCat IN ('PD','RPT')
							FOR XML PATH (''))
						 , 1, 3, '') ,'')
				FROM	LosAgentVerf (NOLOCK)
				JOIN	LosAgentJob (NOLOCK) ON LajPk = LavLajFk AND LajDelId = 0
				JOIN	LosAgentFBJob (NOLOCK) ON LfjLavFk = LavPk AND LfjDelid = 0
				LEFT OUTER JOIN LosAgentFBDocs (NOLOCK) ON LfdLfjFk = LfjPk AND LfdDelId = 0
				LEFT OUTER JOIN LosDocument(NOLOCK) t2 ON t2.DocPk = LfdDocFk  AND t2.DocDelId = 0
				WHERE	LajLedFk = @LeadPk AND LavDelid = 0 
				GROUP BY	LfjRptSts , LfjSrvTyp , LavLapFk,LfdDocFk,LfjPk				
				UNION ALL				

				SELECT DISTINCT	LpdSts,LpdLapFk,'PD',
						DocPath 
				FROM	LosAppPD (NOLOCK) 
				LEFT OUTER JOIN	LosDocument (NOLOCK) ON DocPk = LpdDocFk AND DocDelId =0 
				WHERE	LpdLedFk = @LeadPk AND LpdDelId = 0
				UNION ALL

				SELECT DISTINCT	LtvSts,LtvLapFk ,
						CASE WHEN Ltvtype = 1 THEN 'TER' ELSE 'TEO' END ,
						'' 
				FROM	LosAppTeleVerify (NOLOCK) 
				WHERE	LtvLedFk = @LeadPk AND LtvDelId = 0	
				
				INSERT INTO #AgentTmpTable(RptStatus,FBLapFk,ServiceTyp,DocPath)
				SELECT LptSts, 0, 'TV',''
				FROM   LosPropTechnical(NOLOCK) WHERE LptLedFk = @LeadPk

				IF EXISTS(SELECT 'X' FROM LosPropLegal(NOLOCK) WHERE LplLedFk = @LeadPk)
					BEGIN 					
						INSERT INTO #AgentTmpTable(RptStatus,FBLapFk,ServiceTyp,DocPath)
						SELECT LpLSts, 0, 'LV',''
						FROM   LosPropLegal(NOLOCK) WHERE LplLedFk = @LeadPk
					END

				ELSE
					BEGIN					
						INSERT	INTO #AgentTmpTable(RptStatus,FBLapFk,ServiceTyp,DocPath)
						SELECT	LfjRptSts,0,'LV',''
						FROM	LosAgentJob(NOLOCK)						
						JOIN	LosAgentFBJob (NOLOCK) ON LfjLajFk = LajPk AND LfjDelId = 0
						WHERE	LajLedFk = @LeadPk AND LfjSrvTyp = 4 AND LajDelId = 0												
					END	
																						
												
				-- 1 SUmmary details 

				SELECT	ISNULL(LapFstNm+' '+LapMdNm+' '+LapLstNm,'') 'ApplicantName', LapActor 'Actor',
						CONVERT(numeric(27,2),ISNULL(ROUND(Income,0),0)) 'income' ,
						CONVERT(numeric(27,2),ISNULL(ROUND(Obligation,0),0)) 'Obligation' ,
						ISNULL(LapCibil,'') 'CIBILscore',						
						ISNULL(LapEmpTyp,'') 'customerClass',
						CONVERT(VARCHAR,LedIncPrf) 'incomeClass' ,	
						CASE WHEN dateadd(year, datediff (year, LapDOB, getdate()), LapDOB) > getdate()
						THEN datediff(year, LapDOB, getdate()) - 1
						ELSE datediff(year, LapDOB, getdate()) END as 'Age',
						CASE WHEN LapActor = 0  THEN 'Applicant' WHEN LapActor = 1 THEN 'Co Applicant'  WHEN LapActor = 2 THEN 'Guarantor'  END 'ApplicantType', 
						LapPk 'AppFk' , LaeTyp 'EmpType', LaeNat 'EmpNature',						
						CASE WHEN LaeTotExp > 0 THEN (LaeTotExp/12) ELSE 0 END 'EmpTotExp',CASE WHEN LaeExp > 0 THEN (LaeExp/12) ELSE 0 END 'EmpCurExp',
						LabNat 'BusiNat', LabIncYr 'BusiStartYr', LabOwnShip 'BusiOwner', 
						CASE WHEN LabBusiTyp = 0 THEN 'P' WHEN LabBusiTyp = 1 THEN 'NP' ELSE 'NONE' END 'BusiTyp', 
						CASE WHEN LabOrgTyp = 0 THEN 'PUB' WHEN  LabOrgTyp = 1 THEN 'PVT' ELSE 'NONE' END 'BusiOrgTyp' , 
						LabBusiPrd 'BusiTotPrd' , LabCurBusiPrd 'BusiCurPrd',Obligation 'obligations',LedPNI 'IsPNI'
				FROM	LosLead(NOLOCK) 
						JOIN	LosAppProfile(NOLOCK)  ON LapLedFk = LedPk AND LedDelId = 0
						LEFT OUTER JOIN	LosAppOffProfile (NOLOCK) ON LaeLapFk = LapPk AND LaeDelId = 0 
						LEFT OUTER JOIN	LosAppBusiProfile (NOLOCK) ON LabLapFk = LapPk AND LabDelId = 0
						JOIN	LosApp(NOLOCK) ON AppLedFk = LedPk AND LapAppFk = AppPk AND AppDelId=0
						LEFT OUTER JOIN	#INCOMEOBL ON LapFk = LapPk AND LeadPk = LapLedFk
				WHERE	LedPk = @LeadPk AND LapDelId = 0 ORDER BY LapActor

				
				
				-- Inserted Credit details - based on Approver level 
				INSERT INTO #TempCrediTable
				SELECT	LcaLcrFk ,LcaLnaFk ,LnaCd ,LcaVal ,LcaPk
				FROM	LosCreditAttr (NOLOCK) A
						JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
						JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
				WHERE	B.LcrLedFk = @LeadPk  AND A.LcaDelId = 0  AND LcrDocRvsn = @ApproverLvl										


				-- Temp Previous Credit table

				SELECT	*			
				INTO #TempPreviousCredit				
				FROM
					(
						SELECT	LnaCd ,LcaVal
						FROM	LosCreditAttr (NOLOCK) A
								JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
								JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
						WHERE	B.LcrLedFk = @LeadPk AND A.LcaDelId = 0  
						AND LcrDocRvsn = @ApproverLvl - 1 
					) PIVOTCredit 
					PIVOT (MAX(LcaVal) FOR  LnaCd IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
							ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,
							BT_LTV_A,TOPUP_LTV_A,BT_LTV_M,TOPUP_LTV_M,ROI_CHANGE ))
					AS PIVOTCredit 
				
				IF EXISTS(SELECT 'X' FROM #TempCrediTable)
				BEGIN 
					--2 SELECT the credit details if the same approver level data exists					
					--SELECT * FROM #TempCrediTable					

					SELECT	* FROM
					(
						SELECT AttrCode,Value FROM #TempCrediTable
					)
					PIVOTTABLE
					PIVOT(MAX(Value) FOR AttrCode IN(OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
							ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,
							BT_LTV_A,TOPUP_LTV_A,BT_LTV_M,TOPUP_LTV_M,ROI_CHANGE))
					AS PIVOTTABLE					

				END

				ELSE
				BEGIN
					--2 SELECT the credit details of pervios approver level data if exists, else empty					
					SELECT	*			
					FROM
						(
							SELECT	LnaCd ,LcaVal
							FROM	LosCreditAttr (NOLOCK) A
									JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
									JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
							WHERE	B.LcrLedFk = @LeadPk AND A.LcaDelId = 0  
							AND LcrDocRvsn = @ApproverLvl - 1 AND LcrDocRvsn <> 0
						) PIVOTCredit 
						PIVOT (MAX(LcaVal) FOR  LnaCd IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
								ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,
								BT_LTV_A,TOPUP_LTV_A,BT_LTV_M,TOPUP_LTV_M,ROI_CHANGE ))
						AS PIVOTCredit 
				END

				
				--3 Expected Loan parameters -- From lead
				SELECT	LedLnAmt 'ExpLOAN',LedTenure 'ExpTENURE',REPLACE(LedROI,'%','') 'ExpROI',LedEMI 'ExpEMI'
				FROM	LosLead (NOLOCK) WHERE LedPk = @LeadPk  and LedDelId = 0
				

				-- 4 SELECT LEAD INFO , PRODUCT AND INCOME TYPE
				INSERT INTO #TempLeadInfo(LeadId,BranchFk,BranchName,ApplicationNo,PurposeVal,ProductName,Purpose,ProductFk,ProductCode,customerClass,
							incomeClass,AppFk , LoanAmt,Tenure,ROI,MrkPropValue,EMI,prdicon,ProductGrpFk,grpicon,grpName)
				SELECT	ISNULL(LedId,'') 'LeadId',ISNULL(LedBGeoFk,'') 'BranchFk',ISNULL(GeoNm,'') 'BranchName', ISNULL(AppAppNo,'') 'ApplicationNo', 
						ISNULL(AppLnPur,'') 'PurposeVal', ISNULL(PrdNm,'') 'ProductName',
						CASE WHEN AppLnPur = 0 THEN 'Take over of existing Housing Loan' 
							WHEN AppLnPur = 1 THEN 'Extend Renovate Repair of House Flat' 
							WHEN AppLnPur = 2 THEN 'Construction' 
							WHEN AppLnPur = 3 THEN 'Plot And Construction' 
							WHEN AppLnPur = 4 THEN 'Flat New' 
							WHEN AppLnPur = 5 THEN 'Flat ReSale' 
							WHEN AppLnPur = 6 THEN 'House New' 
							WHEN AppLnPur = 7 THEN 'House ReSale' 
							WHEN AppLnPur = 8 THEN 'Refinance' 
							WHEN AppLnPur = 9 THEN 'House Old' 
							WHEN AppLnPur = 10 THEN 'Additional Finance' 
							WHEN AppLnPur = 11 THEN 'House Extension' 
							ELSE ''
						END 'Purpose',
						ISNULL(PrdPk,'') 'ProductFk',	
						ISNULL(PrdCd,'') 'ProductCode',	
						ISNULL(AppSalTyp,'') 'customerClass',CONVERT(VARCHAR,AppSalPrf) 'incomeClass' , AppPk 'AppFk' ,LedLnAmt 'LoanAmt',
						ISNULL(LedTenure,0) 'Tenure', LedROI 'ROI',LedMrktVal 'MrkPropValue' , LedEMI 'EMI',
						ISNULL(PrdIcon,'') 'prdicon' ,
						ISNULL(AppPGrpFk,'') 'ProductGrpFk',	
						ISNULL(GrpIconCls,'') 'grpicon',
						ISNULL(GrpNm,'') 'grpName'
						--, ISNULL((SELECT PrdIcon FROM GenPrdMas (NOLOCK) WHERE PrdPk = ISNULL(AppPrdSubFk,0) AND PrdDelId=0),'')  'SubPrdicon'
				FROM	LosLead(NOLOCK) 
				JOIN	LosApp(NOLOCK) ON AppLedFk = LedPk AND AppDelId=0
				LEFT OUTER JOIN GenLvlDefn (NOLOCK) ON GrpPk = AppPGrpFk AND GrpDelId = 0
				JOIN	GenGeoMas(NOLOCK) ON GeoPk = LedBGeoFk AND GeoDelId = 0
				LEFT OUTER JOIN	GenPrdMas(NOLOCK) ON PrdPk = AppPrdFk AND PrdDelId = 0
				WHERE	LedPk = @LeadPk AND LedDelId = 0	

				SELECT * FROM #TempLeadInfo

				SELECT @PrdCd = ProductCode FROM #TempLeadInfo

				-- 5 Loan Calculations
				IF @PrdCd IN ('LAPResi', 'LAPCom', 'LAPBTTopup', 'LAPBT', 'LAPTopup')
					EXEC PrcCalculateLoan_LAP @LeadPk,@PrdCd
				ELSE
					EXEC PrcCalculateLoan @LeadPk,@PrdCd
								
				-- 6 Total paid PF amount
				SELECT	ISNULL(SUM(LpcChrg),0) 'PfAmount' 				
				FROM	LosProcChrg (NOLOCK) 
				JOIN	GenMas(NOLOCK)	ON 	MasPk = LpcDocTyp		
				WHERE	LpcLedFk = @LeadPk AND LpcDelId = 0 AND MasCd IN('IMC', 'BPC') 
				AND		MasDelId = 0 AND ISNULL(LpcChqSts,'') <> 'B'

				-- 7 Agents Verfication Status , 0- negative 1 - neutral 2 - positive
				SELECT	RptStatus 'Status',FBLapFk 'LapFk',ServiceTyp 'serv',DocPath 'DocPath' 
				FROM	#AgentTmpTable

				-- 8 PF and wiaver amount
				SELECT	ISNULL(SUM(LpcChrg),0) 'PfAmount',ISNULL(SUM(LpcWavier),0) 'waiveramt' ,MAX(LpcDis) 'perc'
				FROM	LosProcChrg (NOLOCK) 
				JOIN	GenMas(NOLOCK) ON MasPk = LpcDocTyp
				WHERE	LpcLedFk = @LeadPk AND LpcDelId = 0 AND MasCd = 'PFPAY' AND MasDelId = 0
				
				-- 9 NExt Sanction Number to show in page
				IF NOT EXISTS(SELECT 'X' FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0)
				BEGIN 										
					--SELECT @SanctionNo 'SancNo', 0 'PK'
					SELECT @SanctionNo 'SancNo', 0 'PK'

				END
				ELSE
				BEGIN
					SELECT @SanctionNo = LsnSancNo FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0
					SELECT LsnSancNo 'SancNo', LsnPk 'PK' FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0
				END									

				-- 10 To get the recommended values
				SELECT	LOAN_AMT, BT_AMT , TOPUP_AMT , ROI , BT_ROI , TOPUP_ROI , EMI , BT_EMI, TOPUP_EMI 
				FROM	#TempPreviousCredit
								
				-- 11 To get the sancion-subjective conditions
				--SELECT	LscNote 'Snote', LscPk 'Spk',LsnPk 'SancPk'
				SELECT	DISTINCT LscNote 'Snote', 0 'Spk',0 'SancPk'
				FROM	LosSubjCondtion(NOLOCK) 
				JOIN	LosSanction(NOLOCK) ON LsnPk = LscLsnFk AND LsnDelId = 0
				WHERE	LsnLedFk = @LeadPk AND LscDelId = 0 AND LscPreDef = 0
								

				-- 12 SELECT CREDIT TABLE SAVED INPUT  PARAMETERS, LCRLTV,LCRROI,LCRLOAN,LCRFOIR				
				SELECT	LcrLedFk,LcrRolFk,LcrUsrFk,LcrDocNo,LcrDocRvsn,LcrDocTyp,LcrDocDt,LcrPk,LcrLTV 'LTV',LcrROI 'ROI',CONVERT(BIGINT,ISNULL(LcrLoan,0)) 'LOAN',LcrFOIR 'FOIR',LcrTenur 'TENURE',LcrTenurTop 'TENURE_TOP'
				FROM	LosCredit (NOLOCK) WHERE LcrLedFk = @LeadPk AND LcrDocRvsn = @ApproverLvl AND LcrDelId = 0 AND LcrDocRvsn <> 0				

				-- 13 SELECT CREDIT TABLE SAVED INPUT  PARAMETERS, LCRLTV,LCRROI,LCRLOAN,LCRFOIR -- PREVIOUS			
				SELECT	LcrLedFk,LcrRolFk,LcrUsrFk,LcrDocNo,LcrDocRvsn,LcrDocTyp,LcrDocDt,LcrPk,LcrLTV 'LTV',LcrROI 'ROI',CONVERT(BIGINT,ISNULL(LcrLoan,0)) 'LOAN',LcrFOIR 'FOIR',LcrTenur 'TENURE',LcrTenurTop 'TENURE_TOP'
				FROM	LosCredit (NOLOCK) WHERE LcrLedFk = @LeadPk and LcrDocRvsn = @ApproverLvl-1 and LcrDelId = 0 AND LcrDocRvsn <> 0				

				-- 14 Loan Number
				IF NOT EXISTS(SELECT 'X' FROM LosLoan(NOLOCK) WHERE LlnLedFk = @LeadPk AND LlnDelId = 0)
				BEGIN 
					SELECT @MaxLoanNo = (CONVERT(BIGINT,RIGHT(MAX(LlnLoanNo),5)) + 1) FROM LosLoan(NOLOCK)
					IF ISNULL(@MaxLoanNo,0) = 0 SET @MaxLoanNo =  1;
					SELECT @LoanNo = 'SHFHOLOAN' + dbo.gefgGetPadZero(5,(ISNULL(@MaxLoanNo,0)))					
					SELECT @LoanNo 'LoanNo'

				END
				ELSE
				BEGIN
					SELECT @LoanNo = LlnLoanNo FROM LosLoan(NOLOCK) WHERE LlnLedFk = @LeadPk AND LlnDelId = 0
					SELECT @LoanNo 'LoanNo'
				END				
								
				-- 15 SELECT Existing Loan for BT / BT + Topup				
				SELECT	ISNULL(SUM(LelOutstandingAmt),0) 'amount',ProductCode 'PrdCode',ISNULL(LelTenure,0) 'remaining'
				FROM	#TempLeadInfo (NOLOCK) 
				LEFT OUTER JOIN	LosAppExistLn(NOLOCK) ON LelAppFk = AppFk 
				WHERE	LelLedFk = @LeadPk AND LelDelId = 0 
				GROUP BY ProductCode,LelTenure	

				-- 16 th select to get Max approver
				SELECT	ISNULL(MAX(LdvAppBy),0) 'ApproverLevel'
				FROM	LosDeviation (NOLOCK)
				WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 
				
				-- 17 th select to get manual Deviation
				SELECT	LdvAppBy 'Level',LdvRmks 'Remarks'
				FROM	LosDeviation T (NOLOCK)
				JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
				WHERE	LdvStage = 'C' AND LdvLedFk = @LeadPk  AND LnaCd = 'MANUALDEV' AND LdvDelId = 0

				-- 18 th select to get manual Deviation
				SELECT	ISNULL(LdvDevVal,0) 'waiverROI'
				FROM	LosDeviation T (NOLOCK)
				JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
				WHERE	LdvStage = 'C' AND LdvLedFk = @LeadPk  AND LnaCd IN('ROI','BT_ROI')
			END			
			
			IF @Action = 'ADD_NOTES'
			BEGIN						
			
				INSERT INTO	LosCreditAttrNotes(LcnLedFk,LcnLnaFk,LcnUsrFk,LcnRoleFk,LcnNotes,LcnRowId,LcnCreatedBy,LcnCreatedDt,LcnModifiedBy,LcnModifiedDt,LcnDelFlg,LcnDelId)
				OUTPUT INSERTED.*
				SELECT		@LeadPk,LnaPk,@UsrPk,@RoleFk,Notes,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0 
				FROM		#NotesTable
				JOIN		LosLnAttributes (NOLOCK) ON LnaCd = Attr AND LnaDelId = 0
			END
			IF @Action = 'EDIT_NOTES'
			BEGIN						
			
				UPDATE	LosCreditAttrNotes SET LcnNotes = Notes
				OUTPUT INSERTED.*				
				FROM		#NotesTable WHERE LcnPk = CONVERT(BIGINT,ISNULL(Attr,0))
			END			

			IF @Action = 'SELECT_NOTES'
			BEGIN

				SELECT	DISTINCT LcnLnaFk 'AttrPk',LcnNotes 'Notes',LcnPk 'NotesPk'  , 
						LcnUsrFk 'UserPk',LcnCreatedBy 'UserName' ,
						CONVERT(VARCHAR,LcnCreatedDt,100) 'DTime', 
						CASE	WHEN LnaCd = 'EST_PRP'	THEN 'Property Value'
								WHEN LnaCd = 'LOAN_AMT' THEN 'Loan'
								WHEN LnaCd = 'CBL'		THEN 'CIBIL'
								ELSE LnaCd						
						END
						'AttrCode'
				FROM	LosCreditAttrNotes(NOLOCK)
				JOIN	LosCredit(NOLOCK) ON LcrLedFk =  LcnLedFk AND LcrDelId = 0		
				JOIN	LosLnAttributes (NOLOCK ) ON LnaPk =  LcnLnaFk AND LnaDelId = 0
				WHERE	LcrLedFk = @LeadPk 	 AND LcnDelId = 0
			END			

			IF @Action = 'SELECT_QUERY'
			BEGIN
				
				DECLARE @HdrRef TABLE(HdrFk BIGINT);

				INSERT INTO @HdrRef(HdrFk)
				SELECT QrdQrhFk FROM
				(
					SELECT  QroQrdFk 'QrdFk'
					FROM	QryOut
					UNION ALL 
					SELECT  QrIQrdFk 'QrdFk'
					FROM	QryIn 
				)A
				JOIN QryDtls(NOLOCK) ON QrdPk = QrdFk AND QrdDelid = 0
				GROUP BY QrdQrhFk;

				SELECT DISTINCT a.QrhPk 'hdrpk',e.QrcNm 'category',d.UsrPk usrPk,d.UsrDispNm 'userName',CONVERT(VARCHAR,a.QrhCreatedDt,103) 'date', a.QrhKeyFk 'KeyFk',
								ISNULL(QrhSoln,'000') 'solution'
				FROM QryHdr(NOLOCK) a 
				JOIN QryDtls(NOLOCK) b ON a.QrhPk=b.QrdQrhFk AND b.QrdSeqNo = 1 AND EXISTS(SELECT 'X' FROM @HdrRef WHERE HdrFk = QrdQrhFk)
				JOIN QryOut(NOLOCK) c ON b.QrdPk = c.QroQrdFk AND c.QroDelid = 0
				JOIN GenUsrMas(NOLOCK) D ON d.UsrPk=c.QrOUsrFk
				JOIN QryCategory(NOLOCK) e ON a.QrhQrcFk=e.QrcPk 				
				WHERE QrhKeyFk = @LeadPk
				ORDER BY a.QrhPk DESC; 

				SELECT h.QrhPk 'hdrpk',c.UsrPk usrPk,c.UsrDispNm 'usr',b.QrdNotes 'msg', h.QrhKeyFk 'KeyFk'    
				FROM QryIn(NOLOCK) a 
				JOIN QryDtls(NOLOCK) b ON a.QrIQrdFk=b.QrdPk AND EXISTS(SELECT 'X' FROM @HdrRef WHERE HdrFk = QrdQrhFk)
				JOIN QryOut(NOLOCK) e ON b.QrdPk = e.QroQrdFk AND a.QrIQroFk = e.QrOPk AND e.QroDelid = 0
				JOIN GenUsrMas(NOLOCK) c ON e.QrOUsrFk=c.UsrPk 
				JOIN QryHdr(NOLOCK) h ON b.QrdQrhFk=h.QrhPk                         
				WHERE QrhKeyFk = @LeadPk
				GROUP BY h.QrhPk,c.UsrPk,c.UsrDispNm,b.QrdNotes,h.QrhKeyFk,b.QrdPk 
				ORDER BY h.QrhPk,b.QrdPk;
			END
			
			IF @Action = 'INSERT_CREDIT_NEW'
			BEGIN			
			
				IF EXISTS(SELECT 'X' FROM LosCredit(NOLOCK) WHERE LcrLedFk = @LeadPk AND   LcrDocRvsn > ISNULL(@ApproverLvl,0)  AND ISNULL(@ApproverLvl,0) <> 0 )
				BEGIN 
					UPDATE	LosCredit SET LcrDelid = 1 
					WHERE	LcrLedFk = @LeadPk AND LcrDocRvsn > ISNULL(@ApproverLvl,0)  AND ISNULL(@ApproverLvl,0) <> 0 

					DELETE T FROM LosCreditAttr T  (NOLOCK)
					JOIN	LosCredit (NOLOCK) ON LcrPk = LcaLcrFk AND LcrLedFk = @LeadPk  AND 
					LcrDocRvsn > ISNULL(@ApproverLvl,0)  AND ISNULL(@ApproverLvl,0) <> 0 					

				END

				IF NOT EXISTS(SELECT 'X' FROM LosCredit(NOLOCK) WHERE LcrDocRvsn = ISNULL(@ApproverLvl,0) AND ISNULL(@ApproverLvl,0) <> 0 AND LcrLedFk = @LeadPk AND LcrDelId = 0)
				BEGIN
				
					INSERT INTO LosCredit(LcrLedFk,LcrBGeoFk,LcrPrdFk,LcrRolFk,LcrUsrFk,LcrDocNo,LcrDocRvsn,LcrDocTyp,LcrDocDt,
								LcrRowId,LcrCreatedBy,LcrCreatedDt,LcrModifiedBy,LcrModifiedDt,LcrDelFlg,LcrDelId,LcrLTV,LcrROI,LcrLoan,LcrFOIR,LcrTenur,LcrTenurTop)
								--OUTPUT INSERTED.*
					SELECT		LeadPk,BrnchFk,@PrdFk,RoleFk, @UsrPk,NULL,@ApproverLvl,NULL,NULL,@RowId,UsrNm,@CurDt,UsrNm,@CurDt,NULL,0,LTV,ROI,LOAN,FOIR,TENURE,TENUR_TOP
					FROM		#GlobalDtls,#CreditINTable
					
					SET @CreditPk = @@IDENTITY;												
				END
				ELSE
				BEGIN
					SELECT	@CreditPk  = LcrPk 
					FROM	LosCredit(NOLOCK) 
					WHERE	LcrDocRvsn = @ApproverLvl AND LcrLedFk = @LeadPk AND LcrDelId = 0
					
					UPDATE LosCredit SET LcrLTV= LTV ,LcrROI = ROI ,LcrLoan = LOAN,LcrFOIR = FOIR,LcrTenur = TENURE , LcrTenurTop = TENUR_TOP
						   --OUTPUT INSERTED.*
					FROM #CreditINTable
					WHERE LcrPk = @CreditPk AND LcrDocRvsn = @ApproverLvl AND LcrLedFk = @LeadPk AND LcrDelId = 0					
				END
				
				UPDATE LosCreditAttr SET LcaDelId = 1 WHERE LcaLcrFk =  @CreditPk				


			 	INSERT INTO LosCreditAttr(LcaLcrFk,LcaLnaFk,LcaVal,LcaRowId,LcaCreatedBy,LcaCreatedDt,LcaModifiedBy,LcaModifiedDt,LcaDelFlg,LcaDelId)
							OUTPUT INSERTED.LcaLcrFk,INSERTED.LcaLnaFk,INSERTED.LcaVal
							INTO #TempCreditAttrTable
				SELECT		@CreditPk,B.LnaPk,A.value ,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0 
				FROM		#CreditTable A
				JOIN		LosLnAttributes(NOLOCK) B ON B.LnaCd = A.Attr AND B.LnaDelId = 0			
				
				SET @Action = 'INSERT_SANCTION'		
			END

			IF @Action = 'INSERT_SANCTION'
			BEGIN					
				--IF @ApproverLvl = 2 OR 	@ApproverLvl = 4
				-- FOR ALL CREDIT LOGIN
				IF @ApproverLvl IN (1,2,3,4)
				BEGIN 					
		
					IF NOT EXISTS(SELECT 'X' FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0 AND LsnRvnNo = @LsnRvnNo)				
					BEGIN						
						IF @AppPrd IN('HLBTTopup','LAPBTTopup')
						BEGIN	
							
							INSERT INTO #SancTmpTbl(SancCode)
							EXEC @NumGenUNODB 'Sanction',@BrnCd,'ADMIN',null,null,'P' --> For Sanction

							SELECT @SanctionNo = SancCode FROM #SancTmpTbl
								
							INSERT INTO LosSanction (LsnLedFk, LsnBGeoFk, LsnPrdFk, LsnAppFk, LsnSancNo, LsnSancDt, LsnEMIDueDt, LsnEMI, 
										LsnRowId, LsnCreatedBy, LsnCreatedDt, LsnModifiedBy,LsnModifiedDt, LsnDelId ,LsnPGrpFk,LsnRvnNo,LsnStsFlg)
										OUTPUT INSERTED.LsnPk , INSERTED.LsnPrdFk,NULL INTO #SanctionPK
							SELECT		AppLedFk, AppBGeoFk, P.PrdPk, AppPk, @SanctionNo, GETDATE(), 7, EMI, 
										NEWID(), UsrDispNm, GETDATE(), UsrDispNm , GETDATE(), 0 , PrdGrpFk,@LsnRvnNo,ISNULL(@IsReject,'')
							FROM	LosApp (NOLOCK) 
							JOIN	#GlobalDtls ON LeadPk = AppLedFk 
							JOIN	GenPrdMas P (NOLOCK) ON P.PrdCd =
									CASE WHEN @AppPrd = 'HLBTTopup' THEN 'HLBT' WHEN  @AppPrd = 'LAPBTTopup' THEN 'LAPBT' END AND P.PrdDelId = 0
							WHERE	AppPk = @AppFk AND AppDelId = 0												

							DELETE FROM #SancTmpTbl

							INSERT INTO #SancTmpTbl(SancCode)
							EXEC @NumGenUNODB 'Sanction',@BrnCd,'ADMIN',null,null,'P' --> For Sanction

							SELECT @SanctionNo = SancCode FROM #SancTmpTbl

							INSERT INTO LosSanction ( LsnLedFk, LsnBGeoFk, LsnPrdFk, LsnAppFk, LsnSancNo, LsnSancDt, LsnEMIDueDt, LsnEMI, 
										LsnRowId, LsnCreatedBy, LsnCreatedDt, LsnModifiedBy,LsnModifiedDt, LsnDelId,LsnPGrpFk ,LsnRvnNo,LsnStsFlg)
										OUTPUT INSERTED.LsnPk , INSERTED.LsnPrdFk,NULL INTO #SanctionPK
							SELECT		AppLedFk, AppBGeoFk, P.PrdPk, AppPk, @SanctionNo, GETDATE(), 7, TOP_EMI, 
										NEWID(), UsrDispNm, GETDATE(), UsrDispNm , GETDATE(), 0 ,PrdGrpFk,@LsnRvnNo,ISNULL(@IsReject,'')
							FROM	LosApp (NOLOCK) 
							JOIN	#GlobalDtls ON LeadPk = AppLedFk 
							JOIN	GenPrdMas P (NOLOCK) ON P.PrdCd =
									CASE WHEN @AppPrd = 'HLBTTopup' THEN 'HLTopup' WHEN  @AppPrd = 'LAPBTTopup' THEN 'LAPTopup' END AND P.PrdDelId = 0
							WHERE	AppPk = @AppFk AND AppDelId = 0	
																
						END
						ELSE 
						BEGIN
							INSERT INTO #SancTmpTbl(SancCode)
							EXEC @NumGenUNODB 'Sanction',@BrnCd,'ADMIN',null,null,'P' --> For Sanction

							SELECT @SanctionNo = SancCode FROM #SancTmpTbl

							INSERT INTO LosSanction ( LsnLedFk, LsnBGeoFk, LsnPrdFk, LsnAppFk, LsnSancNo, LsnSancDt, LsnEMIDueDt, LsnEMI, 
											LsnRowId, LsnCreatedBy, LsnCreatedDt, LsnModifiedBy,LsnModifiedDt, LsnDelId,LsnPGrpFk,LsnRvnNo,LsnStsFlg)
											OUTPUT INSERTED.LsnPk , INSERTED.LsnPrdFk,NULL INTO #SanctionPK
							SELECT		AppLedFk, AppBGeoFk, P.PrdPk, AppPk, @SanctionNo, GETDATE(), 7, EMI, 
										NEWID(), UsrDispNm, GETDATE(), UsrDispNm , GETDATE(), 0 , PrdGrpFk,@LsnRvnNo,ISNULL(@IsReject,'')
							FROM	LosApp (NOLOCK) 
							JOIN	#GlobalDtls ON LeadPk = AppLedFk 
							JOIN	GenPrdMas P (NOLOCK) ON P.PrdPk = AppPrdFk AND P.PrdDelId = 0
							WHERE	AppPk = @AppFk AND AppDelId = 0																	

							--UPDATE	GenDocCtrlConfig SET DfgLstNo = @LastSancNo 
							--WHERE	DfgDocTypFk = 4 AND DfgBGeoFk = @GeoFk									
						END																																		
					END
					ELSE
					BEGIN
						INSERT INTO #SanctionPK
						SELECT LsnPk,LsnPrdFk,NULL FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0 AND LsnRvnNo = @LsnRvnNo

						IF @AppPrd IN('HLBTTopup','LAPBTTopup')
						BEGIN	

							UPDATE	LosSanction SET LsnEmi = EMI , LsnModifiedDt = GETDATE() , LsnModifiedBy = @UsrDispNm,
									LsnStsFlg = CASE	WHEN @CurApprover = @MaxApprover AND @CurApprover <> 0 THEN ISNULL(NULLIF(@IsReject,''),'A')
														ELSE ISNULL(@IsReject,'')
												END
							FROM	LosApp (NOLOCK) 
							JOIN	#GlobalDtls ON LeadPk = AppLedFk 
							JOIN	GenPrdMas P (NOLOCK) ON P.PrdCd =
									CASE WHEN @AppPrd = 'HLBTTopup' THEN 'HLBT' WHEN  @AppPrd = 'LAPBTTopup' THEN 'LAPBT' END AND P.PrdDelId = 0
							JOIN	#SanctionPK ON ProdFk = P.PrdPk
							WHERE AppPk = @AppFk AND AppDelId = 0 AND LsnPk = SanctionPk  AND LsnPrdFk = ProdFk AND LsnRvnNo = @LsnRvnNo


							UPDATE	LosSanction SET LsnEmi = TOP_EMI , LsnModifiedDt = GETDATE() , LsnModifiedBy = @UsrDispNm,
									LsnStsFlg = CASE	WHEN @CurApprover = @MaxApprover AND @CurApprover <> 0 THEN ISNULL(NULLIF(@IsReject,''),'A')
														ELSE ISNULL(@IsReject,'')
												END
							FROM	LosApp (NOLOCK) 
							JOIN	#GlobalDtls ON LeadPk = AppLedFk 
							JOIN	GenPrdMas P (NOLOCK) ON P.PrdCd =
									CASE WHEN @AppPrd = 'HLBTTopup' THEN 'HLTopup' WHEN  @AppPrd = 'LAPBTTopup' THEN 'LAPTopup' END AND P.PrdDelId = 0
							JOIN	#SanctionPK ON ProdFk = P.PrdPk
							WHERE AppPk = @AppFk AND AppDelId = 0 AND LsnPk = SanctionPk  AND LsnPrdFk = ProdFk AND LsnRvnNo = @LsnRvnNo

						END

						ELSE 
						BEGIN
							UPDATE	LosSanction SET LsnEmi = EMI , LsnModifiedDt = GETDATE() , LsnModifiedBy = @UsrDispNm,
									LsnStsFlg = CASE	WHEN @CurApprover = @MaxApprover AND @CurApprover <> 0 THEN ISNULL(NULLIF(@IsReject,''),'A')
														ELSE ISNULL(@IsReject,'')
												END
							FROM	LosApp (NOLOCK) 
							JOIN	#GlobalDtls ON LeadPk = AppLedFk 
							JOIN	GenPrdMas P (NOLOCK) ON P.PrdCd = @AppPrd
							JOIN	#SanctionPK ON ProdFk = PrdFk
							WHERE	AppPk = @AppFk AND AppDelId = 0 AND LsnPk = SanctionPk  AND 
									LsnPrdFk = ProdFk AND LsnRvnNo = @LsnRvnNo							
						END												
					END										
				
					UPDATE #SanctionPK SET creditPk = @CreditPk

					DELETE T
					FROM  LosSanctionAttr (NOLOCK) T 
					JOIN #SanctionPK ON T.LsaLsnFk = SanctionPk
								
					INSERT INTO LosSanctionAttr(LsaLsnFk,LsaLnaFk,LsaVal,LsaRowId,LsaCreatedBy,LsaCreatedDt,LsaModifiedBy,LsaModifiedDt,LsaDelFlg,LsaDelId)				
					SELECT SanctionPk,LoanAttrFk,val,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
					FROM #TempCreditAttrTable,#SanctionPK
										
					DELETE T
					FROM  LosSubjCondtion T 
					JOIN #SanctionPK ON T.LscLsnFk = SanctionPk AND T.LscDelId = 0

					--LosSubjCondtion
					INSERT INTO LosSubjCondtion(LscLsnFk,LscNote,LscRowId,LscCreatedBy,LscCreatedDt,LscModifiedBy,LscModifiedDt,LscDelFlg,LscDelId,LscPreDef)
					SELECT		SanctionPk,PscDesc,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,1
					FROM		LosPreSubjCondition(NOLOCK),#SanctionPK where PscPrdFk=ProdFk AND PscStatFlg = 'L'
					
					
					
					-- Insert All the Subjective conditions 
					INSERT INTO LosSubjCondtion(LscLsnFk,LscNote,LscRowId,LscCreatedBy,LscCreatedDt,LscModifiedBy,LscModifiedDt,LscDelFlg,LscDelId,LscPreDef)
					SELECT		SanctionPk,note,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,0
					FROM		#SubjectiveNotes,#SanctionPK
				
					EXEC PrcShflRiskCalc @LeadPk , @UsrDispNm

					-- 1 . SELECT All SanctionPk					
					SELECT ISNULL(
					STUFF(					
						(SELECT '~' + CONVERT(VARCHAR(20),SanctionPk) FROM #SanctionPK
						 FOR XML PATH (''))
						 , 1, 1, ''),'') AS 'SanctionPk' 										


					--2  Max Approver level
					SELECT	ISNULL(MAX(LdvAppBy),0) 'ApproverLevel'
					FROM	LosDeviation (NOLOCK)
					WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 
				END								

				IF LOWER(ISNULL(@isMoveNxt,'')) = 'true' AND @ApproverLvl = 1 OR @ApproverLvl = 3
					EXEC PrcShflDeviations @LeadPk,@RowId,@UsrPk,@UsrDispNm,@ApproverLvl
					
				
				IF ISNULL(@waiverROI,0) <> 0 
				BEGIN					

					DELETE T 
					FROM	LosDeviation T (NOLOCK)
					JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
					WHERE	LdvStage = 'C' AND LdvLedFk = @LeadPk  AND LnaCd IN ('ROI','BT_ROI','TOPUP_ROI')

					INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
						LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal)						
					SELECT  @LeadPk,@AppFk, @UsrPk, 'C' , LnaPk , NULL , val , @waiverROI, '',  CASE WHEN @waiverROI <= 0 THEN 'D' ELSE 'N' END , CASE WHEN @waiverROI <= 0 THEN 4 ELSE 1 END  , 'ROI change',
								@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0 , (val - ISNULL(@waiverROI,0))
					FROM	LosLnAttributes(NOLOCK) 
					JOIN	#TempCreditAttrTable ON LoanAttrFk = LnaPk
					WHERE LnaCd IN ('ROI','BT_ROI')

				END

				IF EXISTS( SELECT 'X' FROM #ManualDev)
				BEGIN

					DELETE T 
					FROM	LosDeviation T (NOLOCK)
					JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0 
					WHERE	LdvStage = 'C' AND LdvLedFk = @LeadPk  AND LnaCd = 'MANUALDEV'
					
					INSERT INTO LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
						LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId)						
					SELECT  @LeadPk,@AppFk, @UsrPk, 'C' , LnaPk , NULL , NULL, NULL , '',  'D', levels , Rmks,
								@RowID , @UsrDispNm, GETDATE() , @UsrDispNm, GETDATE() , NULL, 0
					FROM	#ManualDev 
					JOIN	LosLnAttributes(NOLOCK) ON LnaCd = 'MANUALDEV'				
				END
				
				--PF Details Insert					
				IF(@CurApprover = @MaxApprover AND @CurApprover <> 0 AND ISNULL(NULLIF(@IsReject,''),'') <> 'R')
				BEGIN
					EXEC PrcShflLoanDetail @LeadPk, 'SancAdj' --Lead Amount adjustment against Sanction 		
				END		
				ELSE
				BEGIN
					EXEC PrcShflLoanDetail @LeadPk, 'Credit' --Payable entry
				END											

				

			END

			IF @Action = 'CHECK_SANCTION'
			BEGIN						
				-- 1 SANCTION CHECK
				SELECT	LsnSancNo 'sancNo',LsnStsFlg 'flg'
				FROM	LosSanction(NOLOCK) 
				WHERE	LsnLedFk = @LeadPk AND LsnDelId = 0 AND LsnRvnNo = 
						CASE	WHEN ISNULL(@LsnRvnNo,0) <> 0 THEN @LsnRvnNo
								ELSE (SELECT MAX(A.LsnRvnNo) FROM LosSanction (NOLOCK) A WHERE A.LsnLedFk = @LeadPk AND A.LsnDelId = 0 )
						END		
				-- 2 CAM CHECK
				SELECT 'X' FROM LosCredit (NOLOCK) WHERE LcrLedFk = @LeadPk AND LcrDocRvsn <> 0 AND LcrDelId = 0								 
				
				-- 3 RISK CHECK
				SELECT 'X' FROM LosRiskCalc (NOLOCK) WHERE LrcLedFk = @LeadPk AND LrcDelId = 0 						 

			END

			IF @Action = 'GET_APPROVER_LVL'
			BEGIN				
				SELECT	ISNULL(MAX(LdvAppBy),0) 'ApproverLevel'
				FROM	LosDeviation (NOLOCK)
				WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 
			END

			IF @Action = 'DEVIATION_LIST'
			BEGIN				
				
				SELECT	LnaCd 'AttrCode',
						CASE	WHEN LnaCd = 'MANUALDEV' THEN 'Manual'
								WHEN LnaCd = 'NET_INC' THEN 'Income'
								ELSE ISNULL(LnaCd,'')
						END 'AttrDesc',						
						LdvDevSts 'status', LdvAppBy 'approvedBy',
						ISNULL(RTRIM(CONVERT(NUMERIC(27,2),LdvArrVal)),'-') 'Arrived' , 
						CASE  WHEN ISNULL(LdvDevVal,0) <> 0 THEN RTRIM(LdvDevVal)
								ELSE 'NA' END
						'Deviated' , ISNULL(LdvRmks,'') 'remarks' , 
						CASE	WHEN LapActor = 0 THEN 'Applicant' 
								WHEN LapActor = 1 THEN 'CoApplicant' 
								WHEN LapActor = 2 THEN 'Guarantor' 
								ELSE 'General'
						END	'ApplicableTo',
						CASE	WHEN LdvStage = 'C' THEN 'Credit'
								WHEN LdvStage = 'T' THEN 'Technical'
								WHEN LdvStage = 'L' THEN 'Legal'
								WHEN LdvStage = 'D' THEN 'Disbursement'
						END 'stage', 
						CASE  WHEN ISNULL(LdvMarginVal,0) <> 0 THEN RTRIM(LdvMarginVal)
						ELSE 'NA' END 'baseval'
				FROM	LosDeviation (NOLOCK) A
				JOIN	LosLnAttributes (NOLOCK) B ON  B.LnaPk = A.LdvLnaFk AND B.LnaDelId = 0 
				LEFT OUTER JOIN	LosAppProfile C (NOLOCK) ON C.LapPk = A.LdvLapFk AND A.LdvDelid = 0
				WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 

				SELECT	ISNULL(MAX(LdvAppBy),1) 'MaxApproverLevel'
				FROM	LosDeviation (NOLOCK)
				WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 


				SELECT	DISTINCT LcnLnaFk 'AttrPk',LcnNotes 'Notes',LcnPk 'NotesPk'  , 
						LcnUsrFk 'UserPk',LcnCreatedBy 'UserName' ,
						CONVERT(VARCHAR,LcnCreatedDt,100) 'DTime', LnaCd 'AttrCode'
				FROM	LosCreditAttrNotes(NOLOCK)
				JOIN	LosCredit(NOLOCK) ON LcrLedFk =  LcnLedFk AND LcrDelId = 0		
				JOIN	LosLnAttributes (NOLOCK ) ON LnaPk =  LcnLnaFk AND LnaDelId = 0
				WHERE	LcrLedFk = @LeadPk 	 AND LcnDelId = 0
				
			END

			IF @Action = 'UPDATE_PRD_PNI'
			BEGIN
				IF (CONVERT(BIGINT,@ChangePrdFk) > 0)
				BEGIN
					UPDATE LosApp SET AppPrdFk = CONVERT(BIGINT,@ChangePrdFk)		
						OUTPUT INSERTED.*
					WHERE AppLedFk = @LeadPk AND AppDelId = 0 				
				END
			END

			IF @Action = 'APPROVE_DEVIATION'
			BEGIN 
				UPDATE LosDeviation SET LdvIsApp = 'Y' WHERE LdvLedFk = @LeadPk AND LdvDelId = 0
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



