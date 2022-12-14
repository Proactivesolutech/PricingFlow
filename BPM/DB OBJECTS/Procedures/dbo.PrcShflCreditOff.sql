USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflCreditOff]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShflCreditOff]
(
	@Action			VARCHAR(100) ,
	@GlobalJson		VARCHAR(MAX) = NULL,
	@DetailJson		VARCHAR(MAX) = NULL
)
AS
BEGIN
--RETURN
	SET NOCOUNT ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT

	DECLARE @DBNAME VARCHAR(20) = db_name() 

	DECLARE	 @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,
		@AppFk BIGINT,@LapFk BIGINT, @CreditPk BIGINT,@RowId VARCHAR(MAX) , @RoleFk BIGINT , @SanctionNo VARCHAR(50) , @SanctionPk BIGINT,
		@MaxSanNo BIGINT , @AgtFk BIGINT , @PfPk BIGINT , @ApproverLvl TINYINT , @LoanNo VARCHAR(50) , @MaxLoanNo BIGINT;

	CREATE TABLE #GlobalDtls(xx_id BIGINT,LeadPk BIGINT,  UsrPk BIGINT, UsrDispNm VARCHAR(100),UsrNm VARCHAR(100), PrdCd VARCHAR(100),
				RoleFk BIGINT, BrnchFk BIGINT, PrdNm VARCHAR(20), LeadNm VARCHAR(100), LeadID VARCHAR(100), PrdFk BIGINT, AgtNm VARCHAR(100), 
				AgtFk BIGINT, Branch VARCHAR(100), CreditPk BIGINT,EMI NUMERIC(27,7),ApproverLvl TINYINT)

	CREATE TABLE #DetailsTbl (xx_id BIGINT, NotesJson VARCHAR(MAX),CreditJson VARCHAR(MAX),SubjectiveJSON VARCHAR(MAX) , PFJson VARCHAR(MAX))

	DECLARE @NotesJson VARCHAR(MAX),@SubjectiveJSON VARCHAR(MAX), @CreditJson VARCHAR(MAX) , @PfJson VARCHAR(MAX)

	CREATE TABLE #SalarySUmmary (LeadPk BIGINT, LapFk BIGINT , Salary NUMERIC(27,7) , Percentage FLOAT , addless TINYINT )

	CREATE TABLE #ObligationSummary (LeadPk BIGINT , LapFk BIGINT , Obligation NUMERIC(27,7))

	CREATE TABLE #INCOMEOBL(LeadPk BIGINT ,LapFk BIGINT , Income NUMERIC(27,7), Obligation NUMERIC(27,7))

	CREATE TABLE #NotesTable(xx_id BIGINT ,Attr VARCHAR(10), LnaFk  BIGINT ,Notes VARCHAR(MAX));
	
	CREATE TABLE #SubjectiveNotes(xx_id BIGINT ,dt VARCHAR(100), note VARCHAR(MAX));

	CREATE TABLE #CreditTable(xx_id BIGINT ,Attr VARCHAR(10) ,  value NUMERIC(27,7));

	CREATE TABLE #PFtable(xx_id BIGINT ,Attr VARCHAR(10) ,  value NUMERIC(27,7) , perc NUMERIC(27,7), waiver NUMERIC(27,7))

	CREATE TABLE #TempCrediTable(CreditPk BIGINT, LnAttrPk BIGINT , AttrCode VARCHAR(10) , Value NUMERIC(27,7) , AttrPK BIGINT)

	SELECT @CurDt = GETDATE(), @RowId = NEWID()	

	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN					

		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'FwdDataPk,UsrPk,UsrNm,UsrCd,PrdCd,Role,BrnchFk,PrdNm,LeadNm,LeadID,PrdFk,AgtNm,AgtFk,Branch,CreditPk,EMI,ApproverLvl'
		
		IF @DBNAME = 'SHFL_LOS'
		BEGIN
			SELECT	@LeadPk = LeadPk, 
					@AppFk = AppPk, 
					@UsrDispNm = UsrDispNm, @UsrNm = UsrNm , @CreditPk = CreditPk,@UsrPk = UsrPk , 
					@RoleFk = RoleFk,@GeoFk = BrnchFk,@AgtFk = AgtFk,@PrdFk = PrdFk,@ApproverLvl = ApproverLvl
			FROM	#GlobalDtls 
			JOIN	LosApp (NOLOCK) ON AppLedFk = LeadPk AND AppDelId = 0
			JOIN    LosAppProfile (NOLOCK) ON LapLedFk = AppLedFk AND LapDelId = 0	
		END
		ELSE
		BEGIN
			SELECT	@LeadPk = LeadPk, 
					@UsrDispNm = UsrDispNm, @UsrNm = UsrNm , @CreditPk = CreditPk,@UsrPk = UsrPk
			FROM	#GlobalDtls 
		END
	END

	IF @DetailJson != '[]' AND @DetailJson != ''
	BEGIN	
			
		INSERT INTO #DetailsTbl
		EXEC PrcParseJSON @DetailJSON,'NotesJson,CreditJson,SubjectiveJSON,PFJson'
		

		SELECT	@NotesJson = NotesJson , @CreditJson = CreditJson , @SubjectiveJSON = SubjectiveJSON, @PFJson = PFJson 
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

	END

	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN
			
			IF @Action = 'SELECT_SUMMARY'
			BEGIN
				-- calculation of income and obligations
				
				INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage , addless)
				SELECT		LbiLedFk,LbiLapFk,
							CASE WHEN LbiAddLess = 2 THEN -LbiVal ELSE LbiVal END ,LbiPerc	,LbiAddLess
				FROM		LosAppBusiInc (NOLOCK)
				WHERE		LbiLedFk = @LeadPk AND LbiDelId = 0 AND LbiAddLess = 3 AND LbiYr = -1
			
				INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage, addless)
				SELECT		LsiLedFk,LsiLapFk,
							CASE WHEN LsiAddLess = 2 THEN -LsiVal ELSE LsiVal END ,LsiPerc	, LsiAddLess
				FROM		LosAppSalInc (NOLOCK)
				WHERE		LsiLedFk = @LeadPk AND LsiDelId = 0 AND LsiAddLess = 3 AND LsiMon = -1
			
				INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage,addless)
				SELECT		LciLedFk,LciLapFk,
							CASE WHEN LciAddLess = 2 THEN -LciVal ELSE LciVal END,LciPerc	, LciAddLess
				FROM		LosAppCshInc (NOLOCK)
				WHERE		LciLedFk = @LeadPk AND LciDelId = 0 AND LciAddLess = 3 AND LciYr = -1
			

				INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage,addless)
				SELECT		ISNULL(LoiLedFk,0),ISNULL(LoiLapFk,0), 
							CASE WHEN LoiPeriod = 0 THEN  ISNULL(LoiAmt,0) / 12 ELSE ISNULL(LoiAmt,0) END , ISNULL(LoiPerc	,100),1
				FROM		LosAppOthInc (NOLOCK)
				WHERE		LoiLedFk = @LeadPk AND LoiDelId = 0 
			
				INSERT INTO	#SalarySUmmary(LeadPk, LapFk, Salary , Percentage,addless)
				SELECT		LbbLedFk,LbbLapFk,ISNULL(LbbVal,0),ISNULL(LbbPerc	,100), 1
				FROM		LosAppBnkBal (NOLOCK)
				WHERE		LbbLedFk = @LeadPk AND LbbDelId = 0  	

				INSERT INTO #INCOMEOBL(LeadPk ,LapFk , Income)
				SELECT		LeadPk ,LapFk ,  SUM(Salary) sal 
				FROM		#SalarySUmmary GROUP BY LapFk,LeadPk				

				INSERT INTO #ObligationSummary (LeadPk,LapFk,Obligation)
				SELECT LaoLedFk,LaoLapFk,SUM(LaoEMI) FROM LosAppObl (NOLOCK) A 
				WHERE	LaoLedFk = @LeadPk AND LaoDelId = 0 
				GROUP BY LaoLedFk,LaoLapFk
						
						
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
				
				
				-- 1 SUmmary details 
				SELECT	ISNULL(LapFstNm+' '+LapMdNm+' '+LapLstNm,'') 'ApplicantName', LapActor 'Actor',
						CONVERT(numeric(27,2),ISNULL(Income,0)) 'income' ,
						CONVERT(numeric(27,2),ISNULL(Obligation,0)) 'Obligation' ,
						ISNULL(LapCibil,'') 'CIBILscore',						
						ISNULL(LapEmpTyp,'') 'customerClass',
						CONVERT(VARCHAR,LedIncPrf) 'incomeClass' ,	
						CASE WHEN dateadd(year, datediff (year, LapDOB, getdate()), LapDOB) > getdate()
						THEN datediff(year, LapDOB, getdate()) - 1
						ELSE datediff(year, LapDOB, getdate()) END as 'Age',
						CASE WHEN LapActor = 0  THEN 'Applicant' WHEN LapActor = 1 THEN 'Co Applicant'  WHEN LapActor = 2 THEN 'Guarantor'  END 'ApplicantType', LapPk 'AppFk'
				FROM	LosLead(NOLOCK) 
				JOIN	LosAppProfile(NOLOCK)  ON LapLedFk = LedPk AND LedDelId = 0
				JOIN	LosApp(NOLOCK) ON AppLedFk = LedPk AND LapAppFk = AppPk AND AppDelId=0
				LEFT OUTER JOIN	#INCOMEOBL ON LapFk = LapPk AND LeadPk = LapLedFk
				WHERE	LedPk = @LeadPk AND LapDelId = 0


				
				-- Inserted Credit details - based on Approver level 
				INSERT INTO #TempCrediTable
				SELECT	LcaLcrFk ,LcaLnaFk ,LnaCd ,LcaVal ,LcaPk
				FROM	LosCreditAttr (NOLOCK) A
				JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
				JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
				WHERE	B.LcrLedFk = @LeadPk AND LcrRolFk = @RoleFk AND A.LcaDelId = 0  AND LcrDocRvsn = @ApproverLvl										

				IF @@ROWCOUNT > 0
				BEGIN 
					--2 SELECT the credit details if the same approver level data exists
					SELECT * FROM #TempCrediTable
				END

				ELSE
				BEGIN
					--2 SELECT the credit details of pervios approver level data if exists, else empty
					SELECT	LcaLcrFk 'CreditPk',LcaLnaFk 'LnAttrPk',LnaCd 'AttrCode',LcaVal 'Value',LcaPk 'AttrPK'
					FROM	LosCreditAttr (NOLOCK) A
					JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
					JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
					WHERE	B.LcrLedFk = @LeadPk AND LcrRolFk = @RoleFk AND A.LcaDelId = 0  AND LcrDocRvsn = @ApproverLvl - 1
				END


				--3 Expected Loan parameters -- From lead
				SELECT	LedLnAmt 'ExpLOAN',LedTenure 'ExpTENURE',LedROI 'ExpROI',LedEMI 'ExpEMI'
				FROM	LosLead WHERE LedPk = @LeadPk  and LedDelId = 0

				--4 Loan Calculations
				SELECT * FROM dbo.fnCalculateLoan(@LeadPk)

				-- 5 Total paid PF amount
				SELECT SUM(LpcInstrAmt) 'PfAmount' FROM LosProcChrg (NOLOCK) 
				WHERE LpcLedFk = @LeadPk AND LpcDelId = 0 AND LpcDocTyp IS NULL

				-- 6 Agents Verfication Status 
				SELECT	LfjJobSts 'status',LfjJobNo 'JobNo',LfjPk 'JobPk',
						CASE WHEN LfjSrvTyp = 0  THEN 'FIR' WHEN LfjSrvTyp = 1 THEN 'FIO' WHEN LfjSrvTyp = 2 THEN 'DV'
						WHEN LfjSrvTyp = 3 THEN 'CF' WHEN LfjSrvTyp = 4 THEN 'LV'
						WHEN LfjSrvTyp = 5 THEN 'TV' ELSE 'AA'  END AS 'ServiceType'
				FROM	LosAgentFBJob(NOLOCK) 
				JOIN	LosAgentJob(NOLOCK) ON LajPk = LfjLajFk AND LajDelId = 0
				WHERE	LajLedFk = @LeadPk AND LfjDelId = 0

				-- 7 PF and wiaver amoount
				SELECT	ISNULL(LpcChrg,0) 'PfAmount',ISNULL(LpcWavier,0) 'waiveramt' ,LpcDis 'perc'
				FROM	LosProcChrg (NOLOCK) 
				WHERE	LpcLedFk = @LeadPk AND LpcDelId = 0 AND LpcDocTyp = 1								
				
				-- 8 NExt Sanction Number to show in page
				IF NOT EXISTS(SELECT 'X' FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0)
				BEGIN 
					SELECT @MaxSanNo = (CONVERT(BIGINT,RIGHT(MAX(LsnSancNo),5)) + 1) FROM LosSanction(NOLOCK)
					IF ISNULL(@MaxSanNo,0) = 0 SET @MaxSanNo =  1;
					SELECT @SanctionNo = 'SHFHO' + dbo.gefgGetPadZero(5,(ISNULL(@MaxSanNo,0)))
					SELECT @SanctionNo 'SancNo', 0 'PK'
				END
				ELSE
				BEGIN
					SELECT @SanctionNo = LsnSancNo FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0
					SELECT LsnSancNo 'SancNo', LsnPk 'PK' FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0
				END									

				-- 9 To get the recommended values
				SELECT	LnaCd 'code',LcaVal 'value'
				FROM	LosCreditAttr (NOLOCK) A
				JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
				JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrDelId = 0
				WHERE	B.LcrLedFk = @LeadPk AND LcrRolFk = @RoleFk AND A.LcaDelId = 0  AND 
						LcrDocRvsn = @ApproverLvl - 1 AND LnaCd IN('LOAN_AMT','ROI','EMI')

				-- 10 To get the sancion-subjective conditions
				SELECT	LscNote 'Snote', LscPk 'Spk',LsnPk 'SancPk'
				FROM	LosSubjCondtion(NOLOCK) 
				JOIN	LosSanction(NOLOCK) ON LsnPk = LscLsnFk AND LsnDelId = 0
				WHERE	LsnLedFk = @LeadPk AND LscDelId = 0
				
				-- 11 SELECT Product and Income type
				SELECT	AppSalTyp 'saltype',CASE WHEN AppSalPrf = 0 THEN '0' ELSE '1' END 'IsProof' , AppPrdFk 'Product'
				FROM	LosApp (NOLOCK)
				WHERE	AppPk =  @AppFk AND AppLedFk = @LeadPk AND  AppDelId = 0 

			END			

			IF @Action = 'LOAN_PARTICULARS'
			BEGIN
				SELECT * FROM dbo.fnCalculateLoan(@LeadPk)
			END
			
			IF @Action = 'ADD_NOTES'
			BEGIN						
			
				INSERT INTO	LosCreditAttrNotes(LcnLedFk,LcnLnaFk,LcnUsrFk,LcnRoleFk,LcnNotes,LcnRowId,LcnCreatedBy,LcnCreatedDt,LcnModifiedBy,LcnModifiedDt,LcnDelFlg,LcnDelId)
				OUTPUT INSERTED.*
				SELECT		@LeadPk,LnaPk,@UsrPk,@RoleFk,Notes,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0 
				FROM		#NotesTable
				JOIN		LosLnAttributes (NOLOCK) ON LnaCd = Attr AND LnaDelId = 0
			END

			IF @Action = 'SELECT_NOTES'
			BEGIN

				SELECT	LcnLnaFk 'AttrPk',LcnNotes 'Notes',LcnPk 'NotesPk'  , UsrPk 'UserPk',UsrDispNm 'UserName' ,
						CONVERT(VARCHAR,UsrCreatedDt,100) 'DTime', LnaCd 'AttrCode'
				FROM	LosCreditAttrNotes(NOLOCK)
				JOIN	LosCredit(NOLOCK) ON LcrLedFk =  LcnLedFk AND LcrDelId = 0		
				JOIN	LosLnAttributes (NOLOCK ) ON LnaPk =  LcnLnaFk AND LnaDelId = 0
				JOIN	GenUsrMas (NOLOCK) ON  UsrPk = LcnUsrFk AND UsrDelId = 0
				WHERE	LcrLedFk = @LeadPk 	 AND LcnDelId = 0
			END			

			IF @Action = 'SELECT_QUERY'
			BEGIN
				SELECT DISTINCT c.QrhPk 'hdrpk',e.QrcNm 'category',d.UsrDispNm 'userName',CONVERT(VARCHAR,c.QrhCreatedDt,103) 'date', c.QrhKeyFk 'KeyFk', ISNULL(QrhSoln,'000') 'solution'
                FROM QryOut(NOLOCK) a 
                JOIN QryDtls(NOLOCK) b ON a.QrOQrdFk=b.QrdPk
                JOIN QryHdr(NOLOCK) c ON b.QrdQrhFk=c.QrhPk 
                JOIN GenUsrMas(NOLOCK) D ON d.UsrPk=a.QrOUsrFk
                JOIN QryCategory(NOLOCK) e ON c.QrhQrcFk=e.QrcPk  
				WHERE QrhKeyFk = @LeadPk
                ORDER BY c.QrhPk ;

				SELECT h.QrhPk 'hdrpk',c.UsrDispNm 'usr',b.QrdNotes 'msg', h.QrhKeyFk 'KeyFk'  
				FROM QryIn(NOLOCK) a 
				JOIN QryDtls(NOLOCK) b ON a.QrIQrdFk=b.QrdPk   
                JOIN GenUsrMas(NOLOCK) c ON a.QrIUsrFk=c.UsrPk 
                JOIN QryHdr(NOLOCK) h ON b.QrdQrhFk=h.QrhPk 
				WHERE QrhKeyFk = @LeadPk
                ORDER BY h.QrhPk;
			END
			IF @Action = 'INSERT_CREDIT'
			BEGIN											
--RETURN				
				IF NOT EXISTS(SELECT 'X' FROM LosCredit(NOLOCK) WHERE LcrDocRvsn = @ApproverLvl AND LcrLedFk = @LeadPk AND LcrDelId = 0)
				BEGIN
					INSERT INTO LosCredit(LcrLedFk,LcrBGeoFk,LcrPrdFk,LcrRolFk,LcrUsrFk,LcrDocNo,LcrDocRvsn,LcrDocTyp,LcrDocDt,
								LcrRowId,LcrCreatedBy,LcrCreatedDt,LcrModifiedBy,LcrModifiedDt,LcrDelFlg,LcrDelId)
					SELECT		LeadPk,BrnchFk,PrdFk,RoleFk, UsrPk,NULL,@ApproverLvl,NULL,NULL,@RowId,UsrNm,@CurDt,UsrNm,@CurDt,NULL,0 
					FROM		#GlobalDtls	
					SET @CreditPk = @@IDENTITY;												
				END
				ELSE
				BEGIN
					SELECT	@CreditPk  = LcrPk 
					FROM	LosCredit(NOLOCK) 
					WHERE	LcrDocRvsn = 1 AND LcrLedFk = @LeadPk AND LcrDelId = 0
				END
				
				UPDATE LosCreditAttr SET LcaDelId = 1 WHERE LcaLcrFk =  @CreditPk

				INSERT INTO LosCreditAttr(LcaLcrFk,LcaLnaFk,LcaVal,LcaRowId,LcaCreatedBy,LcaCreatedDt,LcaModifiedBy,LcaModifiedDt,LcaDelFlg,LcaDelId)
							OUTPUT INSERTED.*
				SELECT		@CreditPk,B.LnaPk,A.value ,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0 
				FROM		#CreditTable A
				JOIN		LosLnAttributes(NOLOCK) B ON B.LnaCd = A.Attr AND B.LnaDelId = 0			


				IF NOT EXISTS(SELECT 'X' FROM LosProcChrg(NOLOCK) WHERE LpcLedFk = @LeadPk AND LpcDocTyp = @ApproverLvl AND LpcDelId = 0)
				BEGIN
					INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
								LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp)
								OUTPUT INSERTED.*
					SELECT		@LeadPk,@AgtFk ,@GeoFk,@PrdFk,value,0,NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,perc,waiver,@ApproverLvl 
					FROM		#PFtable WHERE Attr = 'PF'
				END
				ELSE 
				BEGIN					
					SELECT @PfPk = LpcPk  FROM LosProcChrg(NOLOCK) WHERE LpcLedFk = @LeadPk AND LpcDocTyp = 1 AND LpcDelId = 0

					UPDATE	LosProcChrg SET LpcLedFk = @LeadPk , LpcAgtFk = @AgtFk  ,LpcBGeoFk = @GeoFk,LpcPrdFk = @PrdFk,LpcChrg = value,LpcInstrAmt = 0 ,
							LpcPayTyp = NULL,LpcInstrNo = NULL,LpcModifiedBy = @UsrNm,LpcModifiedDt = @CurDt,LpcDis = perc ,LpcWavier = waiver 
							OUTPUT INSERTED.*					
					FROM	#PFtable 
					WHERE Attr = 'PF'	AND LpcLedFk = @LeadPk AND LpcDelId = 0
									
				END

				IF @ApproverLvl = 2
				BEGIN 
					SELECT @MaxSanNo = (CONVERT(BIGINT,RIGHT(MAX(LsnSancNo),5)) + 1) FROM LosSanction(NOLOCK)
					IF ISNULL(@MaxSanNo,0) = 0 SET @MaxSanNo =  1;
					SELECT @SanctionNo = 'SHFHO' + dbo.gefgGetPadZero(5,(ISNULL(@MaxSanNo,0)))
					
					

					IF NOT EXISTS(SELECT 'X' FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0)				
					BEGIN
						INSERT INTO LosSanction ( LsnLedFk, LsnBGeoFk, LsnPrdFk, LsnAppFk, LsnSancNo, LsnSancDt, LsnEMIDueDt, LsnEMI, 
									LsnRowId, LsnCreatedBy, LsnCreatedDt, LsnModifiedBy,LsnModifiedDt, LsnDelId )
						SELECT		AppLedFk, AppBGeoFk, AppPrdFk, AppPk, @SanctionNo, GETDATE(), 7, EMI, 
									NEWID(), UsrDispNm, GETDATE(), UsrDispNm , GETDATE(), 0 
						FROM LosApp (NOLOCK) 
						JOIN #GlobalDtls ON LeadPk = AppLedFk 
						WHERE AppPk = @AppFk AND AppDelId = 0
												
						SELECT @SanctionPk = @@IDENTITY
					END
					ELSE
						SELECT @SanctionPk = LsnPk FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0
					
					UPDATE LosSubjCondtion SET LscDelId = 1 WHERE LscLsnFk = @SanctionPk AND LscDelId = 0

					INSERT INTO LosSubjCondtion(LscLsnFk,LscNote,LscRowId,LscCreatedBy,LscCreatedDt,LscModifiedBy,LscModifiedDt,LscDelFlg,LscDelId)
					SELECT		@SanctionPk,note,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0 FROM	#SubjectiveNotes
				END
					
				IF @ApproverLvl = 4
				BEGIN 
					--LosLoan
					SELECT @MaxLoanNo = (CONVERT(BIGINT,RIGHT(MAX(LlnLoanNo),5)) + 1) FROM LosLoan(NOLOCK)
					IF ISNULL(@MaxLoanNo,0) = 0 SET @MaxLoanNo =  1;
					SELECT @LoanNo = 'SHFHOLOAN' + dbo.gefgGetPadZero(5,(ISNULL(@MaxLoanNo,0)))

					IF NOT EXISTS(SELECT 'X' FROM LosLoan(NOLOCK) WHERE LlnLedFk = @LeadPk AND LlnDelId = 0)
					BEGIN
						INSERT INTO LosLoan(LlnLedFk,LlnBGeoFk,LlnPrdFk,LlnAppFk,LlnLoanNo,LlnLoanDt,
									LlnRowId,LlnCreatedBy,LlnCreatedDt,LlnModifiedBy,LlnModifiedDt,LlnDelFlg,LlnDelId)
						SELECT 		@LeadPk,@GeoFk,@PrdFk,@AppFk,@LoanNo,@CurDt,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0
					END

				END
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


GO
