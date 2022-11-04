IF OBJECT_ID('PrcSHFLLosBalancePF','P') IS NOT NULL
	DROP PROC PrcSHFLLosBalancePF
GO
CREATE PROCEDURE PrcSHFLLosBalancePF
(
	@Action			VARCHAR(100)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,
	@LeadPk			BIGINT				=	NULL,
	@LpcFK			BIGINT				=	NULL,
	@sancNo			VARCHAR(50)			=	NULL
	
)
AS
BEGIN
	DECLARE @LogDtls VARCHAR(MAX);
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40),@dep_bank BIGINT;
	DECLARE @LpcChrg NUMERIC(27,7),@LpcInstrAmt NUMERIC(27,7),@LpcPayTyp CHAR(1),@LpcInstrNo VARCHAR(50),@LpcInstrDt VARCHAR(20);
	DECLARE	@DocPk BIGINT,@LeadGrdPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,
			@selActor TINYINT, @Query VARCHAR(MAX),@bnfk VARCHAR(100),@bbmfk VARCHAR(100),@LpcInstrdepoDt VARCHAR(20),
			@TaxFk BIGINT, @DocFk BIGINT,@CmpFk BIGINT, @LnAmt NUMERIC(27,7), @BalPF NUMERIC(27,7), @CollPF NUMERIC(27,7),@lead_grdPk BIGINT;

	DECLARE @IsSancGen CHAR(1) = 'N', @AppPrd VARCHAR(50), @UNODB VARCHAR(100)
	
	CREATE TABLE #ProPrcCalc
	(
		PrdGrpFk BIGINT, PrdFk BIGINT, Qty NUMERIC(27, 7), PrcTyp TINYINT, CompCd VARCHAR(50), CompNm VARCHAR(100), CompRef BIGINT, 
		Rmks VARCHAR(250), CompPer NUMERIC(27, 7), CompVal NUMERIC(27,7 ), CompSgn INT, CompRnd TINYINT, CompTyp VARCHAR(10), 
		TreeId VARCHAR(250), RelCompNm VARCHAR(100), FinalVal NUMERIC(27, 7), xIsProc BIT,
		PrdCd VARCHAR(50), IsAccPst TINYINT, PrdSrcFk BIGINT, CompPrcTyp TINYINT, VchFk BIGINT, IsClng BIT, IsVis BIT, 
		xRowId UNIQUEIDENTIFIER, xPk BIGINT IDENTITY(1, 1), SeqNo TINYINT, DpdFk BIGINT
	)

	CREATE TABLE #BalPFDet
	(
		ID BIGINT,LeadFK BIGINT, SancFK BIGINT, SancNo VARCHAR(50), LOAN_AMT NUMERIC(27, 7), TENUR NUMERIC(27, 7),ROI NUMERIC(27, 7),
		EMI NUMERIC(27, 7),LI NUMERIC(27, 7),GI NUMERIC(27, 7),BT_AMT NUMERIC(27, 7),BT_ROI NUMERIC(27, 7),BT_EMI NUMERIC(27, 7),
		BT_LI NUMERIC(27, 7),BT_GI NUMERIC(27, 7),TOPUP_AMT NUMERIC(27, 7),TOPUP_ROI NUMERIC(27, 7),TOPUP_EMI NUMERIC(27, 7),
		TOPUP_LI NUMERIC(27, 7),TOPUP_GI NUMERIC(27, 7),LTV NUMERIC(27, 7),ACT_LTV NUMERIC(27, 7),BT_LTV_A NUMERIC(27, 7),
		TOPUP_LTV_A NUMERIC(27, 7),BT_LTV_M NUMERIC(27, 7),TOPUP_LTV_M NUMERIC(27, 7), TotalPF NUMERIC(27, 7), BTPF NUMERIC(27, 7),
		TopupPF NUMERIC(27, 7),TotalPFCollected NUMERIC(27, 7), BTPFCollected NUMERIC(27, 7),
		TopupPFCollected NUMERIC(27, 7),BalPF NUMERIC(27, 7), BTPFBal NUMERIC(27, 7),
		TopupPFBal NUMERIC(27, 7), Spread NUMERIC(27, 7), TENUR_TOP NUMERIC(27,7), Waiver_ROI NUMERIC(27,7),
		PrdCd VARCHAR(50), PrdFK BIGINT
	)

	CREATE TABLE #GlobalTbl	(xx_id BIGINT,LeadFk BIGINT ,DocFk BIGINT,RefAgtPk BIGINT,RefBGeoFk BIGINT,LpcPayTyp CHAR(1),RefPrdFk BIGINT,UsrDispNm VARCHAR(100),
								LpcInstrAmt NUMERIC(27,7),LpcInstrDt VARCHAR(20),LpcInstrNo VARCHAR(50),LpcInstrdepoDt VARCHAR(20),bnfk BIGINT,bbmfk BIGINT,lead_grdPk BIGINT,dep_bank BIGINT)
	SELECT @CurDt = GETDATE(), @RowId = NEWID()		
	
	IF @GlobalJson !='[]' AND @GlobalJson != '' 
		BEGIN
			INSERT INTO #GlobalTbl				
			EXEC PrcParseJSON @GlobalJson,'LeadFk,DocFk,DocAgtPk,DocBGeoFk,LpcPayTyp,DocPrdFk,UsrDispNm,LpcInstrAmt,LpcInstrDt,LpcInstrNo,LpcInstrdepoDt,bnfk,bbmfk,lead_grdPk,dep_bank'

			SELECT @UsrDispNm=UsrDispNm,@LpcInstrAmt = LpcInstrAmt,@dep_bank=dep_bank,@LpcInstrDt=LpcInstrDt,@LpcInstrNo=LpcInstrNo,
			@LpcInstrdepoDt=LpcInstrdepoDt,@bnfk=bnfk,@bbmfk=bbmfk,@lead_grdPk=lead_grdPk,@LpcPayTyp=LpcPayTyp FROM #GlobalTbl
		END

	BEGIN TRY

	IF @@TRANCOUNT = 0
		SET @TranCount = 1

	IF @TranCount = 1
		BEGIN TRAN		

		IF @Action='Search-Lead'
		  BEGIN
			SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
		    SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Basic Template' AND PhDelid = 0

		    SELECT	@CollPF = SUM(ISNULL(LpcInstrAmt,0))
		    FROM	LosProcChrg(NOLOCK)
		    JOIN	GenMas ON MasCd NOT IN ('PFPAY') AND LpcDocTyp = MasPk AND MasDelid = 0
		    WHERE	LpcLedFk = @LeadPk AND LpcDelid = 0
		    
		    SELECT	@LnAmt = ISNULL(LpcChrg,0) - ISNULL(LpcWavier,0)
			FROM	LosProcChrg(NOLOCK)
			JOIN	GenMas ON MasCd = 'PFPAY' AND LpcDocTyp = MasPk AND MasDelid = 0
			WHERE	LpcLedFk = @LeadPk AND LpcDelid = 0
			
			IF ISNULL(@LnAmt,0) > 0
				BEGIN
					INSERT INTO #ProPrcCalc 
					(
						VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
						TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
					)
					SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk, PrcPPrc,
							CASE PstcCd WHEN 'PF' THEN ISNULL(@LnAmt,0) ELSE PrcPVal END,
							PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
							PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
							ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
					FROM	GenPrcDtls (NOLOCK) 
					JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
					WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0

					EXEC PrcLosTaxValuation '', @RowId, @CmpFk

					SELECT	@LnAmt = ISNULL(FinalVal,0) FROM #ProPrcCalc(NOLOCK) WHERE CompCd = 'PFVAL'
				END
			
			IF ISNULL(@LnAmt,0) > 0
				SELECT @BalPF = ISNULL(@LnAmt,0) - ISNULL(@CollPF,0)
			
			SELECT	 LpcLedFk 'LeadPk',LpcPk 'ProCrgPk',LedNm 'LeadNm',GeoPk 'BranchPk',GeoNm 'BranchNm',AgtPk 'AgentPk',AgtTitle 'AgentName',
					  CASE LpcPayTyp  WHEN 'D' THEN 'DD' WHEN 'C' THEN 'Cheque' WHEN 'R' THEN 'RTGS' ELSE 'NEFT' END 'ProTypePk',
					  LpcInstrNo 'InstNo',dbo.gefgDMY(LpcInstrDt) 'InstDate',
					  dbo.GefgCurFormat(ISNULL(LpcInstrAmt,0),@CmpFk)'InstAmount',
					  dbo.gefgDMY(LpcInstrDepDt) 'InstDepDate',
					  LpcBnkFk 'BankPk',LpcBbmFk 'BankBrchPk',BnkNm 'BankNm',BbmLoc 'BankBchNm' , MasDesc 'Voucher',
					  dbo.GefgCurFormat(ISNULL(@CollPF,0),@CmpFk) 'ColPF', dbo.GefgCurFormat(ISNULL(@BalPF,0),@CmpFk) 'BalPF',GabCd 'code',GabPk 'PK',PrdCd 'ProductCode'
			FROM LosProcChrg (NOLOCK)
			left outer join GABnkMas(NOLOCK) on LpcDepBankFK=GabPk
				INNER JOIN	LosLead(NOLOCK) on LpcLedFk  =LedPk AND LpcDelid = 0
				INNER JOIN	GenGeoMas(NOLOCK) ON LpcBGeoFk=GeoPk AND GeoDelid = 0
				INNER JOIN	GenAgents(NOLOCK) ON LpcAgtFk=AgtPk AND AgtDelid = 0
				INNER JOIN	GenMas(NOLOCK) ON MasCd NOT IN ('PFPAY','PCA','PCLA') AND LpcDocTyp = MasPk AND MasDelid = 0
				LEFT JOIN	GenBnkMas(NOLOCK) ON LpcBnkFk=BnkPk AND BnkDelid = 0
				LEFT JOIN	GenBnkBrnchMas(NOLOCK) ON LpcBbmFk =BbmPk AND BbmDelid = 0
				LEFT OUTER JOIN LosApp (NOLOCK) ON AppLedFk = @LeadPk AND AppDelId = 0
				LEFT OUTER JOIN GenPrdMas(NOLOCK) ON  AppPrdFk=PrdPk
				WHERE		LedDelId = 0  AND LedPk = @LeadPk  
				ORDER BY	LedPk DESC
			
			SELECT @AppPrd = B.PrdCd FROM LosApp A JOIN GenPrdMas B ON A.AppPrdFk = B.PrdPk WHERE A.AppLedFk = @LeadPk

			IF EXISTS(SELECT 'X' FROM LosSanction WHERE LsnLedFk = @LeadPk AND LsnStsFlg = 'A')
			BEGIN 
				SET @IsSancGen = 'Y'
			END

			SELECT @IsSancGen 'IsSancGen'
			
			IF(@IsSancGen = 'Y')
			BEGIN
				INSERT INTO #BalPFDet
				EXEC PrcShflLoanDetail @LeadPk

				SELECT B.PrdNm 'PrdNm', B.PrdIcon 'PrdIcon', A.SancNo 'SancNo', 
						CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND A.PrdCd IN('HLBT','LAPBT') THEN dbo.GefgCurFormat(ISNULL(A.BTPF,0),@CmpFk)
							WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND A.PrdCd IN('HLTopup','LAPTopup') THEN dbo.GefgCurFormat(ISNULL(A.TopupPF,0),@CmpFk)
							ELSE dbo.GefgCurFormat(ISNULL(A.TotalPF,0),@CmpFk)
						END 'TotalPF',
						CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND A.PrdCd IN('HLBT','LAPBT') THEN dbo.GefgCurFormat(ISNULL(A.BTPFCollected,0),@CmpFk)
							WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND A.PrdCd IN('HLTopup','LAPTopup') THEN dbo.GefgCurFormat(ISNULL(A.TopupPFCollected,0),@CmpFk)
							ELSE dbo.GefgCurFormat(ISNULL(A.TotalPFCollected,0),@CmpFk)
						END 'CollectedPF',
						CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND A.PrdCd IN('HLBT','LAPBT') THEN dbo.GefgCurFormat(ISNULL(A.BTPFBal,0),@CmpFk)
							WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND A.PrdCd IN('HLTopup','LAPTopup') THEN dbo.GefgCurFormat(ISNULL(A.TopupPFBal,0),@CmpFk)
							ELSE dbo.GefgCurFormat(ISNULL(A.BalPF,0),@CmpFk)
						END 'BalPF'
				FROM #BalPFDet A
				JOIN GenPrdMas B ON A.PrdFK = B.PrdPk	
			END						
		  END

		 IF @Action='INSERT'
		  BEGIN

		    IF EXISTS
				(
					SELECT 'X' FROM LosProcChrg(NOLOCK) 
					WHERE LpcPayTyp=@LpcPayTyp AND LpcInstrNo = @LpcInstrNo AND LpcBnkFk=@bnfk 
					AND LpcBbmFk=@bbmfk AND LpcDelId=0
				)
				BEGIN
					RAISERROR('%s',16,1,'Instrument No. Already Exists!')
					RETURN
				END

				SELECT @DocFk = MasPk FROM GenMas(NOLOCK) WHERE MasCd = 'BPC' AND MasDelid = 0 
				
				IF(ISNULL(@sancNo,'') <> '')
				BEGIN
					SELECT @PrdFk = LsnPrdFk FROM LosSanction WHERE LsnSancNo = @sancNo
				END
				ELSE
				BEGIN 
					SELECT @PrdFk = LedPrdFk FROM LosLead WHERE LedPk = @LeadPk
				END

				INSERT INTO LosProcChrg
				(
					LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcDocTyp,LpcChrg,LpcInstrAmt,LpcPayTyp,
					LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,LpcRowId,LpcCreatedBy,
					LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcPGrpFk,LpcBnkFk,LpcBbmFk,LpcInstrDepDt,LpcDrCr,LpcDepBankFK,LpcSancNo,
					LpcPrdFk			
				) --OUTPUT INSERTED.*
				SELECT	@LeadPk,LedAgtFk,LedBGeoFk,@DocFk,ISNULL(@LpcChrg,0),@LpcInstrAmt,@LpcPayTyp,@LpcInstrNo,
						dbo.gefgChar2Date(@LpcInstrDt),NULL,NULL,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,@lead_grdPk,
						@bnfk,@bbmfk,dbo.gefgChar2Date(@LpcInstrdepoDt),'C',@dep_bank,@sancNo, @PrdFk
				FROM	LosLead 
				WHERE   LedPk=@LeadPk

				SET @LpcFK = SCOPE_IDENTITY()
				
				SELECT SCOPE_IDENTITY() 'LpcFK'

				
				SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
				SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Template' AND PhDelid = 0

				IF ISNULL(@LpcInstrAmt,0) > 0
					BEGIN
						DELETE FROM #ProPrcCalc
						
						INSERT INTO #ProPrcCalc 
						(
							VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
							TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
						)
						SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk,
								CASE PstcCd WHEN 'PF' THEN ((100.00/(100.00 + 15.00)) * 100) ELSE PrcPPrc END,
								CASE PstcCd WHEN 'PFVAL' THEN ISNULL(@LpcInstrAmt,0) ELSE PrcPVal END,
								PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
								PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
								ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
						FROM	GenPrcDtls (NOLOCK) 
						JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
						WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0
	
						EXEC PrcLosTaxValuation '', @RowId, @CmpFk

						INSERT INTO LosProcChrgDtls
						(
							LpcdLpcFk,LpcdPstcFk,LpcdAmdNo,LpcdPcdCd,LpcdPcdDispNm,LpcdRmks,LpcdRelPcdCd,LpcdSgn,
							LpcdRndOffDml,LpcdIsCeling,LpcdPer,LpcdVal,LpcdAmt,LpcdPrmDep,LpcdPTreeId,LpcdIsAccPst,LpcdIsVisible,
							LpcdRowid,LpcdCreatedBy,LpcdCreatedDt,LpcdModifiedBy,LpcdModifiedDt,LpcdDelFlg,LpcdDelId
						)
						--OUTPUT INSERTED.*
						SELECT	@LpcFK,CompRef,0,CompCd,CompNm,'',RelCompNm,CompSgn,CompRnd, IsClng, CompPer, CompVal,FinalVal,
								CompTyp,TreeId,IsAccPst,IsVis,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0
						FROM	#ProPrcCalc
						
						UPDATE	LosProcChrg 
						SET LpcChrg = ISNULL(LpcdAmt,0) 
						FROM LosProcChrgDtls(NOLOCK)
						WHERE LpcLedFk = @LeadPk AND LpcdLpcFk = @LpcFK AND LpcPK = LpcdLpcFk AND LpcdPcdCd = 'PF' AND LpcdDelid = 0
						
						 SELECT @UNODB = CmpUNODB + '.dbo.PrcShflReceiptAccEntry' 
						 FROM GenCmpMas 
						 WHERE CmpDelId = 0
						 						 
						--Accounts Entry
						IF ISNULL(@sancNo,'') <> ''
						BEGIN
							EXEC @UNODB @LeadPk,'SancReceipt'
						END
						ELSE
						BEGIN
							EXEC @UNODB @LeadPk,'LeadReceipt'
						END
					END	
		  END
	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	

		SELECT	@ErrMsg = ERROR_MESSAGE() ,--+ ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()

		--EXEC PrcShflGenLog @LogDtls,1000,@DocPk,@Query,1,@ErrMsg

	
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
		
	END CATCH
END




