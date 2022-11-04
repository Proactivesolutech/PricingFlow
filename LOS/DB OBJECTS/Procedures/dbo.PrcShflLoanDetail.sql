
IF OBJECT_ID('PrcShflLoanDetail','P') IS NOT NULL
	DROP PROCEDURE PrcShflLoanDetail
GO
CREATE PROC PrcShflLoanDetail
(
	@LeadPk BIGINT		= NULL,
	@Action VARCHAR(25) = NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	BEGIN TRY
		DECLARE @ErrMsg VARCHAR(MAX), @Error INT, @ErrSeverity INT
		DECLARE @MaxRvnNo BIGINT, @AppPrd VARCHAR(100), @RowId VARCHAR(40), @UNODB VARCHAR(100)

		DECLARE @GeoFk BIGINT,@UsrNm VARCHAR(200),@AgtFk BIGINT, @CurDt DATETIME, @SancFK BIGINT, @SancHdrPk BIGINT, @SancNo VARCHAR(50),@LpcFK BIGINT

		DECLARE @TaxFk BIGINT, @DocFk BIGINT, @CmpFk BIGINT, @TotPF NUMERIC(27,7), @BTPF NUMERIC(27,7), @TopupPF NUMERIC(27,7), @BalPF NUMERIC(27,7), 
				@CollPF NUMERIC(27,7), @WaiverAmt NUMERIC(27,7), @BTWaivePercent NUMERIC(27,7), @TopupWaivePercent NUMERIC(27,7), @WaiverROI NUMERIC(27,7),
				@TotPFWithoutTax NUMERIC(27,7), @BTPFWithoutTax NUMERIC(27,7), @TopupPFWithoutTax NUMERIC(27,7), @BalPFWithoutTax NUMERIC(27,7),
				@TotPFWithWaive NUMERIC(27,7), @BTPFWithWaive NUMERIC(27,7), @TopupPFWithWaive NUMERIC(27,7), @PFPer NUMERIC(27,7), @AdjDocFk BIGINT,
				@CollPFWithoutTax NUMERIC(27,7), @BTWaiverAmt NUMERIC(27,7),@TopUpWaiverAmt NUMERIC(27,7),
				@BTPFColWithoutTax NUMERIC(27,7), @TopupPFColWithoutTax NUMERIC(27,7)

		SET @CurDt = GETDATE()

		SELECT @RowId = NEWID()	

		IF OBJECT_ID('TEMPDB..#ProPrcCalc') IS NOT NULL    
				DROP TABLE #ProPrcCalc 
			
		CREATE TABLE #ProPrcCalc
		(
			PrdGrpFk BIGINT, PrdFk BIGINT, Qty NUMERIC(27, 7), PrcTyp TINYINT, CompCd VARCHAR(50), CompNm VARCHAR(100), CompRef BIGINT, 
			Rmks VARCHAR(250), CompPer NUMERIC(27, 7), CompVal NUMERIC(27,7 ), CompSgn INT, CompRnd TINYINT, CompTyp VARCHAR(10), 
			TreeId VARCHAR(250), RelCompNm VARCHAR(100), FinalVal NUMERIC(27, 7), xIsProc BIT,
			PrdCd VARCHAR(50), IsAccPst TINYINT, PrdSrcFk BIGINT, CompPrcTyp TINYINT, VchFk BIGINT, IsClng BIT, IsVis BIT, 
			xRowId UNIQUEIDENTIFIER, xPk BIGINT IDENTITY(1, 1), SeqNo TINYINT, DpdFk BIGINT
		)

		SELECT @UNODB = CmpUNODB + '.dbo.PrcShflReceiptAccEntry' 
		FROM GenCmpMas 
		WHERE CmpDelId = 0

		IF(@Action = 'PostSanction')
		BEGIN			
			SELECT @DocFk = MasPk
			FROM GenMas
			WHERE MasCd = 'PCLA' AND MasDelId = 0

			SELECT	@UsrNm = UsrDispNm ,@GeoFk = GeoFk, @AgtFk = AgtFk, @SancFK = SancPk, @SancHdrPk = SancHdrPk, @SancNo = B.LsnSancNo
			FROM	#PSGlobalDtls A
			JOIN	LosSanction	B ON A.SancPk = B.LsnPk

			SELECT @BalPFWithoutTax = BalPFWoutTax, @BalPF = BalPFAmt
			FROM #LnDet

			SELECT @PFPer = A.LpcDis, @WaiverAmt = ISNULL(A.LpcWavier,0)
			FROM LosProcChrg A
			JOIN GenMas B ON A.LpcDocTyp = B.MasPk
			WHERE LpcSancNo = @SancNo AND MasCd = 'PFPAY' AND MasDelId = 0

			INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
									LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, 
									LpcDrCr, LpcLoanNo)					
			SELECT DISTINCT @LeadPk,@AgtFk ,@GeoFk,LpsPrdFk, @BalPFWithoutTax, LpsPFAdjAmt,
					NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,
					@WaiverAmt, @DocFk, @SancNo, 'C' , B.LlnLoanNo
			FROM LosPostSanction A
			JOIN LosLoan B On A.LpsPk = B.LlnLpsFk AND B.LlnDelId = 0
			WHERE LpsPk = @SancHdrPk AND LpsLsnFk = @SancFK AND LpsDelId = 0

			SET @LpcFK = SCOPE_IDENTITY()

			SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
			SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Template' AND PhDelid = 0

			INSERT INTO #ProPrcCalc 
			(
				VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
				TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
			)
			SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk,
					CASE PstcCd WHEN 'PF' THEN ((100.00/(100.00 + 15.00)) * 100) ELSE PrcPPrc END,
					CASE PstcCd WHEN 'PFVAL' THEN ISNULL(@BalPF,0) ELSE PrcPVal END,
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
			SELECT	@LpcFK,CompRef,0,CompCd,CompNm,'',RelCompNm,CompSgn,CompRnd, IsClng, CompPer, CompVal,FinalVal,
					CompTyp,TreeId,IsAccPst,IsVis,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0
			FROM	#ProPrcCalc
		
			EXEC @UNODB @LeadPk,'PFAdjWithLn'

			SET @BalPFWithoutTax = 0
		END
		ELSE
		BEGIN				
			IF OBJECT_ID('TEMPDB..#LnwithPfDet') IS NOT NULL    
				DROP TABLE #LnwithPfDet   

			CREATE TABLE #LnwithPfDet
			(
				ID BIGINT IDENTITY(1,1),LeadFK BIGINT, SancFK BIGINT, SancNo VARCHAR(50), LOAN_AMT NUMERIC(27, 7), TENUR NUMERIC(27, 7),ROI NUMERIC(27, 7),
				EMI NUMERIC(27, 7),LI NUMERIC(27, 7),GI NUMERIC(27, 7),BT_AMT NUMERIC(27, 7),BT_ROI NUMERIC(27, 7),BT_EMI NUMERIC(27, 7),
				BT_LI NUMERIC(27, 7),BT_GI NUMERIC(27, 7),TOPUP_AMT NUMERIC(27, 7),TOPUP_ROI NUMERIC(27, 7),TOPUP_EMI NUMERIC(27, 7),
				TOPUP_LI NUMERIC(27, 7),TOPUP_GI NUMERIC(27, 7),LTV NUMERIC(27, 7),ACT_LTV NUMERIC(27, 7),BT_LTV_A NUMERIC(27, 7),
				TOPUP_LTV_A NUMERIC(27, 7),BT_LTV_M NUMERIC(27, 7),TOPUP_LTV_M NUMERIC(27, 7), TotalPF NUMERIC(27, 7), BTPF NUMERIC(27, 7),
				TopupPF NUMERIC(27, 7),TotalPFCollected NUMERIC(27, 7), BTPFCollected NUMERIC(27, 7),
				TopupPFCollected NUMERIC(27, 7),BalPF NUMERIC(27, 7), BTPFBal NUMERIC(27, 7),
				TopupPFBal NUMERIC(27, 7), Spread NUMERIC(27, 7), TENUR_TOP NUMERIC(27,7), Waiver_ROI NUMERIC(27,7),
				PrdCd VARCHAR(50), PrdFK BIGINT, TotWaiverAmt NUMERIC(27,7), BTWaiverAmt NUMERIC(27,7), TopUpWaiverAmt NUMERIC(27,7),
				ColPfInstrSts Char(1)
			)

			CREATE TABLE #PFwithPrd
			(
				LpcLedFk BIGINT, LpcPrdFk BIGINT, LpcDis NUMERIC(27, 7), LpcWavier NUMERIC(27, 7), LpcChrg NUMERIC(27, 7)
			)

			CREATE TABLE #LedPFTemp
			(
				Rno BIGINT, LpcLedFk BIGINT, InstrChrg NUMERIC(27,7), LpcPk BIGINT, Adj NUMERIC(27,7)
			)
						
			--Sanction Details
			SELECT @MaxRvnNo = MAX(LsnRvnNo) FROM LosSanction WHERE LsnLedFk = @LeadPk And LsnDelId = 0	
			
			INSERT INTO #LnwithPfDet(LeadFK,SancFK,SancNo,TENUR,ROI,LOAN_AMT,EMI,LI,GI,BT_AMT,BT_ROI,BT_EMI,BT_LI,BT_GI,TOPUP_AMT,TOPUP_ROI,TOPUP_EMI,TOPUP_LI,TOPUP_GI,
									 LTV,ACT_LTV,BT_LTV_A,TOPUP_LTV_A,BT_LTV_M,TOPUP_LTV_M, Spread,TENUR_TOP, PrdFK, PrdCd)
			SELECT LsnLedFk,LsnPk,LsnSancNo,[TENUR],[ROI],[LOAN_AMT],[EMI],[LI],[GI],[BT_AMT],[BT_ROI],[BT_EMI],[BT_LI],[BT_GI],[TOPUP_AMT],[TOPUP_ROI],[TOPUP_EMI],[TOPUP_LI],[TOPUP_GI],
				   [LTV],[ACT_LTV],[BT_LTV_A],[TOPUP_LTV_A],[BT_LTV_M],[TOPUP_LTV_M],[SPREAD],[TENUR_TOP], PrdPk, PrdCd
			FROM 
			(
				SELECT B.LsaVal, C.LnaCd, A.LsnLedFk, A.LsnPk, A.LsnSancNo, D.PrdPk, D.PrdCd 
				FROM dbo.LosSanction A 
				JOIN dbo.LosSanctionAttr B ON A.LsnPk = B.LsaLsnFk AND B.LsaDelId = 0
				JOIN dbo.LosLnAttributes C ON B.LsaLnaFk = C.LnaPk AND C.LnaDelId = 0
				JOIN dbo.GenPrdMas D ON A.LsnPrdFk = D.PrdPk
				WHERE A.LsnLedFk = @LeadPk  AND A.LsnDelId = 0 AND A.LsnRvnNo = @MaxRvnNo 
				AND C.LnaCd in ('TENUR','ROI','LOAN_AMT','EMI','LI','GI','BT_AMT','BT_ROI','BT_EMI','BT_LI','BT_GI','TOPUP_AMT','TOPUP_ROI','TOPUP_EMI','TOPUP_LI','TOPUP_GI','LTV','ACT_LTV','BT_LTV_A','TOPUP_LTV_A','BT_LTV_M','TOPUP_LTV_M','SPREAD','TENUR_TOP')
			) pivottable 
			Pivot(Max(LsaVal) For LnaCd In ([TENUR],[ROI],[LOAN_AMT],[EMI],[LI],[GI],[BT_AMT],[BT_ROI],[BT_EMI],[BT_LI],[BT_GI],[TOPUP_AMT],[TOPUP_ROI],[TOPUP_EMI],[TOPUP_LI],[TOPUP_GI],[LTV],[ACT_LTV],[BT_LTV_A],[TOPUP_LTV_A],[BT_LTV_M],[TOPUP_LTV_M],[SPREAD],[TENUR_TOP])) 
			As pivottable

			SELECT @AppPrd = B.PrdCd FROM LosApp A JOIN GenPrdMas B ON A.AppPrdFk = B.PrdPk WHERE A.AppLedFk = @LeadPk
		
			--PF Calculation Details
			SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
			SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Basic Template' AND PhDelid = 0
		
			IF(ISNULL(@Action,'') = 'Credit' OR ISNULL(@Action,'') = 'SancAdj')
			BEGIN
				SELECT @PFPer = perc, @WaiverAmt = ISNULL(waiver,0)
				FROM #PFtable
				WHERE Attr = 'PF'

				SELECT @TotPFWithoutTax =  LOAN_AMT * (@PFPer/100),
						@BTPFWithoutTax = ISNULL(BT_AMT,0) * (@PFPer/100),
						@TopupPFWithoutTax = ISNULL(TOPUP_AMT,0) * (@PFPer/100)
				FROM #LnwithPfDet 		
			END
			ELSE
			BEGIN
				INSERT INTO #PFwithPrd(LpcDis, LpcWavier, LpcPrdFk, LpcLedFk, LpcChrg)
				SELECT B.LpcDis, B.LpcWavier, B.LpcPrdFk, B.LpcLedFk, B.LpcChrg 
				FROM #LnwithPfDet A
				JOIN LosProcChrg(NOLOCK) B ON A.LeadFK = B.LpcLedFk 
				JOIN GenMas C ON C.MasCd = 'PFPAY' AND B.LpcDocTyp = C.MasPk AND C.MasDelid = 0

				SELECT @TotPFWithoutTax =  A.LOAN_AMT * (B.LpcDis/100),						
						@WaiverAmt = ISNULL(B.LpcWavier,0)
				FROM #LnwithPfDet A
				JOIN #PFwithPrd B ON A.LeadFK = B.LpcLedFk
			END

			IF @AppPrd IN ('HLBTTopup','LAPBTTopup')
			BEGIN
				IF (ISNULL(@Action,'') = 'Credit') 
				BEGIN
					SET @BTWaivePercent = ROUND((@BTPFWithoutTax/@TotPFWithoutTax * 100),0)
					SET @TopupWaivePercent = ROUND((@TopupPFWithoutTax/@TotPFWithoutTax * 100),0)

					SET @BTWaiverAmt = ROUND((@WaiverAmt * @BTWaivePercent/100),0)
					SET @TopUpWaiverAmt = ROUND((@WaiverAmt * @TopupWaivePercent/100),0)
				END
				ELSE
				BEGIN
					SELECT @BTWaiverAmt = ISNULL(B.LpcWavier,0), @BTPFWithoutTax = 	ISNULL(B.LpcChrg ,0)				      
					FROM #LnwithPfDet A
					JOIN #PFwithPrd B ON A.LeadFK = B.LpcLedFk AND A.PrdFK = B.LpcPrdFk
					WHERE A.PrdCd IN ('HLBT','LAPBT')

					SELECT @TopUpWaiverAmt= ISNULL(B.LpcWavier,0), @TopupPFWithoutTax = ISNULL(B.LpcChrg ,0)
					FROM #LnwithPfDet A
					JOIN #PFwithPrd B ON A.LeadFK = B.LpcLedFk AND A.PrdFK = B.LpcPrdFk
					WHERE A.PrdCd IN ('HLTopup','LAPTopup')

					SET @WaiverAmt = @BTWaiverAmt + @TopUpWaiverAmt
					SET @TotPFWithoutTax = @BTPFWithoutTax + @TopupPFWithoutTax

					SELECT LpcLedFk 'LedFk',LpcPrdFk 'PrdFk', SUM(ISNULL(LpcChrg,0)) 'Chrg'
					INTO #BTTopUPPFDet
					FROM LosProcChrg(NOLOCK)
					JOIN GenMas ON LpcDocTyp = MasPk AND MasCd IN ('PCA','BPC') 
					WHERE ISNULL(LpcSancNo,'') <> ''
					GROUP BY LpcLedFk,LpcPrdFk
					
					SELECT @BTPFColWithoutTax = ISNULL(A.Chrg,0)
					FROM #BTTopUPPFDet A
					JOIN #LnwithPfDet B ON A.LedFk = B.LeadFk AND A.PrdFK = B.PrdFK
					WHERE B.PrdCd IN ('HLBT','LAPBT')

					SELECT @TopupPFColWithoutTax = ISNULL(A.Chrg,0)
					FROM #BTTopUPPFDet A
					JOIN #LnwithPfDet B ON A.LedFk = B.LeadFk AND A.PrdFK = B.PrdFK
					WHERE B.PrdCd IN ('HLTopup','LAPTopup')
				END

				SET @BTPFWithWaive = @BTPFWithoutTax - @BTWaiverAmt
				SET @TopupPFWithWaive = @TopupPFWithoutTax - @TopUpWaiverAmt
			END

			SET @TotPFWithWaive = @TotPFWithoutTax - @WaiverAmt

			SELECT	@CollPF = SUM(ISNULL(LpcInstrAmt,0)), @CollPFWithoutTax = SUM(ISNULL(LpcChrg,0))
			FROM	LosProcChrg(NOLOCK)
			JOIN	GenMas ON MasCd NOT IN ('PFPAY','PCA','PCLA') AND LpcDocTyp = MasPk AND MasDelid = 0
			WHERE	LpcLedFk = @LeadPk AND LpcDelid = 0 AND ISNULL(LpcChqSts,'') <> 'B'

			
			--COllected PF Instrument Cleared Status
			SELECT  Distinct ISNULL(LpcChqSts,'U') ChqSts
			INTO    #InstSts
			FROM	LosProcChrg(NOLOCK)
			JOIN	GenMas ON MasCd NOT IN ('PFPAY','PCA','PCLA') AND LpcDocTyp = MasPk AND MasDelid = 0
			WHERE	LpcLedFk = @LeadPk AND LpcDelid = 0 --AND ISNULL(LpcChqSts,'') <> 'B'

			IF EXISTS (SELECT 'X' From #InstSts WHERE ChqSts = 'U')
			BEGIN
				UPDATE #LnwithPfDet
				SET ColPfInstrSts = 'U'
			END
			ELSE IF EXISTS (SELECT 'X' From #InstSts WHERE ChqSts = 'B')
			BEGIN
				UPDATE #LnwithPfDet
				SET ColPfInstrSts = 'B'
			END
			ELSE
			BEGIN
				UPDATE #LnwithPfDet
				SET ColPfInstrSts = 'C'
			END

			INSERT INTO #ProPrcCalc 
			(
				VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
				TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
			)
			SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk, PrcPPrc,
					CASE PstcCd WHEN 'PF' THEN ISNULL(@TotPFWithWaive,0) ELSE PrcPVal END,
					PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
					PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
					ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
			FROM	GenPrcDtls (NOLOCK) 
			JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
			WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0

			EXEC PrcLosTaxValuation '', @RowId, @CmpFk

			SELECT	@TotPF = ISNULL(FinalVal,0) FROM #ProPrcCalc(NOLOCK) WHERE CompCd = 'PFVAL'

			IF (@AppPrd IN ('HLBTTopup','LAPBTTopup'))
			BEGIN
				--BT PF Amt
				DELETE FROM #ProPrcCalc
				INSERT INTO #ProPrcCalc 
				(
					VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
					TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
				)
				SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk, PrcPPrc,
						CASE PstcCd WHEN 'PF' THEN ISNULL(@BTPFWithWaive,0) ELSE PrcPVal END,
						PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
						PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
						ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
				FROM	GenPrcDtls (NOLOCK) 
				JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
				WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0

				EXEC PrcLosTaxValuation '', @RowId, @CmpFk

				SELECT	@BTPF = ISNULL(FinalVal,0) FROM #ProPrcCalc(NOLOCK) WHERE CompCd = 'PFVAL'

				--TOPUP PF Amt
				DELETE FROM #ProPrcCalc
				INSERT INTO #ProPrcCalc 
				(
					VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
					TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
				)
				SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk, PrcPPrc,
						CASE PstcCd WHEN 'PF' THEN ISNULL(@TopupPFWithWaive,0) ELSE PrcPVal END,
						PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
						PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
						ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
				FROM	GenPrcDtls (NOLOCK) 
				JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
				WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0

				EXEC PrcLosTaxValuation '', @RowId, @CmpFk

				SELECT	@TopupPF = ISNULL(FinalVal,0) FROM #ProPrcCalc(NOLOCK) WHERE CompCd = 'PFVAL'

			END

			IF(ISNULL(@Action,'') = 'WithoutTax')
			BEGIN
				UPDATE #LnwithPfDet
				SET TotalPF = ROUND(ISNULL(@TotPFWithoutTax,0),0), 
					BTPF = ROUND(ISNULL(@BTPFWithoutTax,0),0), 
					TopupPF = ROUND(ISNULL(@TopupPFWithoutTax,0),0),
					TotalPFCollected = ROUND(ISNULL(@CollPFWithoutTax, 0),0), 
					--BTPFCollected = ROUND(CASE WHEN ISNULL(@BTPFWithWaive,0) > ISNULL(@CollPFWithoutTax,0) THEN ISNULL(@CollPFWithoutTax,0)
					--						 ELSE ISNULL(@BTPFWithWaive,0) END,0),
					--TopupPFCollected = ROUND(CASE WHEN @TotPFWithWaive > @CollPFWithoutTax AND (@CollPFWithoutTax - @BTPFWithWaive) <= 0  THEN 0
					--							  WHEN @TotPFWithWaive > @CollPFWithoutTax AND (@CollPFWithoutTax - @BTPFWithWaive) > 0 THEN @CollPFWithoutTax - @BTPFWithWaive
					--							  WHEN @TotPFWithWaive < @CollPFWithoutTax THEN @CollPFWithoutTax - @BTPFWithWaive
					--						      ELSE @TopupPFWithWaive 
					--						  END,0),
					BTPFCollected = ROUND(ISNULL(@BTPFColWithoutTax,0),0),
					TopupPFCollected = ROUND(ISNULL(@TopupPFColWithoutTax,0),0),
					BalPF = ROUND((ISNULL(@TotPF,0) - ISNULL(@CollPF, 0)),0),
					--BTPFBal = ROUND((ISNULL(@BTPF,0) - (CASE WHEN ISNULL(@BTPF,0) > ISNULL(@CollPF,0) THEN ISNULL(@CollPF,0)
					--								  ELSE ISNULL(@BTPF,0) 
					--							END)),0),
					--TopupPFBal = ROUND((ISNULL(@TopupPF,0) - (CASE WHEN @TotPF > @CollPF AND (@CollPF - @BTPF) <= 0  THEN 0
					--										WHEN @TotPF > @CollPF AND (@CollPF - @BTPF) > 0 THEN @CollPF - @BTPF
					--										ELSE @TopupPF 
					--									END)),0),					
					TotWaiverAmt = ISNULL(@WaiverAmt,0),
					BTWaiverAmt = ISNULL(@BTWaiverAmt,0),
					TopUpWaiverAmt = ISNULL(@TopUpWaiverAmt,0)
			END
			ELSE
			BEGIN
				UPDATE #LnwithPfDet
				SET TotalPF = ROUND(ISNULL(@TotPF,0),0), 
					BTPF = ROUND(ISNULL(@BTPF,0),0), 
					TopupPF = ROUND(ISNULL(@TopupPF,0),0),
					TotalPFCollected = ROUND(ISNULL(@CollPF, 0),0), 
					--BTPFCollected = ROUND(CASE WHEN ISNULL(@BTPF,0) > ISNULL(@CollPF,0) THEN ISNULL(@CollPF,0)
					--						 ELSE ISNULL(@BTPF,0) END,0),
					--TopupPFCollected = ROUND(CASE WHEN @TotPF > @CollPF AND (@CollPF - @BTPF) <= 0  THEN 0
					--						WHEN @TotPF > @CollPF AND (@CollPF - @BTPF) > 0 THEN @CollPF - @BTPF
					--						 ELSE @TopupPF END,0),
					BTPFCollected = ROUND(ISNULL(@BTPFColWithoutTax,0),0),
					TopupPFCollected = ROUND(ISNULL(@TopupPFColWithoutTax,0),0),
					TotWaiverAmt = ISNULL(@WaiverAmt,0),
					BTWaiverAmt = ISNULL(@BTWaiverAmt,0),
					TopUpWaiverAmt = ISNULL(@TopUpWaiverAmt,0)
			
				UPDATE #LnwithPfDet
				SET BalPF = TotalPF - TotalPFCollected,
					BTPFBal = BTPF - BTPFCollected,
					TopupPFBal = TopupPF - TopupPFCollected
			END


			--PF Details Insert
			IF(ISNULL(@Action,'') = 'Credit' OR ISNULL(@Action,'') = 'SancAdj')
			BEGIN
				SELECT @DocFk = MasPk
				FROM GenMas
				WHERE MasCd = 'PFPAY' AND MasDelId = 0

				SELECT	@UsrNm = UsrNm ,@GeoFk = BrnchFk, @AgtFk = AgtFk
				FROM	#GlobalDtls		

				IF NOT EXISTS(
					SELECT 'X' 
					FROM	LosProcChrg(NOLOCK) 
					WHERE	LpcLedFk = @LeadPk AND LpcDocTyp = @DocFk AND LpcDelId = 0 
				)
				BEGIN
					INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
								LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr)
					SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk,
							CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLBT','LAPBT') THEN ROUND(ISNULL(@BTPFWithoutTax,0),0)
								WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLTopup','LAPTopup') THEN ROUND(ISNULL(@TopupPFWithoutTax,0),0)
								ELSE ROUND(ISNULL(@TotPFWithoutTax,0),0)
							END,
							0,NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,
							CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLBT','LAPBT') THEN @BTWaiverAmt
								WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLTopup','LAPTopup') THEN @TopUpWaiverAmt
								ELSE @WaiverAmt
							END, @DocFk, SancNo, 'D' 
					FROM #LnwithPfDet 										
				END
				ELSE 
				BEGIN					
					UPDATE	LosProcChrg 
					SET LpcLedFk = @LeadPk , LpcAgtFk = @AgtFk  ,LpcBGeoFk = @GeoFk,LpcPrdFk = PrdFk,
						LpcChrg =  CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLBT','LAPBT') THEN ROUND(@BTPFWithoutTax,0)
										WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLTopup','LAPTopup') THEN ROUND(@TopupPFWithoutTax,0)
										ELSE ROUND(@TotPFWithoutTax,0)
									END,
						LpcPayTyp = NULL,LpcInstrNo = NULL,LpcModifiedBy = @UsrNm, LpcModifiedDt = @CurDt,LpcDis = @PFPer ,
						LpcWavier =  CASE WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLBT','LAPBT') THEN @BTWaiverAmt
											WHEN @AppPrd IN ('HLBTTopup','LAPBTTopup') AND PrdCd IN('HLTopup','LAPTopup') THEN @TopUpWaiverAmt
											ELSE @WaiverAmt
									END 					
					FROM	#LnwithPfDet(NOLOCK) 
					WHERE LpcLedFk = @LeadPk AND LpcSancNo = SancNo AND LpcPrdFk = PrdFK
					AND LpcDelId = 0 AND LpcDocTyp = @DocFk 								
				END	
				
				--Amount Collected against Lead will be adjusted
				IF(ISNULL(@Action,'') = 'SancAdj')
				BEGIN
					SELECT @AdjDocFk = MasPk
					FROM GenMas
					WHERE MasCd = 'PCA' AND MasDelId = 0						

					IF NOT EXISTS(
						SELECT 'X' 
						FROM	LosProcChrg(NOLOCK) 
						WHERE	LpcLedFk = @LeadPk AND LpcDocTyp = @AdjDocFk AND LpcDelId = 0 
					)
					BEGIN						
						--Debit
						INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
									LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr)
						SELECT TOP 1 @LeadPk,@AgtFk ,@GeoFk,PrdFk, @CollPFWithoutTax,
								0,NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,
								@WaiverAmt, @AdjDocFk, NULL, 'D' 
						FROM #LnwithPfDet				
					
						
						INSERT INTO #LedPFTemp(Rno, LpcLedFk, InstrChrg, LpcPk, Adj)
						SELECT ROW_NUMBER() OVER(ORDER BY LpcPk), LpcLedFk, LpcChrg , LpcPk, 0 
						FROM LosProcChrg A
						JOIN GenMas B ON A.LpcDocTyp = B.MasPk AND B.MasDelId = 0
						where LpcLedFk = @LeadPk AND MasCd IN('IMC','BPC') AND LpcDelId = 0 AND ISNULL(LpcSancNo,'') = ''
						Order BY A.LpcPk

						IF(@AppPrd IN ('HLBTTopup','LAPBTTopup'))
						BEGIN
							DECLARE @I INT = 1, @Cnt INT = 0, @UpdAmt NUMERIC(27,7) = 0

							SELECT @Cnt = COUNT(*) FROM LosProcChrg

							IF(@CollPFWithoutTax > @BTPFWithoutTax)
							BEGIN
								WHILE (@I <= (SELECT COUNT(*) FROM #LedPFTemp))
								BEGIN	
									SELECT @UpdAmt = SUM(Adj) FROM #LedPFTemp

									IF(@UpdAmt < @BTPFWithoutTax)
									BEGIN
										INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
																LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr,
																LpcDocDt, LpcDpdFK)					
										SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk,  CASE WHEN InstrChrg <= (@BTPFWithoutTax - @UpdAmt) THEN InstrChrg ELSE @BTPFWithoutTax - @UpdAmt END,
												0,NULL,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
												@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,@WaiverAmt, @AdjDocFk, SancNo, 'C',
												@CurDt, C.LpcPk
										FROM #LnwithPfDet A
										JOIN #LedPFTemp B On A.LeadFK = B.LpcLedFk
										JOIN LosProcChrg C On B.LpcLedFk = C.LpcLedFk AND B.LpcPk = C.LpcPk AND C.LpcDelId = 0
										WHERE Rno = @I AND A.PrdCd IN ('HLBT','LAPBT')
									
										UPDATE #LedPFTemp
										SET Adj = CASE WHEN InstrChrg <= (@BTPFWithoutTax - @UpdAmt) THEN InstrChrg ELSE @BTPFWithoutTax - @UpdAmt END
										FROM #LedPFTemp
										WHERE Rno = @I 

										IF EXISTS (SELECT 'X' FROM #LedPFTemp WHERE Rno = @I AND InstrChrg = Adj)
										BEGIN
											SET @I += 1
										END
									END
									ELSE
									BEGIN
										INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
																LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr,
																LpcDocDt, LpcDpdFK)					
										SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk, B.InstrChrg - B.Adj,
												0,NULL,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
												@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,@WaiverAmt, @AdjDocFk, SancNo, 'C',
												@CurDt, C.LpcPk
										FROM #LnwithPfDet A
										JOIN #LedPFTemp B On A.LeadFK = B.LpcLedFk
										JOIN LosProcChrg C On B.LpcLedFk = C.LpcLedFk AND B.LpcPk = C.LpcPk AND C.LpcDelId = 0
										WHERE Rno = @I AND A.PrdCd IN ('HLTopup','LAPTopup') 
								
										SET @I += 1
									END
								END
							END
							ELSE
							BEGIN
								INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
														LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr,
														LpcDocDt, LpcDpdFK)					
								SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk, InstrChrg,
										0,NULL,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
										@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,@WaiverAmt, @AdjDocFk, SancNo, 'C',
										@CurDt, C.LpcPk
								FROM #LnwithPfDet A
								JOIN #LedPFTemp B On A.LeadFK = B.LpcLedFk
								JOIN LosProcChrg C On B.LpcLedFk = C.LpcLedFk AND B.LpcPk = C.LpcPk AND C.LpcDelId = 0
								WHERE Rno = @I AND A.PrdCd IN ('HLBT','LAPBT')
							END						
							--INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
							--			LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr)					
							--SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk, ROUND(@CollPFWithoutTax,0),
							--	0,NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,
							--	@BTWaiverAmt, @AdjDocFk, SancNo, 'C' 
							--FROM #LnwithPfDet
							--WHERE @CollPF <= @BTPF AND PrdCd IN ('HLBT','LAPBT')
					
							----IF Collected PF greater than BT PF, then excess will be adjusted for TopUp PF - Credit
							--IF(@CollPF > @BTPF)
							--BEGIN
							--	INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
							--				LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr)
							--	--IF COllected PF Greater than BT						
							--	SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk, ROUND(@BTPFWithoutTax,0),
							--			0,NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,
							--			@BTWaiverAmt, @AdjDocFk, SancNo, 'C' 
							--	FROM #LnwithPfDet
							--	WHERE @CollPF > @BTPF AND PrdCd IN ('HLBT','LAPBT')
							--	UNION ALL
							--	--IF COllected PF Greater than BT and Less than Topup - Credit					
							--	SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk, ROUND((@CollPFWithoutTax - @BTPFWithoutTax),0),
							--			0,NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,
							--			@TopUpWaiverAmt, @AdjDocFk, SancNo, 'C' 
							--	FROM #LnwithPfDet
							--	WHERE @CollPF > @BTPF AND @CollPF <= @TopupPF AND PrdCd IN ('HLTopup','LAPTopup')
							--	UNION ALL
							--	--IF COllected PF Greater than BT and greater than Topup  - Credit						
							--	SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk, ROUND(@TopupPFWithoutTax,0),
							--			0,NULL,NULL,@CurDt,NULL,NULL,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,
							--			@TopUpWaiverAmt, @AdjDocFk, SancNo, 'C' 
							--	FROM #LnwithPfDet
							--	WHERE @CollPF >= @TotPF AND PrdCd IN ('HLTopup','LAPTopup')
							--END
						END
						ELSE
						BEGIN
							INSERT INTO LosProcChrg(LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcPrdFk,LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
										LpcRowId,LpcCreatedBy,LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcDis,LpcWavier,LpcDocTyp, LpcSancNo, LpcDrCr,
										LpcDocDt, LpcDpdFK)					
							SELECT @LeadPk,@AgtFk ,@GeoFk,PrdFk, LpcChrg,0,NULL,LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,
								   @RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,0,0,@PFPer,@WaiverAmt, @AdjDocFk, SancNo, 'C',
								   @CurDt, C.LpcPk
							FROM #LnwithPfDet A
							JOIN #LedPFTemp B On A.LeadFK = B.LpcLedFk
							JOIN LosProcChrg C On B.LpcLedFk = C.LpcLedFk AND B.LpcPk = C.LpcPk AND C.LpcDelId = 0
						END		
										
						EXEC @UNODB @LeadPk,'SanctionAdj'						
					END		
				END
			END						
			ELSE IF(ISNULL(@Action,'') = 'WithoutTax')
			BEGIN
				SELECT ID,LeadFK, SancFK, SancNo, LOAN_AMT, TENUR, ROI,	EMI, LI, GI, BT_AMT,BT_ROI,BT_EMI,
						BT_LI ,BT_GI ,TOPUP_AMT ,TOPUP_ROI ,TOPUP_EMI,	TOPUP_LI ,TOPUP_GI ,LTV ,ACT_LTV ,BT_LTV_A ,
						TOPUP_LTV_A ,BT_LTV_M ,TOPUP_LTV_M , TotalPF , BTPF ,TopupPF,TotalPFCollected , BTPFCollected ,
						TopupPFCollected,BalPF, BTPFBal, TopupPFBal, Spread, TENUR_TOP, Waiver_ROI,	PrdCd, PrdFK,
						TotWaiverAmt, BTWaiverAmt, TopUpWaiverAmt, ColPfInstrSts 
				FROM #LnwithPfDet
			END
			ELSE
			BEGIN
				SELECT ID,LeadFK, SancFK, SancNo, LOAN_AMT, TENUR, ROI,	EMI, LI, GI, BT_AMT,BT_ROI,BT_EMI,
						BT_LI ,BT_GI ,TOPUP_AMT ,TOPUP_ROI ,TOPUP_EMI,	TOPUP_LI ,TOPUP_GI ,LTV ,ACT_LTV ,BT_LTV_A ,
						TOPUP_LTV_A ,BT_LTV_M ,TOPUP_LTV_M , TotalPF , BTPF ,TopupPF,TotalPFCollected , BTPFCollected ,
						TopupPFCollected,BalPF, BTPFBal, TopupPFBal, Spread, TENUR_TOP, Waiver_ROI,	PrdCd, PrdFK  
				FROM #LnwithPfDet
			END
		END
	END TRY
	BEGIN CATCH		
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
	END CATCH			
	SET NOCOUNT OFF
	SET ANSI_WARNINGS OFF
END
