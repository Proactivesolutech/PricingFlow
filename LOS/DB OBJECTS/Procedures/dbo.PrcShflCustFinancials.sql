IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflCustFinancials' AND [type]='P')
	DROP PROC PrcShflCustFinancials
GO
CREATE PROCEDURE PrcShflCustFinancials
(
	@Action			VARCHAR(MAX)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,
	@DetailsJSON	VARCHAR(MAX)		=	NULL,
	@popupjson      VARCHAR(MAX)		=	NULL,
	@pkpop			BIGINT				=	NULL,
	@PopType		TINYINT				=	NULL,
	@PrpJson		VARCHAR(MAX)		=	NULL,
	@PrpslNoteInfo	VARCHAR(MAX)		=	NULL,
	@Proposal       VARCHAR(MAX)        =   NULL
)
AS
BEGIN
--RETURN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40);

	DECLARE @pop_date VARCHAR(100),@pop_rptstatus BIGINT, @ApprveLvl TINYINT,@DevRmks VARCHAR(MAX)
	
	DECLARE	@DocPk BIGINT, @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,@AgtFk BIGINT,
			@selActor TINYINT, @Query VARCHAR(MAX),@AppFk BIGINT,@LapFk BIGINT,@NHBdepndtFk BIGINT,
			@CreditPk BIGINT,@CreditJson VARCHAR(MAX)  ,@SalType  VARCHAR(3) ,  @SalPrf  VARCHAR(3),@PrdType  VARCHAR(3),@PrdGrpType VARCHAR(2);

	DECLARE @FeedPk BIGINT , @pop_text VARCHAR(500);
	
	DECLARE @businessJSON VARCHAR(MAX),@salaryJSON VARCHAR(MAX),@cashJSON VARCHAR(MAX),@bankJSON VARCHAR(MAX),@otherJSON VARCHAR(MAX),@IncomeHead VARCHAR(MAX),@LiabilityJSON VARCHAR(MAX),
			@NHBclssJSON VARCHAR(MAX),@NHBdepndtJSON VARCHAR(MAX),@BankDetailJSON VARCHAR(MAX) , @PDFileJson VARCHAR(MAX) , @ExstLoan VARCHAR(MAX), @RefJson VARCHAR(MAX),
			@manualDevJson VARCHAR(MAX)

	CREATE TABLE #GlobalDtls(xx_id BIGINT,LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100),UsrNm VARCHAR(100), PrdCd VARCHAR(100),DocDelPK BIGINT,
				RoleFk BIGINT, BrnchFk BIGINT, PrdNm VARCHAR(100), LeadNm VARCHAR(200), LeadID VARCHAR(100), PrdFk BIGINT, AgtNm VARCHAR(100), AgtFk BIGINT, 
				Branch VARCHAR(200),SalType VARCHAR(3),SalPrf VARCHAR(3),PrdType VARCHAR(3),PrdGrpType VARCHAR(3),ApprveLvl TINYINT,DevRmks VARCHAR(MAX),Brch_date VARCHAR(15))
	
	CREATE TABLE #DetailsTbl(xx_Id BIGINT,business VARCHAR(MAX) , salary VARCHAR(MAX) , 
					cash VARCHAR(MAX) , bank VARCHAR(MAX) , Liability VARCHAR(MAX),other VARCHAR(MAX),incomeHead VARCHAR(MAX),NHBclss VARCHAR(MAX), NHBdepndt VARCHAR(MAX),BankDetail VARCHAR(MAX),
					CreditJson VARCHAR(MAX),PDFileJson VARCHAR(MAX) , ExistingLoan VARCHAR(MAX), Reference VARCHAR(MAX),manualDev VARCHAR(MAX))

	CREATE TABLE #CreditTable(xx_Id BIGINT, AttrCd VARCHAR(20),Value NUMERIC(27,7))
			
			--LapPk,remarks,incomeName,IncType,MoPay,SumAmount,isIncExc

	CREATE TABLE #TempmanualDev (xx_Id BIGINT,ManualDevPk BIGINT)

	CREATE TABLE #TempAppHeadTable(xx_Id BIGINT,LapPk BIGINT,remarks VARCHAR(500),incomeName VARCHAR(50),IncType CHAR(2),MoPay VARCHAR(100),SumAmount NUMERIC,isIncExc INT)

	CREATE TABLE #TempAppBusiInc(xx_Id BIGINT, remarks VARCHAR(500),PayMentType VARCHAR(100),incomeName VARCHAR(50),amount NUMERIC,
					comppk BIGINT,addless INT, MntYrname VARCHAR(100),isIncExc INT,LapPk BIGINT,Percentage INT, HeadPK BIGINT,DoF VARCHAR(50))		

	CREATE TABLE #TempAppSalInc(xx_Id BIGINT,remarks VARCHAR(500),PayMentType VARCHAR(100),incomeName VARCHAR(50),amount NUMERIC,comppk BIGINT,
					addless INT, MntYrname VARCHAR(100),isIncExc INT,LapPk BIGINT,Percentage INT, HeadPK BIGINT)
	
	CREATE TABLE #TempAppBankInc(xx_Id BIGINT,remarks VARCHAR(500),bankNm VARCHAR(100),Month VARCHAR(100), PayMentType VARCHAR(100),
					incomeName VARCHAR(50),amount NUMERIC,comppk BIGINT,addless INT, MntYrname VARCHAR(100),isIncExc INT,LapPk BIGINT,Percentage INT, HeadPK BIGINT)	
	
	CREATE TABLE #TempAppCashInc(xx_Id BIGINT,remarks VARCHAR(200),incomeName VARCHAR(50),amount NUMERIC,comppk BIGINT,addless INT, MntYrname VARCHAR(100),isIncExc INT,LapPk BIGINT,Percentage INT, HeadPK BIGINT)				
	
	CREATE TABLE #TempAppOtherInc(xx_Id BIGINT,desctxt VARCHAR(200),remarks VARCHAR(500),amount NUMERIC,MntYrname VARCHAR(100),isIncExc INT,LapPk BIGINT,incomeName VARCHAR(50),Percentage INT, HeadPK BIGINT)
	
	CREATE TABLE #TempNHBClsTbl(xx_Id BIGINT,NHBApplicable VARCHAR(50),NHBPuccaHouse VARCHAR(50),NHBHouseHldCatogory VARCHAR(100),
					NHBHouseHldAnnInc BIGINT,NHBLocCode BIGINT, NHBLocNm VARCHAR(100))
	
	CREATE TABLE #TempNHBDepndtTbl(xx_Id BIGINT,depndtnm VARCHAR(200),depndtrefno VARCHAR(200),depndtproof VARCHAR(200))
	
	CREATE TABLE #TempBankDtlsTbl(xx_Id BIGINT,bankPk BIGINT,appFk BIGINT,AccountName VARCHAR(100),AccountType BIGINT,AccountNumber VARCHAR(100),
				 BankName VARCHAR(100),BranchName VARCHAR(100),bnkTran BIGINT,AvgBal VARCHAR(100),InChqBounce BIGINT,Notes VARCHAR(250),BankFk BIGINT,BranchFk BIGINT,OperativeSince VARCHAR(100))
	
	CREATE TABLE #TempAppLiability(xx_Id BIGINT,LiabilityPk BIGINT,LapPK BIGINT,Bank VARCHAR(100),RefNo VARCHAR(100), incexlswitch BIGINT,
				 EMI VARCHAR(100),OutStandAmt VARCHAR(100),RemTerms VARCHAR(200),Notes VARCHAR(250),svsswitch BIGINT,OblTyp BIGINT, HeadPK BIGINT,BounceNo BIGINT, DepBank VARCHAR(100),
				 Lnamt VARCHAR(100))
    
	CREATE TABLE #Temppopup(xx_id BIGINT,sel_Pop_typ TINYINT,sel_lapFk BIGINT,Popdate VARCHAR(50),Poptext VARCHAR(MAX),pop_rptstatus BIGINT,popmobile VARCHAR(50))
	
	CREATE TABLE #PDFiles (xx_id BIGINT, FilePath VARCHAR(300))

	CREATE TABLE #TempExistLn(xx_id BIGINT, FinInst VARCHAR(200),RefNo VARCHAR(200),LoanAmt NUMERIC(27,7) , RemainingTenure NUMERIC(27,7))

	CREATE TABLE #TempReference(xx_id BIGINT, Summary VARCHAR(200),RefCrdStatus VARCHAR(50),RefPk BIGINT)
	
	CREATE TABLE #TempProp(xx_id BIGINT, NrBranch VARCHAR(200),Distance VARCHAR(50),PropPk BIGINT)

	CREATE TABLE #TempHeadTable(LapFk BIGINT,Headpk BIGINT,IncomeName VARCHAR(200),Inctype CHAR(2))

	CREATE TABLE #AgentTmpTable(RptStatus VARCHAR(100),FBLapFk VARCHAR(100),ServiceTyp VARCHAR(100),DocPath VARCHAR(100))

	CREATE TABLE #Proposaldtls (Pid BIGINT,notespk BIGINT,notes VARCHAR(max))

	--FOR PRODUCT RESTRICTION			
	DECLARE @PI_PNI VARCHAR(20) , @PROD_GRP VARCHAR(20)	, @SELECTED_PRD VARCHAR(20)	,  @IS_BTTOP VARCHAR(20), @PROD_ERROR VARCHAR(MAX) = ''

	SELECT @CurDt = GETDATE(), @RowId = NEWID()	
	

	
	IF @Proposal != '[]' AND @Proposal != ''
	BEGIN					
		INSERT INTO #Proposaldtls
		EXEC PrcParseJSON @Proposal,'pk,Notes'
	END

	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN					
	
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,UsrNm,PrdCd,DocDelPK,RoleFk,BrnchFk,PrdNm,LeadNm,LeadID,PrdFk,AgtNm,AgtFk,Branch,SalType,SalPrf,PrdType,GrpType,ApprveLvl,DevRmks,B_date'
	
		SELECT	@LeadPk = LeadPk, @AppFk = AppPk, @UsrDispNm = G.UsrDispNm, @UsrNm = G.UsrNm, @SalType = SalType ,
				@PrdType = PrdType, @PrdGrpType = PrdGrpType, @SalPrf = SalPrf , @UsrPk = G.UsrPk , @AgtFk = G.AgtFk ,
				@GeoFk = GeoFk , @PrdFk = AppPrdFk	, @ApprveLvl = ApprveLvl ,@DevRmks = DevRmks
		FROM	#GlobalDtls  G
		--JOIN	GenPrdMas (NOLOCK) ON PrdCd = PrdCd AND PrdDelid = 0
		JOIN	LosApp (NOLOCK) ON AppLedFk = LeadPk AND AppDelId = 0
		JOIN    LosAppProfile (NOLOCK) ON LapLedFk = AppLedFk AND LapDelId = 0	

	END
	
	IF @DetailsJSON != '[]' AND @DetailsJSON != ''
	BEGIN
			
		INSERT INTO #DetailsTbl
		EXEC PrcParseJSON @DetailsJSON,'business,salary,cash,bank,Liability,other,incomeHead,NHBclss,NHBdepndt,BankAcc,CreditJson,PDFileJson,ExistingLoan,Reference,manualDev';		

		SELECT	@businessJSON = business, @salaryJSON= salary, @cashJSON = cash,@bankJSON = bank,@LiabilityJSON = Liability,@otherJSON = other ,@IncomeHead = incomeHead,
				@NHBclssJSON = NHBclss, @NHBdepndtJSON = NHBdepndt,@BankDetailJSON = BankDetail , @CreditJson = CreditJson , @PDFileJson = PDFileJson,
				@ExstLoan = ExistingLoan, @RefJson = Reference , @manualDevJson = manualDev
				FROM  #DetailsTbl		
									
		IF @manualDevJson != '[]' AND @manualDevJson != ''
		BEGIN
			INSERT INTO #TempmanualDev(xx_id,ManualDevPk)
			EXEC PrcParseJSON @manualDevJson,'pk'	
		END
									
		IF @businessJSON != '[]' AND @businessJSON != ''
		BEGIN
			INSERT INTO #TempAppBusiInc(xx_id,remarks,PayMentType,incomeName,amount,comppk,addless, MntYrname,isIncExc,LapPk,Percentage,DoF)
			EXEC PrcParseJSON @businessJSON,'remarks,PayMentType,incomeName,amount,comppk,addless, MntYrname,isIncExc,LapPk,LbiPerc,DoF'	
		END
		
		IF @salaryJSON != '[]' AND @salaryJSON != ''
		BEGIN
			INSERT INTO #TempAppSalInc(xx_id,remarks,PayMentType,incomeName,amount,comppk,addless, MntYrname,isIncExc,LapPk,Percentage)
			EXEC PrcParseJSON @salaryJSON,'remarks,PayMentType,incomeName,amount,comppk,addless, MntYrname,isIncExc,LapPk,LbiPerc'
				
		END
		
		IF @bankJSON != '[]' AND @bankJSON != ''
		BEGIN
			INSERT INTO #TempAppBankInc(xx_id,remarks,bankNm,Month,PayMentType,incomeName,amount,comppk,addless,MntYrname,isIncExc,LapPk,Percentage)
			EXEC PrcParseJSON @bankJSON,'remarks,bankNm,Month,PayMentType,incomeName,amount,comppk,addless, MntYrname,isIncExc,LapPk,LbiPerc'
			
		END
	
		IF @cashJSON != '[]' AND @cashJSON != ''
		BEGIN
			INSERT INTO #TempAppCashInc(xx_id,remarks,incomeName,amount,comppk,addless, MntYrname,isIncExc ,LapPk,Percentage)
			EXEC PrcParseJSON @cashJSON,'remarks,incomeName,amount,comppk,addless, MntYrname,isIncExc,LapPk,LbiPerc'			
		END		
		
		IF @otherJSON != '[]' AND @otherJSON != ''
		BEGIN
		
			INSERT INTO #TempAppOtherInc(xx_id,desctxt,remarks,amount,MntYrname,isIncExc,LapPk,incomeName,Percentage)
			EXEC PrcParseJSON @otherJSON,'desctxt,remarks,amount, MntYrname,isIncExc,LapPk,incomeName,LbiPerc'

		END								   
		IF @IncomeHead != '[]'  AND @IncomeHead != '' 
		BEGIN 				
			INSERT INTO #TempAppHeadTable(xx_id,LapPk,remarks,incomeName,IncType,MoPay,SumAmount,isIncExc)
			EXEC PrcParseJSON @IncomeHead ,'LapFk,remarks,incNm,incometype,MoP,amount,incexc'
		END
		
		IF @NHBclssJSON != '[]' AND @NHBclssJSON != ''
		BEGIN
			INSERT INTO #TempNHBClsTbl
			EXEC PrcParseJSON @NHBclssJSON,'NHBApplicable,NHBPuccaHouse,NHBHouseHldCatogory,NHBHouseHldAnnInc,NHBLocCode, NHBLocNm'
		END		

		IF @NHBdepndtJSON != '[]' AND @NHBdepndtJSON != ''
			BEGIN
			INSERT INTO #TempNHBDepndtTbl
			EXEC PrcParseJSON @NHBdepndtJSON,'depndtnm,depndtrefno,depndtproof'
		END	

		IF @BankDetailJSON != '[]' AND @BankDetailJSON != ''
			BEGIN
			INSERT INTO #TempBankDtlsTbl
			EXEC PrcParseJSON @BankDetailJSON,'bankPk,appFk,AccountName,AccountType,AccountNumber,BankName,BranchName,bnkTran,AvgBal,InChqBounce,Notes,BankFk,BranchFk,OperativeSince'
		END	

		IF @LiabilityJSON != '[]' AND @LiabilityJSON != ''
		BEGIN
			INSERT INTO #TempAppLiability(xx_id,LiabilityPk,LapPK,Bank,RefNo,incexlswitch,EMI,OutStandAmt,RemTerms,Notes,svsswitch,OblTyp,BounceNo,DepBank,Lnamt)
			EXEC PrcParseJSON @LiabilityJSON,'LiabilityPk,LapPK,Bank,RefNo,incexlswitch,EMI,OutStandAmt,RemTerms,Notes,svsswitch,OblTyp,BounceNo,DepBank,Lnamt'
		END	
			
		IF @CreditJson != '[]' AND @CreditJson != ''
		BEGIN					
			INSERT INTO #CreditTable
			EXEC PrcParseJSON @CreditJson ,'AttrCd,Value'					
		END	

		IF @PDFileJson != '[]'  AND @PDFileJson != '' 
		BEGIN 
			INSERT INTO #PDFiles
			EXEC PrcParseJSON @PDFileJson ,'filePath'
		END

		IF @ExstLoan != '[]'  AND @ExstLoan != '' 
		BEGIN 		
			INSERT INTO #TempExistLn
			EXEC PrcParseJSON @ExstLoan ,'bank,RefNo,amount,tenure'
		END	
		
		IF @RefJson != '[]'  AND @RefJson != '' 
		BEGIN 		
			INSERT INTO #TempReference
			EXEC PrcParseJSON @RefJson ,'Summary,Status,refFk'
		END		
						
	END
	
		IF @PrpJson != '[]'  AND @PrpJson != '' 
		BEGIN 		
			INSERT INTO #TempProp
			EXEC PrcParseJSON @PrpJson ,'NrBranch,Distance,PropPk'
		END	
	
		IF @popupjson != '[]' AND @popupjson != ''
		BEGIN
			INSERT INTO #Temppopup
			EXEC PrcParseJSON @popupjson,'sel_Pop_typ,sel_lapFk,pop_date,pop_text,pop_rptstatus,popmobile'
				
		SELECT @pop_date=Popdate,@pop_text=Poptext, @pop_rptstatus = pop_rptstatus FROM #Temppopup
	END
	
	BEGIN TRY
	 

	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN	
			
			IF @Action ='LOAD_DATA'
	    	BEGIN
			  SELECT  MasCd 'Cd',MasDesc 'Masname',MasPk 'Mpk'	
			  FROM   GenMas(NOLOCK) WHERE MasTyp='P' AND MasDelId=0
			  ORDER BY MasSeqNo
		    END

			IF @Action = 'GET_INCOME_COMPONENTS'
			BEGIN				
				SELECT LcmNm name , LcmTyp type, LcmPk pk 	, LcmAddLess addless, LcmSeq seqno , LcmIsTot istotal,
						CONVERT(INT,ISNULL(LcmIsPerc,0)) isPerc,ISNULL(LcmSrcComp,0) srccomp,ISNULL(LcmDstComp,0) dstcomp,ISNULL(LcmCd,'') compcode
				FROM LosComp (NOLOCK) WHERE LcmDelId = 0 	
				ORDER BY LcmTyp,seqno
				
				SELECT ''
				SELECT ''

			END

			IF @Action ='DOCUMENT'
			BEGIN
			
				SELECT	DocLedFk 'LeadFk',ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',
						DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',DocCat	'Catogory',	DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk',
						CASE WHEN DocActor = 0 THEN 'Applicant' WHEN DocActor = 1  THEN 'Co-Applicant'  END 'Actor'
						FROM LosDocument(NOLOCK)
						JOIN GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
						JOIN #GlobalDtls ON LeadPk = DocLedFk			
						WHERE DocDelId=0 
			END

			IF @Action ='INSERT_FIN_DET'
			BEGIN									

				DELETE FROM LosAppBusiInc WHERE LbiLedFk = @LeadPk
				DELETE FROM LosAppSalInc WHERE LsiLedFk = @LeadPk
				DELETE FROM LosAppCshInc WHERE LciLedFk = @LeadPk
				DELETE FROM LosAppOthInc WHERE LoiLedFk = @LeadPk
				DELETE FROM LosAppBnkBal WHERE LbbLedFk = @LeadPk

				UPDATE LosAppDates SET AdtDelId=1 WHERE AdtTyp='B' AND AdtLedFk=@LeadPk

				-- CHANGES FOR ** File send Date is not mandatory when confirm, but in confirm and handover. 
				IF EXISTS(SELECT 'X' FROM #GlobalDtls WHERE ISNULL(Brch_date,'') <> '')
				BEGIN 
					INSERT INTO LosAppDates 
					(
						AdtLedFk,AdtTyp,AdtDt,AdtRowId,AdtCreatedBy,AdtCreatedDt,AdtModifiedBy,
						AdtModifiedDt,AdtDelFlg,AdtDelId
					)
					SELECT     @LeadPk,'B',dbo.gefgChar2Date(Brch_date),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,
							   @CurDt,NULL,0
					FROM       #GlobalDtls 
				END
				
				UPDATE LosNHB SET NHBDelId = 1 WHERE NHBLedFk = @LeadPk				

				UPDATE  A SET A.LndDelId = 1 
				FROM LosNHBDpd(NOLOCK) A
				JOIN LosNHB(NOLOCK) B ON A.LndNHBFk = B.NHBPk AND B.NHBLedFk = @LeadPk															

				UPDATE	LosAppIncObl SET LioDelId = 1 
				WHERE	LioLedFk = @LeadPk

				UPDATE	LosAppRef 
				SET		LarSummary = Summary,LarCreditSts = RefCrdStatus,
						LarRowId = @RowId,LarModifiedBy = @UsrDispNm,LarModifiedDt = @CurDt
				FROM	#TempReference
				WHERE	LarPk = RefPk AND LarDelId = 0			

				INSERT	INTO LosAppIncObl(LioLedFk,LioAppFk,LioLapFk,LioType,LioName,LioRmks,LioMoP,LioIncExc,LioSumAmt,
						LioRowId,LioCreatedBy,LioCreatedDt,LioModifiedBy,LioModifiedDt,LioDelFlg,LioDelId)
						OUTPUT	INSERTED.LioLapFk,INSERTED.LioPk,INSERTED.LioName,INSERTED.LioType
						INTO	#TempHeadTable
				SELECT	@LeadPk,@AppFk,LapPk,IncType,incomeName,remarks,MoPay,isIncExc,SumAmount,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0
				FROM	#TempAppHeadTable

				INSERT INTO	LosAppBusiInc(LbiLedFk,LbiAppFk,LbiLapFk,LbiYr,LbiLcmFk,LbiAddLess,LbiVal,LbiIncExl,
							LbiRowId,LbiCreatedBy,LbiCreatedDt,LbiModifiedBy,LbiModifiedDt,LbiDelFlg,LbiDelId,LbiName,LbiPerc,LbiLioFk,LbiITR)
							OUTPUT INSERTED.*
				SELECT		@LeadPk,@AppFk,A.LapPk,A.MntYrname,A.comppk,A.addless,A.amount,A.isIncExc,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,A.incomeName,A.Percentage,B.Headpk,A.DoF
				FROM		#TempAppBusiInc A				
				JOIN		#TempHeadTable B ON B.LapFk = A.LapPk AND B.IncomeName = A.incomeName			
								

				INSERT INTO LosAppSalInc(LsiLedFk,LsiAppFk,LsiLapFk,LsiMon,LsiLcmFk,LsiAddLess,LsiVal,LsiIncExl,LsiRowId,
							LsiCreatedBy,LsiCreatedDt,LsiModifiedBy,LsiModifiedDt,LsiDelFlg,LsiDelId,LsiName,LsiPerc,LsiLioFk)
							OUTPUT INSERTED.*
				SELECT		@LeadPk,@AppFk,A.LapPk,CONVERT(VARCHAR(100),A.MntYrname),A.comppk,A.addless,A.amount,A.isIncExc,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,A.incomeName,A.Percentage,B.Headpk
				FROM		#TempAppSalInc A
				JOIN		#TempHeadTable B ON B.LapFk = A.LapPk AND B.IncomeName = A.incomeName			

				INSERT INTO LosAppCshInc(LciLedFk,LciAppFk,LciLapFk,LciYr,LciLcmFk,LciAddLess,LciVal,LciIncExl,LciRowId,
							LciCreatedBy,LciCreatedDt,LciModifiedBy,LciModifiedDt,LciDelFlg,LciDelId,LciName,LciPerc,LciLioFk)												
							OUTPUT INSERTED.*
				SELECT		@LeadPk,@AppFk,A.LapPk,CONVERT(VARCHAR(100),A.MntYrname),A.comppk,A.addless,A.amount,A.isIncExc,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,A.incomeName,A.Percentage,B.Headpk
				FROM		#TempAppCashInc A
				JOIN		#TempHeadTable B ON B.LapFk = A.LapPk AND B.IncomeName = A.incomeName			
							
				INSERT INTO LosAppOthInc(LoiLedFk,LoiAppFk,LoiLapFk,LoiDesc,LoiPeriod,LoiAmt,LoiRowId,LoiCreatedBy,LoiCreatedDt,
							LoiModifiedBy,LoiModifiedDt,LoiDelFlg,LoiDelId,LoiName,LoiPerc,LoiLioFk)
							OUTPUT INSERTED.*
				SELECT		@LeadPk,@AppFk,A.LapPk,A.desctxt,CONVERT(VARCHAR(100),A.MntYrname),A.amount,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,A.incomeName,A.Percentage,B.Headpk
							FROM #TempAppOtherInc A
				JOIN		#TempHeadTable B ON B.LapFk = A.LapPk AND B.IncomeName = A.incomeName

				INSERT INTO LosAppBnkBal(LbbLedFk,LbbAppFk,LbbLapFk,LbbBnkNm,LbbMon,LbbDay,LbbVal,LbbRowId,LbbCreatedBy,
							LbbCreatedDt,LbbModifiedBy,LbbModifiedDt,LbbDelFlg,LbbDelId,LbbPerc,LbbName,LbbLioFk,LbbLcmFk)
							OUTPUT INSERTED.*
				SELECT		@LeadPk,@AppFk,A.LapPk,A.bankNm,A.Month, A.MntYrname, A.amount ,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,A.Percentage,A.incomeName,B.Headpk,A.comppk
							FROM #TempAppBankInc A
				JOIN		#TempHeadTable B ON B.LapFk = A.LapPk AND B.IncomeName = A.incomeName
									
				INSERT INTO LosNHB(NHBLedFk,NHBAppFk,NHBPuccaHouse,NHBHosCat,NHBHosInc,NHBLocCd,NHBLocNm,NHBRowId,NHBCreatedBy,
							NHBCreatedDt,NHBModifiedBy,NHBModifiedDt,NHBDelFlg,NHBDelId)
							OUTPUT INSERTED.*
				SELECT		@LeadPk,@AppFk,NHBPuccaHouse,NHBHouseHldCatogory,NHBHouseHldAnnInc,NHBLocCode, NHBLocNm,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0
						    FROM #TempNHBClsTbl
							
				SET @NHBdepndtFk = SCOPE_IDENTITY();

				
				INSERT	INTO LosNHBDpd(LndNHBFk,LndDpdNm,LndProof,LndRefNo,LndRowId,LndCreatedBy,LndCreatedDt,LndModifiedBy,
							 LndModifiedDt,LndDelFlg,LndDelId)
							 OUTPUT INSERTED.*
				SELECT		 @NHBdepndtFk,depndtnm,depndtproof,depndtrefno,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0
							 FROM #TempNHBDepndtTbl
							 

				UPDATE LosAppBank SET LbkDelId = 1 WHERE LbkLedFk = @LeadPk
				
				INSERT INTO LosAppBank(LbkLedFk,LbkAppFk,LbkLapFk,LbkNm,LbkAccNo,LbkBank,LbkBranch,LbkIFSC,LbkRowId,LbkCreatedBy,LbkCreatedDt,LbkModifiedBy,
							LbkModifiedDt,LbkDelFlg,LbkDelId,LbkAccTyp,LbkBnkTran,LbkAvgBkBal,LbkInChqBnc,LbkNotes,LbkBnkFk,LbkBbmFk,LbkOpSince)
				SELECT		@LeadPk,@AppFk,appFk,AccountName,AccountNumber,BankName,BranchName,'',@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,
							AccountType,bnkTran,AvgBal,InChqBounce,Notes,NULLIF(ISNULL(BankFk,0),0),NULLIF(ISNULL(BranchFk,0),0),DBO.gefgChar2Date(OperativeSince)
				FROM		#TempBankDtlsTbl			

				DELETE FROM LosAppObl WHERE LaoLedFk = @LeadPk

				INSERT INTO	LosAppObl(LaoLedFk,LaoAppFk,LaoLapFk,LoaIsIncl,LaoTyp,LaoIsShri,LaoSrc,LaoRefNo,LaoEMI,LaoOutstanding,LaoTenure,LaoNotes,
							LaoRowId,LaoCreatedBy,LaoCreatedDt,LaoModifiedBy,LaoModifiedDt,LaoDelFlg,LaoDelId,LaoLioFk,LaoEMIBounceNo,LaoEMIDepBnk,LaoLnamt)
							OUTPUT INSERTED.*
				SELECT		@LeadPk,@AppFk,A.LapPK,A.incexlswitch,A.OblTyp,A.svsswitch,A.Bank,A.RefNo,A.EMI,A.OutStandAmt,A.RemTerms,A.Notes,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,B.Headpk,BounceNo,DepBank,Lnamt
				FROM		#TempAppLiability	A
				JOIN		#TempHeadTable B ON B.LapFk = A.LapPk AND B.Inctype = 'OB'

				DELETE FROM LosAppExistLn WHERE LelLedFk = @LeadPk
				
				INSERT INTO LosAppExistLn(LelLedFk,LelAppFk,LelFinInst,LelRefNo,LelOutstandingAmt,
							LelRowId,LelCreatedBy,LelCreatedDt,LelModifiedBy,LelModifiedDt,LelDelFlg,LelDelId,LelTenure)
						OUTPUT INSERTED.* 
				SELECT @LeadPk,@AppFk,FinInst,RefNo,LoanAmt ,@RowId,@UsrNm,GETDATE(),@UsrNm,GETDATE(),0,0,RemainingTenure
				FROM  #TempExistLn

				/*
				DELETE T FROM LosDeviation  T
				JOIN LosLnAttributes (NOLOCK) ON LnaCd = 'MANUALDEV' AND LnaDelId = 0
				WHERE LdvStage = 'C' AND  LdvLedFk = @LeadPk

				INSERT INTO  LosDeviation(LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvRmks,
				LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal,LdvLmdFk)
				OUTPUT INSERTED.*
				SELECT @LeadPk,@AppFk,@UsrPk,'C',LnaPk,LmdDeviation,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,NULL,ManualDevPk				
				FROM	#TempmanualDev
				JOIN	LosManualDeviation (NOLOCK) ON LmdPk = ManualDevPk AND LmdDelid = 0
				LEFT OUTER JOIN LosLnAttributes (NOLOCK) ON LnaCd = 'MANUALDEV' AND LnaDelId = 0								
				*/

				
				UPDATE LosAppNotes SET LanDelId = 1 WHERE LanLedFk = @LeadPk AND LanTyp ='P'

				INSERT INTO LosAppNotes (LanLedFk,LanAppFk,LanLapFk,LanNotes,LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy, 
                     LanModifiedDt,LanDelFlg,LanDelId,LanMasFk,LanTyp
				)
				SELECT @LeadPk,@AppFk,@LapFk,notes,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,notespk,'P'
				FROM #Proposaldtls

			END
			
			
			IF @Action = 'UPDATE_PROP_DET'
				BEGIN
					UPDATE	LosProp 
					SET		PrpNearBrnch = NrBranch, PrpBrnchDist = Distance, PrpRowId = @RowId,PrpModifiedBy = @UsrDispNm,PrpModifiedDt = @CurDt
					FROM	#TempProp 
					WHERE	PrpPk = PropPk
				END

			IF @Action = 'DELETE'
			BEGIN	
			select ''		 
				UPDATE A SET A.DocDelId = 1 FROM LosDocument A (NOLOCK)
				JOIN #GlobalDtls B ON   B.DocDelPK = A.DocPk			
			END
		
			IF @Action='SelFinDetails'
			BEGIN		
				

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
				SELECT		LptSts, 0, 'TV',''
				FROM		LosPropTechnical(NOLOCK) WHERE LptLedFk = @LeadPk AND LptDocSts = 'A'

					
				INSERT INTO #AgentTmpTable(RptStatus,FBLapFk,ServiceTyp,DocPath)
				SELECT LpLSts, 0, 'LV',''
				FROM   LosPropLegal(NOLOCK) WHERE LplLedFk = @LeadPk AND LplDocSts = 'A'


				-- FOR MARKET AND ACTUAL PROP VALUE -- NOT USED
				SELECT  Ledpk , MIN(LptMktVal) LptMktVal,MIN(LplAgrmtVal) LplAgrmtVal,Lptprpfk
				INTO	#TempPropValuation
				FROM	LosLead (NOLOCK)
				JOIN	LosApp(NOLOCK) ON AppLedFk = LedPk AND AppDelId=0
				LEFT OUTER JOIN	LosPropTechnical(NOLOCK) ON LptLedFk =  LedPk AND LptDelId = 0
				LEFT OUTER JOIN	LosPropLegal(NOLOCK) ON LplLedFk =  LedPk AND LplDelId = 0
				WHERE	LedPk = @LeadPk AND LedDelid= 0	
				GROUP BY Lptprpfk,Ledpk

				DECLARE @ACT_PRP_VAL NUMERIC(27,7),@MRKPROP_VAL NUMERIC(27,7)

				SELECT	@MRKPROP_VAL = ISNULL(SUM(LptMktVal),0),@ACT_PRP_VAL= ISNULL(SUM(LplAgrmtVal),0) 
				FROM	#TempPropValuation

							
				-- 1  SELECT Lead Details	
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
						ISNULL(LedEmpCat,'') 'customerClass',CONVERT(VARCHAR,LedIncPrf) 'incomeClass' , AppPk 'AppFk' ,LedLnAmt 'LoanAmt',
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
				LEFT OUTER JOIN	GenPrdMas(NOLOCK) ON PrdPk = AppPrdFk AND PrdGrpFk = AppPGrpFk AND PrdDelId = 0
				WHERE	LedPk = @LeadPk AND LedDelId = 0	
			
				
				-- 2 SELECT Applicants Details
				SELECT	ISNULL(LapFstNm+' '+LapMdNm+' '+LapLstNm,'') 'ApplicantName', LapActor 'Actor',0 'income' ,0 'Obligation' ,ISNULL(LapCibil,0) 'CIBILscore',
						ISNULL(LapEmpTyp,'') 'customerClass',CONVERT(VARCHAR,LedIncPrf) 'incomeClass' ,	
						CASE WHEN dateadd(year, datediff (year, LapDOB, getdate()), LapDOB) > getdate() THEN datediff(year, LapDOB, getdate()) - 1 ELSE datediff(year, LapDOB, getdate()) END as 'Age',
						CASE WHEN LapActor = 0  THEN 'Applicant' WHEN LapActor = 1 THEN 'Co Applicant' WHEN LapActor = 2 THEN 'Guarantor'  END 'ApplicantType', LapPk 'AppFk'
				FROM	LosLead(NOLOCK) 
				JOIN	LosAppProfile(NOLOCK)  ON LapLedFk = LedPk AND LedDelId = 0
				JOIN	LosApp(NOLOCK) ON AppLedFk = LedPk AND LapAppFk = AppPk AND AppDelId=0
				WHERE	LedPk = @LeadPk AND LapDelId = 0
				ORDER BY LapActor,LapPk

				-- 3 SELECT Bank Details
				SELECT	LbkNm 'AccountName',LbkAccNo 'AccountNumber',LbkBank 'BankName',LbkBranch 'BranchName',LbkIFSC 'IFSC',
						LbkPk 'BankPk',LbkAccTyp 'AccountType' , LapActor 'Actor' ,ISNULL(LbkBnkTran,0) 'bnkTran' ,ISNULL(LbkAvgBkBal,0) 'AvgBal' ,
						ISNULL(LbkInChqBnc,0) 'InChqBounce',ISNULL(LbkNotes,'') 'Notes' , LapPk 'AppPk' , LbkBnkFk 'BankFk',LbkBbmFk 'BranchFk',DBO.gefgDMY(LbkOpSince) 'OperativeSince'
				FROM	LosAppBank (NOLOCK) 
				JOIN	LosAppProfile(NOLOCK)  ON LapLedFk = LbkLedFk AND LbkLapFk = LapPk  AND  LapDelId = 0
				WHERE	LbkLedFk = @LeadPk AND LbkDelId = 0
				
				-- 4 SELECT Obligation Details
				SELECT	LaoLedFk 'LeadFk',LaoAppFk 'AppFk',LaoLapFk 'LapFk',LoaIsIncl 'OblIncExc',LaoTyp 'LoanType',LaoIsShri 'IsSVS',
						LaoSrc 'Source',LaoRefNo 'RefNo',LaoEMI 'EMI',LaoOutstanding 'OutStandingAmt',LaoTenure 'Tenure',ISNULL(LaoNotes,'') 'OblNotes',LaoPk 'OblPk',LaoLioFk 'HeadFk',
						LioRmks 'HdRmks',ISNULL(LaoEMIBounceNo,'') 'OblBounce',ISNULL(LaoEMIDepBnk,'') 'OblDebtBank',LaoLnamt 'Lnamt'
				FROM	LosAppObl (NOLOCK)
				LEFT OUTER JOIN	LosAppIncObl (NOLOCK) ON LioPk = LaoLioFk AND LioDelId = 0
				WHERE	LaoLedFk = @LeadPk AND LaoDelId = 0

				-- 5 SELECT PF amount Details
				SELECT SUM(LpcInstrAmt) 'PfAmt' FROM LosProcChrg(NOLOCK) WHERE LpcLedFk =@LeadPk AND LpcDelId = 0
				
				-- 6 SELECT Applicant Income type Details
				SELECT	CONVERT(VARCHAR(5),AppSalTyp) 'saltype', CONVERT(VARCHAR(5),AppSalPrf) 'proof'
				FROM	LosApp(NOLOCK) 
				WHERE	AppLedFk = @LeadPk AND AppDelId = 0 

				-- 7 SELECT Existing Loan
				SELECT	ISNULL(LelFinInst,'') 'BankNm',ISNULL(LelRefNo,'') 'RefNo',ISNULL(LelOutstandingAmt,0) 'Amount', LelPk 'Pk' ,ISNULL(LelTenure,0) 'remaining'
				FROM	LosAppExistLn (NOLOCK) 
				WHERE	LelLedFk = @LeadPk AND LelDelId = 0 

				-- 8 Agents Verfication Status , 0- negative 1 - neutral 2 - positive
				SELECT	RptStatus 'Status',FBLapFk 'LapFk',ServiceTyp 'serv',DocPath 'DocPath' 
				FROM	#AgentTmpTable

				---- 9 Reference Details ----

				SELECT	LarNm 'ReferNm',LarOffNo 'RefOffNo',LarResNo 'RefTeleNo',ISNULL(LarSummary,'') 'Summary',ISNULL(LarCreditSts,2) 'RefSts',LarPk 'LarPk',LarMobNo 'RefMobNo'
				FROM	LosAppRef(NOLOCK) WHERE LarLedFk = @LeadPk AND LarDelId = 0			

					--10 Proposal Details

				  SELECT LanNotes 'Notes',LanMasFk 'ProposalPk'
				  FROM	LosAppNotes(NOLOCK)
				  WHERE	LanLedFk=@LeadPk AND LanTyp='P' AND LanDelId=0 


			END			

			IF @Action = 'SelectIncomeDetails'
			BEGIN
				-- business Income
				SELECT	LcmPk 'comppk',LbiYr 'busiyear',LbiLcmFk 'busilcmFk',LbiAddLess 'busiaddless',ISNULL(LbiVal,0) 'busiValue',
						CONVERT(VARCHAR,LbiIncExl) 'IncExc',LbiPk 'busiPk' ,LapActor 'Actor', LapPk 'AppPk',LbiPerc 'percentage',LbiName 'Name',LbiLioFk 'HeadFk'
						,LioType 'HdIncObType',LioName 'HdIncName',LioRmks 'HdRmks',LioMoP 'HdMoP',LioIncExc 'HdIncExc',LbiITR 'ITRDoF',LcmCd 'compcode'
				FROM	LosAppBusiInc(NOLOCK) 
				JOIN	LosAppIncObl (NOLOCK) ON LioPk = LbiLioFk AND LioDelId = 0
				LEFT OUTER JOIN	LosComp (NOLOCK) ON LcmPk = LbiLcmFk AND LcmDelId = 0
				JOIN	LosAppProfile(NOLOCK) ON LapAppFk = LbiAppFk AND LbiLapFk=LapPk AND  LapDelId = 0
				WHERE	LbiLedFk = @LeadPk AND LbiDelId = 0
				ORDER	BY LbiPk,LbiLioFk;

				-- Bank Balance income
				SELECT	LbbLcmFk 'comppk', LbbBnkNm 'bankName',LbbMon 'bankmonth',LbbDay 'day',LbbVal 'bankValue', LbbPk 'bankPk',
						LapActor 'Actor', LapPk 'AppPk',LbbPerc 'percentage',LbbName 'Name',LbbLioFk 'HeadFk'
						,LioType 'HdIncObType',LioName 'HdIncName',LioRmks 'HdRmks',LioMoP 'HdMoP',LioIncExc 'HdIncExc'
				FROM	LosAppBnkBal(NOLOCK)  
				JOIN	LosAppIncObl (NOLOCK) ON LioPk = LbbLioFk AND LioDelId = 0
				JOIN	LosAppProfile(NOLOCK) ON LapAppFk = LbbAppFk AND LbbLapFk=LapPk AND  LapDelId = 0
				WHERE	LbbLedFk = @LeadPk AND LbbDelId = 0
				ORDER	BY LbbPk,LbbLioFk;
				
				-- Cash Income
				SELECT	LcmPk 'comppk',LciYr 'cashyear',LciLcmFk 'cashlcmFk',LciAddLess 'cashaddless',LciVal 'cashValue',
						CONVERT(VARCHAR,LciIncExl) 'IncExc', LciPk 'cashPk',LapActor 'Actor', LapPk 'AppPk',LciPerc 'percentage',LciName 'Name',LciLioFk 'HeadFk'
						,LioType 'HdIncObType',LioName 'HdIncName',LioRmks 'HdRmks',LioMoP 'HdMoP',LioIncExc 'HdIncExc',LcmCd 'compcode'
				FROM	LosAppCshInc(NOLOCK) 
				JOIN	LosAppIncObl (NOLOCK) ON LioPk = LciLioFk AND LioDelId = 0
				LEFT OUTER JOIN	LosComp (NOLOCK) ON LcmPk = LciLcmFk AND LcmDelId = 0
				JOIN	LosAppProfile(NOLOCK) ON LapAppFk = LciAppFk AND  LciLapFk=LapPk AND LapDelId = 0
				WHERE	LciLedFk = @LeadPk AND LciDelId = 0				
				ORDER	BY LciPk,LciLioFk;

				--Other Income
				SELECT	LoiDesc 'desc',LoiPeriod 'period' ,LoiAmt 'OtherInc', LoiPk 'otherPk',LapActor 'Actor', LapPk 'AppPk',
						ISNULL(LoiPerc,100) 'percentage',LoiName 'Name',LoiLioFk 'HeadFk'
						,LioType 'HdIncObType',LioName 'HdIncName',LioRmks 'HdRmks',LioMoP 'HdMoP',LioIncExc 'HdIncExc'
				FROM	LosAppOthInc(NOLOCK) 
				JOIN	LosAppIncObl (NOLOCK) ON LioPk = LoiLioFk AND LioDelId = 0
				JOIN	LosAppProfile(NOLOCK) ON LapAppFk = LoiAppFk AND LoiLapFk=LapPk AND  LapDelId = 0
				WHERE	LoiLedFk = @LeadPk AND LoiDelId = 0
				ORDER	BY LoiPk,LoiLioFk;

				-- salary income
				SELECT	LcmPk 'comppk',LsiMon 'salmonth',LsiLcmFk 'sallcmFk',LsiAddLess 'saladdless',LsiVal 'salValue',
						CONVERT(VARCHAR,LsiIncExl) 'IncExc', LsiPk 'salPk',LapActor 'Actor', LapPk 'AppPk',LsiPerc 'percentage',LsiName 'Name',LsiLioFk 'HeadFk'
						,LioType 'HdIncObType',LioName 'HdIncName',LioRmks 'HdRmks',LioMoP 'HdMoP',LioIncExc 'HdIncExc',LcmCd 'compcode'
				FROM	LosAppSalInc(NOLOCK) 
				JOIN	LosAppIncObl (NOLOCK) ON LioPk = LsiLioFk AND LioDelId = 0
				LEFT OUTER JOIN	LosComp (NOLOCK) ON LcmPk = LsiLcmFk AND LcmDelId = 0
				JOIN	LosAppProfile(NOLOCK) ON LapAppFk = LsiAppFk AND LsiLapFk=LapPk AND LapDelId = 0
				WHERE	LsiLedFk = @LeadPk AND LsiDelId = 0			
				ORDER	BY LsiPk,LsiLioFk;

				--- NHB Master
				SELECT	NHBLedFk,NHBAppFk,NHBPuccaHouse 'puccahouse',NHBHosCat 'NHBcatogory',NHBHosInc 'hosInc',NHBLocCd 'Loccode',NHBLocNm 'LocName',NHBPk 'NHBPk'
				FROM	LosNHB(NOLOCK) 
				WHERE	NHBLedFk = @LeadPk AND NHBDelId = 0
				
				-- NHB details
				SELECT	LndDpdNm 'depndtnm',LndProof 'depndtproof',LndRefNo 'depndtrefno' ,LndPk 'lndPk',LndNHBFk			
				FROM	LosNHB(NOLOCK)
				JOIN	LosNHBDpd(NOLOCK)	 ON  LndNHBFk =  NHBPk AND LndDelId = 0
				WHERE	NHBLedFk = @LeadPk AND NHBDelId = 0

				-- Income/Obl Head
				SELECT	LioLedFk 'LeadPk',LioAppFk 'AppPk',LioLapFk 'LapPK',LioType 'IncObType',LioName 'IncName',LioRmks 'Rmks',LioMoP 'MoP',LioIncExc 'IncExc',
						LioSumAmt 'SumAmt',LioPk 'HeadPk'
				FROM	LosAppIncObl(NOLOCK) WHERE LioLedFk = @LeadPk AND LioDelId = 0

			END		

			IF @Action = 'SELECT_CREDIT_DTLS'
			BEGIN								
				SELECT * FROM 
				(
					SELECT	ISNULL(LnaCd,'') LnaCd,ISNULL(LcaVal,'')LcaVal
					FROM	LosCreditAttr(NOLOCK) A
					JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0
					JOIN	LosCredit (NOLOCK) B ON B.LcrPk = A.LcaLcrFk AND B.LcrLedFk = @LeadPk AND B.LcrDelId = 0 AND B.LcrDocRvsn = 0 
					WHERE	A.LcaDelId = 0 AND L.LnaCd IN ('LOAN_AMT','ROI','TENUR')
				) PIVOTTABLE
				PIVOT (MIN (LcaVal) FOR LnaCd IN (LOAN_AMT,ROI,TENUR) ) 
				AS PIVOTTABLE

				SELECT       dbo.gefgDMY(AdtDt) 'Dt'
				FROM         LosAppDates (NOLOCK)
				WHERE        AdtLedFk=@LeadPk AND AdtTyp= 'B' AND AdtDelId=0
			END

			IF @Action = 'SelectPropDetails'
			BEGIN

				SELECT	PrpSeller 'sellerNm',PrpTyp,PrpDoorNo 'Prpdoorno',PrpBuilding 'Prpbuilding',PrpPlotNo 'Prpplotno',PrpStreet 'Prpstreet',PrpLandmark 'Prplandmark',
						PrpArea 'Prparea',PrpDistrict 'Prpdistrict',PrpState 'Prpstate',PrpCountry 'Prpcountry',PrpPin 'Prppincode',PrpPk 'prp_pk',ISNULL(PrpNearBrnch,'') 'PrpBranch',ISNULL(PrpBrnchDist,'') 'PrpDistance'								
				FROM	LosProp(NOLOCK)	
				WHERE	PrpLedFk = @LeadPk

			END

			IF @Action = 'INSERT_CREDIT_DTLS'
			BEGIN
				IF EXISTS(SELECT 'X' FROM LosCredit(NOLOCK) WHERE LcrLedFk = @LeadPk AND LcrDelId = 0 AND LcrDocRvsn = 0 )
				BEGIN 
					-- Select 1 
					UPDATE	T SET T.LcrBGeoFk = A.GeoFk ,T.LcrPrdFk = @PrdFk ,T.LcrRolFk = A.RoleFk ,T.LcrUsrFk = @UsrPk,T.LcrDocNo=NULL,T.LcrDocRvsn=0,T.LcrDocTyp=NULL,
							T.LcrDocDt = NULL,T.LcrRowId = @RowId,T.LcrModifiedBy = A.UsrNm ,T.LcrModifiedDt = @CurDt , @CreditPk = T.LcrPk
					OUTPUT INSERTED.*
					FROM LosCredit(NOLOCK) T 
					JOIN #GlobalDtls A ON A.LeadPk =  T.LcrLedFk
					WHERE T.LcrLedFk = @LeadPk AND LcrDocRvsn = 0 AND LcrDelId = 0
				END
				ELSE
				BEGIN
					-- Select 1 
					INSERT INTO LosCredit(LcrLedFk,LcrBGeoFk,LcrPrdFk,LcrRolFk,LcrUsrFk,LcrDocNo,LcrDocRvsn,LcrDocTyp,LcrDocDt,LcrRowId,LcrCreatedBy,LcrCreatedDt,LcrModifiedBy,LcrModifiedDt,LcrDelFlg,LcrDelId)
					OUTPUT INSERTED.*
					SELECT LeadPk,GeoFk,@PrdFk,RoleFk, @UsrPk,NULL,0,NULL,NULL,@RowId,UsrNm,@CurDt,UsrNm,@CurDt,NULL,0 FROM #GlobalDtls	
				
					SET @CreditPk = @@IDENTITY
				END

				UPDATE	T 
				SET		T.LcaDelId = 1 
				FROM	LosCreditAttr (NOLOCK) T
				JOIN	LosCredit (NOLOCK) ON LcrPk = LcaLcrFk AND LcrDelId = 0
				WHERE	LcaDelId = 0 AND LcrDocRvsn = 0 AND LcrLedFk = @LeadPk

				-- Select 2 
				INSERT INTO LosCreditAttr(LcaLcrFk,LcaLnaFk,LcaVal,LcaRowId,LcaCreatedBy,LcaCreatedDt,LcaModifiedBy,LcaModifiedDt,LcaDelFlg,LcaDelId)
				OUTPUT INSERTED.*
				SELECT	 @CreditPk,B.LnaPk,A.Value ,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0 
				FROM #CreditTable A
				JOIN LosLnAttributes(NOLOCK) B ON B.LnaCd = A.AttrCd AND B.LnaDelId = 0

				-- Select 3 TELEverf status
				SELECT	CASE WHEN COUNT(LtvPk) = (SELECT COUNT(LapPk) FROM LosAppProfile A (NOLOCK) WHERE  A.LapLedFk = @LeadPk AND A.LapDelId = 0 ) THEN 'TRUE' 
						ELSE 'FALSE' END 'TELE_STS_OFF'
				FROM	LosAppTeleVerify (NOLOCK) 
				JOIN	LosAppProfile B (NOLOCK) ON B.LapLedFk = LtvLedFk AND B.LapPk =LtvLapFk AND B.LapDelId = 0
				WHERE	LtvLedFk = @LeadPk AND LtvDelId = 0 AND Ltvtype = 1
				
				-- select 4 TELEverf status
				SELECT	CASE WHEN COUNT(LtvPk) = (SELECT COUNT(LapPk) FROM LosAppProfile A (NOLOCK) WHERE  A.LapLedFk = @LeadPk AND A.LapDelId = 0 ) THEN 'TRUE' 
						ELSE 'FALSE' END 'TELE_STS_RES'
				FROM	LosAppTeleVerify (NOLOCK) 
				JOIN	LosAppProfile B (NOLOCK) ON B.LapLedFk = LtvLedFk AND B.LapPk =LtvLapFk AND B.LapDelId = 0
				WHERE	LtvLedFk = @LeadPk AND LtvDelId = 0 AND Ltvtype = 2

				--Select 5 PD status
				SELECT	CASE WHEN COUNT(LpdPk) = (SELECT COUNT(LapPk) FROM LosAppProfile A (NOLOCK) WHERE  A.LapLedFk = @LeadPk AND A.LapDelId = 0 ) THEN 'TRUE' 
						ELSE 'FALSE' END 'PD_STS'
				FROM	LosAppPD (NOLOCK) 
				JOIN	LosAppProfile B (NOLOCK) ON B.LapLedFk = LpdLedFk AND B.LapPk =LpdLapFk AND B.LapDelId = 0
				WHERE	LpdLedFk = @LeadPk AND LpdDelId = 0

			END
		  
		  IF @Action ='INSERT_FB_POP'
			BEGIN
				SELECT @AppFk = AppPk FROM LosApp (NOLOCK) WHERE AppLedFk =  @LeadPk AND AppDelId = 0			

				IF  @PopType = 1 OR @PopType = 3
				BEGIN			
																
					INSERT INTO LosAppTeleVerify(LtvLedFk,LtvAppFk,LtvLapFk,LtvRptDt,LtvNotes,LtvSts,LtvRowId,LtvCreatedBy,LtvCreatedDt
								,LtvModifiedBy,LtvModifiedDt,LtvDelFlg,LtvDelId,Ltvtype,LtvPhone)
					SELECT      @LeadPk,@AppFk,sel_lapFk,dbo.gefgChar2Date(Popdate),Poptext,pop_rptstatus,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,
								CASE WHEN @PopType = 1  THEN 2 ELSE 1 END,popmobile
					FROM		#Temppopup
					WHERE		sel_Pop_typ = @PopType

					IF @@ROWCOUNT > 0
						SELECT @FeedPk = SCOPE_IDENTITY()
				END
				ELSE IF @PopType = 2
				BEGIN
					
					INSERT INTO LosDocument (DocLedFk,DocBGeoFk,DocPrdFk,DocActor,DocCat,DocSubCat,DocNm,DocPath,
								DocRowId,DocCreatedBy,DocCreatedDt,DocModifiedBy,DocModifiedDt,DocDelFlg,DocDelId,DocAgtFk,DocSubActor) 
					SELECT		@LeadPk,@GeoFk,@PrdFk,0,'PD','PD','PD',FilePath,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,@AgtFk,1 
					FROM		#PDFiles
										
					SELECT @DocPk = @@IDENTITY

					INSERT INTO LosAppPD(LpdLedFk,LpdAppFk,LpdLapFk,LpdRptDt,LpdNotes,LpdSts,LpdRowId,LpdCreatedBy,LpdCreatedDt,LpdModifiedBy,LpdModifiedDt,LpdDelFlg,LpdDelId,LpdDocFk)
					SELECT      @LeadPk,@AppFk,sel_lapFk,dbo.gefgChar2Date(Popdate),Poptext,pop_rptstatus,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,@DocPk 
					FROM		#Temppopup
					WHERE		sel_Pop_typ = 2

					IF @@ROWCOUNT > 0
						SELECT @FeedPk = SCOPE_IDENTITY()
				END	
				SELECT	ISNULL(@FeedPk,0) 'Pk', sel_Pop_typ 'sel_Pop_typ', sel_lapFk 'sel_lapFk'
				FROM	#Temppopup
			END

	    IF @Action ='SELECT_FB_POP'
			BEGIN 			
				SELECT	LtvPk 'LtvPk',LtvLedFk 'LtvLedFk',LtvAppFk 'LtvAppFk',LtvLapFk 'LtvLapFk',DBO.gefgDMY(LtvRptDt) 'pop_date',
						LtvNotes 'pop_text',LtvSts 'pop_rptstatus',Ltvtype 'type',ISNULL(NULLIF(LtvPhone,''),'0') 'appnumber'
				FROM	LosAppTeleVerify (NOLOCK)
				WHERE	LtvLapFk = @pkpop AND LtvLedFk=@LeadPk AND LtvDelId=0

				SELECT	LpdPk 'LpdPk',LpdLedFk 'LpdLedFk',LpdAppFk 'LpdAppFk',LpdLapFk 'LpdLapFk',DBO.gefgDMY(LpdRptDt) 'pop_date',
						LpdNotes 'pop_text',LpdSts 'pop_rptstatus' , ISNULL(DocPath,'') 'filepath'
				FROM	LosAppPD (NOLOCK)
				LEFT OUTER JOIN	LosDocument (NOLOCK) ON DocPk = LpdDocFk AND DocDelId = 0
				WHERE	LpdLapFk = @pkpop AND LpdLedFk=@LeadPk AND LpdDelId=0
			 
				SELECT	ISNULL(LapMobile,'') 'LapMob',ISNULL(LapResi,'') 'LapRes', ISNULL(LaeOffNo,'') 'OffNo',ISNULL(LabOffNo,'') 'BusNo',ISNULL(LapAltMobile,'') 'alterno'
				FROM	LosAppProfile (NOLOCK)
				LEFT OUTER JOIN	LosAppOffProfile (NOLOCK) ON LaeLapFk = LapPk AND LaeDelId = 0
				LEFT OUTER JOIN	LosAppBusiProfile (NOLOCK) ON LabLapFk = LapPk AND LabDelId = 0				
				WHERE	LapLedFk = @LeadPk AND LapPk = @pkpop AND LapDelId = 0 
			END

	    IF @Action ='UPDATE_FB_POP'
		BEGIN
			IF @PopType = 1 OR @PopType = 3
			BEGIN
				UPDATE	LosAppTeleVerify 
				SET		LtvRptDt=dbo.gefgChar2Date(@pop_date),LtvNotes=@pop_text,LtvSts = @pop_rptstatus, LtvModifiedBy = @UsrDispNm ,LtvModifiedDt = @CurDt,LtvPhone=popmobile
				OUTPUT	INSERTED.*
				FROM	#Temppopup
				WHERE	LtvPk = @pkpop AND LtvDelId = 0
			END
			ELSE IF @PopType = 2
			BEGIN								
				
				UPDATE T SET T.DocDelId = 1 
				FROM LosDocument T (NOLOCK)
				JOIN LosAppPD A (NOLOCK) ON LpdDocFk = DocPk AND LpdDelId = 0 
				WHERE DocDelId = 0

				INSERT INTO LosDocument (DocLedFk,DocBGeoFk,DocPrdFk,DocActor,DocCat,DocSubCat,DocNm,DocPath,
								DocRowId,DocCreatedBy,DocCreatedDt,DocModifiedBy,DocModifiedDt,DocDelFlg,DocDelId,DocAgtFk,DocSubActor) 
				SELECT		@LeadPk,@GeoFk,@PrdFk,0,'PD','PD','PD',FilePath,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,@AgtFk,1 
				FROM		#PDFiles
										
				SELECT @DocPk = @@IDENTITY

				UPDATE	LosAppPD 
				SET		LpdRptDt=dbo.gefgChar2Date(@pop_date),LpdNotes=@pop_text,LpdSts = @pop_rptstatus, LpdModifiedBy = @UsrDispNm 
						,LpdModifiedDt = @CurDt , LpdDocFk = @DocPk						
				OUTPUT	INSERTED.*
				FROM	#Temppopup
				WHERE	LpdPk = @pkpop AND LpdDelId = 0
			END
		END
		
		IF @Action ='UPDATE_APP_EMP'
		BEGIN								
					
			
			SELECT	@PI_PNI  = ISNULL(LedPNI,'N') ,@IS_BTTOP = ISNULL(LedBT,'N')
			FROM	LosLead (NOLOCK) 
			WHERE	LedPk = @LeadPk AND LedDelId = 0
			
			SELECT @PROD_GRP = GrpCd
			FROM	LosApp(NOLOCK) 
			JOIN	GenLvlDefn (NOLOCK) ON GrpPk = AppPGrpFk AND GrpDelId = 0
			WHERE AppLedFk = @LeadPk AND AppDelId = 0
				
			SELECT	@SELECTED_PRD = PrdCd
			FROM	GenPrdMas (NOLOCK) 
			WHERE	PrdPk = @PrdType AND PrdDelId = 0 


			IF NULLIF(ISNULL(@PrdType,0),0) IS NOT NULL 
			BEGIN
				IF @PI_PNI = 'N' AND @IS_BTTOP = 'N' AND 
				( 
					(@PROD_GRP = 'HL' AND @SELECTED_PRD NOT IN ('HLNew','HLResale','HLExt','HLImp','HLBT','HLTopup','HLPltConst','HLConst','HLRefin') )
				OR
					(@PROD_GRP = 'LAP' AND @SELECTED_PRD NOT IN ('LAPResi','LAPCom','LAPBT','LAPTopup') )
				OR	(@PROD_GRP = 'PL' AND @SELECTED_PRD NOT IN ('PL') )
				)
				BEGIN
					SELECT @PROD_ERROR = 'Cannot choose this product type!'
				END

				IF @PI_PNI = 'Y' AND @IS_BTTOP = 'N' AND 
				(
					(@PROD_GRP = 'HL' AND @SELECTED_PRD NOT IN ('HLNew','HLResale','HLPltConst','HLConst'))
				OR
				 	(@PROD_GRP = 'PL' AND @SELECTED_PRD NOT IN ('PL'))
				)
				BEGIN
					SELECT @PROD_ERROR = 'Cannot choose this product type!'
				END

				IF @PI_PNI = 'N' AND @IS_BTTOP = 'Y' AND 
				(
					(@PROD_GRP = 'HL' AND @SELECTED_PRD NOT IN ('HLBTTopup'))
				OR
				 	(@PROD_GRP = 'LAP' AND @SELECTED_PRD NOT IN ('LAPBTTopup'))
				)
				BEGIN
					SELECT @PROD_ERROR = 'Cannot choose this product type!'
				END
			END
			
			IF @PROD_ERROR != ''
				SELECT @PROD_ERROR 'ERROR'
			ELSE
			BEGIN
				UPDATE LosApp SET AppSalTyp = NULLIF(ISNULL(@SalType,''),''), AppSalPrf = NULLIF(ISNULL(@SalPrf,''),'') , AppPrdFk = NULLIF(ISNULL(@PrdType,0),0)
				OUTPUT INSERTED.*
				WHERE AppPk =  @AppFk AND AppLedFk = @LeadPk AND  AppDelId = 0 

				UPDATE	LosLead SET LedPrdFk = NULLIF(ISNULL(@PrdType,0),0) 
				WHERE	LedPk = @LeadPk AND LedDelId = 0 		
			END

			SELECT	PrdCd 'ProductCode' FROM GenPrdMas(NOLOCK) 
			WHERE	PrdPk =  @PrdType AND PrdDelId = 0			
		END

		IF @Action ='SELECT_SUB_PRODUCTS'
		BEGIN					
			
			SELECT	@PI_PNI  = ISNULL(LedPNI,'N') ,@IS_BTTOP = ISNULL(LedBT,'N')
			FROM	LosLead (NOLOCK) 
			WHERE	LedPk = @LeadPk AND LedDelId = 0
			
			SELECT @PROD_GRP = GrpCd FROM GenLvlDefn (NOLOCK)
			WHERE GrpPk = @PrdGrpType AND GrpDelId = 0
							
			IF @PI_PNI = 'N' AND @IS_BTTOP = 'N'			
			BEGIN
				SELECT	PrdCd 'ProdCd',PrdNm 'Name',PrdPk 'Pk',PrdIcon 'icon',PrdGrpFk 'GrpFk'
				FROM	GenPrdMas(NOLOCK) 
				WHERE	PrdGrpFk = @PrdGrpType AND PrdDelId = 0 AND PrdCd IN ('HLNew','HLResale','HLExt','HLImp','HLBT','HLTopup',
						'HLPltConst','HLConst','HLRefin','LAPResi','LAPCom','LAPBT','LAPTopup','PL')
			END

			IF @PI_PNI = 'Y' AND @IS_BTTOP = 'N' 			
			BEGIN
				SELECT	PrdCd 'ProdCd',PrdNm 'Name',PrdPk 'Pk',PrdIcon 'icon',PrdGrpFk 'GrpFk'
				FROM	GenPrdMas(NOLOCK) 
				WHERE	PrdGrpFk = @PrdGrpType AND PrdDelId = 0 AND PrdCd IN ('HLNew','HLResale','HLPltConst','HLConst','PL')
			END

			IF @PI_PNI = 'N' AND @IS_BTTOP = 'Y'
			BEGIN
				SELECT	PrdCd 'ProdCd',PrdNm 'Name',PrdPk 'Pk',PrdIcon 'icon',PrdGrpFk 'GrpFk'
				FROM	GenPrdMas(NOLOCK) 
				WHERE	PrdGrpFk = @PrdGrpType AND PrdDelId = 0 AND PrdCd IN ('HLBTTopup','LAPBTTopup')
			END
						
		END	

		IF @Action = 'GetPrpslInfo'
		BEGIN			
				SELECT LanNotes 'PrpslNoteInfo'
				FROM LosAppNotes(NOLOCK)
				WHERE LanLedFk = @LeadPk AND LanTyp = 'P' AND LanDelId = 0		
		END		

		IF @Action = 'SavePrpslInfo'
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 'X' FROM LosAppNotes(NOLOCK) WHERE LanLedFk = @LeadPk)
			BEGIN
				SELECT @LapFk = LapPk 
				FROM LosAppProfile (NOLOCK)
				WHERE LapLedFk = @LeadPk AND LapActor = 0 AND LapDelId = 0

				IF ISNULL(@PrpslNoteInfo,'') <> ''
				BEGIN
					INSERT INTO LosAppNotes(LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,LanRowId,
											LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId)
					VALUES (@LeadPk, @AppFk, @LapFk, 'P', @PrpslNoteInfo,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0)
				END
			END
			ELSE
			BEGIN
				IF ISNULL(@PrpslNoteInfo,'') <> ''
				BEGIN
					UPDATE LosAppNotes
					SET LanNotes = @PrpslNoteInfo
					WHERE LanLedFk = @LeadPk AND LanTyp = 'P' AND LanDelId = 0
				END
			END
		END			
		
		IF @Action = 'ADD_MANUALDEV'
		BEGIN			
			INSERT INTO LosDeviation (LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
									LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal)
			SELECT @LeadPk,@AppFk,@UsrPk,'C',LnaPk,NULL,NULL,NULL,'','D',@ApprveLvl,@DevRmks,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,NULL
			FROM	LosLnAttributes (NOLOCK) 
			WHERE	LnaCd = 'MANUALDEV' AND LnaDelId = 0
		END

		IF @Action = 'MANUALDEV_DATA'
		BEGIN 
			-- 1 Category details
			SELECT	DISTINCT LmdCategory AS 'text' 
			FROM	LosManualDeviation (NOLOCK) WHERE LmdDelId = 0 
			
			-- 2 Deviation details			
			SELECT	LmdCategory AS 'category',LmdDeviation AS 'text' ,LmdPk 'Pk'
			FROM	LosManualDeviation (NOLOCK) WHERE LmdDelId = 0 
			ORDER BY LmdCategory

			-- 3 Manual Deviation Details

			SELECT  LmdCategory 'Category' , ISNULL(STUFF(
						(SELECT ',' + RTRIM(LmdPk)
						FROM	LosDeviation (NOLOCK)
						JOIN	LosManualDeviation (NOLOCK) ON  LmdPk = LdvLmdFk AND LmdDelid = 0
						JOIN	LosLnAttributes (NOLOCK) ON LnaCd = 'MANUALDEV' AND LnaDelId = 0
						WHERE	LdvStage = 'C' AND  LdvLedFk = @LeadPk							
						FOR XML PATH (''))
						, 1, 1, '') ,'') 'Selected'
			FROM	LosDeviation (NOLOCK)
			JOIN	LosManualDeviation (NOLOCK) ON  LmdPk = LdvLmdFk AND LmdDelid = 0
			JOIN	LosLnAttributes (NOLOCK) ON LnaCd = 'MANUALDEV' AND LnaDelId = 0
			WHERE	LdvStage = 'C' AND  LdvLedFk = @LeadPk
			GROUP BY LmdCategory 

		END

		IF @Action = 'SELECT_MANUALDEV'
		BEGIN
			SELECT	LdvAppBy 'AppLvl',LdvRmks 'Rmks'
			FROM	LosDeviation (NOLOCK) 
			JOIN	LosLnAttributes (NOLOCK) ON LnaCd = 'MANUALDEV' AND LnaDelId = 0
			WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 AND LdvStage = 'C'
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


