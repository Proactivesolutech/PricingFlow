
IF OBJECT_ID('PrcShflProposalNotePrint','P') IS NOT NULL
	DROP PROCEDURE PrcShflProposalNotePrint
GO
CREATE PROC PrcShflProposalNotePrint(
	@LeadPk		BIGINT = NULL
)

AS
BEGIN
    DECLARE @Insdtls TABLE(InsNo VARCHAR(100),InsDate VARCHAR(100),CusBank VARCHAR(100),Branch VARCHAR(100),InsAmnt VARCHAR(100))
	DECLARE @Lpcnt INT = 0, @TblCnt INT = 0, @PFAmtDet VARCHAR(max), @EndUsofProp VARCHAR(250), @AppPrd VARCHAR(100),@ApSalProof TINYINT,@DEV VARCHAR(MAX) = '',
			@GrpFk BIGINT, @ColFB NUMERIC(27,2), @IsAgtTrig NUMERIC(27,2), @CmpFk BIGINT, @BrnchFk BIGINT, @LnAmt NUMERIC(27,7),@IsExistLoan CHAR(1) = 'N', @ExistLoan NUMERIC(27,7) = 0,
			@InsDet VARCHAR(MAX)

	DECLARE @PFPercent NUMERIC(27,7), @WaiverROI NUMERIC(27,7), @QryString VARCHAR(MAX), @QryCols VARCHAR(MAX)
	DECLARE @BrnchUsr VARCHAR(100), @ApprUsr VARCHAR(100), @i INT = 0, @PrpCnt INT = 1, @SanPk BIGINT,@AppDtls VARCHAR(MAX)
	DECLARE @Adddr TABLE(AdrText VARCHAR(MAX), LapFk BIGINT)
	DECLARE @SrvTyp TABLE(SrvTyp INT)
	DECLARE @PFIMC TABLE(Sts CHAR(1),Amt NUMERIC(27,2),Ord TINYINT)
	DECLARE @JobDtls TABLE(LedFk BIGINT,ApplicableTo VARCHAR(100), LajSrvTyp TINYINT, Sts VARCHAR(50), FBRmks VARCHAR(MAX))
	DECLARE @LedROI NUMERIC(27,7), @LedTenure INT, @AffordEMI NUMERIC(27,7), @X_Factor NUMERIC(27,2)
	
	CREATE TABLE #LoanDet(LedFk BIGINT , Product VARCHAR(250), PropertyType VARCHAR(100), Branch VARCHAR(150), IncScheme VARCHAR(100), CustTpe VARCHAR(50),
						ProposedLnAmt VARCHAR(500), EMI VARCHAR(200), Tenure VARCHAR(MAX),TenureNumber INT, ROI VARCHAR(500), PolicyLTV VARCHAR(MAX), ActualLTV VARCHAR(MAX),
						PolicyIIR VARCHAR(MAX), ActualIIR VARCHAR(MAX), CLIR VARCHAR(10) DEFAULT '-', PFAmtDet VARCHAR(MAX),AppliedLnAmt NUMERIC(27,0),
						NeworExist VARCHAR(20), PropUse VARCHAR(250), AffordEMI NUMERIC(27,0), PFPercent NUMERIC(27,2), IntRatType VARCHAR(5))

	CREATE TABLE #ApplDet(	ApplName VARCHAR(100), ApplRel VARCHAR(100), IncConsider VARCHAR(100), PropOwner VARCHAR(100), 
						AgeatLogin VARCHAR(100), MaturityAge  VARCHAR(100), Cibil VARCHAR(10), LapFk VARCHAR(100),Actor INT)

	--CREATE TABLE #ApplAddr(ApplicantNm VARCHAR(100),AddrTyp VARCHAR(10),Addr VARCHAR(100))

	CREATE TABLE #PropDet(Sno INT, ColOrder INT,PropCol1 VARCHAR(500), PropCol2 VARCHAR(500))

	CREATE TABLE #BankDet(BankName VARCHAR(100), AccNo VARCHAR(100), AccNm VARCHAR(100), ABB VARCHAR(100), Remarks VARCHAR(250), Actor INT)

	CREATE TABLE #ObligDet(Financer VARCHAR(100), CustNm VARCHAR(100), LnType VARCHAR(100), LnAmt NUMERIC(27,2), EMI NUMERIC(27,2), Tenure VARCHAR(50), 
						   POS BIGINT, TenureBal VARCHAR(50), EmiBounce VARCHAR(3), EmiDebitBank VARCHAR(250), Remarks  VARCHAR(250))

	CREATE TABLE #RiskDet(RiskVal VARCHAR(MAX))
	
	--CREATE TABLE #Deviation(DevVal VARCHAR(MAX))

	CREATE TABLE #RefDet(Name VARCHAR(100), ContNo VARCHAR(100), PosOrNeg VARCHAR(20), Summary VARCHAR(MAX))

	CREATE TABLE #SancConditions(Condition VARCHAR(MAX))

	CREATE TABLE #AdditionalPrpslDet(AddDet VARCHAR(MAX), Title VARCHAR(100), Cd VARCHAR(50), RNo INT)

	CREATE TABLE #TempIncomList(component VARCHAR(100),periodNm VARCHAR(100),amount NUMERIC,sumAmount NUMERIC,
						AppFk BIGINT,LapFk BIGINT,Usrname VARCHAR(200),IncomeType CHAR(5),HeadPk BIGINT,comppk BIGINT,
						CompType INT,Actor INT,incomeName VARCHAR(200),seqNo INT)
						
	CREATE TABLE #RptChk(RptNm VARCHAR(100), AppTo VARCHAR(100), IsRptRcd VARCHAR(100), RptSts VARCHAR(100), RptSrvTyp TINYINT, NegRmks VARCHAR(MAX))
	/* ---------------------------- Loan Details ----------------------------- */
	
	SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK)
	SELECT @AppPrd = B.PrdCd, @ApSalProof = A.AppSalPrf FROM LosApp A JOIN GenPrdMas B ON A.AppPrdFk = B.PrdPk WHERE A.AppLedFk = @LeadPk	
	
	IF EXISTS(SELECT 'X' FROM LosAppExistLn (NOLOCK) WHERE LelLedFk = @LeadPk AND LelDelId = 0)
		SELECT	@IsExistLoan = 'Y' , @ExistLoan = SUM(ISNULL(LelOutstandingAmt,0)) 
		FROM	LosAppExistLn (NOLOCK) WHERE LelLedFk = @LeadPk AND LelDelId = 0  

	SELECT @LnAmt = LedLnAmt, @GrpFk =  LedPGrpFk, @BrnchFk = LedBGeoFk, 
		   @LedROI = CASE WHEN CHARINDEX('-',LedROI) > 0 THEN CONVERT(NUMERIC(27,2),SUBSTRING(LedROI,0,CHARINDEX('-',LedROI,0)))/12/100
		             WHEN CHARINDEX('To',LedROI) > 0 THEN CONVERT(NUMERIC(27,2),SUBSTRING(LedROI,0,CHARINDEX('To',LedROI,0)))/12/100
				     ELSE CONVERT(NUMERIC(27,2),LedROI)/12/100 END, @LedTenure = LedTenure
	FROM LosLead(NOLOCK) WHERE LedPk = @LeadPk 	

	SET @X_Factor = POWER((1 + @LedROI), @LedTenure)
	
	SET @AffordEMI  = @LnAmt * @LedROI * ( @X_Factor / (@X_Factor - 1))
				
	INSERT INTO #LoanDet (LedFk,Product,PropertyType,Branch,IncScheme,CustTpe,AppliedLnAmt,NeworExist,PropUse,AffordEMI)
	SELECT	LedPk,ISNULL(GrpNm,'') + ' ( '+ ISNULL(PrdNm,'') +' ) ' , 
			CASE	WHEN PrpTyp = 0 THEN 'Residential'
					WHEN PrpTyp = 1 THEN 'Commercial' 
					ELSE ''
					END ,	GeoNm  ,
			ISNULL(STUFF(
			(SELECT ',' + CASE ISNULL(LioType,'') 
				WHEN 'S' THEN 'Salaried' 
				WHEN 'B' THEN 'ITR' 
				WHEN 'C' THEN 'NIP'	
				WHEN 'BK' THEN 'Banking' 
				WHEN 'OT' THEN 'Others' END
			FROM LosAppIncObl(NOLOCK) t1 where t1.LioLapFk = LP.LapPk AND t1.LioDelid = 0 FOR XML PATH('')), 1, 1, '') ,'')	
			/*	
			CASE	WHEN AppSalPrf = 0 THEN 'Income Proof Scheme'
					WHEN AppSalPrf = 1 THEN 'Non Income Proof Scheme'
					ELSE ''
			END	*/, 
			CASE	WHEN AppSalTyp = 0 THEN 'Salaried'
					WHEN AppSalTyp = 1 THEN 'Self Employed'
					ELSE ''
			END	 , ISNULL(LD.LedLnAmt,'') , CASE LapCusExs WHEN 1 THEN 'Existing Customer' ELSE 'Fresh Customer' END, '-' , 
			CONVERT(NUMERIC(27,0),@AffordEMI)
	FROM	LosLead(NOLOCK) LD 
	JOIN	LosApp (NOLOCK)		A	ON A.AppLedFk =  LD.LedPk AND A.AppDelId = 0
	JOIN	LosAppProfile(NOLOCK) LP ON A.AppPk = LP.LapAppFk AND LP.LapActor = 0 AND LP.LapDelid = 0
	JOIN	GenPrdMas (NOLOCK)	B	ON B.PrdPk = A.AppPrdFk AND B.PrdDelId = 0
	JOIN	GenLvlDefn (NOLOCK) C	ON C.GrpPk = B.PrdGrpFk AND C.GrpDelId = 0	
	LEFT JOIN	LosProp (NOLOCK)	D	ON D.PrpLedFk = A.AppLedFk AND D.PrpDelId = 0
	JOIN	GenGeoMas (NOLOCK)	E	ON E.GeoPk = A.AppBGeoFk AND E.GeoDelId = 0
	WHERE	LD.LedPk = @LeadPk AND LD.LedDelId = 0

	SELECT @WaiverROI = ISNULL(LdvDevVal,0) FROM LosDeviation (NOLOCK) 
	JOIN LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0
	WHERE  LdvLedFk = @LeadPk AND LdvDelId = 0

	UPDATE #LoanDet SET 
	PolicyIIR = CASE WHEN ISNULL(NET_INC,0) < 30000 THEN '50%' ELSE '60%' END,
	ActualIIR = CASE	WHEN  PrdCd IN ('LAPResi','LAPCom','LAPBTTopup','LAPBT','LAPTopup') THEN 
							CASE	WHEN PrdCd = 'LAPBTTopup' THEN   CAST(CONVERT(NUMERIC(5,2),BT_EMI / (NET_INC - OBL) * 100) AS VARCHAR) +  '% For BT & ' +
																	 CAST(CONVERT(NUMERIC(5,2),TOPUP_EMI / (NET_INC - OBL+BT_EMI) * 100) AS VARCHAR) +  '% For Topup '
									ELSE CAST(CAST(ISNULL(IIR,0) AS NUMERIC(27,2)) AS VARCHAR) + '%'
							END
						ELSE 
							CASE	WHEN PrdCd = 'HLBTTopup' THEN	CAST(CONVERT(NUMERIC(5,2),(BT_EMI+OBL) / NET_INC  * 100) AS VARCHAR) +  '% For BT & ' +
																	CAST(CONVERT(NUMERIC(5,2),(TOPUP_EMI+OBL+BT_EMI)/ NET_INC * 100) AS VARCHAR) +  '% For Topup '
									ELSE CAST(CAST(ISNULL(FOIR,0) AS NUMERIC(27,2)) AS VARCHAR) + '%'
							END						
						END ,
	IntRatType = CASE WHEN  PrdCd IN ('LAPResi','LAPCom','LAPBTTopup','LAPBT','LAPTopup') THEN 'IIR' ELSE 'FOIR' END,
	Tenure = CASE	WHEN PrdCd IN ('LAPBTTopup','HLBTTopup') THEN RTRIM(CONVERT(NUMERIC(27,0),TENUR)) + ' Months for BT & ' + RTRIM(CONVERT(NUMERIC(27,0),TENUR_TOP)) + ' Months for Topup'
					ELSE RTRIM(CONVERT(NUMERIC(27,0),TENUR)) + ' Months'
			 END,
	TenureNumber = TENUR,
	ProposedLnAmt = CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN RTRIM(CONVERT(NUMERIC(27,0),ISNULL(BT_AMT,0))) + ' For BT & Rs. ' + RTRIM(CONVERT(NUMERIC(27,0),ISNULL(TOPUP_AMT,0))) + ' For Topup '
						 ELSE RTRIM(CONVERT(NUMERIC(27,0),LOAN_AMT))
	END, 
	ROI = CASE	WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN RTRIM(CONVERT(NUMERIC(5,2),ISNULL(BT_ROI,0))) + '% For BT & ' +  RTRIM(CONVERT(NUMERIC(5,2),ISNULL(TOPUP_ROI,0))) + '% For Topup'
			ELSE RTRIM(CONVERT(NUMERIC(5,2),PIVOTTABLE.ROI)) 
	END,
	EMI  = CASE	WHEN  @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN RTRIM(CONVERT(NUMERIC(27,0),ISNULL(BT_EMI,0))) + ' For BT & Rs' + RTRIM(CONVERT(NUMERIC(27,0),ISNULL(TOPUP_EMI,0))) + ' For Topup'
			ELSE RTRIM(CONVERT(NUMERIC(27,0),PIVOTTABLE.EMI))
	END,
	PolicyLTV = CASE	WHEN @ApSalProof = 0 THEN
							CASE	WHEN @AppPrd IN ('HLNew','HLResale','HLPltConst','HLConst') THEN '80%' 
									WHEN @AppPrd IN ('LAPResi') THEN '60%' 
									WHEN @AppPrd IN ('LAPCom') THEN '50%' 
									WHEN @AppPrd IN ('HLBT') THEN '75%' 
									WHEN @AppPrd IN ('HLTopup') THEN '50% for Topup & 75% for combined' 
									WHEN @AppPrd IN ('HLImp','HLExt') THEN '70%'
									WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN '50% for BT , 75% for Topup & 75% for combined'
									ELSE '80%'
							END							
						WHEN @ApSalProof = 1 THEN 
						CASE	WHEN @AppPrd IN ('HLNew','HLResale','HLPltConst','HLConst') THEN '70%' 
								WHEN @AppPrd IN ('LAPResi') THEN '60%' 
									WHEN @AppPrd IN ('LAPCom') THEN '50%' 
									WHEN @AppPrd IN ('HLBT') THEN '70%' 
									WHEN @AppPrd IN ('HLTopup') THEN '50% for Topup & 70% for combined' 
									WHEN @AppPrd IN ('HLImp','HLExt') THEN '70%'
									--WHEN @AppPrd IN ('HLImp','HLExt') THEN '70%'
									WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN '50% for BT , 70% for Topup & 70% for combined'
									ELSE '80%'
						END		
				END,
	ActualLTV = CASE	WHEN @AppPrd IN ('HLTopup') THEN CAST(CAST(TOPUP_LTV_M AS NUMERIC(27,2)) AS VARCHAR) + '% for Topup & '+CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR) +'% for combined' 											
						WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN +CAST(CAST(BT_LTV_M AS NUMERIC(27,2)) AS VARCHAR)+'% for BT , '+CAST(CAST(TOPUP_LTV_M AS NUMERIC(27,2)) AS VARCHAR)+'% for Topup & '+CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR)+'% for combined'
						ELSE CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR) + '%'
				END						
	--ActualLTV = CASE	WHEN @AppPrd IN ('HLNew','HLResale','HLPltConst','HLConst') THEN CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR) + '%'
	--					WHEN @AppPrd IN ('HLBT') THEN CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR) + '%'
	--					WHEN @AppPrd IN ('HLTopup') THEN CAST(CAST(TOPUP_LTV_M AS NUMERIC(27,2)) AS VARCHAR) + '% for Topup & '+CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR) +'% for combined' 
	--					WHEN @AppPrd IN ('HLImp','HLExt') THEN CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR)						
	--					WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN +CAST(CAST(BT_LTV_M AS NUMERIC(27,2)) AS VARCHAR)+'% for BT , '+CAST(CAST(TOPUP_LTV_M AS NUMERIC(27,2)) AS VARCHAR)+'% for Topup & '+CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR)+'% for combined'
	--					ELSE CAST(CAST(LTV AS NUMERIC(27,2)) AS VARCHAR) + '%'
	--			END						
	FROM 
	(
		SELECT	LnaCd 'AttrCode',LcaVal 'Value',Prdcd
		FROM	LosCreditAttr (NOLOCK) A
		JOIN	LosCredit	S (NOLOCK) ON S.LcrPk = A.LcaLcrFk AND S.LcrDelId = 0
		JOIN	GenPrdMas G (NOLOCK) ON G.PrdPk = S.LcrPrdFk AND G.PrdDelId = 0
		JOIN	LosLnAttributes (NOLOCK) L ON L.LnaPk = A.LcaLnaFk AND L.LnaDelId = 0				
		WHERE	LcrDocRvsn = (SELECT MAX(LcrDocRvsn) FROM LosCredit(NOLOCK) WHERE LcrLedFk = @LeadPk) AND  A.LcaDelId = 0
			AND S.LcrLedFk = @LeadPk AND LnaCd IN ('OBL','IIR','NET_INC','FOIR','CBL','TENUR','TENUR_TOP','LOAN_AMT','ROI','EMI','SPREAD','EST_PRP','ACT_PRP','LTV',
				'ACT_LTV','LI','GI','TOPUP_AMT','BT_AMT','BT_ROI','BT_EMI','TOPUP_EMI','BT_LI','TOPUP_LI','BT_GI','TOPUP_GI','TOPUP_ROI','BT_LTV_M','TOPUP_LTV_M')
	)
	PIVOTTABLE
	PIVOT (MAX(Value) FOR AttrCode IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,TENUR_TOP,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
			ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,BT_LTV_M,TOPUP_LTV_M) )
	AS PIVOTTABLE  	

	SELECT @PFPercent = LpcDis
	FROM LosProcChrg (NOLOCK)
	WHERE LpcLedFk = @LeadPk AND LpcDocTyp = 5
	
	INSERT INTO  @PFIMC(Sts, Amt, Ord)
	SELECT	ISNULL(LpcChqSts,'U') 'Sts', SUM(LpcInstrAmt) 'Amt', 
			CASE ISNULL(LpcChqSts,'U') WHEN 'C' THEN 3 WHEN 'B' THEN 4 ELSE 2 END
	FROM	LosProcChrg(NOLOCK)
	WHERE	LpcLedFk = @LeadPk AND LpcDocTyp IN (3,6) AND LpcDelId = 0
	GROUP BY ISNULL(LpcChqSts,'U')
	
	INSERT INTO @PFIMC(Sts,Amt,Ord)
	SELECT 'A' , SUM(Amt), 1 FROM @PFIMC

	INSERT INTO @Insdtls(InsNo,InsDate,CusBank,Branch,InsAmnt)
    SELECT LpcInstrNo,DBO.gefgDMY(LpcInstrDt),BnkNm,BbmLoc,LpcInstrAmt 
	FROM LosProcChrg(NOLOCK)
	JOIN GenBnkMas(NOLOCK) ON BnkPk=LpcBnkFk AND BnkDelId=0
	JOIN GenBnkBrnchMas(NOLOCK) ON BbmPk=LpcBbmFk AND BbmBnkFk=BnkPk AND BbmDelId=0 
	WHERE LpcLedFk=@LeadPk AND LpcDelId=0

	SELECT @InsDet = ISNULL(@InsDet,'') + 'Instrument No-' + InsNo + '  ' +  'Dated on-' + InsDate + '  ' + 'From bank-' + CusBank + '  ' + 'Branch-' + Branch + '  ' + 'For the amount of-' + InsAmnt + '<br/>' FROM @Insdtls
	     
   --SELECT @InsDet = ISNULL(@InsDet,'') +InsNo + ' ' +  InsDate + CusBank + ' '+ Branch +  InsAmnt  FROM @Insdtls           

	SELECT @PFAmtDet = ISNULL(@PFAmtDet,'') + 
						CASE Sts WHEN 'A' THEN 'Amount Collected - ' + CONVERT(VARCHAR,Amt) + '<br/>' 
								 WHEN 'U' THEN 'Uncleared Amount - ' + CONVERT(VARCHAR,Amt) + '<br/>'
								 WHEN 'C' THEN 'Cleared Amount - ' + CONVERT(VARCHAR,Amt) + '<br/>' 
								 WHEN 'B' THEN 'Bounced Amount - ' + CONVERT(VARCHAR,Amt) + '<br/>'
						END
	FROM @PFIMC
	ORDER BY Ord
	
	SELECT @PFAmtDet = ISNULL(@PFAmtDet,'') + '<br/>'+  ISNULL(@InsDet,'') 
	


	UPDATE #LoanDet
	SET PFAmtDet = @PFAmtDet /*CAST(CAST(@PFAmtDet AS NUMERIC(27,2)) AS VARCHAR)*/, PFPercent = @PFPercent
	
	--End Use of Property
	SELECT @EndUsofProp = CASE WHEN C.Clctext ='Select' THEN '-' ELSE C.Clctext END
	FROM LosColletral A (NOLOCK)
	JOIN GenColletralAttr B (NOLOCK) ON A.LcdClaFk = B.ClaPk
	JOIN GenColletralCombo C (NOLOCK) ON B.ClaPk = C.ClcClaFk AND A.LcdVal = C.ClcVal
	WHERE A.LcdLedFk = @LeadPk AND B.ClaName = 'End Use Of Property'

	UPDATE #LoanDet
	SET PropUse = CASE ISNULL(@EndUsofProp,'-1') WHEN '-1' THEN '-' ELSE @EndUsofProp END

	DECLARE @TENURE INT , @TenureInYear INT;
	SELECT @TenureInYear = TenureNumber / 12, @TENURE  = TenureNumber FROM  #LoanDet

	-- Notes for this Print.
	INSERT INTO #AdditionalPrpslDet(AddDet,Title, Cd, RNo)
	SELECT	'<p style="max-width:795px;word-wrap: break-word;">' + LanNotes + '</p>', MasDesc, MasCd, ROW_NUMBER() OVER (ORDER BY MasSeqNo)
	FROM	LosAppNotes (NOLOCK)
	JOIN	GenMas(NOLOCK) ON LanMasFk = MasPk AND MasDelid = 0
	WHERE	LanLedFk = @LeadPk AND LanTyp = 'P' AND LanDelId = 0	
	
	SELECT @QryCols = ISNULL(@QryCols, '') + '[' + MasCd + '],' FROM GenMas(NOLOCK) WHERE MasTyp = 'P' AND MasDelid = 0 ORDER BY MasSeqNo
	
	SET @QryString = 'SELECT ''Table9'' ''TNo'',*
	FROM 
	(
	  SELECT ''<p><u><strong>'' + Title +'':- </strong></u></p>
				<table border="0" cellpadding="1" cellspacing="1" style="width:100%">
				  <tbody>
					<tr>
					  <td>''+ AddDet +''</td>
					</tr>
				  </tbody>
				</table>'' ''Content'', Cd
	  FROM #AdditionalPrpslDet
	) SRC
	PIVOT
	(
	  MAX(Content)
	  FOR Cd IN ('+ LEFT(@QryCols,(LEN(@QryCols) - 1)) +')
	) PIV;'
	
	SELECT	@IsAgtTrig = GbpVal
	FROM	GenCmpConfigHdr(NOLOCK)
	JOIN	GenBrnchPolicy(NOLOCK) ON GbpccfFk = ccfPk AND GbpBGeoFk = ISNULL(@BrnchFk,0) AND GbpGrpFk = ISNULL(@GrpFk,0)
	WHERE	ccfObjname = 'gAgtTchTrig' AND ccfDelid = 0
	
	IF @@ROWCOUNT = 0
		SELECT @IsAgtTrig = dbo.gefgGetCmpCnfgVal('gAgtTchTrig',@CmpFk)
		
	SELECT	@ColFB = GbpVal
	FROM	GenCmpConfigHdr(NOLOCK)
	JOIN	GenBrnchPolicy(NOLOCK) ON GbpccfFk = ccfPk AND GbpBGeoFk = ISNULL(@BrnchFk,0)
	WHERE	ccfObjname = 'gColFB' AND ccfDelid = 0

	IF @@ROWCOUNT = 0
		SELECT @ColFB = dbo.gefgGetCmpCnfgVal('gColFB',@CmpFk)
	
	IF @LnAmt > @IsAgtTrig 
		SELECT	@PrpCnt = COUNT(*) FROM LosProp(NOLOCK) WHERE PrpLedFk = @LeadPk AND PrpDelid = 0
	
	INSERT INTO @JobDtls(LedFk,  ApplicableTo, LajSrvTyp, Sts, FBRmks)
	SELECT		LajLedFk, CASE LajSrvTyp WHEN 3 THEN '-' ELSE ISNULL(LapFstNm,'') + ' ' + ISNULL(LapMdNm,'')  + ' ' + ISNULL(LapLstNm,'') END,
				LajSrvTyp, CASE ISNULL(LfjRptSts,99) WHEN 0 THEN 'Negative' WHEN 1 THEN 'Neutral' WHEN 2 THEN 'Positive' ELSE 'Pending' END,
				CASE ISNULL(LfjRptSts,99) WHEN 0 THEN ISNULL(NULLIF(LfjNotes,''),'-') ELSE '-' END
	FROM		LosAgentJob(NOLOCK)
	JOIN		LosAgentVerf(NOLOCK) ON LavLajFk = LajPk AND LavDelid = 0
	JOIN		LosAppProfile(NOLOCK) ON  LapPk = LavLapFk AND LapDelid = 0
	LEFT JOIN	LosAgentFBJob(NOLOCK) ON LfjLavFk = LavPk AND LfjDelid = 0
	WHERE		LajLedFk = @LeadPk AND LajDelid = 0
	
	INSERT INTO @JobDtls(LedFk, ApplicableTo, LajSrvTyp, Sts, FBRmks)
	SELECT		LajLedFk,
				CASE WHEN LajSrvTyp = 5 AND @LnAmt > @IsAgtTrig THEN 'Property ' + CAST(NTILE(@PrpCnt) OVER (PARTITION BY LajSrvTyp ORDER BY LpvPrpFk) AS VARCHAR)
					 ELSE 'Property ' + CAST(ROW_NUMBER() OVER (PARTITION BY LajSrvTyp ORDER BY LpvPrpFk) AS VARCHAR) END, LajSrvTyp,
				CASE ISNULL(LfjRptSts,99) WHEN 0 THEN 'Negative' WHEN 1 THEN 'Neutral' WHEN 2 THEN 'Positive' ELSE 'Pending' END,
				CASE ISNULL(LfjRptSts,99) WHEN 0 THEN ISNULL(NULLIF(LfjNotes,''),'-') ELSE '-' END
	FROM		LosAgentJob(NOLOCK)
	JOIN		LosAgentPrpVerf(NOLOCK) ON LpvLajFk = LajPk AND LpvDelid = 0
	LEFT JOIN	LosAgentFBJob(NOLOCK) ON LfjLpvFk = LpvPk AND LfjDelid = 0
	WHERE		LajLedFk = @LeadPk AND LajDelid = 0

	WHILE @i <= 6
		BEGIN
			INSERT INTO @SrvTyp VALUES(@i)
			SET @i = @i + 1;
		END
		
	INSERT INTO #RptChk(RptNm, AppTo, IsRptRcd, RptSts,RptSrvTyp,NegRmks)
	SELECT		CASE LajSrvTyp	WHEN 0 THEN 'Field Investigation(Residence)' 
								WHEN 1 THEN 'Field Investigation(Office)' 
								WHEN 2 THEN 'Document Verification' 
								WHEN 3 THEN 'Collection Feedback'
								WHEN 4 THEN 'Legal Verification'
								WHEN 5 THEN CASE WHEN @LnAmt > @IsAgtTrig THEN 'Technical Valuation '+ CAST(ROW_NUMBER() OVER(PARTITION BY LajSrvTyp,ApplicableTo ORDER BY LajSrvTyp) AS VARCHAR)
											ELSE 'Technical Valuation' END
				END, ApplicableTo, 'Received', Sts, LajSrvTyp, FBRmks
	FROM		@JobDtls
	
	
	INSERT INTO #RptChk(RptNm,AppTo,IsRptRcd, RptSts,RptSrvTyp,NegRmks)
	SELECT		'RCU Report', ISNULL(LapFstNm,'') + ' ' + ISNULL(LapMdNm,'')  + ' ' + ISNULL(LapLstNm,''),
				'Received', CASE ISNULL(LruRptSts,99) WHEN 1 THEN 'Negative' WHEN 2 THEN 'Neutral' WHEN 0 THEN 'Positive' ELSE 'Pending' END,
				6, CASE ISNULL(LruRptSts,99) WHEN 1 THEN ISNULL(NULLIF(LruNotes,''),'-') ELSE '-' END
	FROM		LosRCU(NOLOCK)
	JOIN		LosAppProfile(NOLOCK) ON  LapPk = LruLapFk AND LapDelid = 0
	WHERE		LruLedFk = @LeadPk AND LruDelid = 0
	
	
	INSERT INTO #RptChk(RptNm, AppTo, IsRptRcd, RptSts,RptSrvTyp,NegRmks)
	SELECT		CASE SrvTyp 	WHEN 0 THEN 'Field Investigation(Residence)' 
								WHEN 1 THEN 'Field Investigation(Office)' 
								WHEN 2 THEN 'Document Verification' 
								WHEN 3 THEN 'Collection Feedback'
								WHEN 4 THEN 'Legal Verification'
								WHEN 5 THEN 'Technical Verification'
								WHEN 6 THEN 'RCU Report'
				END, '-',
				CASE WHEN SrvTyp = 3 AND @LnAmt <= @ColFB THEN 'NA' ELSE 'Not Received' END, 
				CASE WHEN SrvTyp = 3 AND @LnAmt <= @ColFB THEN 'NA' ELSE 'Not Received' END,
				SrvTyp, '-'
	FROM		@SrvTyp
	WHERE		NOT EXISTS(SELECT 'X' FROM #RptChk WHERE SrvTyp = RptSrvTyp)

	/* ---------------------------- App Details ----------------------------- */
	
	INSERT INTO #ApplDet(ApplName,ApplRel,IncConsider,PropOwner,AgeatLogin,MaturityAge,Cibil,LapFk,Actor)
	SELECT DISTINCT	CASE	WHEN C.LapTitle = 0 THEN 'Mr. '
					WHEN C.LapTitle = 1 THEN 'Ms. '
					WHEN C.LapTitle = 2 THEN 'Mrs. '
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
			ISNULL(ROUND(RTRIM(CASE	WHEN DATEADD(YEAR, DATEDIFF (YEAR, C.LapDOB, GETDATE()), C.LapDOB) > GETDATE()
							THEN DATEDIFF(YEAR, C.LapDOB, GETDATE()) - 1
							ELSE DATEDIFF(YEAR, C.LapDOB, GETDATE()) 
					END) + @TenureInYear,0),'-')  , C.LapCibil , C.LapPk , C.LapActor
	FROM	LosLead (NOLOCK)		A
	JOIN	LosApp (NOLOCK)			B	ON B.AppLedFk = A.LedPk AND B.AppDelId = 0
	JOIN	LosAppProfile(NOLOCK)	C	ON C.LapLedFk = A.LedPk AND C.LapDelId = 0
	LEFT OUTER JOIN LosPropOwner (NOLOCK) D ON D.LpoLapFk = C.LapPk AND D.LpoDelId = 0
	LEFT OUTER JOIN	LosAppIncObl (NOLOCK) E ON E.LioLapFk = C.LapPk AND E.LioDelId = 0 AND E.LioType NOT IN ('OB') AND E.LioIncExc = 0
	WHERE	A.LedPk = @LeadPk AND A.LedDelId = 0 
	ORDER BY C.LapActor

	/* ---------------------------- Property Details ----------------------------- */	
	SELECT	DISTINCT A.LptPk, A.LptLedFk, A.LptPrpFk, 
			P.PrpDoorNo + ',' + ISNULL(P.PrpBuilding,'') + ',' + P.PrpPlotNo + ',' + ISNULL(P.PrpStreet,'') + ',' + P.PrpArea 
			+ ',' + P.PrpDistrict + ',' + P. PrpState + '-' + P.PrpPin 'Addr',
			CASE A.LptApprLandUse WHEN 0 THEN 'Residential' ELSE 'Commercial' END	+ ' ' + 
								 CASE A.LptPrpTyp WHEN 0 THEN 'Flat'
												   WHEN 1 THEN 'Plot'
												   ELSE 'Independant'
								 END 'PrpType',
			CONVERT(VARCHAR(3),A.LptConstper) +'% Completed' 'ConstStg',
			CASE A.LptPrpTyp WHEN 0 THEN ISNULL(CAST(CAST(A.LptUdsArea AS NUMERIC(27,0)) AS VARCHAR),'NA')
							 ELSE ISNULL(CAST(CAST(A.LptLandArea AS NUMERIC(27,0)) AS VARCHAR),'NA')
			END + 
			CASE A.LptPrpTyp WHEN 0 THEN 
					  CASE A.LptUdsmmt WHEN 0 THEN 'Sq Feet' WHEN 1 THEN 'Sq Yard' WHEN 2 THEN 'Sq Meter' 
									   WHEN 3 THEN 'Acre' WHEN 4 THEN 'Hectare' WHEN 5 THEN 'Ground' WHEN 6 THEN 'Cent' ELSE 'NA' END
				  ELSE CASE A.LptLandmmt WHEN 0 THEN 'Sq Feet' WHEN 1 THEN 'Sq Yard' WHEN 2 THEN 'Sq Meter' 
									    WHEN 3 THEN 'Acre' WHEN 4 THEN 'Hectare' WHEN 5 THEN 'Ground' WHEN 6 THEN 'Cent' ELSE 'NA' END
			END 'LandArea', 
			CASE A.LptPrpTyp WHEN 0 THEN ISNULL(CAST(CAST(A.LptUdsVal AS NUMERIC(27,2)) AS VARCHAR),'NA')
							 ELSE ISNULL(CAST(CAST(A.LptLandVal AS NUMERIC(27,2)) AS VARCHAR),'NA')
			END 'LandVal',
			CASE A.LptPrpTyp WHEN 1 THEN 'NA' ELSE
			ISNULL(CAST(CAST(A.LptBuldArea AS NUMERIC(27,0)) AS VARCHAR),'NA') + 
			CASE A.LptBuldmmt WHEN 0 THEN 'Sq Feet' WHEN 1 THEN 'Sq Yard' WHEN 2 THEN 'Sq Meter' 
							 WHEN 3 THEN 'Acre' WHEN 4 THEN 'Hectare' WHEN 5 THEN 'Ground' WHEN 6 THEN 'Cent' ELSE 'NA' END END 'BuldArea',
			CASE A.LptPrpTyp WHEN 1 THEN 'NA' ELSE
			ISNULL(CAST(CAST(A.LptSupBuldArea AS NUMERIC(27,0)) AS VARCHAR),'NA') + 
			CASE A.LptSupBuldmmt WHEN 0 THEN 'Sq Feet' WHEN 1 THEN 'Sq Yard' WHEN 2 THEN 'Sq Meter' 
								 WHEN 3 THEN 'Acre' WHEN 4 THEN 'Hectare' WHEN 5 THEN 'Ground' WHEN 6 THEN 'Cent' ELSE 'NA' END END 'SupBuldArea',
			CASE A.LptPrpTyp WHEN 1 THEN 'NA' ELSE
			ISNULL(CAST(CAST(A.LptCrpArea AS NUMERIC(27,0)) AS VARCHAR),'NA') + 
			CASE A.LptCrpmmt WHEN 0 THEN 'Sq Feet' WHEN 1 THEN 'Sq Yard' WHEN 2 THEN 'Sq Meter' 
								 WHEN 3 THEN 'Acre' WHEN 4 THEN 'Hectare' WHEN 5 THEN 'Ground' WHEN 6 THEN 'Cent' ELSE 'NA' END END 'CarpArea',
			A.LptMktVal 'MktVal', ISNULL(A.LptPropDtRmks,'NA') 'Rmrk',
			ISNULL(P.PrpBrnchDist,'NA') 'BrnchDist', G.AgtFName + ' ' + G.AgtMName + ' ' + G.AgtLName 'AgtNm',
			A.LptAppPlnNo 'SancNo', A.LptEstmtBuldLife 'EstmtBuildLyf',
			CASE LptDemolishRsk WHEN 0 THEN 'High'
								WHEN 1 THEN 'Medium'
								WHEN 2 THEN 'Low'
								WHEN 3 THEN 'No Risk'
								ELSE 'NA' END 'DemolishRisk' ,
			ROW_NUMBER() Over(Partition By LptPrpFk Order By LptMktVal) Rno
	INTO	#TechPropDet
	FROM	LosPropTechnical A(NOLOCK)
	JOIN	LosProp P (NOLOCK) ON A.LptPrpFk = P.PrpPk
	JOIN	GenAgents G (NOLOCK) ON A.LptAgtFk = G.AgtPk
	WHERE	A.LptLedFk = @LeadPk  AND A.LptDelId = 0


	INSERT INTO #PropDet(Sno,ColOrder,PropCol1,PropCol2)
	SELECT		ROW_NUMBER() Over(Order By LptPrpFk),1,'Property - ' + CONVERT(VARCHAR(3),ROW_NUMBER() Over(Order By LptPrpFk))+'~Title',''
	FROM		#TechPropDet  
	WHERE Rno = 1
	UNION ALL
	SELECT		ROW_NUMBER() Over(Order By LptPrpFk),2,'Address-Property', Addr
	FROM		#TechPropDet  
	WHERE Rno = 1
	UNION ALL
	SELECT		ROW_NUMBER() Over(Order By LptPrpFk),3,'Property Type', PrpType
	FROM		#TechPropDet
	WHERE Rno = 1
	UNION ALL
	SELECT		ROW_NUMBER() Over(Order By LptPrpFk),4,'Stage of Construction', ConstStg 	
	FROM		#TechPropDet
	WHERE Rno = 1	
	UNION ALL
	SELECT		ROW_NUMBER() Over(Order By LptPrpFk),5, 'Market Value',
				'Agent - ' + AgtNm  +'<br/>'+ 	 
				'Plan No - ' + ISNULL(SancNo,'-') +'<br/>'+ 	
				'Amount - ' + CONVERT(VARCHAR,CONVERT(NUMERIC(27,0),MktVal))  +'<br/>'+ 
				'Demolision Risk - ' + ISNULL(DemolishRisk,'NA') + '<br/>'+
				'Residual Age - ' + CONVERT(VARCHAR,EstmtBuildLyf) + '<br/>'+
				'Land Area - ' + REPLACE(LandArea ,'NANA','NA') +'<br/>'+
				'Built Up Area - ' + REPLACE(BuldArea ,'NANA','NA') + '<br/>'+
				'Super Built Up Area - ' + REPLACE(SupBuldArea ,'NANA','NA') +'<br/>'+ 	
				'Carpet Area - ' + REPLACE(CarpArea ,'NANA','NA') +'<br/>'								
	FROM		#TechPropDet
	WHERE Rno = 1
	UNION ALL	
	SELECT		ROW_NUMBER() Over(Order By LptPrpFk),6,'How long is the property from the Branch', BrnchDist
	FROM		#TechPropDet
	WHERE Rno = 1		
	
	/* ---------------------------- Bank Details ----------------------------- */	
	
	INSERT INTO #BankDet(BankName, AccNo, AccNm, ABB, Remarks, Actor)
	SELECT DISTINCT B.BnkNm, A.LbkAccNo, A.LbkNm, CONVERT(NUMERIC(27,2),ISNULL(A.LbkAvgBkBal,0)), 
		   CASE WHEN A.LbkNotes IS NULL THEN 'NA' WHEN A.LbkNotes = '' THEN 'NA' ELSE A.LbkNotes END,
		   C.LapActor	
	FROM LosAppBank (NOLOCK) A
	JOIN GenBnkMas (NOLOCK) B ON A.LbkBnkFk = B.BnkPk AND B.BnkDelId = 0
	JOIN LosAppProfile C(NOLOCK) ON  A.LbkAppFk = C.LapAppFk AND A.LbkLapFk = C.LapPk AND C.LapDelId = 0
	WHERE A.LbkLedFk = @LeadPk AND A.LbkDelId = 0
	ORDER BY C.LapActor

	/* ---------------------------- Obligation Details ----------------------------- */	

	INSERT INTO #ObligDet(Financer, CustNm, LnType, LnAmt, EMI, Tenure, POS, TenureBal, EmiBounce, EmiDebitBank, Remarks)
	SELECT A.LaoSrc, C.LapFstNm + CASE WHEN ISNULL(C.LapMdNm,'') <> '' THEN ' ' + C.LapMdNm ELSE ' ' END + C.LapLstNm, 
		  CASE A.LaoTyp WHEN 0 THEN 'Auto Loan' WHEN 1 THEN 'Car Loan' WHEN 2 THEN 'Twowheeler Loan'
											    WHEN 3 THEN 'Bank' WHEN 4 THEN 'Loan Against Property' WHEN 5 THEN 'Gold Loan'
											    WHEN 6 THEN 'Personal Loan' WHEN 7 THEN 'Business Loan' WHEN 8 THEN 'Term Loan'
											    WHEN 9 THEN 'Consumer Loan'  WHEN 10 THEN 'Other Loan'
		   				END,
			A.LaoLnamt, A.LaoEMI,A.LaoTenure,A.LaoOutstanding,A.LaoTenure,ISNULL(A.LaoEMIBounceNo,0),
			CASE WHEN A.LaoEMIDepBnk IS NULL THEN 'NA' WHEN A.LaoEMIDepBnk = '' THEN 'NA' ELSE A.LaoEMIDepBnk END, 
			CASE WHEN A.LaoNotes IS NULL THEN 'NA' WHEN A.LaoNotes = '' THEN 'NA' ELSE A.LaoNotes END
	FROM LosAppObl (NOLOCK) A
	JOIN LosApp (NOLOCK) B ON A.LaoAppFk = B.AppPk AND B.AppDelId = 0
	JOIN LosAppProfile (NOLOCK) C ON B.AppPk = C.LapAppFK AND A.LaoLapFK = C.LapPK AND C.LapDelId = 0
	WHERE A.LaoLedFk = @LeadPk AND A.LaoDelId = 0

	/* ---------------------------- Risk Details ----------------------------- */	

	INSERT INTO #RiskDet(RiskVal)
	SELECT CASE ISNULL(LrcTxtVal,'') WHEN 'V' THEN 'Very High Risk'
									 WHEN 'H' THEN 'High Risk' 
									 WHEN 'M' THEN 'Moderate Risk' 
									 WHEN 'L' THEN 'Low Risk' 
									 WHEN 'N' THEN 'Very Low Risk'
									 ELSE 'NA' 
			END
	FROM LosRiskCalc
	WHERE LrcLedFk = @LeadPk AND LrcParameter = 'R'

	/* ---------------------------- Deviation Details ----------------------------- */	
	
	SELECT  B.LnaCd 'DevDesc', LdvArrVal  'Val',
			CASE WHEN ISNULL(A.LdvLapFk,0) <> 0 THEN 
					  C.LapFstNm + CASE WHEN ISNULL(C.LapMdNm,'') <> '' THEN ' ' + C.LapMdNm + ' ' ELSE ' ' 
										END + C.LapLstNm 
				 ELSE '' END 'ApplNm' 
	INTO #DevDetails
	FROM LosDeviation (NOLOCK) A
	JOIN LosLnAttributes (NOLOCK) B ON A.LdvLnaFk = B.LnaPk AND B.LnaDelId = 0
	LEFT JOIN LosAppProfile (NOLOCK) C ON A.LdvLedFk = C.LapLedFk AND A.LdvLapFk = C.LapPk AND C.LapDelId = 0
	WHERE A.LdvLedFk = @LeadPk AND A.LdvDevSts = 'D' ANd A.LdvDelId = 0 AND ISNULL(A.LdvArrVal,0) <> 0

	SELECT  @DEV = @DEV + CASE WHEN ApplNm = '' THEN DevDesc + ' Deviation - ' ELSE ApplNm +'''s '+DevDesc + ' Deviation - ' END + ' ' 
			+  CASE  WHEN right(Val,1) <> '0' THEN cast(Val AS VARCHAR)  ELSE  CAST(CAST(Val AS NUMERIC(27,2)) AS VARCHAR) END + ' ' + '<br>'
	FROM #DevDetails

	/* ---------------------------- Refernce Details ----------------------------- */
	INSERT INTO #RefDet(Name, ContNo, PosOrNeg, Summary)
	SELECT LarNm,  CASE WHEN ISNULL(LarResNo,'') <> '' THEN ISNULL(LarResNo,'')  ELSE '' END +
				   CASE WHEN ISNULL(LarOffNo,'') <> ''  THEN  ','+ LarOffNo ELSE '' END +
				   CASE WHEN ISNULL(LarMobNo,'') <> ''  THEN  ','+ LarMobNo ELSE '' END, 					  					  
		   CASE LarCreditSts WHEN 0 THEN 'Negative' WHEN 2 THEN 'Positive' ELSE '-' END , 
		   CASE WHEN LarSummary IS NULL THEN 'NA' WHEN LarSummary = '' THEN 'NA' ELSE LarSummary END
	FROM LosAppRef (NOLOCK)
	WHERE LarLedFk = @LeadPk AND LarDelId = 0

	/* ---------------------------- Sanction(Subjective) Condition Details ----------------------------- */
	SELECT @SanPk = Max(LsnPk) FROM LosSanction(NOLOCK) WHERE LsnLedFk = @LeadPk AND LsnDelId = 0
	
	INSERT INTO #SancConditions(Condition)
	SELECT ISNULL(
	STUFF((
			SELECT  RTRIM(linenum) +'.  &nbsp;&nbsp;'+ ISNULL(condition,'') + '<br>'
			FROM
			(
				SELECT  ISNULL(LscNote,'') condition , ROW_NUMBER() OVER (ORDER BY LscPk) linenum
				FROM	LosSubjCondtion(NOLOCK) 
				JOIN	LosSanction(NOLOCK) ON LsnPk = LscLsnFk  AND LsnDelId = 0							
				WHERE	LsnLedFk = @LeadPk AND LscDelId = 0 AND LscPreDef = 0 AND LsnPk = @SanPk
			) AS Y
			FOR XML PATH(''), ROOT('MYSTRING'),TYPE).value('/MYSTRING[1]','VARCHAR(MAX)'
		),3,1,'') ,'')		 AS condition					
	/* ---------------------------- Applicant Address Details ----------------------------- */

	INSERT INTO @Adddr(AdrText,LapFk)
	SELECT 
			'<tr>
				<td><p>'+ CASE WHEN LaaAddTyp IN (0) THEN 'Residential Address' 
							   WHEN LaaAddTyp IN (2,3,4) THEN 'Office Address'  END +'(Owned/Rented):</p></td>
				<td>'+A.LaaDoorNo + CASE WHEN ISNULL(A.LaaBuilding,'') <> '' THEN  ',' + ISNULL(A.LaaBuilding,'') ELSE '' END + ',' + A.LaaPlotNo + 
				CASE WHEN ISNULL(A.LaaStreet,'') <> '' THEN  ',' + ISNULL(A.LaaStreet,'') ELSE '' END  + 
				CASE WHEN ISNULL( A.LaaLandmark,'') <> '' THEN  ',' + ISNULL( A.LaaLandmark,'') ELSE '' END + ',' + 
				A.LaaArea + ',' + A.LaaDistrict + ',' + A.LaaState + '-' + A.LaaPin+'</td>
			</tr>', LapPk
	FROM	LosAppAddress(NOLOCK) A
	JOIN	LosAppProfile(NOLOCK) B ON A.LaaLapFk = B.LapPk AND B.LapDelid = 0
	WHERE	A.LaaLedFk = @LeadPk AND A.LaaDelid = 0

	IF EXISTS(SELECT 'X' FROM @Adddr)
		SELECT		@AppDtls = ISNULL(@AppDtls,'') + 
					'<p> <strong> ' + 
						CASE WHEN LapActor = 0 THEN 'Applicant' 
							 WHEN LapActor = 1 THEN 'Co-Applicant' ELSE 'Gurantor' END +
						' Name : '+ B.LapFstNm + ' ' + ISNULL(B.LapMdNm,'') + ' ' + ISNULL(B.LapLstNm,'') +
					'</strong> </p>' +
					'<table border="1" cellpadding="1" cellspacing="1" style="width:100%"> <tbody>' +
					STUFF((
						SELECT AdrText
						FROM
						(
						  SELECT AdrText,LapFk FROM @Adddr
						) AS Y WHERE LapFk = LapPk
						ORDER BY LapFk
						FOR XML PATH(''), ROOT('MYSTRING'),TYPE).value('/MYSTRING[1]','VARCHAR(MAX)'
					),4,0,'') +
					'</tbody></table><br/>'
		FROM		LosAppProfile B(NOLOCK)
		WHERE		LapLedFk = @LeadPk AND LapDelid = 0
		ORDER BY	LapPk	
	/* ------------------------------- INCOME INFO SELECT --------------------------------------------- */						
	INSERT INTO #TempIncomList(component,periodNm,amount,sumAmount,AppFk,LapFk,Usrname,IncomeType,HeadPk,comppk,CompType,Actor,incomeName,seqNo)
	SELECT	 CASE	WHEN A.LioType = 'Bk' THEN 
							CASE 
								WHEN H.LcmIsTot = 1 THEN H.LcmNm
								ELSE 'On ' + H.LcmNm +'th'
							END
					ELSE H.LcmNm 
			END,
			ISNULL(CASE 
				WHEN A.LioType = 'S' THEN C.LsiMon
				WHEN A.LioType = 'B' THEN D.LbiYr
				WHEN A.LioType = 'C' THEN E.LciYr
				WHEN A.LioType = 'Bk' THEN F.LbbMon
				ELSE '-'
			END,'-'),
			ISNULL(CASE 
				WHEN A.LioType = 'S' THEN C.LsiVal
				WHEN A.LioType = 'B' THEN D.LbiVal
				WHEN A.LioType = 'C' THEN E.LciVal
				WHEN A.LioType = 'Bk' THEN F.LbbVal
				ELSE 0
			END,0) ,A.LioSumAmt ,
			A.LioAppFk ,A.LioLapFk ,ISNULL(B.LapPrefNm,'-') ,A.LioType ,A.LioPk , H.LcmPk,H.LcmTyp,B.LapActor,A.LioName,H.LcmSeq
	FROM	LosAppIncObl (NOLOCK) A
	JOIN	LosAppProfile(NOLOCK)	B ON B.LapPk = A.LioLapFk AND B.LapDelId = 0
	LEFT OUTER JOIN LosAppSalInc (NOLOCK) C ON C.LsiLioFk = A.LioPk AND C.LsiDelId = 0 AND C.LsiIncExl = 0
	LEFT OUTER JOIN LosAppBusiInc (NOLOCK) D ON D.LbiLioFk = A.LioPk AND D.LbiDelId = 0 AND D.LbiIncExl = 0
	LEFT OUTER JOIN LosAppCshInc (NOLOCK) E ON  E.LciLioFk = A.LioPk AND E.LciDelId = 0 AND E.LciIncExl = 0
	LEFT OUTER JOIN LosAppBnkBal (NOLOCK) F ON F.LbbLioFk = A.LioPk AND F.LbbDelId = 0  
	JOIN	LosComp(NOLOCK) H ON H.LcmPk = C.LsiLcmFk OR H.LcmPk = C.LsiLcmFk OR H.LcmPk = D.LbiLcmFk 
			OR H.LcmPk = E.LciLcmFk OR H.LcmPk = F.LbbLcmFk AND H.LcmDelId = 0
	WHERE	 A.LioLedFk = @LeadPk AND A.LioType NOT IN ('OB','OT')
	ORDER BY B.LapPk


	INSERT INTO #TempIncomList(component,periodNm,amount,sumAmount,AppFk,LapFk,Usrname,IncomeType,HeadPk,comppk,CompType,Actor,incomeName,seqNo)
	SELECT A.LoiDesc,
			CASE	WHEN A.LoiPeriod = 0 THEN 'Yearly'
					WHEN A.LoiPeriod = 1 THEN 'Monthly'
					ELSE ''
			END
			,A.LoiAmt,C.LioSumAmt,B.LapAppFk,B.LapPk,ISNULL(B.LapPrefNm,'-'),C.LioType,C.LioPk,NULL,NULL,B.LapActor,C.LioName,99
	FROM	LosAppOthInc (NOLOCK)  A
	JOIN	LosAppProfile (NOLOCK) B ON B.LapLedFk = A.LoiLedFk AND B.LapPk = A.LoiLapFk
	JOIN	LosAppIncObl (NOLOCK) C ON C.LioLapFk = B.LapPk AND C.LioDelId = 0 AND C.LioType = 'OT'
	WHERE	A.LoiLedFk = @LeadPk AND A.LoiDelId = 0		

	UPDATE #TempIncomList SET periodNm = 'Average' WHERE periodNm = '-1'


	CREATE TABLE #IncomeDataSet(Column1 VARCHAR(MAX),Column2 VARCHAR(MAX),Column3 VARCHAR(MAX),Column4 VARCHAR(MAX),Column5 VARCHAR(MAX),
								Column6 VARCHAR(MAX),Column7 VARCHAR(MAX),Column8 VARCHAR(MAX),Column9 VARCHAR(MAX),Column10 VARCHAR(MAX),idColumn INT IDENTITY(1,1))

	DECLARE @HeadPk BIGINT, @IncomeTable CHAR(5),@LapFk BIGINT,@Usrname VARCHAR(200),@Actor INT,@incomeName VARCHAR(200);
	DECLARE @Inc_ExecQuery  NVARCHAR(MAX), @Inc_ColumnList  VARCHAR(MAX) , @Inc_NulltoZeroCol NVARCHAR(MAX),
				@ColTitle VARCHAR(MAX);

	DECLARE @INSERT_COL NVARCHAR(MAX) , @PrevActor INT = 9;
	CREATE TABLE #PeriodTable (Period VARCHAR(200),	ID INT IDENTITY(1,1),columnNm AS 'Column'+convert(varchar,ID) PERSISTED PRIMARY KEY)


	DECLARE IncomeCursor CURSOR FOR  	
		SELECT DISTINCT HeadPk,IncomeType,LapFk,Usrname,Actor,incomeName FROM #TempIncomList
	OPEN IncomeCursor
	FETCH NEXT FROM IncomeCursor INTO @HeadPk,@IncomeTable,@LapFk,@Usrname,@Actor,@incomeName

	WHILE @@FETCH_STATUS = 0   
	BEGIN     
		TRUNCATE TABLE #PeriodTable
	
		SELECT @Inc_ColumnList = ''
	
		SET @Inc_ColumnList = STUFF(
		(
			SELECT N',' + QUOTENAME(y) AS [text()]
			FROM (
					SELECT DISTINCT periodNm AS y FROM #TempIncomList WHERE HeadPk = @HeadPk
					) AS Y
			ORDER BY y
			FOR XML PATH('')
		),1, 1, N'');


		SELECT @Inc_NulltoZeroCol = ''

		SELECT @Inc_NulltoZeroCol = SUBSTRING((SELECT ',ISNULL(['+periodNm+'],0) AS ['+periodNm+']' 
		FROM (SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average' )TAB  
		ORDER BY periodNm FOR XML PATH('')),2,8000) 			

		IF @IncomeTable <> 'OT'
			SELECT @Inc_NulltoZeroCol = 'Average,'+@Inc_NulltoZeroCol;
	
		SELECT @ColTitle = SUBSTRING((SELECT ',''' + periodNm + '~HeaderRow'''
		FROM (SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average' )TAB  
		ORDER BY periodNm FOR XML PATH('')),2,8000) 		
	
		INSERT INTO #PeriodTable
		SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average'	

		IF @IncomeTable <> 'OT'
			INSERT INTO #PeriodTable
			VALUES ('component'),('Average')
		ELSE
			INSERT INTO #PeriodTable
			VALUES ('component')
	
		SELECT @INSERT_COL = ''

		SELECT @INSERT_COL = SUBSTRING((SELECT ',' + columnNm  
		FROM (SELECT DISTINCT columnNm FROM #PeriodTable)COL_TAB  
		ORDER BY columnNm FOR XML PATH('')),2,8000) 	

		SELECT @INSERT_COL = '(' + @INSERT_COL + ')'


		IF @PrevActor <> @Actor
		BEGIN
			INSERT INTO  #IncomeDataSet(Column1)
			SELECT CASE 
					WHEN @Actor = 0 THEN 'Applicant'
					WHEN @Actor = 1 THEN 'CoApplicant'
					WHEN @Actor = 2 THEN 'Guarantor'
					ELSE '-' 
				END + '~Title'
		END

		IF @IncomeTable <> 'OT'
		BEGIN
			SELECT @Inc_ExecQuery = N'		
			INSERT INTO  #IncomeDataSet(Column1)
			SELECT '' ~Title''
			INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
			SELECT '''+ @incomeName + ' - '+ @Usrname + N'~HeaderRow'', ''Average~HeaderRow'', ' + @ColTitle + N' ;
	
			INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
			SELECT component,' + @Inc_NulltoZeroCol + N'	
			FROM	
			(		
				SELECT component,
						CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(amount,0)),1)amount,periodNm,IncomeType,HeadPk,comppk,CompType,seqNo
				FROM #TempIncomList WHERE amount > 0 AND HeadPk = ' + RTRIM(@HeadPk) + N'
			) PIVOTTABLE_INC
			PIVOT(
				MIN(amount) FOR periodNm IN ('+RTRIM(@Inc_ColumnList) + N')
			)
			AS PIVOTTABLE_INC
			ORDER BY seqNo,comppk,CompType';			
		END
		ELSE
		BEGIN
			SELECT @Inc_ExecQuery = N'		
			INSERT INTO  #IncomeDataSet(Column1)
			SELECT '' ~Title''
			INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
			SELECT '''+ @incomeName + ' - '+ @Usrname + N'~HeaderRow'',' + @ColTitle + N' ;
	
			INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
			SELECT component,' + @Inc_NulltoZeroCol + N'	
			FROM	
			(		
				SELECT component,
						CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(amount,0)),1)amount,periodNm,IncomeType,HeadPk,comppk,CompType,seqNo
				FROM #TempIncomList WHERE amount > 0 AND HeadPk = ' + RTRIM(@HeadPk) + N'
			) PIVOTTABLE_INC
			PIVOT(
				MIN(amount) FOR periodNm IN ('+RTRIM(@Inc_ColumnList) + N')
			)
			AS PIVOTTABLE_INC
			ORDER BY seqNo,comppk,CompType';	
		END

		EXEC SP_EXECUTESQL @Inc_ExecQuery			
			
		SET @PrevActor = @Actor

		FETCH NEXT FROM IncomeCursor INTO @HeadPk,@IncomeTable,@LapFk,@Usrname,@Actor,@incomeName
	END   

	CLOSE IncomeCursor   
	DEALLOCATE IncomeCursor	
			
	SELECT 'Table' 'TNo', * FROM #LoanDet
	SELECT 'Table1' 'TNo',* FROM #ApplDet	ORDER BY Actor 
	SELECT 'Table2' 'TNo',PropCol1,PropCol2 FROM #PropDet ORDER BY Sno, ColOrder
	
	SELECT 'Table3' 'TNo',BankName, AccNo, AccNm, ABB, Remarks FROM #BankDet

	IF EXISTS (SELECT TOP 1 'X' FROM #ObligDet)
	BEGIN
		SELECT 'Table4' 'TNo',* FROM #ObligDet 
	END
	ELSE
	BEGIN
		SELECT 'Table4' 'TNo','Nil~nodata' Financer, '' CustNm, '' LnType, '' LnAmt, '' EMI,  '' Tenure, 
				'' POS, '' TenureBal, '' EmiBounce, '' EmiDebitBank, '' Remarks
	END 

	IF EXISTS (SELECT TOP 1 'X' FROM #RiskDet)
	BEGIN
		SELECT 'Table5' 'TNo',ISNULL(RiskVal,'NA') RiskVal FROM #RiskDet
	END
	ELSE
	BEGIN
		SELECT 'Table5' 'TNo','NA' RiskVal 
	END

	SELECT 'Table6' 'TNo',ISNULL(@DEV,'NA') 'DevVal'

	
	IF EXISTS (SELECT TOP 1 'X' FROM #RefDet)
	BEGIN
		SELECT DISTINCT 'Table7' 'TNo',Name, CASE WHEN LEFT(ContNo,1) = ',' THEN SUBSTRING(ContNo,2,LEN(ContNo)-1) ELSE  ContNo END 'ContNo', PosOrNeg, Summary 
		FROM #RefDet
	END
	ELSE
	BEGIN
		SELECT 'Table7' 'TNo','Nil~nodata' Name, '' ContNo, '' PosOrNeg, '' Summary
	END

	SELECT 'Table8' 'TNo',ISNULL(Condition,'NA') 'Condition' FROM #SancConditions


	/* ---------------------------- Notes Details ----------------------------- */	
	IF ISNULL(@QryString,'') <> ''
		EXEC(@QryString)


	--SELECT TOP 1 'Table10' 'TNo',ISNULL(Addr,'NA') 'ResiAddr' FROM #ApplAddr WHERE LaaAddTyp IN (0,1)
	SELECT 'Table10' ,ISNULL(@AppDtls,'NA')  'AddrDtls' 
	--SELECT TOP 1 'Table11' 'TNo',ISNULL(Addr,'NA') 'OffAddr' FROM #ApplAddr WHERE LaaAddTyp IN (2,3,4)		
	SELECT	'Table12' 'TNo',ISNULL(Column1,'$~$') 'col1',ISNULL(Column2,'$~$') 'col2',ISNULL(Column3,'$~$') 'col3',ISNULL(Column4,'$~$') 'col4',ISNULL(Column5,'$~$') 'col5',
			ISNULL(Column6,'$~$') 'col6',ISNULL(Column7,'$~$') 'col7',ISNULL(Column8,'$~$') 'col8',ISNULL(Column9,'$~$') 'col9',ISNULL(Column10,'$~$') 'col10' 
	FROM #IncomeDataSet
	ORDER BY idColumn
	
	SELECT  'Table13' 'TNo',CONVERT(VARCHAR,A.LpdRptDt,105) 'PdDt', 
			CASE ISNULL(LpdNotes,'') WHEN '' THEN '' ELSE '<br/> <strong>PD Details :- </strong>' + ISNULL(LpdNotes,'') + '<br/>' END 'Notes'
	FROM LosAppPD A
	JOIN LosAppProfile B ON A.LpdLedFk = B.LapLedFk AND A.LpdAppFk = B.LapAppFk AND A.LpdLapFk = B.LapPk AND B.LapActor = 0 AND B.LapDelId = 0
	WHERE A.LpdLedFk = @LeadPk AND A.LpdDelId = 0
	
	--GenMas
	SELECT 'Table14' 'TNo',ApplName FROM #ApplDet WHERE Actor = 0
	
	SELECT	@BrnchUsr = CASE LcrDocRvsn WHEN 0 THEN LcrModifiedBy END
	FROM	LosCredit WHERE LcrDocRvsn = 0 AND LcrLedFk = @LeadPk AND LcrDelid = 0 

	SELECT	@ApprUsr = CASE WHEN LcrDocRvsn IN(2,4) THEN LcrModifiedBy END
	FROM	LosCredit WHERE LcrDocRvsn IN(2,4) AND LcrLedFk = @LeadPk AND LcrDelid = 0
	
	SELECT 'Table15' 'TNo',ISNULL(@BrnchUsr,'') 'BrnchUsr', ISNULL(@ApprUsr,'') 'ApprUsr'
	
	SELECT 'Table16' 'TNo', RptNm,AppTo,IsRptRcd,RptSts,NegRmks FROM #RptChk ORDER BY RptSrvTyp
END

