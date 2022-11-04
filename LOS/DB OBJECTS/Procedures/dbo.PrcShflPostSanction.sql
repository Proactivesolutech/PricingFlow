IF OBJECT_ID('PrcShflPostSanction','P') IS NOT NULL
	DROP PROCEDURE PrcShflPostSanction
GO
CREATE PROCEDURE PrcShflPostSanction
(
    @Action		  VARCHAR(100)		=	NULL,
	@GlobalJson	  VARCHAR(MAX)		=	NULL,
	@InsJson	  VARCHAR(MAX)		=	NULL,
	@LINomneeJson VARCHAR(MAX)		=	NULL,
	@GINomneeJson VARCHAR(MAX)		=	NULL,
	@BankDetJson  VARCHAR(MAX)		=	NULL,
	@PayDetJson   VARCHAR(MAX)		=	NULL,
	@DisbuAppr    VARCHAR(3)        =   NULL,
	@PropValDet	  VARCHAR(MAX)		=	NULL,
	@HdrJson	  VARCHAR(MAX)		=	NULL,
	@Docdet       VARCHAR(MAX)      =   NULL,
	@SellerJson	  VARCHAR(MAX)		=	NULL,
	@selPk		  VARCHAR(MAX)		=	NULL,
	@PfOvrride    CHAR(1)           =   NULL 
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	BEGIN TRY
		DECLARE @TranCount INT = 0, @ErrMsg VARCHAR(MAX), @Error INT, @ErrSeverity INT

		IF @@TRANCOUNT = 0
			SET @Trancount = 1

		IF @Trancount = 1
			BEGIN TRAN
	
		DECLARE	@LeadPk BIGINT, @GeoFk BIGINT, @UsrDispNm VARCHAR(100),@PrdFk BIGINT,@SancPk BIGINT, @AppPK BIGINT,@AgtFk BIGINT,@MaxJobNo VARCHAR(100),
				@LeadID VARCHAR(100),@lajfk BIGINT,@confirm BIGINT,@flag BIGINT, @MaxLoanNo BIGINT, @LoanNo VARCHAR(50),
				@PrdNm  VARCHAR(100), @PrdIcon VARCHAR(100), @PrdGrpFk BIGINT, @AppPrd VARCHAR(100), @ExistLnAmt NUMERIC(27,7),@ExistLnFinInst VARCHAR(100),
				@BTLnExst CHAR(1), @SancHdrPk BIGINT, @DocTypePk BIGINT, @DocNo VARCHAR(20),@UsrPk BIGINT,@Approver VARCHAR(20),@NumGenUNODB VARCHAR(100), @BrnCd VARCHAR(100),@PrdCd VARCHAR(50);

		DECLARE @CurDt DATETIME,@RowId VARCHAR(40)

		DECLARE @LIPK BIGINT, @GIPK BIGINT, @SellerPk BIGINT

		DECLARE @TaxFk BIGINT, @DocFk BIGINT,@CmpFk BIGINT, @TotPF NUMERIC(27,7), @BTPF NUMERIC(27,7), @TopupPF NUMERIC(27,7), @BalPF NUMERIC(27,7), @CollPF NUMERIC(27,7)

		CREATE TABLE #ColletralTbl	(xx_id BIGINT,LcdCltFk BIGINT,LcdClaFk BIGINT,LcdVal VARCHAR(100),UsrDispNm VARCHAR(100))

		CREATE TABLE #PSGlobalDtls
		(
			id BIGINT, LeadPk BIGINT, GeoFk BIGINT, UsrDispNm VARCHAR(100), PrdFk BIGINT,PCd VARCHAR(100),SancPk BIGINT,AgtFk BIGINT,LeadID  VARCHAR(100),
			PrdGrpFk BIGINT, SancHdrPk BIGINT, UsrPk BIGINT,Approver VARCHAR(20)
		)

		CREATE TABLE #LnCreditDet
		(
			ID BIGINT,LeadFK BIGINT, SancFK BIGINT, SancNo VARCHAR(50), LOAN_AMT NUMERIC(27, 7), TENUR NUMERIC(27, 7),ROI NUMERIC(27, 7),
			EMI NUMERIC(27, 7),LI NUMERIC(27, 7),GI NUMERIC(27, 7),BT_AMT NUMERIC(27, 7),BT_ROI NUMERIC(27, 7),BT_EMI NUMERIC(27, 7),
			BT_LI NUMERIC(27, 7),BT_GI NUMERIC(27, 7),TOPUP_AMT NUMERIC(27, 7),TOPUP_ROI NUMERIC(27, 7),TOPUP_EMI NUMERIC(27, 7),
			TOPUP_LI NUMERIC(27, 7),TOPUP_GI NUMERIC(27, 7),LTV NUMERIC(27, 7),ACT_LTV NUMERIC(27, 7),BT_LTV_A NUMERIC(27, 7),
			TOPUP_LTV_A NUMERIC(27, 7),BT_LTV_M NUMERIC(27, 7),TOPUP_LTV_M NUMERIC(27, 7), TotalPF NUMERIC(27, 7), BTPF NUMERIC(27, 7),
			TopupPF NUMERIC(27, 7),TotalPFCollected NUMERIC(27, 7), BTPFCollected NUMERIC(27, 7),
			TopupPFCollected NUMERIC(27, 7),BalPF NUMERIC(27, 7), BTPFBal NUMERIC(27, 7),
			TopupPFBal NUMERIC(27, 7), Spread NUMERIC(27, 7), TENUR_TOP NUMERIC(27, 7), Waiver_ROI NUMERIC(27, 7),
			PrdCd VARCHAR(50), PrdFK BIGINT, TotWaiverAmt NUMERIC(27,7), BTWaiverAmt NUMERIC(27,7),TopUpWaiverAmt NUMERIC(27,7),
			ColPfInstrSts Char(1) 
		)

		CREATE TABLE #InsDtls
		(
			Insrid BIGINT,LiLapFK BIGINT,LiInsurerNm VARCHAR(100),LiInsurer VARCHAR(100),LiSinJnt BIGINT,LiSumAssured BIGINT,LiPremium BIGINT,LiAddtoLn BIGINT,
			GiLapFK VARCHAR(10),GiIsurerNm VARCHAR(100),GiInsurer VARCHAR(100),GiSumAssured BIGINT,GiPremium BIGINT,GiPlcyPrd BIGINT,GiPerAccCvr BIGINT,GiAddtoLn BIGINT,
			LIPK BIGINT, GIPK BIGINT,LiInspk BIGINT,GiInspk BIGINT,psq_hdn_new BIGINT,psq_hdn_confirm BIGINT
		)

		--Nominees Details table from Page
		CREATE TABLE #NomineeDtls
		(
			NomId BIGINT, NomName VARCHAR(250), NomAge TINYINT, NomGender CHAR(2), NomRelation VARCHAR(100), 
			NomGuardian VARCHAR(250), NomGuarRel VARCHAR(100), InsType CHAR(2),NomPk BIGINT
		)

		--AppCheque Details
		Create TABLE #AppChqDet
		(
			ChqId BIGINT, Paymode CHAR(1), BnkFk BIGINT, ChqCnt TINYINT, MinChqCnt TINYINT,AppChqPK BIGINT
		)

		--PayDetails
		CREATE TABLE #Paydtls
		(
			PayID BIGINT, PayTo CHAR(1), InstruType CHAR(1), InstruAmt NUMERIC(27,2), PayInfav VARCHAR(100) ,PayPk BIGINT
		)
	
		--Seller Details 
		CREATE TABLE #SelDetails
		(
			SelID Bigint,psq_agnttype VARCHAR(20),LslNm varchar(250),LslTyp CHAR(2),LslDoorNo varchar(10),LslBuilding varchar(150),LslPlotNo varchar(20),LslStreet varchar(150),
			LslLandmark varchar(250),LslArea varchar(150),LslDistrict varchar(100),LslState varchar(100),LslPin CHAR(6), SellerPk BIGINT, BuilderCIN VARCHAR(100), PropFk BIGINT, LslSelTrig VARCHAR(10), BuilderPk BIGINT
		)

		--Property Valuation Details LosPropAstCost
		CREATE TABLE #PropValuationDet
		(
			PropId BIGINT, AgreementValue NUMERIC(27,2), RegCharge NUMERIC(27,2), StampCharge NUMERIC(27,2), AmenitiesAmt NUMERIC(27,2),LegEstimate NUMERIC(27,2),
			AssetCst NUMERIC(27,2), PropFk BIGINT, Astcstpk BIGINT
		)

		--PF Details
		CREATE TABLE #ProPrcCalc
		(
			PrdGrpFk BIGINT, PrdFk BIGINT, Qty NUMERIC(27, 7), PrcTyp TINYINT, CompCd VARCHAR(50), CompNm VARCHAR(100), CompRef BIGINT, 
			Rmks VARCHAR(250), CompPer NUMERIC(27, 7), CompVal NUMERIC(27,7 ), CompSgn INT, CompRnd TINYINT, CompTyp VARCHAR(10), 
			TreeId VARCHAR(250), RelCompNm VARCHAR(100), FinalVal NUMERIC(27, 7), xIsProc BIT,
			PrdCd VARCHAR(50), IsAccPst TINYINT, PrdSrcFk BIGINT, CompPrcTyp TINYINT, VchFk BIGINT, IsClng BIT, IsVis BIT, 
			xRowId UNIQUEIDENTIFIER, xPk BIGINT IDENTITY(1, 1), SeqNo TINYINT, DpdFk BIGINT
		)

		--Loan Details
		CREATE TABLE #LnDet
		(
			LnId BIGINT, ActualLnAmt NUMERIC(27,7), EMI NUMERIC(27,7), EMIDueDt TINYINT, FinalLnAmt NUMERIC(27,7), 
			PFAdjsted INT, PFAmt NUMERIC(27,7), BalPFAmt NUMERIC(27,7), BalPFWoutTax NUMERIC(27,7) 
		)

		CREATE TABLE #LisPK
		(
			psq_hdn_Lipk BIGINT
		)

		CREATE TABLE #GisPK
		(
			psq_hdn_Gipk BIGINT
		)

		CREATE TABLE #SelPK
		(
			psq_hdn_Sellerpk BIGINT
		)

		CREATE TABLE #DOCDTLS
		(
		DID BIGINT,Com_Doctype VARCHAR(100),Com_DoctPk BIGINT,Com_RecDate VARCHAR(100),Com_Refno VARCHAR(100),Com_Docstatus VARCHAR(100),
		Com_ValidDate VARCHAR(100),Com_rowPk BIGINT,Com_refDate VARCHAR(100),Com_notes VARCHAR(100)
		)
		CREATE TABLE #TempVerf
		(
			VerLajFk BIGINT
		)
		CREATE TABLE #LoanNoTmpTbl
		(
			LoanNo VARCHAR(100)
		)
		CREATE TABLE #DocNoTmpTbl
		(
			DocNo VARCHAR(100)
		)
		SELECT @CurDt = GETDATE(), @RowId = NEWID()	
		IF @HdrJson !='[]' AND @HdrJson != '' 
		BEGIN
			INSERT INTO #ColletralTbl				
			EXEC PrcParseJSON @HdrJson,'LcdCltFk,LcdClaFk,LcdVal,UsrDispNm'

		END
		IF @GlobalJson != '[]' AND @GlobalJson != ''
		BEGIN
			INSERT INTO #PSGlobalDtls
			EXEC PrcParseJSON @GlobalJson,'LeadFk,GeoFk,UsrDispNm,PrdFk,PrdCd,SancPk,AgtFk,LeadID,PrdGrpFk,SancHdrPk,UsrPk,Approver'
			
			SELECT	@LeadPk = A.LeadPk, @GeoFk = A.GeoFk, @UsrDispNm = A.UsrDispNm, 
					@PrdFk = B.PrdPk, @SancPk = SancPk,@AgtFk=AgtFk,@LeadID=LeadID,
					@PrdNm = B.PrdNm, @PrdIcon = B.PrdIcon, @SancHdrPk = SancHdrPk,@UsrPk=UsrPk,@Approver=Approver,@PrdCd = PrdCd

			FROM	#PSGlobalDtls A
			LEFT JOIN	GenPrdMas B(NOLOCK) ON B.PrdCd = A.PCd AND B.PrdDelid = 0			
		END

		IF @InsJson != '[]' AND @InsJson != ''
		BEGIN	
			INSERT INTO #InsDtls(Insrid ,LiLapFK ,LiInsurerNm ,LiInsurer ,LiSinJnt ,LiSumAssured ,LiPremium ,LiAddtoLn ,GiLapFK ,GiIsurerNm ,GiInsurer ,GiSumAssured ,GiPremium ,GiPlcyPrd ,GiPerAccCvr ,GiAddtoLn,LIPK,GIPK,LiInspk,GiInspk,psq_hdn_new,psq_hdn_confirm)
			EXEC PrcParseJSON @InsJson,'psq_sel_LyfInsur_Per,psq_LyfInsuredPer_Name,psq_LyfInsurerName,psq_sel_LyfInsurFor,psq_LyfInsurAmt,psq_LyfInsurPremium,psq_LyfInsur_AddtoLn,psq_sel_GenInsur_Per,psq_GenInsuredPer_Name,psq_GenInsurerName,psq_GenInsurAmt,psq_GenInsurPremium,psq_GenInsur_Period,psq_sel_AccidentCover,psq_GenInsur_AddtoLn,psq_hdn_Lipk,psq_hdn_Gipk,psq_LyfInsurerPk,psq_GenInsurerPk,psq_hdn_new,psq_hdn_confirm'			

			INSERT INTO #LnDet(LnId, ActualLnAmt, EMI, EMIDueDt,FinalLnAmt, PFAdjsted, PFAmt, BalPFAmt,BalPFWoutTax)
			EXEC PrcParseJSON @InsJson,'psq_Lnamt,psq_EmiAmt,psq_EmiDueDt,psq_hdn_finalLnAmt,psq_pfamt_DedFrmLn,psq_totpfamt,psq_balpfamt,psq_hdn_BalPF_Wout_Tax'			
		END
	
		IF @LINomneeJson != '[]' AND @LINomneeJson != ''
		BEGIN
			INSERT INTO #NomineeDtls(NomId, NomName, NomAge, NomGender, NomRelation, NomGuardian, NomGuarRel, InsType, NomPk )
			EXEC PrcParseJSON @LINomneeJson,'psq_LINomnee_Nm,psq_LINomnee_Age,psq_LINomnee_Gender,psq_LINomnee_Relation,psq_LINomnee_GuardNm,psq_LINomnee_GuardRel,psq_LINomnee_InsType,psq_LINomnee_PK'
		END

		IF @GINomneeJson != '[]' AND @GINomneeJson != ''
		BEGIN
			INSERT INTO #NomineeDtls(NomId, NomName, NomAge, NomGender, NomRelation, NomGuardian, NomGuarRel, InsType, NomPk )
			EXEC PrcParseJSON @GINomneeJson,'psq_GINomnee_Nm,psq_GINomnee_Age,psq_GINomnee_Gender,psq_GINomnee_Relation,psq_GINomnee_GuardNm,psq_GINomnee_GuardRel,psq_GINomnee_InsType,psq_GINomnee_PK'
		END

		IF @BankDetJson != '[]' AND @BankDetJson != ''
		BEGIN
			INSERT INTO #AppChqDet
			EXEC PrcParseJSON @BankDetJson,'psq_sel_PayMode,psq_sel_BankName,psq_ChqNo,psq_MinChqNo,psq_appchq_PK'
		END

		IF @PayDetJson != '[]' AND @PayDetJson != ''
		BEGIN
			INSERT INTO #Paydtls
			EXEC PrcParseJSON @PayDetJson,'psq_PayableTo,psq_InstruType,psq_InstruAmt,psq_InFavour,psq_paydet_PK'
		END

		IF @PropValDet != '[]' AND @PropValDet!= ''
		BEGIN
			INSERT INTO #PropValuationDet
			EXEC PrcParseJSON @PropValDet,'psq_aggreeValue,psq_regChrges,psq_StmpdutyChrges,psq_amenamt,psq_LegEstimate,psq_assetcst,PropFk,psq_AstCstPK'
		END


		IF @Docdet != '[]' AND @Docdet != ''
		BEGIN		
			INSERT INTO #DOCDTLS
			EXEC PrcParseJSON @Docdet,'Com_Doctype,Com_DoctPk,Com_RecDate,Com_Refno,Com_Docstatus,Com_ValidDate,Com_rowPk,Com_refDate,Com_notes'
		END

		IF @SellerJson != '[]' AND @SellerJson != ''
		BEGIN				
			INSERT INTO #SelDetails
			EXEC PrcParseJSON @SellerJson,'psq_agnttype,psq_SellerName,psq_SellerType,psq_SellerFLatNo,psq_SellerBuild,psq_SellerPlotNo,psq_SellerSt,psq_SellerLndMrk,psq_SellerTown,psq_SellerDist,psq_SellerState,psq_SellerPin,psq_hdn_Sellerpk,psq_CIN,PropFk,psq_check_agt,psq_BuilderPk'			
		END

		IF @Action='SelectRefno'
		BEGIN
				SELECT LadDocVal 'REFNO',GdmName 'DOCUMENTNAME'
				FROM  LosAppDocuments(NOLOCK)
				JOIN  GenDocuments(NOLOCK) ON GdmPk=LadGdmFk AND GdmDelId=0
				WHERE LadLedFk <> @LeadPk AND LadDelId=0 AND LadStage ='S'
		END

		ELSE IF @Action='Search-Collateral'
		  BEGIN

				SELECT * FROM GenColletral 
				WHERE CltDelId=0
				ORDER BY	CltPk DESC

					SELECT	T4.CltCd,T4.CltName,T4.CltPk,T3.ClaPk,T3.ClaName,T3.ClaCtrlTyp,ISNULL(T5.LcdLedFk,'') LcdLedFk,
							ISNULL(T5.LcdPk,'') LcdPk,ISNULL(T5.LcdVal,'') LcdVal,ISNULL(T5.LcdBGeoFk,'') LcdBGeoFk,ISNULL(T5.LcdPrdFk,'') LcdPrdFk,
							ISNULL(T5.LcdAppFk,'') LcdAppFk,ISNULL(T5.LcdLsnFk,'') LcdLsnFk ,T3.Combo_Value,T3.Combo_Text
					FROM (SELECT T2.ClaCltFk 'ClaCltFk_1',T2.ClaName,T2.ClaCtrlTyp,T2.ClaPk,T2.ClaDelId,
					Combo_Value= STUFF((SELECT ',' + ClcVal  FROM GenColletralCombo T1 WHERE T1.ClcClaFk=T2.ClaPk AND T1.ClcDelId=0 ORDER BY T1.ClcVal FOR XML PATH ('')), 1, 1, ''),
					Combo_Text = STUFF((SELECT ',' + Clctext FROM GenColletralCombo T1 WHERE T1.ClcClaFk=T2.ClaPk AND T1.ClcDelId=0 ORDER BY T1.ClcVal FOR XML PATH ('')), 1, 1, '')  
					FROM GenColletralAttr T2) T3
					INNER JOIN GenColletral T4 ON T4.CltPk=T3.ClaCltFk_1 AND T4.CltDelId=0
					LEFT JOIN LosColletral T5 ON T5.LcdLsnFk = @SancPk AND T5.LcdClaFk=T3.ClaPk AND T5.LcdDelId=0 
				ORDER BY	CltPk DESC
			
		  END 
		ELSE IF @Action = 'Load'
		BEGIN
			
			SELECT @AppPrd = B.PrdCd FROM LosApp A JOIN GenPrdMas B ON A.AppPrdFk = B.PrdPk WHERE A.AppLedFk = @LeadPk
			
			SELECT @ExistLnAmt = SUM(LelOutstandingAmt), @ExistLnFinInst = MAX(LelFinInst)
			FROM LosAppExistLn WHERE LelLedFk = @LeadPk AND LelDelId = 0

			IF (@AppPrd IN ('HLBTTopup','LAPBTTopup'))
			BEGIN
				SELECT		@BTLnExst = CASE WHEN ISNULL(LlnPk,0) <> 0 THEN 'Y' ELSE 'N' END
				FROM		LosSanction A
				JOIN		GenPrdMas B ON A.LsnPrdFk = B.PrdPk 
				LEFT JOIN	LosLoan C ON A.LsnPk = C.LlnLsnFk 
				WHERE A.LsnLedFk = @LeadPk AND B.PrdCd IN ('HLBT','LAPBT')  AND A.LsnDelId = 0
			END
		
			INSERT INTO #LnCreditDet
			EXEC PrcShflLoanDetail @LeadPk,'WithoutTax'

			SELECT  @SancPk 'SancPk', B.LedId 'psq_LeadId', A.LsnSancNo 'psq_SancNo', C.AppAppNo 'psq_AppNo', 
					CASE	WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TENUR_TOP
							ELSE D.TENUR  
					END 'psq_Tenure', 
					CASE WHEN ISNULL(S.LpsPk,0) = 0 THEN A.LsnEMIDueDt ELSE S.LpsEMIDueDt END 'psq_EmiDueDt', 
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BT_AMT
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TOPUP_AMT
							ELSE D.LOAN_AMT 
					END 'psq_Lnamt',
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BT_ROI 
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TOPUP_ROI 
							ELSE  D.ROI 
					END  'psq_ROI', 							
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') AND ISNULL(S.LpsPk,0) = 0 THEN D.BT_EMI
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') AND ISNULL(S.LpsPk,0) = 0 THEN D.TOPUP_EMI
							WHEN ISNULL(S.LpsPk,0) <> 0 THEN S.LpsEMI
							ELSE D.EMI
					END 'psq_EmiAmt', 
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BT_LI
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TOPUP_LI
							ELSE D.LI 
					END 'LiPremium', 
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BT_GI
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TOPUP_GI
							ELSE  D.GI 
					END 'GiPremium', 
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BT_LTV_M
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TOPUP_LTV_M
							WHEN P.PrdCd IN ('HLExt','HLImp') AND ISNULL(@ExistLnAmt,0) <> 0 THEN D.TOPUP_LTV_M
							ELSE D.LTV 
					END 'psq_mvltv',
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BT_LTV_A
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TOPUP_LTV_A
							ELSE D.ACT_LTV 
					END 'psq_avltv',
					D.LTV 'psq_combmvltv', D.ACT_LTV 'psq_combavltv',
					CASE WHEN  P.PrdCd IN ('HLNew','HLResale','HLPltConst','PL') THEN 'N' ELSE 'Y' END 'SellerDetHide' ,
					CASE	WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN (D.TOPUP_AMT + ISNULL(@ExistLnAmt,0))
							WHEN P.PrdCd IN ('HLExt','HLImp','HLTopup','LAPTopup') THEN (D.LOAN_AMT + ISNULL(@ExistLnAmt,0))
							ELSE D.LOAN_AMT
					END'psq_hdn_ltvlnamt',
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BTPF
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TopupPF
							ELSE D.TotalPF 
					END 'psq_totpfamt',
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BTPFCollected
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TopupPFCollected
							ELSE D.TotalPFCollected 
					END 'psq_colpfamt', 
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BTWaiverAmt
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TopUpWaiverAmt
							ELSE D.TotWaiverAmt 
					END  'psq_waiveramt',
					CONVERT(CHAR(1),S.LpsPFAdjFrmLn) 'psq_pfamt_DedFrmLn',-- ISNULL(A.LsnPFAdjstAmt,0) 'psq_Adjpfamt',
					CASE WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN @BTLnExst 
						 ELSE 'Y'
						 END 'BTLnCreated',
					ISNULL(S.LpsPk,0) 'SancHdrPk', 
					CASE	WHEN P.PrdCd IN ('HLBT','LAPBT')	   AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.BT_ROI - 15
							WHEN P.PrdCd IN ('HLTopup','LAPTopup') AND @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN D.TOPUP_ROI - 15
							ELSE  D.ROI - 15
					END 'psq_Spread', 
					'15' 'psq_Shplr', @ExistLnFinInst 'ExistLnFinInst',
					CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') THEN 'Y' ELSE 'N' END 'IsBTandTopupLn',
					ISNULL(S.LpsFinalLnAmt,0) 'psq_hdn_finalLnAmt', D.ColPfInstrSts 'PFIstrSts',
					CASE ISNULL(S.LpsOvrride,'') WHEN 'Y' THEN '0' ELSE '1' END 'psq_ovrride'
			FROM dbo.LosSanction A 
			JOIN dbo.LosLead B ON A.LsnLedFk = B.LedPk
			JOIN dbo.LosApp C ON B.LedPk = C.AppLedFk 
			JOIN #LnCreditDet D ON B.LedPk = D.LeadFK AND A.LsnPk = D.SancFK
			JOIN GenPrdMas P ON A.LsnPrdFk = P.PrdPk
			LEFT JOIN LosPostSanction S ON A.LsnLedFk = S.LpsLedFk AND A.LsnPk = S.LpsLsnFk AND S.LpsDelId = 0
			Where A.LsnLedFk = @LeadPk AND A.LsnPk = @SancPk AND LsnDelId = 0 
										
			SELECT DISTINCT B.LapPk 'LapPk', QDEFstNm +' '+ QDEMdNm+' '+QDELstNm 'CusNm',
					CASE QDEActor WHEN 0 THEN 'Applicant'
									WHEN 1 THEN 'Co-Applicant' + CONVERT(CHAR(2),QDESubActor)
									WHEN 2 Then 'Guarantor' + CONVERT(CHAR(2),QDESubActor)
					END 'ApplTyp'
			FROM dbo.LosQDE A
			JOIN dbo.LosCustomer C ON A.QdeCusFk = C.CusPk
			JOIN dbo.LosAppProfile B ON A.QDELedFk = B.LapLedFk AND A.QDEActor = B.LapActor AND C.CusPk = B.LapCusfk
			Where QDELedFK = @LeadPk AND QDEDelId = 0	
			
			IF (ISNULL(@SancHdrPk,0) = 0)
			BEGIN
				SELECT @SancHdrPk = ISNULL(LpsPk,0)
				FROM LosPostSanction 
				WHERE LpsLedFk = @LeadPk AND LpsLsnFk = @SancPk AND LpsDelId = 0
			END

			--General Insurance
			SELECT Distinct A.LisPk 'psq_hdn_Gipk', A.LisLapFk 'psq_sel_GenInsur_Per',A.LisIsurer 'psq_GenInsurerName', A.LisSumAssured 'psq_GenInsurAmt',
					A.LisPremium 'psq_GenInsurPremium', CONVERT(CHAR(1),A.LisAddtoLn) 'psq_GenInsur_AddtoLn', CONVERT(CHAR(1),A.LisPerAccCvr) 'psq_sel_AccidentCover', LisPlcyPrd 'psq_GenInsur_Period',
					B.QDEFstNm +' '+ B.QDEMdNm+' '+B.QDELstNm 'psq_GenInsuredPer_Name',A.LisInsFK 'psq_GenInsurerPk'
			FROM dbo.LosInsurance A
			JOIN dbo.LosAppProfile C ON A.LisLedFk = C.LapLedFk AND A.LisLapFk = C.LapPk AND C.LapDelId = 0
			JOIN dbo.LosQDE B ON C.LapLedFk = B.QDELedFk AND C.LapActor = B.QDEActor AND C.LapCusFk = B.QdeCusFk AND B.QDEDelId = 0
			WHERE A.LisLedFk = @LeadPk AND A.LisLsnFk = @SancPk AND A.LisLpsFk = @SancHdrPk AND A.LisTyp = 0 AND A.LisDelId = 0

			--GI Nominee Details
			SELECT A.LinNominee 'psq_GINomnee_Nm', A.LinAge 'psq_GINomnee_Age', A.LinGender 'psq_GINomnee_Gender', A.LinRelation 'psq_GINomnee_Relation', 
					A.LinGuardian 'psq_GINomnee_GuardNm', A.LinGuardianRel 'psq_GINomnee_GuardRel',A.LinPk 'psq_GINomnee_PK','GI' 'psq_GINomnee_InsType'
			FROM dbo.LosInsNominee A
			JOIN dbo.LosInsurance B ON A.LinLisFk = B.LisPk
			WHERE B.LisLedFk = @LeadPk AND B.LisLsnFk = @SancPk AND A.LinLpsFk = @SancHdrPk AND B.LisTyp = 0 AND A.LinDelId = 0
					
			--Life Insurance
			SELECT A.LisPk 'psq_hdn_Lipk', A.LisLapFk 'psq_sel_LyfInsur_Per',A.LisIsurer 'psq_LyfInsurerName', A.LisSumAssured 'psq_LyfInsurAmt', CONVERT(CHAR(1),A.LisSinJnt) 'psq_sel_LyfInsurFor',
					A.LisPremium 'psq_LyfInsurPremium', CONVERT(CHAR(1),A.LisAddtoLn) 'psq_LyfInsur_AddtoLn',
					B.QDEFstNm +' '+ B.QDEMdNm+' '+B.QDELstNm 'psq_LyfInsuredPer_Name',A.LisInsFK 'psq_LyfInsurerPk'
			FROM dbo.LosInsurance A
			JOIN dbo.LosAppProfile C ON A.LisLedFk = C.LapLedFk AND A.LisLapFk = C.LapPk AND C.LapDelId = 0
			JOIN dbo.LosQDE B ON C.LapLedFk = B.QDELedFk AND C.LapActor = B.QDEActor  AND  C.LapCusFk = B.QdeCusFk AND B.QDEDelId = 0
			WHERE A.LisLedFk = @LeadPk AND A.LisLsnFk = @SancPk AND A.LisLpsFk = @SancHdrPk AND A.LisTyp = 1 AND A.LisDelId = 0

			--Life Nominee Details
			SELECT A.LinNominee 'psq_LINomnee_Nm', A.LinAge 'psq_LINomnee_Age', A.LinGender 'psq_LINomnee_Gender', A.LinRelation 'psq_LINomnee_Relation', 
					A.LinGuardian 'psq_LINomnee_GuardNm', A.LinGuardianRel 'psq_LINomnee_GuardRel',A.LinPk 'psq_LINomnee_PK','LI' 'psq_LINomnee_InsType'						   
			FROM dbo.LosInsNominee A
			JOIN dbo.LosInsurance B ON A.LinLisFk = B.LisPk
			WHERE B.LisLedFk = @LeadPk AND B.LisLsnFk = @SancPk AND A.LinLpsFk = @SancHdrPk AND B.LisTyp = 1 AND A.LinDelId = 0

			--Lead Bank Details
			SELECT A.LbkPk 'LbkPk', B.BnkNm 'BankName', C.BbmIFSC 'Ifsc', LbkAccNo 'AccNo'
			FROM dbo.LosAppBank A
			JOIN dbo.GenBnkMas B ON A.LbkBnkFk = B.BnkPk AND B.BnkDelId = 0
			JOIN dbo.GenBnkBrnchMas C ON B.BnkPk = C.BbmBnkFk AND A.LbkBbmFk = C.BbmPk AND C.BbmDelId = 0
			WHERE LbkLedFk = @LeadPk AND LbkDelid = 0

			--AppCheque Details
			SELECT A.LcqPayMode 'psq_sel_PayMode',A.LcqLbkFk 'psq_sel_BankName', A.LcqChqCnt 'psq_ChqNo',A.LcqPk 'psq_appchq_PK',
				   E.BbmIFSC 'psq_IfscCode', C.LbkAccNo 'psq_AccNo', ISNULL(A.LcqMinChqCnt,0) 'psq_MinChqNo'
			FROM dbo.LosAppCheque A
			--JOIN dbo.LosSanction B ON A.LcqLsnFk = B.LsnPk 
			JOIN dbo.LosPostSanction B ON A.LcqLpsFk = B.LpsPk AND A.LcqLsnFk = B.LpsLsnFk 
			JOIN dbo.LosAppBank C ON A.LcqLbkFk = C.LbkPk
			JOIN dbo.GenBnkMas D ON C.LbkBnkFk = D.BnkPk AND D.BnkDelId = 0
			JOIN dbo.GenBnkBrnchMas E ON D.BnkPk = E.BbmBnkFk AND C.LbkBbmFk = E.BbmPk AND E.BbmDelId = 0
			WHERE B.LpsLedFk = @LeadPk AND B.LpsLsnFk = @SancPk AND B.LpsPk = @SancHdrPk AND B.LpsDelId = 0 AND A.LcqDelId = 0

			--PayDetails
			SELECT   A.LpdPayTo 'psq_PayableTo', A.LpdAmt 'psq_InstruAmt', A.LpdInsTyp 'psq_InstruType', A.LpdPk 'psq_paydet_PK',
			CASE WHEN   A.LpdPayTo = 'S' OR A.LpdPayTo = 'B' THEN A.LpdInFav END 'psq_InFavour_seller',
			CASE WHEN   A.LpdPayTo = 'G' OR A.LpdPayTo = 'L' OR A.LpdPayTo = 'C' OR A.LpdPayTo = 'F' OR A.LpdPayTo = 'O' THEN A.LpdInFav END 'psq_InFavour'			
			FROM dbo.LosPayDtls A
			--JOIN dbo.LosSanction B ON A.LpdLsnFk = B.LsnPk
			JOIN dbo.LosPostSanction B ON A.LpdLpsFk = B.LpsPk AND A.LpdLsnFk = B.LpsLsnFk 
			WHERE B.LpsLedFk = @LeadPk AND B.LpsLsnFk = @SancPk AND B.LpsPk = @SancHdrPk AND B.LpsDelId = 0 AND A.LpdDelId = 0

			--Seller Details
			SELECT	A.LslNm 'psq_SellerName',A.LslTyp 'psq_SellerType',A.LslDoorNo 'psq_SellerFLatNo',A.LslBuilding 'psq_SellerBuild',
					A.LslPlotNo 'psq_SellerPlotNo',A.LslStreet 'psq_SellerSt',A.LslLandmark 'psq_SellerLndMrk',A.LslArea 'psq_SellerTown',
					A.LslDistrict 'psq_SellerDist',A.LslState 'psq_SellerState',A.LslPin 'psq_SellerPin',A.LslPk 'psq_hdn_Sellerpk', 
					A.LslAgtFk 'psq_agnttype', A.LslBuilderCIN 'psq_CIN', A.LslPrpFK 'PropFk', ISNULL(LslGbmFk,'') 'psq_BuilderPk' ,
					CASE WHEN A.LslSelTrig = 'Y' THEN '0'ELSE '1' END 'psq_check_agt', B.AgtFName + ' ' + B.AgtMName + ' ' + B.AgtLName 'AgtName'					
			FROM	dbo.LosSeller A(NOLOCK)	
			LEFT JOIN	GenAgents B(NOLOCK) ON B.AgtPk = A.LslAgtFk			
			WHERE	LslLedFk = @LeadPk AND LslDelId = 0 
			ORDER BY LslPrpFK

			--Agents details
				SELECT	AgtFName 'firstnm', AgtMName 'midnm' ,  AgtLName  'lname',AgtPk 'AgtPk' 
				FROM	GenAgents (NOLOCK) 
				WHERE	AgtDelId = 0

			--Property Details
			SELECT	LptPk, LptLedFk, LptPrpFk, ROW_NUMBER() Over(Partition By LptPrpFk Order By LptMktVal) Rno
			INTO	#TechPropDet
			FROM	LosPropTechnical (NOLOCK)
			WHERE	LptLedFk = @LeadPk  AND LptDelId = 0

			SELECT		A.LptMktVal 'psq_mktval',A.LptPrpValRmks 'psq_propremarks',A.LptPrpTyp 'psq_proptyp',
						A.LptDemolishRsk 'psq_demolrisk',A.LptUdsArea 'psq_UDSarea',A.LptUdsmmt 'psq_udsmmt',A.LptUdsVal 'psq_UDSval',
						A.LptSupBuldArea 'psq_supbuildarea',A.LptSupBuldmmt 'psq_supbuildmmt',A.LptBuldArea 'psq_buildarea',A.LptBuldmmt 'psq_buildupmmt',
						A.LptCrpArea 'psq_carpetarea',A.LptCrpmmt 'psq_carpetmmt',A.LptEstmt 'psq_estimate',ISNULL(CONVERT(Varchar,C.LplOwnTyp),'-1') 'psq_ownertype',
						A.LptPossessTyp 'psq_possessiontyp',A.LptSurvNo 'psq_surveyno',A.LptLocTyp 'psq_loctyp',A.LptApprLandUse 'psq_landuse',
						A.LptApprAuth 'psq_apprauth',A.LptBuildApprAuth 'psq_buildapprauth',A.LptPropDtRmks 'psq_prpdtlsremarks',A.LptBuldAge 'psq_buildingage',A.LptEstmtBuldLife 'psq_estimatebuilding',
						A.LptStructTyp 'psq_structyp',A.LptFloorNo 'psq_nooffloor',A.LptConstPer 'psq_construction',A.LptConstRmks 'psq_constremarks',
						A.LptLandArea 'psq_landarea',A.LptLandVal 'psq_landvalue',A.LptLandmmt 'psq_landmmt',A.LptLeasePer 'psq_leasepriod', A.LptPk 'psq_prptechPk',
						A.LptDistressAmt 'psq_distressval', ISNULL(CONVERT(Varchar,A.LptMumty),'-1')'psq_mumty', A.LptOccupSts 'psq_propoccupy',
						ISNULL(B.PacAgrmtVal,0) 'psq_aggreeValue', ISNULL(B.PacAstCost,0) 'psq_assetcst', ISNULL(B.PacRegChg,0) 'psq_regChrges', 
						ISNULL(B.PacStmpChg,0) 'psq_StmpdutyChrges', ISNULL(B.PacAmen,0) 'psq_amenamt', ISNULL(B.PacEstimate,0) 'psq_LegEstimate',
						ISNULL(B.PacPk,0) 'psq_AstCstPK', ISNULL(A.LptAppPlnNo,'') 'psq_apprvalplanno',A.LptPrpFk 'psq_PrpFK'
			FROM		#TechPropDet T
			JOIN		LosPropTechnical A (NOLOCK) ON T.LptPk = A.LptPk AND T.LptPrpFk = A.LptPrpFk AND T.Rno = 1
			LEFT JOIN   LosPropLegal C (NOLOCK) ON A.LptPrpFk = C.LplPrpFk 
			LEFT JOIN	LosPropAstCost B (NOLOCK) ON A.LptLedFk = B.PacLedFk AND A.LptPrpFk = B.PacPrpFk AND B.PacDelId = 0
			Order BY	A.LptPrpFk

			--Product Code & Icon Details
			SELECT @PrdNm 'PrdNm', @PrdIcon 'PrdIcon'	
			
			
			--Documents Details
			SELECT   LadDocTyp 'Com_Doctype', LadGdmFk 'Com_DoctPk',DBO.gefgDMY(LadRcvdDt) 'Com_RecDate',LadDocVal 'Com_Refno',
			        case when LadDocSts= '' then '-1' else LadDocSts end  'Com_Docstatus',DBO.gefgDMY(LadValidUpto) 'Com_ValidDate',LadPk 'Com_rowPk',GdmName 'Com_Docname',
					  LadRmks 'Com_notes',DBO.gefgDMY(LadRefDt) 'Com_refDate'
			FROM     LosAppDocuments(NOLOCK)
			JOIN     GenDocuments(NOLOCK) ON GdmPk=LadGdmFk AND GdmDelId=0
		    WHERE	 LadLedFk=@LeadPk AND LadDelId=0 AND LadStage ='S'		

			-- SELECT MAX APPROVER LEVEL
			SELECT	ISNULL(MAX(LdvAppBy),1) 'MaxApproverLevel'
			FROM	LosDeviation (NOLOCK)
			WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 AND LdvIsApp IS NULL

		END

		ELSE IF @Action = 'Save'
		BEGIN
			Select @AppPK = AppPk
			FROM dbo.LosApp
			Where AppLedFk = @LeadPk

			SELECT @DocTypePk = MasPk FROM GenMas WHERE MasCd = 'PS'

			SELECT	@NumGenUNODB = CmpUNODB + '.dbo.GetGenNumForLOS'
			FROM	GenCmpMas(NOLOCK)

			--SELECT	@BrnCd =  GeoCd FROM GenGeoMas(NOLOCK) 
			--JOIN	LosLead(NOLOCK) ON LedBGeoFk = GeoPk AND LedDelId = 0
			--WHERE	LedPk = @LeadPk		
						
			SELECT	@BrnCd =  GeoCd FROM GenGeoMas(NOLOCK) 					
			WHERE	GeoPk = @GeoFk

			INSERT INTO #DocNoTmpTbl(DocNo)
			EXEC @NumGenUNODB 'Proposal',@BrnCd,'ADMIN',null,null,'P' --> For Proposal						

			SELECT @DocNo = DocNo FROM #DocNoTmpTbl

			--SELECT @DocNo = CASE DfgLstNo WHEN 0 THEN DfgPrefix + RIGHT('00000' + CONVERT(VARCHAR(3),DfgStartNo),6) 
			--									 ELSE DfgPrefix + RIGHT('00000' + CONVERT(VARCHAR(3),(DfgLstNo + 1)),6) 
			--				END
			--FROM GenDocCtrlConfig A
			--JOIN GenMas B ON A.DfgDocTypFk = B.MasPk 
			--WHERE A.DfgBGeoFk = 52 AND B.MasCd = 'PS' AND A.DfgDelId = 0 AND B.MasDelId = 0 

			--Post Sanction Header
			IF(@SancHdrPk = 0)
			BEGIN
				INSERT INTO LosPostSanction(LpsLedFk,LpsBGeoFk,LpsPrdFk,LpsAppFk,LpsLsnFk,LpsDocTypFk,LpsDocNo,LpsDocDt,LpsEMIDueDt,LpsEMI,LpsLnAmt,LpsFinalLnAmt,
											LpsPFAdjFrmLn,LpsPFAdjAmt,LpsRowId,LpsCreatedBy,LpsCreatedDt,LpsModifiedBy,LpsModifiedDt,LpsDelFlg,LpsDelId,LpsDocSts)
				SELECT @LeadPk, @GeoFk, @PrdFk, @AppPK, @SancPk, @DocTypePk, @DocNo, GETDATE(), EMIDueDt, EMI, ActualLnAmt, FinalLnAmt,
					   CONVERT(CHAR(1),PFAdjsted), BalPFAmt, @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, 0, 0,@Approver
				FROM #LnDet				

				SELECT @SancHdrPk = SCOPE_IDENTITY()

				UPDATE GenDocCtrlConfig
				SET DfgLstNo = DfgLstNo + 1
				FROM GenDocCtrlConfig A
				JOIN GenMas B ON A.DfgDocTypFk = B.MasPk 
				WHERE A.DfgBGeoFk = 1 AND B.MasCd = 'PS' AND A.DfgDelId = 0 AND B.MasDelId = 0 
			END
			ELSE
			BEGIN
				UPDATE LosPostSanction
				SET LpsEMIDueDt = EMIDueDt, LpsEMI = EMI, LpsFinalLnAmt = FinalLnAmt,
					LpsPFAdjFrmLn = CONVERT(CHAR(1),PFAdjsted), 
					LpsPFAdjAmt = CASE CONVERT(CHAR(1),PFAdjsted) WHEN '0' THEN BalPFAmt ELSE 0 END,
					LpsDocSts=@Approver,
					LpsOvrride = @PfOvrride
				FROM #LnDet 
				WHERE LpsLedFk = @LeadPk AND LpsLsnFk = @SancPk AND LpsPk = @SancHdrPk 
			END
			
			--Colletral
				UPDATE LosColletral SET LcdDelId = 1 WHERE LcdLsnFk = @SancPk AND LcdLpsFk = @SancHdrPk AND LcdDelid = 0
				
				INSERT INTO LosColletral
				(
					LcdLedFk,LcdBGeoFk,LcdPrdFk,LcdAppFk,LcdLsnFk,LcdCltFk,
					LcdClaFk,LcdVal, LcdLpsFk, LcdRowId,LcdCreatedBy,
					LcdCreatedDt,LcdModifiedBy,LcdModifiedDt,LcdDelFlg,LcdDelId		
				) 
				SELECT	@LeadPk,@GeoFk,@PrdFk,@AppPK,@SancPk,LcdCltFk,LcdClaFk,LcdVal,@SancHdrPk, @RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
				FROM	#ColletralTbl
			
			--Life Insurance
			IF EXISTS(SELECT 'X' FROM #InsDtls WHERE Isnull(LIPK,0)= 0)
			BEGIN
				INSERT INTO LosInsurance(LisLedFk,LisBGeoFk,LisPrdFk,LisAppFk,LisLsnFk,LisTyp,LisLapFk,LisIsurer,LisSumAssured,LisPremium,LisSinJnt,
							LisPlcyPrd,LisPerAccCvr,LisAddtoLn, LisLpsFk,LisRowId,LisCreatedBy,LisCreatedDt,LisModifiedBy,LisModifiedDt,LisDelFlg,LisDelId,LisInsFK)
				OUTPUT		INSERTED.LisPk INTO #LisPK
				SELECT		@LeadPk,@GeoFk,@PrdFk,@AppPK,@SancPk,1,LiLapFK,LiInsurer,LiSumAssured,LiPremium,LiSinJnt,
							NULL,NULL,LiAddtoLn,@SancHdrPk,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,LiInspk
				FROM		#InsDtls 
				WHERE		LiLapFK <> -1
			END
			ELSE
				BEGIN
					UPDATE  LosInsurance
					SET		LisIsurer = LiInsurer,  LisSumAssured = LiSumAssured, LisPremium = LiPremium, LisSinJnt = LiSinJnt, LisAddtoLn = LiAddtoLn,
							LisRowId = @RowId, LisModifiedBy = @UsrDispNm, LisModifiedDt = @CurDt,LisInsFK=LiInspk,LisLapFk = LiLapFK
					FROM	#InsDtls
					WHERE	LisPk = LIPK AND LisTyp = 1

					SELECT @LIPK  = LIPK FROM #InsDtls 
				END
				
			--General Insurance
			IF EXISTS(SELECT 'X' FROM #InsDtls WHERE Isnull(GIPK,0) = 0 AND ISNULL(GiLapFK,'-1') <> '-1')
			BEGIN
				INSERT INTO LosInsurance(LisLedFk,LisBGeoFk,LisPrdFk,LisAppFk,LisLsnFk,LisTyp,LisLapFk,LisIsurer,LisSumAssured,LisPremium,LisSinJnt,
							LisPlcyPrd,LisPerAccCvr,LisAddtoLn,LisLpsFk,LisRowId,LisCreatedBy,LisCreatedDt,LisModifiedBy,LisModifiedDt,LisDelFlg,LisDelId,LisInsFK)
				OUTPUT		INSERTED.LisPk INTO #GisPK
				SELECT		@LeadPk,@GeoFk,@PrdFk,@AppPK,@SancPk,0,CONVERT(BIGINT,GiLapFK),GiInsurer,GiSumAssured,GiPremium,NULL,GiPlcyPrd,GiPerAccCvr,GiAddtoLn,@SancHdrPk,
							@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0,GiInspk
				FROM		#InsDtls
				WHERE		GiLapFK <> -1
			END
			ELSE 
				BEGIN
					UPDATE  LosInsurance
					SET		LisIsurer = GiInsurer,  LisSumAssured = GiSumAssured, LisPremium = GiPremium,LisPlcyPrd = GiPlcyPrd, LisPerAccCvr = GiPerAccCvr, 
							LisAddtoLn = GiAddtoLn,LisRowId = @RowId, LisModifiedBy = @UsrDispNm, LisModifiedDt = @CurDt,LisInsFK=GiInspk,LisLapFk = CONVERT(BIGINT,GiLapFK)
					FROM	#InsDtls
					WHERE	LisPk = GIPK AND ISNULL(GiLapFK,'-1') <> '-1' AND LisTyp = 0

					SELECT @GIPK  = ISNULL(GIPK,0) FROM #InsDtls 
			END	
					
			SELECT @LIPK = psq_hdn_Lipk FROM #LisPK WHERE ISNULL(psq_hdn_Lipk,0) <> 0
					
			SELECT @GIPK = psq_hdn_Gipk FROM #GisPK	WHERE ISNULL(psq_hdn_Gipk,0) <> 0	
					
			--Existing Nominee Details - Delete
			UPDATE LosInsNominee
			SET LinRowId = @RowId,
				LinModifiedBy = @UsrDispNm, LinModifiedDt = @CurDt, LinDelId = 1 , LinDelFlg = dbo.gefgGetDelFlg(@CurDt)
			FROM dbo.LosInsurance A					
			JOIN dbo.LosInsNominee B ON A.LisPk = B.LinLisFk 
			LEFT JOIN #NomineeDtls C ON B.LinPk = C.NomPk --AND C.InsType = 'LI'
			WHERE A.LisLedFk = @LeadPk AND A.LisPk = @LIPK AND ISNULL(C.NomPk,0) = 0

			UPDATE LosInsNominee
			SET LinRowId = @RowId,
				LinModifiedBy = @UsrDispNm, LinModifiedDt = @CurDt, LinDelId = 1 , LinDelFlg = dbo.gefgGetDelFlg(@CurDt)
			FROM dbo.LosInsurance A					
			JOIN dbo.LosInsNominee B ON A.LisPk = B.LinLisFk 
			LEFT JOIN #NomineeDtls C ON B.LinPk = C.NomPk --AND C.InsType = 'GI'
			WHERE A.LisLedFk = @LeadPk AND A.LisPk = @GIPK AND ISNULL(C.NomPk,0) = 0
									
		    --New GI Nominee Details - Insert
			INSERT INTO LosInsNominee(LinLisFk, LinNominee, LinAge, LinGender, LinRelation, LinGuardian, LinGuardianRel, LinLpsFk, LinRowId, 
										LinCreatedBy, LinCreatedDt,LinModifiedBy, LinModifiedDt,LinDelFlg,LinDelId)
			SELECT @GIPK,NomName, NomAge, NomGender, NomRelation, NomGuardian, NomGuarRel, @SancHdrPk, @RowId,
					@UsrDispNm, @CurDt, @UsrDispNm, @CurDt, 0, 0
			FROM #NomineeDtls 
			WHERE ISNULL(NomPk,0) = 0 AND InsType = 'GI' AND ISNULL(NomName,'') <> ''

			--New LI Nominee Details - Insert
			INSERT INTO LosInsNominee(LinLisFk, LinNominee, LinAge, LinGender, LinRelation, LinGuardian, LinGuardianRel, LinLpsFk, LinRowId, 
										LinCreatedBy, LinCreatedDt,LinModifiedBy, LinModifiedDt,LinDelFlg,LinDelId)
			SELECT @LIPK ,NomName, NomAge, NomGender, NomRelation, NomGuardian, NomGuarRel, @SancHdrPk, @RowId,
					@UsrDispNm, @CurDt, @UsrDispNm, @CurDt, 0, 0
			FROM #NomineeDtls 
			WHERE ISNULL(NomPk,0) = 0 AND InsType = 'LI' AND ISNULL(NomName,'') <> '' 

			--Existing Nominee Details - Update
			UPDATE LosInsNominee
			SET LinNominee = A.NomName, LinAge = A.NomAge, LinGender = A.NomGender, LinRelation = A.NomRelation, 
				LinGuardian = A.NomGuardian, LinGuardianRel = A.NomGuarRel, LinRowId = @RowId,
				LinModifiedBy = @UsrDispNm, LinModifiedDt = @CurDt
			FROM #NomineeDtls A
			JOIN dbo.LosInsNominee B ON A.NomPk = B.LinPk AND B.LinLpsFk = @SancHdrPk
			WHERE ISNULL(A.NomPk,0) <> 0
			
			--Existing App cheque Details - Delete
			UPDATE LosAppCheque
			SET LcqRowId = @RowId,LcqModifiedBy = @UsrDispNm,LcqModifiedDt = @CurDt,
				LcqDelId = 1,LcqDelFlg = dbo.gefgGetDelFlg(@CurDt)
			FROM #AppChqDet A
			RIGHT JOIN dbo.LosAppCheque B On A.AppChqPK = B.LcqPk  
			WHERE B.LcqLsnFk = @SancPk AND B.LcqLpsFk = @SancHdrPk AND ISNULL(A.AppChqPK,0) = 0

			--New App cheque Details - Insert
			INSERT INTO LosAppCheque(LcqLsnFk,LcqPayMode,LcqLbkFk,LcqChqCnt,LcqMinChqCnt, LcqLpsFk,LcqRowId,LcqCreatedBy,LcqCreatedDt,
										LcqModifiedBy,LcqModifiedDt,LcqDelFlg,LcqDelId) 
			SELECT @SancPk, Paymode, BnkFk, Isnull(ChqCnt,0), ISNULL(MinChqCnt,0), @SancHdrPk, @RowId, @UsrDispNm, @CurDt, 
					@UsrDispNm, @CurDt, 0, 0
			FROM #AppChqDet
			WHERE ISNULL(AppChqPK,0) = 0 AND ISNULL(Paymode,'') <> '' 

			--Existing App cheque Details - Update
			UPDATE LosAppCheque
			SET LcqPayMode = Paymode, LcqLbkFk = BnkFk, LcqChqCnt = Isnull(ChqCnt,0), LcqMinChqCnt = ISNULL(MinChqCnt,0),
				LcqRowId = @RowId,LcqModifiedBy = @UsrDispNm,LcqModifiedDt = @CurDt
			FROM #AppChqDet A
			JOIN dbo.LosAppCheque B On A.AppChqPK = B.LcqPk AND B.LcqLsnFk = @SancPk AND B.LcqLpsFk = @SancHdrPk
			WHERE ISNULL(AppChqPK,0) <> 0
					
			--Existing Pay Details - Delete
			UPDATE LosPayDtls
			SET LpdModifiedBy = @UsrDispNm, LpdModifiedDt = @CurDt, LpdRowId = @RowId, 
				LpdDelId = 1, LpdDelFlg = dbo.gefgGetDelFlg(@CurDt)
			FROM #Paydtls A
			RIGHT JOIN dbo.LosPayDtls B ON A.PayPk = B.LpdPk  
			WHERE B.LpdLsnFk = @SancPk AND B.LpdLpsFk = @SancHdrPk AND ISNULL(PayPk,0) = 0 
					
			--New Pay Details - Insert
			INSERT INTO  LosPayDtls(LpdLsnFk,LpdPayTo,LpdInsTyp,LpdAmt,LpdInFav, LpdLpsFk,LpdRowId,LpdCreatedBy,LpdCreatedDt,
									LpdModifiedBy,LpdModifiedDt,LpdDelFlg,LpdDelId) 
			SELECT @SancPk, PayTo, InstruType, InstruAmt, PayInfav, @SancHdrPk, @RowId, @UsrDispNm, @CurDt,
					@UsrDispNm, @CurDt,0, 0
			FROM #Paydtls
			WHERE ISNULL(PayPk,0) = 0 AND ISNULL(PayTo,'') <> ''
					
			--Existing Pay Details - Update
			UPDATE LosPayDtls
			SET LpdPayTo = PayTo, LpdInsTyp = InstruType, LpdAmt = InstruAmt, LpdInFav = PayInfav,
				LpdModifiedBy = @UsrDispNm, LpdModifiedDt = @CurDt, LpdRowId = @RowId
			FROM #Paydtls A
			JOIN dbo.LosPayDtls B ON A.PayPk = B.LpdPk AND B.LpdLsnFk = @SancPk AND B.LpdLpsFk = @SancHdrPk
			WHERE ISNULL(A.PayPk,0) <> 0 

			--Seller Details
		/*	IF EXISTS(SELECT TOP 1 'X' FROM #SelDetails WHERE ISNULL(LslNm,'') <> '')
			BEGIN 

				IF EXISTS(SELECT 'X' FROM #SelDetails WHERE Isnull(SellerPk,0)= 0)
				BEGIN
					INSERT INTO LosSeller(LslLedFk,LslBGeoFk,LslPrdFk,LslAppFk,LslLsnFk,LslNm,LslTyp,LslBuilderCIN,LslDoorNo,
											LslBuilding,LslPlotNo,LslStreet,LslLandmark,LslArea,LslDistrict,LslState,LslAgtFk,
											LslCountry,LslPin, LslLpsFk, LslPrpFK, LslRowId,LslCreatedBy,LslCreatedDt,LslModifiedBy,LslModifiedDt,LslDelFlg,LslDelId,LslSelTrig,LslGbmFk)
					OUTPUT		INSERTED.LslPk INTO #SelPK
					SELECT		@LeadPk,@GeoFk,@PrdFk,@AppPK,@SancPk,LslNm,LslTyp,BuilderCIN,LslDoorNo,	LslBuilding,LslPlotNo,LslStreet,LslLandmark,
								LslArea,LslDistrict,LslState,psq_agnttype,'INDIA',LslPin,@SancHdrPk, PropFk, @RowId,@UsrDispNm,@CurDt,@UsrDispNm,
								@CurDt,0,0,LslSelTrig ,ISNULL(BuilderPk,'')
					FROM		#SelDetails
					WHERE		ISNULL(SellerPk,0) = 0 AND ISNULL(LslNm,'') <> ''
					

					SELECT @SellerPk  = psq_hdn_Sellerpk FROM #SelPK 
				END
				ELSE
					BEGIN
						UPDATE  LosSeller 
						SET		LslNm = A.LslNm,  LslTyp = A.LslTyp, LslBuilderCIN = BuilderCIN,
								LslDoorNo = A.LslDoorNo, LslBuilding = A.LslBuilding, LslPlotNo = A.LslPlotNo,
								LslStreet=A.LslStreet,LslLandmark=A.LslLandmark,LslArea=A.LslArea,LslDistrict=A.LslDistrict,LslState=A.LslState,
								LslCountry='INDIA',LslPin=A.LslPin,LslRowId = @RowId, LslModifiedBy = @UsrDispNm, LslModifiedDt = @CurDt,
								LslAgtFk = psq_agnttype, LslPrpFK = PropFk, LslSelTrig = A.LslSelTrig  ,
								LslGbmFk = ISNULL(BuilderPk,'')
						FROM	#SelDetails A
						WHERE	LslPk = A.SellerPk  

						SELECT @SellerPk  = SellerPk FROM #SelDetails 
					END
					
				SELECT @confirm = psq_hdn_confirm,@flag =psq_hdn_new  FROM #InsDtls

				IF EXISTS (SELECT 'X' FROM #SelDetails WHERE Isnull(SellerPk,0) > 0 AND ISNULL(@confirm,0) = 1 AND @flag = 1)				
					BEGIN		
											
						SELECT @MaxJobNo = (CONVERT(BIGINT,RIGHT(MAX(LfjJobNo),5)) + 1) FROM LosAgentFBJob(NOLOCK)
						IF ISNULL(@MaxJobNo,0) = 0 SET @MaxJobNo = 1;

						INSERT INTO LosAgentJob
						(
							LajAgtFk,LajSrvTyp,LajJobNo,LajJobDt,LajLedFk,LajLedNo,LajRowId,
							LajCreatedBy,LajCreatedDt,LajModifiedBy,LajModifiedDt,LajDelFlg,LajDelId,LajBGeoFk,LajPrdFk
						) output inserted.LajPk INTO #TempVerf
						SELECT  psq_agnttype,6,'JOB_' + dbo.gefgGetPadZero(5,(ISNULL(@MaxJobNo,0))),@CurDt,@LeadPk,
								@LeadID,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,@GeoFk,@PrdFk
						FROM	#SelDetails A	
						WHERE	A.LslSelTrig = 'Y'	OR A.LslSelTrig = '0' GROUP BY psq_agnttype

						

						INSERT INTO LosAgentVerf(LavLajFk,LavNm,LavMobNo,LavAddTyp,LavDoorNo,LavBuilding,LavPlotNo,LavStreet,LavLandmark,LavArea,LavDistrict,
									LavState,LavCountry,LavPin,LavRowId,LavCreatedBy,LavCreatedDt,LavModifiedBy,LavModifiedDt,LavDelFlg,LavDelId,LavLapFk,LavLslFk)									

									
						SELECT		VerLajFk, LslNm, LapMobile, 0, LslDoorNo, LslBuilding, LslPlotNo, LslStreet, LslLandmark, LslArea, LslDistrict,LslState, LslCountry,
									LslPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, 0, 0, LslAppFk , LslPk
						FROM		LosSeller (NOLOCK)

						JOIN		LosAppProfile (NOLOCK) ON LapAppFk = LslAppFk AND LapDelId = 0 
						JOIN		LosAgentJob (NOLOCK) ON LajAgtFk = LslAgtFk AND LajSrvTyp = 6 AND LajLedFk = @LeadPk AND LajDelId = 0
						JOIN		#TempVerf ON	VerLajFk = LajPk
						WHERE		LslLedFk = @LeadPk AND LapActor = 0 AND LslSelTrig = 'Y' AND LslDelId = 0 AND LslTyp = 'S'
						
																		
						INSERT INTO LosAgentVerf(LavLajFk,LavNm,LavMobNo,LavAddTyp,LavDoorNo,LavBuilding,LavPlotNo,LavStreet,LavLandmark,LavArea,LavDistrict,
									LavState,LavCountry,LavPin,LavRowId,LavCreatedBy,LavCreatedDt,LavModifiedBy,LavModifiedDt,LavDelFlg,LavDelId,
									LavLapFk,LavLslFk)		
																
						SELECT		VerLajFk,GbmName, GbmMobileNo, 0, GbaDoorNo,GbaBuilding,GbaPlotNo,GbaStreet,GbaLandmark,GbaArea,GbaDistrict,GbaState,
									GbaCountry,GbaPin,@RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, 0, 0, LslAppFk , LslPk
						FROM		GenBuilderAddress(NOLOCK)
						JOIN		LosSeller (NOLOCK) ON LslGbmFk = GbaGbmFk
						JOIN		GenBuilder (NOLOCK) ON GbmPk = LslGbmFk AND GbmDelId = 0 AND GbaDelId = 0
						JOIN		LosAgentJob (NOLOCK) ON LajAgtFk = LslAgtFk AND LajSrvTyp = 6 AND LajLedFk = @LeadPk AND LajDelId = 0
						JOIN		#TempVerf ON	VerLajFk = LajPk
						JOIN		LosAppProfile (NOLOCK) ON LapAppFk = LslAppFk AND LapDelId = 0 AND LapActor = 0 							
						WHERE		LslLedFk = @LeadPk  AND LslSelTrig = 'Y' AND LslDelId = 0	AND LslTyp = 'B'	
					END											
			END	*/
							
			--Loan Details
			IF @DisbuAppr = 'Y'
			BEGIN	
				IF NOT EXISTS(SELECT TOP 1 'X' FROM LosLoan WHERE LlnLedFk = @LeadPk AND LlnLsnFk = @SancPk AND LlnLpsFk = @SancHdrPk)	
				BEGIN					
					--SELECT @MaxLoanNo = (CONVERT(BIGINT,RIGHT(MAX(LlnLoanNo),5)) + 1) FROM LosLoan(NOLOCK)

					--IF ISNULL(@MaxLoanNo,0) = 0 SET @MaxLoanNo =  1;
					--	SELECT @LoanNo = 'SHFHOLOAN' + dbo.gefgGetPadZero(5,(ISNULL(@MaxLoanNo,0)))

					SELECT	@NumGenUNODB = CmpUNODB + '.dbo.GetGenNumForLOS'
					FROM	GenCmpMas(NOLOCK)

					SELECT	@BrnCd =  GeoCd FROM GenGeoMas(NOLOCK) 					
					WHERE	GeoPk = @GeoFk

					
					--SELECT	@PrdCd =  PrdCd FROM GenPrdMas(NOLOCK) 
					--JOIN	LosLead(NOLOCK) ON LedPrdFk = PrdPk AND LedDelId = 0
					--WHERE	LedPk = @LeadPk


					INSERT INTO #LoanNoTmpTbl(LoanNo)
					EXEC @NumGenUNODB 'Loan',@BrnCd ,'ADMIN',@PrdCd,null,'P'

					SELECT @LoanNo = LoanNo FROM #LoanNoTmpTbl
			
						
					INSERT INTO LosLoan(LlnLedFk,LlnBGeoFk,LlnPrdFk,LlnAppFk,LlnLoanNo,LlnLoanDt,LlnPGrpFk,LlnLsnFk,LlnLpsFk,
										LlnRowId,LlnCreatedBy,LlnCreatedDt,LlnModifiedBy,LlnModifiedDt,LlnDelFlg,LlnDelId)
					SELECT 		@LeadPk,@GeoFk,@PrdFk,@AppPK,@LoanNo,@CurDt,@PrdGrpFk,@SancPk,@SancHdrPk,
								@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0
					
					IF EXISTS (SELECT 'X' FROM LosPostSanction WHERE LpsPk = @SancHdrPk AND LpsLsnFk = @SancPk AND LpsPFAdjFrmLn = 0 AND LpsPFAdjAmt > 0)
					BEGIN
						EXEC PrcShflLoanDetail @LeadPk,'PostSanction'
					END

					SELECT @LoanNo 'LoanNo'	
				END			
			END	

			--New Property Valuation Details - Insert					
			IF EXISTS (SELECT TOP 1 'X' FROM #PropValuationDet WHERE Isnull(Astcstpk,0) = 0 AND ISNULL(AssetCst,0) <> 0)
			BEGIN
				INSERT INTO LosPropAstCost(PacLedFk,PacBGeoFk,PacPrpFk,PacAgrmtVal,PacRegChg,PacStmpChg,PacEstimate,PacAmen,PacAstCost,
											PacRowId,PacCreatedBy,PacCreatedDt,PacModifiedBy,PacModifiedDt,PacDelId,PacDelFlg)
				SELECT @LeadPk,@GeoFk,PropFk,AgreementValue,RegCharge,StampCharge,LegEstimate,AmenitiesAmt,AssetCst,
						@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,0,0
				FROM #PropValuationDet
			END

			--Existing Property Valuation Details - Update	
			UPDATE LosPropAstCost
			SET PacAgrmtVal = AgreementValue, PacRegChg = RegCharge, PacStmpChg = StampCharge, PacEstimate = LegEstimate, PacAmen = AmenitiesAmt,
				PacAstCost = AssetCst, PacRowId = @RowId, PacModifiedBy = @UsrDispNm, PacModifiedDt = @CurDt
			FROM #PropValuationDet A
			JOIN LosPropAstCost B ON A.Astcstpk = B.PacPk AND A.PropFk = B.PacPrpFk
			WHERE Isnull(A.Astcstpk,0) <> 0

			IF EXISTS(SELECT 'X' FROM #DOCDTLS)
			BEGIN
				 UPDATE	LosAppDocuments
				 SET 	LadDelId = 1, LadDelFlg = dbo.gefgGetDelFlg(@CurDt),LadRowId=@RowId,LadModifiedBy=@UsrDispNm,LadModifiedDt=@CurDt
				 WHERE	LadAppFk = @AppPK AND LadDelId = 0 AND LadStage ='S'


				INSERT INTO LosAppDocuments
				(
					 LadLedFk,LadAppFk,LadDocTyp,LadGdmFk,LadRcvdBy,LadRcvdDt,LadDocVal,LadDocDt,LadDocSts,LadValidUpto,LadRowId,
					 LadCreatedBy,LadCreatedDt,LadModifiedBy,LadModifiedDt,LadDelFlg,LadDelId,LadRmks,LadRefDt,LadStage
	            )
				SELECT	@LeadPk,@AppPK,Com_Doctype,Com_DoctPk,@UsrPk,ISNULL(DBO.gefgChar2Date(Com_RecDate),''),Com_Refno,@CurDt,case when Com_Docstatus= '-1' then '' else Com_Docstatus end,DBO.gefgChar2Date(Com_ValidDate),
				        @RowId, @UsrDispNm, @CurDt, @UsrDispNm, @CurDt, NULL, 0,Com_notes,DBO.gefgChar2Date(Com_refDate),'S'
			    FROM	#DOCDTLS
								
				SELECT	@Error = @@ERROR

				IF @Error > 0
				BEGIN
					RAISERROR('%s',16,1,'Error : PostSanction Documents Insert')
					RETURN
				END									
			END
			ELSE
			BEGIN
			  IF EXISTS(SELECT 'X' FROM LosAppDocuments WHERE LadAppFk = @AppPK AND LadDelId = 0 AND LadStage ='S' )
			  BEGIN
			     UPDATE	LosAppDocuments
				 SET 	LadDelId = 1, LadDelFlg = dbo.gefgGetDelFlg(@CurDt),LadRowId=@RowId,LadModifiedBy=@UsrDispNm,LadModifiedDt=@CurDt
				 WHERE	LadAppFk = @AppPK AND LadDelId = 0 AND LadStage ='S'
	          END
			END
		END
				
		ELSE IF @Action = 'DOCUMENT'
		BEGIN
			SELECT	DocCat	'Catogory',	DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk',DocLedFk 'LeadFk',
					ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',
					CASE WHEN DocActor = 0 THEN 'Applicant' WHEN DocActor = 1  THEN 'Co-Applicant' WHEN DocActor = 2  THEN 'Guarantor' END 'Actor'
					FROM LosDocument(NOLOCK)
					JOIN GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
					JOIN #PSGlobalDtls ON LeadPk = DocLedFk			
					WHERE DocDelId=0 AND DocCat !='RPT'
		END
		
		ELSE IF @Action = 'LoanExist_Check'
		BEGIN
			SELECT DISTINCT LlnLsnFk 'SancPk'
			FROM LosLoan 
			WHERE LlnLedFk = @LeadPk AND LlnDelId = 0
		END

		ELSE IF @Action = 'Delete_Seller'
		BEGIN
			UPDATE  LosSeller
			SET		LslDelId = 1,  
					LslRowId = @RowId, LslModifiedBy = @UsrDispNm, LslModifiedDt = @CurDt			
			WHERE	LslPk = @selPk AND LslDelId = 0
		END
		
		ELSE IF @Action = 'SHOW_DEVIATION'
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
						CASE	WHEN C.LapActor = 0 THEN 'Applicant' 
								WHEN C.LapActor = 1 THEN 'CoApplicant' 
								WHEN C.LapActor = 2 THEN 'Guarantor' 
								ELSE 'General'
						END	'ApplicableTo',
						CASE	WHEN LdvStage = 'C' THEN 'Credit'
								WHEN LdvStage = 'T' THEN 'Technical'
								WHEN LdvStage = 'L' THEN 'Legal'
								WHEN LdvStage = 'D' THEN 'Disbursement'
						END 'stage', 
						CASE  WHEN ISNULL(LdvMarginVal,0) <> 0 THEN RTRIM(LdvDevVal)
						ELSE 'NA' END 'baseval'
				FROM	LosDeviation (NOLOCK) A
				JOIN	LosLnAttributes (NOLOCK) B ON  B.LnaPk = A.LdvLnaFk AND B.LnaDelId = 0 
				LEFT OUTER JOIN	LosAppProfile C (NOLOCK) ON C.LapPk = A.LdvLapFk AND A.LdvDelid = 0
				WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 AND LdvIsApp IS NULL 

				SELECT	ISNULL(MAX(LdvAppBy),1) 'MaxApproverLevel'
				FROM	LosDeviation (NOLOCK)
				WHERE	LdvLedFk = @LeadPk AND LdvDelId = 0 AND  LdvIsApp IS NULL
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
	SET NOCOUNT OFF
	SET ANSI_WARNINGS OFF
END


