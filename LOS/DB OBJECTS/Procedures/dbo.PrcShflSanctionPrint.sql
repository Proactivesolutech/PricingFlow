IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflSanctionPrint' AND [type]='P')
	DROP PROC PrcShflSanctionPrint
GO
CREATE PROCEDURE PrcShflSanctionPrint
(
	@Action			VARCHAR(100) = NULL,
	@GlobalJson		VARCHAR(MAX) = NULL
)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT

	DECLARE @DBNAME VARCHAR(20) = db_name() , @LeadPk BIGINT, @WaiverROI INT = 0, @PfAmt NUMERIC(27,7),@TaxFk BIGINT,@CmpFk BIGINT
	DECLARE @PrpAddr VARCHAR(MAX) = '', @GrpCd VARCHAR(50)

	DECLARE @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT, @FinalPrdFk BIGINT,
		@AppFk BIGINT,@LapFk BIGINT, @CreditPk BIGINT,@RowId VARCHAR(MAX) , @RoleFk BIGINT , @SanctionNo VARCHAR(50) , @SanctionPk BIGINT,
		@MaxSanNo BIGINT , @AgtFk BIGINT , @PfPk BIGINT , @ApproverLvl TINYINT , @LoanNo VARCHAR(50) , @MaxLoanNo BIGINT , @SancRvnNo INT , 
		@sancNo VARCHAR(200),@ProductCode VARCHAR(20) , @CurProductCode VARCHAR(20)

	CREATE TABLE #GlobalDtls
	(
		xx_id BIGINT,LeadPk BIGINT,LeadId VARCHAR(100),LeadNm VARCHAR(100),AppNo VARCHAR(100), GeoFk BIGINT, BranchNm VARCHAR(100),UsrDispNm VARCHAR(100),
		PrdFk BIGINT,PrdNm VARCHAR(100),AgtFk BIGINT,SancRvnNo INT,sancNo VARCHAR(200)
	)
	CREATE TABLE #ProPrcCalc
	(
		PrdGrpFk BIGINT, PrdFk BIGINT, Qty NUMERIC(27, 7), PrcTyp TINYINT, CompCd VARCHAR(50), CompNm VARCHAR(100), CompRef BIGINT, 
		Rmks VARCHAR(250), CompPer NUMERIC(27, 7), CompVal NUMERIC(27,7 ), CompSgn INT, CompRnd TINYINT, CompTyp VARCHAR(10), 
		TreeId VARCHAR(250), RelCompNm VARCHAR(100), FinalVal NUMERIC(27, 7), xIsProc BIT,
		PrdCd VARCHAR(50), IsAccPst TINYINT, PrdSrcFk BIGINT, CompPrcTyp TINYINT, VchFk BIGINT, IsClng BIT, IsVis BIT, 
		xRowId UNIQUEIDENTIFIER, xPk BIGINT IDENTITY(1, 1), SeqNo TINYINT, DpdFk BIGINT
	)
	
	SELECT @RowId = NEWID()
	SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN	
		
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'FwdDataPk,LeadId,LeadNm,AppNo,GeoFk,BranchNm,UsrDispNm,PrdFk,PrdNm,AgtFk,SancRvnNo,sancNo'

		SELECT	@LeadPk = LeadPk, @UsrDispNm = G.UsrDispNm, 
				@PrdFk = AppPrdFk, @AgtFk = G.AgtFk , @SancRvnNo = G.SancRvnNo,@sancNo = G.sancNo,
				@ProductCode = PrdCd, @GrpCd = GrpCd
		FROM	#GlobalDtls G
		JOIN	LosApp (NOLOCK) ON AppLedFk = LeadPk AND AppDelId = 0
		JOIN	GenLvlDefn(NOLOCK) ON GrpPk = AppPGrpFk AND GrpDelid = 0
		LEFT OUTER JOIN GenPrdMas (NOLOCK) ON PrdGrpFk = GrpPk AND PrdPk = AppPrdFk AND AppDelId = 0

		SELECT @SancRvnNo = CASE	WHEN ISNULL(@SancRvnNo,0) <> 0 THEN @SancRvnNo
									ELSE (SELECT MAX(LsnRvnNo) FROM LosSanction (NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelid = 0 )
							END

	END

	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN
			
			IF @Action = 'PRINT_SANCTION'
			BEGIN
			--SELECT @SancRvnNo , @sancNo , @LeadPk
				-- 1 Sanction Details
				SELECT	RTRIM(LedId) +' / ' + RTRIM(LsnSancNo) 'SancNo',CONVERT(VARCHAR,GETDATE()+90,106) 'SancDate' , 
						LsnPk 'SanctionPk' , PrdCd 'ProductCode' , PrdPk 'Productpk',  PrdNm 'ProductName'
				INTO	#SancTable
				FROM	LosSanction(NOLOCK) 
				JOIN	LosLead (NOLOCK) ON LedPk = LsnLedFk AND LedDelId = 0 
				JOIN	GenPrdMas (NOLOCK) ON  PrdPk = LsnPrdFk AND PrdDelId = 0
				JOIN	GenLvlDefn (NOLOCK) ON GrpPk = PrdGrpFk AND GrpDelId = 0
				WHERE	LsnLedFk = @LeadPk AND LsnDelId = 0 AND 
						LsnRvnNo = @SancRvnNo AND LsnSancNo = @sancNo
						
				SELECT @CurProductCode = ProductCode FROM #SancTable
														
				IF EXISTS(SELECT 'X' FROM #SancTable)
				BEGIN
					SELECT * FROM #SancTable
				END
				ELSE
				BEGIN
					SELECT 'Loan is not yet sanctioned for this Lead.' AS 'ERROR';
				END				

				--2  Applicant, Product , Property
				SELECT	@PrpAddr = ISNULL(@PrpAddr,'') + '<strong>Property ' + CAST(ROW_NUMBER() OVER (ORDER BY P.PrpPk) AS VARCHAR) + '</strong>: <br/>'+ P.PrpDoorNo + ',' 
						+ ISNULL(P.PrpBuilding,'') + ',' + P.PrpPlotNo + ',' + ISNULL(P.PrpStreet,'') + ',<br/>' + P.PrpArea 
						+ ',' + P.PrpDistrict + ',' + P. PrpState + ' - ' + P.PrpPin + '.<br/><br/>'
				FROM	LosProp P(NOLOCK)
				WHERE	P.PrpLedFk = @LeadPk AND P.PrpDelid = 0
				
				IF ISNULL(@PrpAddr,'') <> ''
					SET @PrpAddr = LEFT(@PrpAddr,(LEN(@PrpAddr) - 10))
					
				SELECT DISTINCT	 AppApplNm  'AppName',  
						CASE WHEN PrdCd IN ('HLBT','HLTopup','LAPBT','LAPTopup') THEN PrdNm ELSE GrpNm END 'Product' , 
						CASE WHEN PrdCd IN ('HLBT','HLTopup','LAPBT','LAPTopup') THEN ''
						ELSE
							CASE WHEN AppLnPur = 0 THEN 'Take over of existing Housing Loan' 
								WHEN AppLnPur = 1 THEN 'Extend Renovate Repair of House Flat' 
								WHEN AppLnPur = 2 THEN 'Construction' 
								WHEN AppLnPur = 3 THEN 'Plot And Construction' 
								WHEN AppLnPur = 4 THEN 'Flat New' 
								WHEN AppLnPur = 5 THEN 'Flat Resale' 
								WHEN AppLnPur = 6 THEN 'House New' 
								WHEN AppLnPur = 7 THEN 'House ReSale' 
								WHEN AppLnPur = 8 THEN 'Refinance' 
								WHEN AppLnPur = 9 THEN 'House Old' 
								WHEN AppLnPur = 10 THEN 'Additional Finance' 
								WHEN AppLnPur = 11 THEN 'House Extension' 
								ELSE PrdNm
								END 
							END 'Purpose',
							PrdCd 'OrgProduct' ,
							CONVERT(VARCHAR,GETDATE(),107) + ' <br> To,<br><strong>'+
							ISNULL(UPPER(LapFstNm),' ')+' '+
							ISNULL(UPPER(LapMdNm),' ')+' '+
							ISNULL(UPPER(LapLstNm),' ')+'</strong><br> ' +  
							ISNULL(UPPER(LaaDoorNo),'') + ' , <br>' +
							ISNULL(UPPER(LaaBuilding),'') + ' , ' + ISNULL(UPPER(LaaPlotNo),' ') + ', <br>' +
							ISNULL(UPPER(LaaStreet),'') + ISNULL(UPPER(LaaLandmark),'') +', <br> '+
							ISNULL(UPPER(LaaArea),'') + ',' + ISNULL(UPPER(LaaDistrict),'') + ' <br>'+
							ISNULL(UPPER(LaaState),'') + ' '+ISNULL(LaaPin,'') +' <br>' 'ApplAddr',							
							STUFF((
								SELECT actor + '<br>'
								FROM
								(
								  SELECT 
										CASE WHEN A.LapActor = 0 THEN '' 
											WHEN A.LapActor = 1 THEN '<tr> <td style="width:35%">CoApplicant</td><td style="width:2%">&nbsp;:</td><td colspan="4" style="width:17%">' + A.LapFstNm + ' '+ A.LapMdNm+' '+ A.LapLstNm + '</td>' 
											WHEN A.LapActor = 2 THEN '<tr> <td style="width:35%">Guarantor</td><td style="width:2%">&nbsp;:</td><td colspan="4" style="width:17%">' + A.LapFstNm + ' '+ A.LapMdNm+' '+ A.LapLstNm + '</td>' 
										END AS 'actor' ,A.LapPk 'PK'
								  FROM		LosAppProfile(NOLOCK) A WHERE A.LapLedFk = @LeadPk AND A.LapDelId = 0
								) AS Y
								ORDER BY PK
								FOR XML PATH(''), ROOT('MYSTRING'),TYPE).value('/MYSTRING[1]','VARCHAR(MAX)'
							),4,0,'') 'CoAppNo'																			
				FROM	LosApp (NOLOCK) 
				JOIN	LosAppProfile (NOLOCK) ON LapAppFk = AppPk AND LapDelId = 0 AND LapActor = 0
				LEFT OUTER JOIN LosAppAddress (NOLOCK) ON LaaLapFk = LapPk AND LaaDelId = 0 AND LaaAddTyp = 0
				LEFT OUTER JOIN	LosSanction (NOLOCK) ON LsnLedFk = @LeadPk AND LsnSancNo = @sancNo
				JOIN	GenPrdMas (NOLOCK) ON PrdPk =  LsnPrdFk AND PrdDelId = 0
				JOIN	GenLvlDefn (NOLOCK) ON GrpPk = PrdGrpFk AND GrpDelId = 0
				WHERE	AppLedFk = @LeadPk AND AppDelId = 0	

			
			
			CREATE TABLE #TempCreditTable(OBL NUMERIC,IIR NUMERIC(27,2),NET_INC NUMERIC,FOIR NUMERIC(27,2),CBL NUMERIC,TENUR NUMERIC,LOAN_AMT NUMERIC,ROI NUMERIC(27,2),
						EMI NUMERIC,SPREAD NUMERIC(27,0),EST_PRP NUMERIC,ACT_PRP NUMERIC,LTV NUMERIC(27,2), ACT_LTV NUMERIC(27,2),LI NUMERIC,GI NUMERIC,ROIType VARCHAR(200),
						SHPLR NUMERIC(27,0),LOAN_LI NUMERIC, LOAN_LI_EMI NUMERIC,LOAN_GI NUMERIC, LOAN_GI_EMI NUMERIC,LOAN_LIGI NUMERIC, LOAN_LIGI_EMI NUMERIC)
				

				SELECT @WaiverROI = ISNULL(LdvDevVal,0) FROM LosDeviation (NOLOCK) 
				JOIN LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0
				WHERE  LdvLedFk = @LeadPk AND LdvDelId = 0 AND LnaCd IN ('ROI','BT_ROI')



				INSERT INTO #TempCreditTable(OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
								ACT_LTV,LI,GI,ROIType,SHPLR,LOAN_LI,LOAN_LI_EMI,LOAN_GI, LOAN_GI_EMI,LOAN_LIGI,LOAN_LIGI_EMI)
				SELECT OBL,ISNULL(IIR,0),NET_INC,ISNULL(FOIR,0),CBL,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(TENUR,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(TENUR,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(TENUR,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TENUR_TOP,0)
								ELSE TENUR
						END,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(LOAN_AMT,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_AMT,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(LOAN_AMT,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_AMT,0)
								ELSE LOAN_AMT
						END, 
						(CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(ROI,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_ROI,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(ROI,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_ROI,0)
								ELSE ROI
						END) ,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(EMI,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_EMI,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(EMI,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_EMI,0)
								ELSE EMI
						END,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(ROI -15 ,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_ROI - 15,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(ROI -15 ,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_ROI - 15,0)
								ELSE ROI -15
						END,EST_PRP,ACT_PRP,LTV,ACT_LTV,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(LI ,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_LI,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(LI ,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LI,0)
								ELSE LI
						END,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(GI ,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_GI,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(GI ,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_GI,0)
								ELSE GI
						END ,'Floating Interest Rate' 'ROIType' , 15 'SHPLR' ,
						0,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(LI_EMI ,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_LI_EMI,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(LI_EMI ,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LI_EMI,0)
								ELSE LI_EMI
						END LOAN_LI_EMI, 0, 
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(GI_EMI ,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_GI_EMI,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL( GI_EMI,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_GI_EMI,0)
								ELSE GI_EMI
						END LOAN_GI_EMI,0,
						CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(LIGI_EMI ,0)
								WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_LIGI_EMI,0)
								WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(LIGI_EMI,0)
								WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LIGI_EMI ,0)
								ELSE LIGI_EMI
						END LOAN_LIGI_EMI
				FROM 
				(
					SELECT	LnaCd 'AttrCode',LsaVal 'Value',Prdcd
					FROM	LosSanctionAttr (NOLOCK) A
					JOIN	LosSanction	S (NOLOCK) ON S.LsnPk = A.LsaLsnFk AND S.LsnDelId = 0
					JOIN	GenPrdMas G (NOLOCK) ON G.PrdPk = LsnPrdFk AND G.PrdDelId = 0
					JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LsaLnaFk AND L.LnaDelId = 0				
					WHERE	LsnRvnNo = @SancRvnNo AND  LsnSancNo = @sancNo AND A.LsaDelId = 0
							AND S.LsnLedFk = @LeadPk AND LnaCd IN ('OBL','IIR','NET_INC','FOIR','CBL','TENUR','LOAN_AMT','ROI','EMI','SPREAD','EST_PRP','ACT_PRP','LTV',
								'ACT_LTV','LI','GI','TOPUP_AMT','BT_AMT','BT_ROI','BT_EMI','TOPUP_EMI','BT_LI','TOPUP_LI','BT_GI','TOPUP_GI','TOPUP_ROI','TENUR_TOP',
								'LI_EMI','GI_EMI','LIGI_EMI','BT_LI_EMI','BT_GI_EMI','BT_LIGI_EMI','TOPUP_LI_EMI','TOPUP_GI_EMI','TOPUP_LIGI_EMI')
				)
				PIVOTTABLE
				PIVOT (MAX(Value) FOR AttrCode IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
								ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,TENUR_TOP,
								LI_EMI,GI_EMI,LIGI_EMI,BT_LI_EMI,BT_GI_EMI,BT_LIGI_EMI,TOPUP_LI_EMI,TOPUP_GI_EMI,TOPUP_LIGI_EMI))
				AS PIVOTTABLE

				IF EXISTS(SELECT 'X' FROM #TempCreditTable)
				BEGIN
					UPDATE	#TempCreditTable 
					SET		LOAN_LI = ISNULL(LOAN_AMT,0) + ISNULL(LI,0) ,
							LOAN_GI = ISNULL(LOAN_AMT,0) + ISNULL(GI,0) ,
							LOAN_LIGI = ISNULL(LOAN_AMT,0) + ISNULL(LI,0) + ISNULL(GI,0)		
				END

				-- 3 CREDIT SELECT
				--SELECT	CONVERT(VARCHAR,CONVERT(MONEY,OBL),1) OBL,IIR,CONVERT(VARCHAR,CONVERT(MONEY,OBL),1) OBL,FOIR,CBL,TENUR,
				--		CONVERT(VARCHAR,CONVERT(MONEY,LOAN_AMT),1)LOAN_AMT,ROI,CONVERT(VARCHAR,CONVERT(MONEY,EMI),1)EMI,SPREAD,
				--		CONVERT(VARCHAR,CONVERT(MONEY,EST_PRP),1)EST_PRP,CONVERT(VARCHAR,CONVERT(MONEY,ACT_PRP),1)ACT_PRP,LTV,
				--		ACT_LTV,CONVERT(VARCHAR,CONVERT(MONEY,LI),1)LI,CONVERT(VARCHAR,CONVERT(MONEY,GI),1)GI,ROIType,SHPLR ,
				--		CONVERT(VARCHAR,CONVERT(MONEY,LOAN_LI),1)LOAN_LI , CONVERT(VARCHAR,CONVERT(MONEY,LOAN_LI_EMI),1)LOAN_LI_EMI ,
				--		CONVERT(VARCHAR,CONVERT(MONEY,LOAN_GI),1)LOAN_GI , CONVERT(VARCHAR,CONVERT(MONEY,LOAN_GI_EMI),1)LOAN_GI_EMI ,
				--		CONVERT(VARCHAR,CONVERT(MONEY,LOAN_LIGI),1)LOAN_LIGI , CONVERT(VARCHAR,CONVERT(MONEY,LOAN_LIGI_EMI),1)LOAN_LIGI_EMI				
				--FROM #TempCreditTable

				SELECT	dbo.GefgCurFormat_Print(ROUND(OBL,0),@CmpFk) OBL,IIR,FOIR,CBL,TENUR,
						dbo.GefgCurFormat_Print(ROUND(LOAN_AMT,0),@CmpFk) LOAN_AMT,ROI,dbo.GefgCurFormat_Print(ROUND(EMI,0),@CmpFk)EMI,SPREAD,
						dbo.GefgCurFormat_Print(ROUND(EST_PRP,0),@CmpFk) EST_PRP,dbo.GefgCurFormat_Print(ROUND(ACT_PRP,0),@CmpFk) ACT_PRP,LTV,
						ACT_LTV,dbo.GefgCurFormat_Print(ROUND(LI,0),@CmpFk) LI,dbo.GefgCurFormat_Print(ROUND(GI,0),@CmpFk) GI,ROIType,SHPLR ,
						dbo.GefgCurFormat_Print(ROUND(LOAN_LI,0),@CmpFk) LOAN_LI , dbo.GefgCurFormat_Print(ROUND(LOAN_LI_EMI,0),@CmpFk) LOAN_LI_EMI ,
						dbo.GefgCurFormat_Print(ROUND(LOAN_GI,0),@CmpFk) LOAN_GI , dbo.GefgCurFormat_Print(ROUND(LOAN_GI_EMI,0),@CmpFk) LOAN_GI_EMI ,
						dbo.GefgCurFormat_Print(ROUND(LOAN_LIGI,0),@CmpFk) LOAN_LIGI , dbo.GefgCurFormat_Print(ROUND(LOAN_LIGI_EMI,0),@CmpFk) LOAN_LIGI_EMI				
				FROM #TempCreditTable

				-- 4 Subjective	
				SELECT ISNULL(
				STUFF((
						SELECT  RTRIM(linenum) + '.  &nbsp;&nbsp;' + ISNULL(condition,'') + '<br/>'
						FROM
						(
							SELECT  ISNULL(LscNote,'') condition , ROW_NUMBER() OVER (ORDER BY LscPreDef DESC) linenum
							FROM	LosSubjCondtion(NOLOCK) 
							JOIN	LosSanction(NOLOCK) ON LsnPk = LscLsnFk  AND LsnDelId = 0							
							WHERE	LsnLedFk = @LeadPk AND LscDelId = 0 AND LsnSancNo = @sancNo AND LsnRvnNo = @SancRvnNo
						) AS Y
						FOR XML PATH(''), ROOT('MYSTRING'),TYPE).value('/MYSTRING[1]','VARCHAR(MAX)'
					),3,1,'') ,'') AS condition					

				
				-- PF Charges
				SELECT @FinalPrdFk = LsnPrdFk FROM LosSanction(NOLOCK) WHERE LsnSancNo = @sancNo AND LsnDelid = 0
				IF ISNULL(@FinalPrdFk,0) = 0
					SET @FinalPrdFk = @PrdFk
				
				SELECT	@PfAmt = ISNULL(LpcChrg,0)
				FROM	LosProcChrg(NOLOCK) 
				JOIN	GenMas(NOLOCK) ON MasCd = 'PFPAY' AND LpcDocTyp = MasPk AND MasDelid = 0
				WHERE	LpcPrdFk = @FinalPrdFk AND LpcLedFk = @LeadPk AND LpcDelId = 0
				
				IF ISNULL(@PfAmt,0) > 0
				BEGIN
					SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Basic Template' AND PhDelid = 0
					
					INSERT INTO #ProPrcCalc 
					(
						VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
						TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
					)
					SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk, PrcPPrc,
							CASE PstcCd WHEN 'PF' THEN ISNULL(@PfAmt,0) ELSE PrcPVal END,
							PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
							PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
							ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
					FROM	GenPrcDtls (NOLOCK) 
					JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
					WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0

					EXEC PrcLosTaxValuation '', @RowId, @CmpFk

					SELECT	@PfAmt = ISNULL(FinalVal,0) FROM #ProPrcCalc(NOLOCK) WHERE CompCd = 'PFVAL'
				END
				
				SELECT  dbo.GefgCurFormat_Print(ROUND(@PfAmt,0),@CmpFk) 'PF'
			
				--Sanction Terms & Conditions
				SELECT '<h3 style="text-align:center;">MOST IMPORTANT TERMS AND CONDITIONS</h3>
						<ol type="1" style="margin:0; padding:0 20px;">
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Loan</strong></h2> 
							<p style="margin:0;">Details of the Loan Amount sanctioned, Loan Tenure, Rate of Interest, Installment Type, EMI Amount, Total no. of Installments, Installment due
							  date and Purpose of the Loan are as mentioned in the preceding section(s) of the San ction Letter.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Fees and other charges*:</strong></h2> 
							<table border="1" cellpadding="5" style="border-collapse:collapse; margin:5px 0 5px 0px; padding:0; border-color: #969696; ">
							  <tr>
								<td><p style="margin:0;">Processing fees</p></td>
								<td><p style="margin:0;">As mentioned in the preceding section(s) of Sanction Letter</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Pre-payment charges </p></td>
								<td><p style="margin:0;">Individual Borrowers - Nil Non Individual borrowers/co-borrowers - 2.00% of the balance outstanding
									at the time of foreclosure or 2.00% of the part prepayment amount. </p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Instrument return charges</p></td>
								<td><p style="margin:0;">Rs. 750/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Penalty for Instrument return - Construction Finance</p></td>
								<td><table style="background: #EBEBEB;">
									<tr>
									  <td>1st time return</td>
									  <td> Rs.5000/-</td>
									</tr>
									<tr>
									  <td>2nd time and above return</td>
									  <td> Rs.10000/-</td>
									</tr>
								  </table></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Overdue interest rate</p></td>
								<td><p style="margin:0;">30% p.a. i.e. 2.50% per month of the overdue installments / amount</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">CERSAI fees</p></td>
								<td><p style="margin:0;">Rs.50/- for loans up to 5 lacs & Rs.100/- for loans greater than 5 lacs(to be collected at the time of closure of the loan)</p></td>
							  </tr>
							  <tr>
								<td><p>Duplicate statement issuance charges</p></td>
								<td><p>Rs.250/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Duplicate statement issuance charges</p></td>
								<td><p style="margin:0;">Rs.250/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Photocopy of title deeds issuance charges</p></td>
								<td><p style="margin:0;">Rs.500/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Retrieval of title deeds</p></td>
								<td><p style="margin:0;">Rs.500/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Cheque/Instrument swap charges</p></td>
								<td><p style="margin:0;">Rs.500/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Duplicate amortization schedule issuance charges</p></td>
								<td><p style="margin:0;">Rs.250/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Duplicate interest certificate (provisional / actual) issuance charges</p></td>
								<td><p style="margin:0;">Rs.250/- per instance</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Mortgage Creation /Release Charges</p></td>
								<td><p style="margin:0;">As per the laws of the State where the property is located/ mortgage is being created.</p></td>
							  </tr>
							  <tr>
								<td><p style="margin:0;">Legal / Recovery Charges</p></td>
								<td><p style="margin:0;">As per actual, applicable in the event of default.</p></td>
							  </tr>
							</table>
							<p>*Above mentioned fees and charges are exclusive of service tax, education cess and other Government taxes, levies etc., and
							  subject to change at the sole discretion of the Shriram Housing Finance Limited. Any change in charges, would be uploaded on the
							  website or intimated to the customer by letter/email/SMS. **In case there is no bounce of installments in the initial 24 months from
							  the second month of the start of repayment, the ROI will be reduced by 50 bps. The residual tenor of the loan a/c will be adjusted
							  accordingly.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Security for the Loan:</strong></h2> 
							<p style="margin:0;">Mortgage of below mentioned property in favour of SHFL.</p>
							<table>
							  <tr>
								<td style="vertical-align:top;">Property Address :</td>
								<td>'+ @PrpAddr +'</td>
							  </tr>
							  <tr>
								<td>Guarantee :</td>
								<td>&nbsp;</td>
							  </tr>
							  <tr>
								<td>Other Security :</td>
								<td>&nbsp;</td>
							  </tr>
							</table>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Insurance of Property/Borrowers:</strong></h2> 
							<p style="margin:0;"><strong>Property Insurance:</strong> It is mandatory for the customer to obtain Property Insurance, fully insuring the property to be purchased / constructed
							  against all losses, unforeseen hazards like damages on due to fire, riots and other natural calamities like earthquake, floods etc. and if required
							  by SHFL against any other insurable risk for Home Loan / Addition Finance. Such Insurance Policy obtained by the borrower will be assigned in
							  favour of SHFL. Please refer details as mentioned in point no. 11 & 12 of terms and conditions.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Life Insurance:</strong></h2> 
							<p style="margin:0;">Borrower has the option to avail Life Insurance cover to the extent of the loan amount. The premium amount would vary depending on the age of
							  the insurer and the stage of construction of the property.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Condition for disbursement of Loan:</strong></h2> 
							<p style="margin:0;">The Loan disbursement would be subject to satisfactory compliance of all terms and conditions as stipulated in the legal opinion report, technical
							  verification report, creation of security, furnishing of r equisite statutory approvals of the property to be funded by SHFL. And in cases of
							  construction of homes, disbursement will also be based on its stage of construction.</p>
							<div class="left" style="width:45%;">
							<p style="padding:0;">Accepted</p>
							<div style="margin:15px 0;"> <span style="border-top:1px solid #969696; width:100%; display:inline-block;">(Signature or thumb impression of the Borrower/s)</span>
							</div>
						  </li>
						  <div class="clear"></div>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Procedure for intimation of the changes in rate of interest / EMI:</strong></h2> 
							<p style="margin:0;">The rate of interest is reviewed on periodic basis. In event of any change in rate of interest /EMI, SHFL will communicate the same to the
							  borrower via updating it on website/ letter/email at the last known contact details, updated in our records.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Procedure for recovery of overdue amount:</strong></h2> 
							<p style="margin:0;">In the event of non-payment of any scheduled dues to SHFL, e.g. EMIs, pre-EMIs, etc., the Borrower would receive intimation by SMS (on the
							  mobile number registered with SHFL) and/or telephonic call a nd/or letter. Such unpaid dues would need to be paid within 7 days of the originally
							  scheduled date, along with all overdue and bounce charges, as listed out under the section â€oeFees and other chargesâ€ . In the event of the dues,
							  in full or in part, remaining unpaid after 7 days, SHFL shall, at its sole discretion, initiate legal action for its recovery.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Date on which Annual Outstanding Balance Statement will be issued:</strong></h2> 
							<p style="margin:0;">SHFL shall issue a statement reflecting the Annual Outstanding Balance, before the end of the 1st quarter of the consecutive financial year.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Customer Service:</strong></h2> 
							<p style="margin:0;"><strong>a) Visiting Hour at the office :</strong> 11.00 AM till 3.30 PM on all working days (Monday to Friday)</p>
							<p style="margin:0;"><strong>b) For any other queries,</strong> you can contact us at our toll free number 1800-102-4345.</p>
							<p style="margin:0;"><strong>c) Procedure to o btain loan account statement, photocopy of the title documents, return of original documents on closure</strong></p>
							<p style="margin:0;"><strong>transfer of loan:</strong> - For obtaining any of above mentioned document borrowers are requested to provide a written request letter / appli cation along with Demand Draft / Pay order / Cheque of amount mentioned in the above schedule of charges in favour of Shriram Housing Finance
							  Limited and submit it to nearest SHFL Branch. After realization of DD / Pay order / Cheque the requested document s will be dispatched to the
							  borrower address within 3 weeks time.</p>
						  </li>
						  <li style="margin-bottom:10px;">
							<h2 style="font-size:12px; margin:0;"><strong>Grievance redressal mechanism:</strong></h2> 
							<p style="margin:0;">In a rare event of you not being satisfied with the services of SHFL, you may prefer to submit your grievances or queries, through the following
							  channels of communication:</p>
							<ul type="disc">
							  <li>Branch-Make a Complaint to respective Branch Head and it shall be recorded in Complaint Register</li>
							  <li>Call Toll Free No. â€'' 1800-102-4345</li>
							  <li>Email-contact@shriramhousing.in</li>
							  <li>Letter: Shriram Housing Finance Limited, Level 3, East Wing, Wockhardt To wers, , Bandra Kurla Complex, Mumbai 400051</li>
							</ul>
							<p>SHFL will make available facilities at each of its branches and offices for the customers to lodge and/or submit their complaints or grievances, if
							  any. Incase you are not satisfied with the initial response or do not receive a response to your complaint, from the company, you may escalate your
							  concerns to:</p>
							<strong>Grievance Redressal Officer: Mr. Sameer Shilotri</strong>
							<p style="margin:0;">Level 3, Wockhardt Towers, East Wing<br>
							  Bandra Kurla Complex, Mumbai - 40 0051<br>
							  Phone - (022) 42410400, Fax - (022) 42410422</p>
							<p>In case the response given is still unsatisfactory or is not received from the company within reasonable time (6 weeks), the customer may approach
							  NHB either through online mode at the link htt ps://grids.nhbonline.org.in or through offline mode, in prescribed format, at the following
							  address/email id:</p>
							<p><strong>National Housing Bank (Complaint Redressal Cell)</strong><br>
							  Department of Regulation and Supervision<br>
							  4th Floor, Core 5-A, India Hab itat Centre<br>
							  Lodhi Road, New Delhi - 110003<br>
							  Email Id - crcell@nhb.org.in</p>
							<p>It is hereby agreed that for detail terms and conditions of the loan, the parties hereto shall refer to and rely upon the loan and other
							  security documents executed/to be executed by them.</p>
							<p>The above terms and conditions have been read by the borrower/s/read over to the borrower by
							  Shri/Smt./Km.<span class="sign-border">&nbsp;</span> of the company and have been understood by the borrower/s.</p>
							<div class="footer" style="margin:5px 0 0 0; padding:0;">
							  <div style="width:45%; float:left;">
								<p style="padding:0;">Accepted</p>
								<div style="margin:15px 0;"> <span style="border-top:1px solid #969696; width:100%; display:inline-block;">(Signature or thumb impression of the Borrower/s)
								  <p style="padding:0;">&nbsp;</p>
								  </span>
								  <p style="padding:0;">Date :</p>
								</div>
							  </div>
							  <div style="width:45%; float:right;">
								<p>&nbsp;</p>
								<div style="margin:15px 0; padding:0; border-top:1px solid #969696; width:100%;"> <span style="display:inline-block;">
								  <p style="padding:0;">Authorised Signatory</p>
								  <p style="padding:0;">Shriram Housing Finance Limited</p>
								  </span>
								  <p style="padding:0;">Date :</p>
								</div>
							  </div>
							  <p>&nbsp;</p>
							</div>
						  </li>
						</ol>' SancTermsCond
						
						IF @GrpCd = 'LAP'
							BEGIN
								SELECT '<div id="MITC" class="container">
										<h3 style="line-height: 10px;">The following  are the additional  terms and conditions to be compiled  with by you:
										</h3>
										<ol type="1">
										<li>The borrower(s) here by agree(s) and Conforms that SHFL shall have be absolute right to levy such charges as it may deem fit including but not limited to cheque bounce/ return and any another penal for the delayed/late payment or otherwise. The Borrower(s) agree(s) that in the  event  of such a levy, The Borrower(s)  shell forthwith pay the said amount without demur or protest and that it shell not object to such levy nor claim waiver of  or make a claim or defense that the same was not brought to his/her their notice. The Borrower(s) is / are aware of the fact that it is not mandatory for SHFL to inform either advance or subsequently of the said levy and /or change in the levy or introduction of such levy. It shall be responsibility of the borrower(s) enquire or avail from SHFL the details of thereof.</li>
										<li>You will pay the EMI''s through the Post Dated Cheque (PDC) or Electronic Clearing Systems (ECS). You are required to furnish 24 PDCs   or 1 EMI Cheque and 1 Cancelled Cheque in case of ECS and the same will be replenished thereafter. You are also requested to give requisite Cheque/s   towards Pre- EMI & 3 updated Cheque not exceeding the loan amount as security Cheque.</li>
										<li>The Loan shall be used only for the Purpose for which it is sanctioned.</li>
										<li>The loan is subjected to satisfactory compliance of all terms and conditions as stipulated in the legal opinion report, the title of which should be clear and marketable given by SHFL approved lawyer.</li>
										<li>The quantum of loan will be based on a satisfactory valuation report from SHFL approved valuer.</li>
										<li>No amount shall be disbursed under the facility for Home Loan, until and unless the browser has contributed his contribution towards the purpose(s),executed the required agreements ,documents and writings and performed such other acts and deeds and created  such security as SHFL may require.</li>
										<li>The loan shall be disbursed in lump sum or in installments, as decided by SHFL, taking into consideration the needs and progress as of   construction, or the improvement, or the extension works and not necessarily as for the agreement with the builder /developer / contractor.</li>
										<li>At the time of closure all property owners in the loan have to collectively collect the little deeds.</li>
										<li>Pre-EMI interest at the rate applicable for EMI shall be changed, from the date of disbursement to the date of commencement of EMI.</li>
										<li>The rate of interest  as mentioned in this sanction letter is subjected to change in accordance with the variation in the SHPLR(Prime Lending Rate Of SHFL) and the applicable rate of interest for the loan facility shall be the one prevailing as on the date of disbursement and as mentioned in the Schedule to the Loan Agreement.</li>
										<li>Borrower(s) shall be deemed to have notice of change in rate of interest whenever the change in SHPLR is displayed /notified at/by the branch or at website.</li>
										<li>Please note that this is mandatory for the customers to obtained property Insurance. You shall fully insure the property to be purchased/constructed/against all losses. Damages on a/c of fire, riots and other hazards like earthquake, floods if required by SHFL any other insurable risk for home loan or addition Finance. Such Insurance policy obtained by the borrower   will be assigned in favor of SHFL.</li>
										<li>The borrower who have availed credit sheild, have to undergo mediacls if he falls under the grid laid down by the insurance company .Decision and medical casses is puerly on the underwriting  Decision by insurance company nad SHFL.will not be laible for any aspect of decision shared by the life insurance company. Cover on the loan  in such cases will commence only if  the life proposed for insurance ( at the loan discretion of SHFL) Undergoes the medical tests and provides acknowldgement on the underwriting decision communicated by the insurance company. All these necessary procedures to be completed prior to loan disbursement. In case  there is no response from the browser(s) on any aspect of insurance process within 45days of loan disbursement, SHFL shall have absolute rights to adjust the premium amount back to the loan and the loan will remain uncovered.</li>
										<li>The Borrower  has to submit  the insurance policy within 15days of  the Final Disbursement of the Loan Amount to SHFL. if the borrower fails to provide/submit such insuranec policy to SHFL within 15days, SHFL reserves the rigth to dibit the borrowers loan account for the insurance premium amount and obatin the insuranec policy assigned in favOr of SHFL.</li>
										<li>In the event of any change of address for communication, any change in job, profession by you or your co-borrower or at the guarantor, the same should be intimated to SHFL immediately.</li>
										<li>The property shall be maintained at all times and during the pendency of the loan if the property suffers   any loss on account of natural calamities or due to riots etc., the same should be intimated to SHFL without fail.</li>
										<li>You will ensure that the property is transferred in your name and necessary tax assessment is completed. All taxes on the property should be promptly paid.</li>
										<li>In the event of default by you, as per the clause of loan agreement, in payment of loan is installments, interests, costs etc., and loan shall be  recalled forthwith    Without any notice to yourself. Up on a demand being made on you to repay the   amount, you shall  forthwith repay the entire amount together with interests, costs and charges etc., failing which, SHFL reserves the right to seek legal remedies to recover its dues from you and guarantor.  Any ''Event Of Default ''as define under the loan agreement shall attract penal interest  @30% per annum or such other rate of interest as decided by SHFL.</li>
										<li>You will not be entitled to sell, mortgage, lease, surrender or alienate the mortgaged property, or any part thereof, during the subsistence of the mortgage without prior intimation to SHFL.</li>
										<li>The disbursement of the loan is subjected to the execution/submission of necessary documents, which forms part of the overall sanction communication from us.</li>
										<li>All stamp duty and registration charges payable in execution of loan documents and creation of charge in favor of SHFL shall be payable by the Borrower(s).</li>
										<li>Any additional cost such as payment towards meter charges, society formations, one time maintenance etc., should be paid by you directly.</li>
										<li>SHFL is entitled to add to, delete or modify all or any of the aforesaid terms and conditions.</li>
										<li>The processing fees and/or login fees are no refundable.</li>
										<li>The sanctioning of loan facility is at the sole discretion of SHFL.</li>
										<li>This sanction letter shall remain in force till the validity period mentioned in this sanction letter from date of sanction.  However, the revalidation is subject to and at the sole discretion of SHFL, on application of borrower(s).</li>
										<li>The Borrower(s) and the Guarantor(s) shall be deemed to have given their express consent to SHFL to disclose the information and data furnished by them to SHFL and also those regarding the credit facility/ties to the credit information Bureau (India) Ltd. (''CIBIL''), upon signing the copy of sanction letter. The Borrower(s) and the        Guarantor(s) further agree that they shall further execute such additional   documents as may be necessary for this purpose.</li>
										<li>SHFL also reserves the right to assign, securitize or otherwise the loan hereby agreed to be granted (or a portion thereof) to any person or a third party (''assignee'')  without any notice or consent along with or without underlying security/ties (movable or immovable) created or to be created for the benefit of SHFL and the pursuant to which the assignee shall be entitled to all or any rights and benefits under the loan and other agreements and/or the security/ties created or to be created by me/us or the guarantor.</li>
										<li>The funds lent under the additional finance facility cannot be used for investment in the capital market.</li>
										<li>The issuance of this sanction letter does not give /confer nay legal right to the Borrower(s) and the SHFL will be at the liberty or revoke or modify without assigning any reason whatsoever.</li></ol></div>
										<p>The applicant /co-applicant(s) (if any) may please sign on all pages of this sanction letter and deliver the duplicate copy of this letter in due acceptance of the above mentioned terms and conditions.</p>
										<p>We look forward to mutually beneficial and long-term relationship.</p>
										<div style="width: 50%;" class="left">
											<p>Thanking you,</p>
											<p>For Shriram Housing Finance Ltd</p>
											<p style="padding: 12px; border-bottom: 1px solid #c3b4b4;" class="sign"></p>
											<p>Authorized signatory</p>
											<p>Date:</p></div>
											<div class="footer">
										  <div style="float: right; width: 300px; text-align: center;" class="right">
											<p>Accepted</p>
										   <p style="padding: 12px; border-bottom: 1px solid #c3b4b4;" class="sign"></p>
											  <p >Applicant / co-applicant / Guarantor (if any)</p>
											  <p style="text-align: left;margin-left: 26px;" class="date">Date : </p>
											</div>
										  </div>' 'MITCCond'
										END
									ELSE 
										BEGIN 
										   SELECT '<div id="MITC" class="container">
											<h3 style="line-height: 10px;">The following  are the additional  terms and conditions to be compiled  with by you:</h3>
											<ol type="1">
											<li>The borrower(s) here by agree(s) and Conforms that SHFL shall have be absolute right to levy such charges as it may deem fit including but not limited to cheque bounce/ return and any another penal for the delayed/late payment or otherwise. The Borrower(s) agree(s) that in the  event  of such a levy, The Borrower(s)  shell forthwith pay the said amount without demur or protest and that it shell not object to such levy nor claim waiver of  or make a claim or defense that the same was not brought to his/her their notice. The Borrower(s) is/ are aware of the fact that it is not mandatory for SHFL to inform either advance or subsequently of the said levy and /or change in the levy or introduction of such levy. It shall be responsibility of the borrower(s) enquire or avail from SHFL the details of thereof.</li>
											<li>You will pay the EMI''s through the Post Dated Cheque(PDC) or Electronic Clearing Systems(ECS). You are required to furnish 24 PDCs   or 1 EMI Cheque and 1 Cancelled Cheque in case of ECS and the same will be replenished thereafter. You are also requisted to give requisite Cheque/s   towards Pre- EMI & 3 updated Cheque not exceeding the loan amount as security Cheque.</li>
											<li>The Loan shall be used only for the Purpose for which it is sanctioned.</li>
											<li>The Loan is subjected to Satisfactory Compliance of all terms and conditions as stipulated in the legal opinion report, the title of which should be clear and marketable given by SHFL approved Lawyer.</li>
											<li>The quantum of loan will be based on satisfactory valuation report from SHFL approved valuer.</li>
											<li>No amount shall be disbursed under the facility for Loan against Property Loan, until and unless the borrower(s) has executed the required agreements,   documents and writings and performed such other acts and deeds and created   such security as SHFL may require.</li>
											<li>The Loan shall be disbursed in lump sum or installments, as decides by SHFL.</li>
											<li>At the time of closure, all the property owners in the loan have to collectively collect the title deeds.</li>
											<li>The rate of interest as mentioned in the sanction letter is subject to change in accordance with the variation in the SHPLR(Prime Lending Rate of SHFL) and applicable rate if interest for the loan facility shell be the one prevailing as on the date of disbursement and as mentioned in  to schedule to the Loan Agreement.</li>
											<li>Borrower(s) shall be Deemed to have notice of change in rate of interest whenever the change in SHPLR   Displayed or notified at/by the branch or website.</li>
											<li>Please note that it is mandatory for the customer obtain Property Insurance. You all fully insure the Property to be purchased/constructed against all losses, damages a/c of fire, riots and other hazards like earthquake, floods and if required by SHFL against any other insurable risk for Loan against property-Commercial/loan for purchase of commercial  property/Takeover of existing loan with additional finance. Such insurance Policy Obtained by the borrower(s) will be assigned in favor of SHFL.</li>
											<li>The Borrower(s) has to submit the   insurance policy within 15days of the final Disbursement of the Loan Amount to SHFL. If the borrower fails to Provide/submit such insurance policy to SHFL within 15 days, SHFL reserves the right to debit the borrowers loan account for the insurance premium amount and obtain the insurance policy assigned in favor of SHFL.</li>
											<li>The borrower who have availed credit shield, have to undergo medicals if he falls under the grid laid down by the insurance company. Decision on medical cases in purely on the underwriting decision by the insurance company. Cover on the  loan in such cases will be commence only if the life proposed for insurance(at the sole discretion of SHFL) Undergoes the medical tests and provides acknowledgement on the underwriting decision communicated  by the insurance company. All this necessary procedures to be completed prior to loan disbursement. In case there is no response from the borrower(s) on any aspect of insurance process, within 45days of loan disbursement, SHFL shall have absolute rights to adjust the premium amount back to the loan and the loan will remain uncovered.</li>
											<li>If the event of any change of address for communication, any change in job, profession by you/your co-borrower or the guarantor, the same should be intimated SHFL, Immediately.</li>
											<li>The property shell we maintained at all times during the pendency of the loan if the property suffers ant loss an account of natural calamities or due riots etc. The same should be intimated to SHFL without fail.</li>
											<li>You will ensure that the property is transferred     in your name and necessary tax assessment is completed. All taxes on the property should be promptly paid.</li>
											<li>In the event of default by you, as per the clauses of loan agreement, in payment of loan installments, interests, costs etc.,    and the loan shall be recalled   forthwith   without any notice to yourself. Upon a  demand being made on you to repay the amount, You shall forthwith repay the entire amount together with interests  , costs and charges etc., failing which ,  SHFL  reserves the right to seek legal remedies to recover its dues from you and guarantor. Any ''Event of Default'' as define under the loan agreement   shall attract penal interest @30% per annum or such other rate of interest as decided by SHFL.</li>
											<li>You will not be entitled to sell, mortgage, lease, surrender or alienate or the mortgaged property, or any part thereof, during the subsistence of the mortgage without prior intimation to SHFL.</li>
											<li>The disbursement of the loan is subjected to the execution /submission of necessary documents, which forms of part of the overall sanction communication from us</li>
											<li>All stamp duty and registration charges, Payable in execution of loan documents and creation of charges in favor of SHFL shall be payable by the Borrower(s).</li>
											<li>
												SHFL is the entitled to add to, delete or modify all or any of the aforesaid terms and conditions.</li>
												<li>The processing fees and/or login fees are non refundable.</li>
												<li>The sanctioning of loan facility is at the sole discretion of SHFL.</li>
												<li>This sanction letter shall remain in force till the validity period mentioned in this sanction letter from date of sanction. However the revalidation is subject to and at the sole discretion of SHFL, on application of borrower(s).</li>
												<li>The Borrower(s) and Guarantor(s) shall be deemed to have given their express contest SHFL to disclose the information and data furnished by them to SHFL and also those regarding the credit facility/ties to the credit information Bureau (India) Ltd. (''CIBIL'') , upon signing the copy sanction letter. The Borrower(s) and Guarantor(s) further agree that they shall further execute such additional documents as may be necessary for this purpose.</li>
												<li>SHFL also reserves right to assign, or securitize or otherwise the loan here by agreed to be granted (or a portion thereof) to any person or third party (''assignee'') without any notice or consent along with or without underlying security/ties(movable or immovable) created or to be created for the benefit of SHFL and/or the security/ties created or to be created by me/ us or the guarantor.</li>
												<li>The funds lent under the facility cannot be used for the investment in the capital market.</li>
												<li>Pre closure charges will be   levied by SHFL, as decided from time to time at the sole discretion of SHFL.</li>
												<li>The insurance of this sanction letter does not give/confer any legal right to be Borrower(s) and SHFL will be at the liberty to revoke or modify without assigning any reason whatsoever</li>
												</ol>
												</div>
												<p>The applicant /co-applicant(s) (if any) may please sign on all pages of this sanction letter and deliver the duplicate copy of this letter in due acceptance of the above mentioned terms and conditions.</p>
												<p>We look forward to mutually beneficial and long-term relationship.</p>
												<div style="width: 50%;" class="left">
												<p>Thanking you,</p>
												<p class="shrm">For Shriram Housing Finance Ltd</p>
											<p style="padding: 12px; border-bottom: 1px solid #c3b4b4;" class="sign"></p>
												<p>Authorized signatory</p>
												<p>Date:</p></div>
												<div class="footer">
											  <div style="float: right; width: 300px; text-align: center;" class="right">
												<p>Accepted</p>
											 <p style="padding: 12px; border-bottom: 1px solid #c3b4b4;" class="sign"></p>
												  <p >Applicant / co-applicant / Guarantor (if any)</p>
												  <p style="text-align: left;margin-left: 26px;" class="date">Date : </p>
												</div>
											  </div>' 'MITCCond'
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


