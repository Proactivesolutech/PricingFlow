IF OBJECT_ID('PrcShflRemPFCalc','P') IS NOT NULL
	DROP PROCEDURE PrcShflRemPFCalc
GO
CREATE PROCEDURE PrcShflRemPFCalc	 
(
	@LeadPk			BIGINT				=   NULL,
	@TotPF			NUMERIC(27,7)		=	NULL,
	@CollectedPF	NUMERIC(27,7)		=	NULL,
	@Waiver			NUMERIC(27,7)		=	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @RemPF NUMERIC(27,7),@RowId VARCHAR(40), @CmpFk BIGINT, @TaxFk BIGINT

	CREATE TABLE #ProPrcCalc
		(
			PrdGrpFk BIGINT, PrdFk BIGINT, Qty NUMERIC(27, 7), PrcTyp TINYINT, CompCd VARCHAR(50), CompNm VARCHAR(100), CompRef BIGINT, 
			Rmks VARCHAR(250), CompPer NUMERIC(27, 7), CompVal NUMERIC(27,7 ), CompSgn INT, CompRnd TINYINT, CompTyp VARCHAR(10), 
			TreeId VARCHAR(250), RelCompNm VARCHAR(100), FinalVal NUMERIC(27, 7), xIsProc BIT,
			PrdCd VARCHAR(50), IsAccPst TINYINT, PrdSrcFk BIGINT, CompPrcTyp TINYINT, VchFk BIGINT, IsClng BIT, IsVis BIT, 
			xRowId UNIQUEIDENTIFIER, xPk BIGINT IDENTITY(1, 1), SeqNo TINYINT, DpdFk BIGINT
		)

	SELECT @RowId = NEWID()

	--PF Calculation Details
	SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
	SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Basic Template' AND PhDelid = 0

	SET  @RemPF = @TotPF - ISNULL(@Waiver,0) - @CollectedPF
	

		INSERT INTO #ProPrcCalc 
		(
			VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
			TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
		)
		SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk, PrcPPrc,
				CASE PstcCd WHEN 'PF' THEN ISNULL(@RemPF,0) ELSE PrcPVal END,
				PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
				PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
				ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
		FROM	GenPrcDtls (NOLOCK) 
		JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
		WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0
				
		EXEC PrcLosTaxValuation '', @RowId, @CmpFk

	IF(@RemPF <= 0)
	BEGIN
		UPDATE #ProPrcCalc
		SET FinalVal = @RemPF
		FROM #ProPrcCalc 
		WHERE CompCd IN ('PF','PFVAL')

		UPDATE #ProPrcCalc
		SET FinalVal = 0
		FROM #ProPrcCalc 
		WHERE CompCd NOT IN ('PF','PFVAL')
	END		
	
	SELECT	CompCd 'CompCd',CompNm 'CompNm', CompPer'CompPer',ISNULL(ROUND(FinalVal,0),0) 'RemPF'
	FROM #ProPrcCalc(NOLOCK) 			
END




