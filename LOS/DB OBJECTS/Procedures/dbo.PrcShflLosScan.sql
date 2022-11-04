IF OBJECT_ID('PrcSHFLLosScan','P') IS NOT NULL
	DROP PROCEDURE PrcSHFLLosScan
GO
CREATE PROCEDURE PrcSHFLLosScan
(
	@Action			VARCHAR(100)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,	
	@HdrJson		VARCHAR(MAX)		=   NULL,
	@LpcFK			BIGINT				=	NULL,
	@LeadGrdPk      BIGINT				=	NULL,
	@PfValue		NUMERIC(27,7)		=	NULL,
	@dateJson       VARCHAR(MAX)		=   NULL,
	@IsCnfmHndOvr   CHAR(1)				=   NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON


	DECLARE @LogDtls VARCHAR(MAX), @UNODB VARCHAR(100);
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40);
	DECLARE @LpcChrg NUMERIC(27,7),@LpcInstrAmt NUMERIC(27,7),@LpcPayTyp CHAR(1),@LpcInstrNo VARCHAR(50),@LpcInstrDt DATETIME
	DECLARE	@DocPk BIGINT, @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,
			@selActor TINYINT, @Query VARCHAR(MAX),@bnfk VARCHAR(100),@bbmfk VARCHAR(100),@LpcInstrdepoDt DATETIME,
			@TaxFk BIGINT, @CmpFk BIGINT, @DocFk BIGINT,@Doc_loginDt VARCHAR(20),@Dep_bank BIGINT;
	DECLARE @PrcChrgRef TABLE(LpcFk BIGINT)
	
	CREATE TABLE #GlobalTbl	(xx_id BIGINT,LeadFk BIGINT ,DocFk BIGINT,RefAgtPk BIGINT,RefBGeoFk BIGINT,RefPrdFk BIGINT,UsrDispNm VARCHAR(100))
	CREATE TABLE #LpcInstrDt ( xx_id BIGINT,charges NUMERIC(27,7),InstrAmt NUMERIC(27,7),paytyp CHAR(1),InstrNo VARCHAR(50),InstrDt VARCHAR(20),lead_grdPk BIGINT,
	                           bnfk BIGINT,bbmfk BIGINT,LpcInstrdepoDt VARCHAR(20),Doc_logindt VARCHAR(20),dep_bank BIGINT)
	
	CREATE TABLE #ProPrcCalc
	(
		PrdGrpFk BIGINT, PrdFk BIGINT, Qty NUMERIC(27, 7), PrcTyp TINYINT, CompCd VARCHAR(50), CompNm VARCHAR(100), CompRef BIGINT, 
		Rmks VARCHAR(250), CompPer NUMERIC(27, 7), CompVal NUMERIC(27,7 ), CompSgn INT, CompRnd TINYINT, CompTyp VARCHAR(10), 
		TreeId VARCHAR(250), RelCompNm VARCHAR(100), FinalVal NUMERIC(27, 7), xIsProc BIT,
		PrdCd VARCHAR(50), IsAccPst TINYINT, PrdSrcFk BIGINT, CompPrcTyp TINYINT, VchFk BIGINT, IsClng BIT, IsVis BIT, 
		xRowId UNIQUEIDENTIFIER, xPk BIGINT IDENTITY(1, 1), SeqNo TINYINT, DpdFk BIGINT
	)
	CREATE TABLE #TempDate
	(
	xx_ID BIGINT,Code CHAR(1),DT VARCHAR(15)
	)
	
	SELECT @CurDt = GETDATE(), @RowId = NEWID()		

	IF @GlobalJson !='[]' AND @GlobalJson != '' 
		BEGIN
			INSERT INTO #GlobalTbl				
			EXEC PrcParseJSON @GlobalJson,'LeadFk,DocFk,DocAgtPk,DocBGeoFk,DocPrdFk,UsrDispNm'

			SELECT @UsrDispNm=UsrDispNm , @LeadPk = LeadFk FROM #GlobalTbl
		END

     IF @HdrJson !='[]' AND @HdrJson != ''
		BEGIN
			INSERT INTO #LpcInstrDt
			EXEC PrcParseJSON @HdrJson,'LpcChrg,LpcInstrAmt,LpcPayTyp,LpcInstrNo,LpcInstrDt,lead_grdPk,bnfk,bbmfk,LpcInstrdepoDt,Doc_loginDt,dep_bank'

			SELECT  @LpcInstrAmt=InstrAmt,@LpcPayTyp=paytyp,@LpcInstrNo=InstrNo,@LpcInstrDt=dbo.gefgChar2Date(InstrDt),
					@bnfk=bnfk,@bbmfk=bbmfk,@LpcInstrdepoDt=dbo.gefgChar2Date(LpcInstrdepoDt),@Doc_loginDt=dbo.gefgChar2Date(Doc_logindt),
					@Dep_bank=dep_bank
			FROM    #LpcInstrDt
		END

		IF @dateJson !='[]' AND @dateJson !=''
		BEGIN
		INSERT INTO #TempDate
		EXEC PrcParseJSON @dateJson,'Code,Date' 	
		END

	BEGIN TRY

	IF @@TRANCOUNT = 0
		SET @TranCount = 1


	IF @TranCount = 1
		BEGIN TRAN		

						
		IF @Action = 'DOC_LIST'
		  BEGIN
			SELECT	DocLedFk 'LeadFk',ISNULL(AgtFName,'') + ' ' +  ISNULL(AgtMName,'') + ' ' + ISNULL(AgtLName,'') 'AgentNm',
					DocBGeoFk 'GeoFk',DocPrdFk 'PrdFk',DocActor 'Actor', DocSubActor 'SubActor',DocCat	'Catogory',
					DocSubCat 'SubCatogory',DocNm 'DocName',DocPath 'DocPath',DocPk 'Pk'
			FROM	LosDocument(NOLOCK) 
			JOIN	#GlobalTbl ON LeadFk = DocLedFk
			JOIN	GenAgents(NOLOCK) ON AgtPk = DocAgtFk AND AgtDelid = 0
			WHERE	DocDelId = 0 


			SELECT	LpcChrg 'LpcChrg',LpcInstrAmt 'LpcInstrAmt',LpcPayTyp 'LpcPayTyp',LpcInstrNo 'LpcInstrNo',dbo.gefgDMY(LpcInstrDt) 'LpcInstrDt',
					LpcPk 'LpcFK',dbo.gefgDMY(LpcInstrDepDt) LpcInstrdepoDt,BnkPk 'Bnkpk',BnkNm 'BnkNm',BbmPk 'Branchfk', BbmLoc 'Branchloc',LpcDepBankFK 'dep_bank',GabCd 'bnkCode'
			FROM	LosProcChrg(NOLOCK)
			JOIN    GABnkMas  ON LpcDepBankFK=GabPk 
			JOIN	#GlobalTbl ON   LpcLedFk=LeadFk
			JOIN    GenBnkMas(NOLOCK) ON  BnkPk=LpcBnkFk 
			JOIN    GenBnkBrnchMas(NOLOCK) ON  BbmBnkFk=BnkPk AND BbmPk=LpcBbmFk 
			WHERE	LpcDelId = 0 

			SELECT  dbo.gefgDMY(AdtDt) 'Dt',AdtTyp 'code'
			FROM    LosAppDates
			WHERE   AdtLedFk=@LeadPk AND AdtTyp IN('R','D') AND AdtDelId=0

			IF NOT EXISTS(SELECT 'X' FROM LosProcChrg WHERE LpcLedFk = @LeadPk AND LpcDelId = 0) 
			BEGIN
			   SELECT	GrpNm 'productnm', GrpPk 'productpk', GrpCd 'ProductCode',GrpIconCls 'classNm'
			   FROM		GenLvlDefn(NOLOCK)
			   JOIN		LosLead(NOLOCK) ON LedPGrpFk = GrpPk
			   WHERE	LedPk =  @LeadPk AND GrpDelId = 0 AND LedDelId=0
			 END
			 ELSE
			 BEGIN
			   SELECT	GrpNm 'productnm', GrpPk 'productpk', GrpCd 'ProductCode',GrpIconCls 'classNm'
			   FROM		GenLvlDefn(NOLOCK)
			   JOIN		LosProcChrg(NOLOCK) ON LpcPGrpFk = GrpPk
			   WHERE	LpcLedFk =  @LeadPk AND GrpDelId = 0 AND LpcDelId=0
			 END

			   SELECT	LedPNI 'PNICASE'
			   FROM		LosLead(NOLOCK) 
			   WHERE	LedPk =  @LeadPk AND LedDelId=0
		  END

		IF @Action = 'DELETE_DOC' 
		  BEGIN
			UPDATE A SET A.DocDelId = 1 FROM LosDocument A
			JOIN #GlobalTbl B ON B.LeadFk = A.DocLedFk AND B.DocFk = A.DocPk
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

			    SELECT @DocFk = MasPk FROM GenMas(NOLOCK) WHERE MasCd = 'IMC' AND MasDelid = 0 
			
				INSERT INTO LosProcChrg
				(
					LpcLedFk,LpcAgtFk,LpcBGeoFk,LpcDocTyp,LpcChrg,LpcInstrAmt,LpcPayTyp,
					LpcInstrNo,LpcInstrDt,LpcChqSts,LpcChqClrDt,LpcRowId,LpcCreatedBy,
					LpcCreatedDt,LpcModifiedBy,LpcModifiedDt,LpcDelFlg,LpcDelId,LpcPGrpFk,LpcBnkFk,
					LpcBbmFk,LpcInstrDepDt,LpcDrCr,LpcDepBankFK
				) 
				SELECT	LeadFk,RefAgtPk,RefBGeoFk,@DocFk,0,@LpcInstrAmt,@LpcPayTyp,@LpcInstrNo,
						@LpcInstrDt,NULL,NULL,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,@LeadGrdPk,
						@bnfk,@bbmfk,@LpcInstrdepoDt,'C',@Dep_bank
				FROM	#GlobalTbl 
				
				SET @LpcFK = SCOPE_IDENTITY()
				SELECT SCOPE_IDENTITY() 'LpcFK'

			
				INSERT INTO LosAppDates
	            (
	                AdtLedFk,AdtTyp,AdtDt,AdtRowId,AdtCreatedBy,AdtCreatedDt,AdtModifiedBy,
					AdtModifiedDt,AdtDelFlg,AdtDelId
	            )
				SELECT     @LeadPk,Code,dbo.gefgChar2Date(DT),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,
				           @CurDt,NULL,0
                FROM       #TempDate 
				
				UPDATE	LosLead
				SET		LedPGrpFk = ISNULL(NULLIF(@LeadGrdPk,0),LedPGrpFk),LedModifiedBy = @UsrDispNm, LedModifiedDt = @CurDt, LedRowID = @RowId 
				WHERE	LedPk = @LeadPk

				
		  END

		  IF @Action = 'sel_prd'
			BEGIN
				SELECT  GrpNm 'productnm', GrpPk 'productpk', GrpCd 'ProductCode'
				FROM	GenLvlDefn(NOLOCK)
				WHERE	GrpDelId = 0
			END

		 
		IF @Action='UPDATE'
		  BEGIN 

		    UPDATE LosAppDates SET AdtDelId=1 WHERE AdtLedFk=@LeadPk AND AdtTyp IN ('R','D')

			UPDATE	LosProcChrg
			SET		LpcChrg = ISNULL(@LpcChrg,0), LpcInstrAmt = @LpcInstrAmt,LpcPayTyp = @LpcPayTyp,LpcInstrNo = @LpcInstrNo,LpcInstrDt = @LpcInstrDt,
					LpcPGrpFk=@LeadGrdPk,LpcRowId = @RowId, LpcModifiedBy = @UsrDispNm, LpcModifiedDt = @CurDt,
					LpcBnkFk=@bnfk,LpcBbmFk=@bbmfk,LpcInstrDepDt=@LpcInstrdepoDt,LpcDepBankFK=@Dep_bank
			WHERE	LpcPK = @LpcFK
		
			UPDATE	LosLead
			SET		LedPGrpFk = ISNULL(NULLIF(@LeadGrdPk,0),LedPGrpFk),LedModifiedBy = @UsrDispNm, LedModifiedDt = @CurDt, LedRowID = @RowId 
			WHERE	LedPk = @LeadPk

			INSERT INTO LosAppDates
	            (
	                AdtLedFk,AdtTyp,AdtDt,AdtRowId,AdtCreatedBy,AdtCreatedDt,AdtModifiedBy,
					AdtModifiedDt,AdtDelFlg,AdtDelId
	            )
				SELECT     @LeadPk,Code,dbo.gefgChar2Date(DT),@RowId,@UsrDispNm,@CurDt,@UsrDispNm,
				           @CurDt,NULL,0
                FROM       #TempDate  	 

			SELECT @LpcFK 'LpcFK'
		  END
		 
		 IF @Action = 'CREDIT_TAX'
			BEGIN
				SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
				
				IF ISNULL(@PfValue,0) = 0
					BEGIN
				
						INSERT INTO @PrcChrgRef(LpcFk)
						SELECT	LpcPk
						FROM	LosProcChrg(NOLOCK)
						WHERE	LpcLedFk = @LeadPk AND LpcDelid = 0
						
						SELECT		CASE LpcdPcdCd WHEN 'PFVAL' THEN 'PF Received' ELSE LpcdPcdDispNm  END 'CompNm',  
									CASE WHEN LpcdPcdCd = 'PF' THEN '' WHEN ISNULL(LpcdPer,0) = 0 THEN '' ELSE dbo.GefgCurFormat(LpcdPer,@CmpFk) END 'Per', 
									dbo.GefgCurFormat(ROUND(SUM(ISNULL(LpcdAmt,0)),0),@CmpFk) 'TaxAmt'
						FROM		LosProcChrgDtls(NOLOCK)
						WHERE		EXISTS(SELECT 'X' FROM @PrcChrgRef WHERE LpcdLpcFk = LpcFk) AND LpcdDelid = 0
						GROUP BY	LpcdPcdDispNm, LpcdPcdCd, LpcdPer, LpcdPTreeId
						ORDER BY	LpcdPTreeId DESC
					END
				ELSE
					BEGIN						
						IF ISNULL(@PfValue,0) > 0
							BEGIN
								SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Basic Template' AND PhDelid = 0
				
								INSERT INTO #ProPrcCalc 
								(
									VchFk, PrdGrpFk, PrdFk, Qty, PrcTyp, CompCd, CompNm, CompRef, CompPer, CompVal, CompSgn, CompRnd, CompTyp, 
									TreeId, RelCompNm, xIsProc, xRowId, IsAccPst, PrdCd, CompPrcTyp, IsClng, IsVis, SeqNo, DpdFk
								)
								SELECT	0,0,0,1,5,PstcCd,PstcDispNm,PstcPk, PrcPPrc,
										CASE PstcCd WHEN 'PF' THEN ISNULL(@PfValue,0) ELSE PrcPVal END,
										PrcPSgn,PrcPRndOffDml,PrcPPrmDep,
										PrcPPTreeId,PrcPRelPcdCd,0,@RowId,PrcIsAccPst,'',0,PrcIsCeling,PrcIsVisible,
										ROW_NUMBER()OVER(ORDER BY PrcPPTreeId DESC),0
								FROM	GenPrcDtls (NOLOCK) 
								JOIN	GenCompStrutsCodes WITH(NOLOCK) ON PstcPk = PrcPPstcFk AND PstcDelId = 0
								WHERE	PrcPPhFk = @TaxFk AND PrcPDelid = 0
			
								EXEC PrcLosTaxValuation '', @RowId, @CmpFk
								
								SELECT		CASE CompCd WHEN 'PFVAL' THEN 'Total Amount' ELSE CompNm  END 'CompNm',
											CASE WHEN CompCd = 'PF' THEN '' WHEN ISNULL(CompPer,0) = 0 THEN '' ELSE dbo.GefgCurFormat(CompPer,@CmpFk) END 'Per', 
											dbo.GefgCurFormat(ROUND(SUM(ISNULL(FinalVal,0)),0),@CmpFk) 'TaxAmt'
								FROM		#ProPrcCalc(NOLOCK)
								GROUP BY	CompNm, CompCd, CompPer,TreeId
								ORDER BY	CASE CompCd WHEN 'PFVAL' THEN '099' ELSE TreeId END DESC
							END
					END

					--PF Instrument Details 
					SELECT	LpcInstrNo 'LpcInstrNo',dbo.gefgDMY(LpcInstrDt) 'LpcInstrDt',LpcInstrAmt 'LpcInstrAmt',
							LpcPk 'LpcFK',dbo.gefgDMY(LpcInstrDepDt) 'LpcInstrdepoDt',LpcDepBankFK 'dep_bank',GabCd 'BankNm',
							CASE WHEN ISNULL(LpcChqSts,'') = '' THEN  'Unknown' WHEN ISNULL(LpcChqSts,'') = 'C' THEN 'Cleared' WHEN ISNULL(LpcChqSts,'') = 'B' THEN 'Bounced' END	'Chq_sts'
					FROM	LosProcChrg(NOLOCK)
					JOIN    GABnkMas  ON LpcDepBankFK=GabPk 
					--JOIN	GenBnkMas(NOLOCK) ON  BnkPk= LpcBnkFk
					WHERE	LpcLedFk = @LeadPk AND LpcDelId = 0

					SELECT	ISNULL(SUM(lpcdamt),0)  'totclrdPF'FROM LosProcChrg a 
					JOIN	LosProcChrgDtls b ON a.LpcPk=b.LpcdLpcFk 
					WHERE	LpcLedFk=@LeadPk and LpcdPcdCd='PF' AND LpcDelId = 0 AND LpcdDelId = 0
					AND		LpcChqSts ='C' 
					--SELECT A.LpcInstrNo 'InstrNo', A.LpcInstrDt 'InstrDt' ,A.LpcInstrAmt 'InstrAmt',
					--	   A.LpcInstrDepDt 'InstrDepDt', B.GabNm 'InstrDepBank', 
					--	   CASE WHEN ISNULL(A.LpcChqSts,'') = 'C' THEN 'Cleared' 
					--			WHEN ISNULL(A.LpcChqSts,'') = 'B' THEN 'Bounced'
					--			ELSE 'Unkonown'
					--	   END
					--FROM dbo.LosProcChrg A
					--JOIN dbo.GABnkMas B ON A.LpcDepBankFK = B.GabPk AND A.LpcDelId = 0 AND B.GabDelId = 0
					--WHERE A.LpcLedFk = @LeadPk AND A.LpcDocTyp IN (3,6)
					
			END
			
		 IF @Action IN ('INSERT','UPDATE')
			BEGIN

			
				SELECT @CmpFk = CmpPk FROM GenCmpMas(NOLOCK) WHERE CmpDelid = 0
				SELECT @TaxFk = PhPk FROM GenPriceHdr(NOLOCK) WHERE PhNm = 'PF Template' AND PhDelid = 0

				UPDATE	LosProcChrgDtls SET LpcdDelid = 1, LpcdModifiedBy = @UsrDispNm, LpcdModifiedDt = @CurDt 
				WHERE	LpcdLpcFk = @LpcFK AND LpcdDelid = 0

				IF ISNULL(@LpcInstrAmt,0) > 0
					BEGIN
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
						WHERE	LpcLedFk = @LeadPk AND LpcdLpcFk = @LpcFK AND LpcPk = LpcdLpcFk AND LpcdPcdCd = 'PF' AND LpcdDelid = 0
						
						--Accounts Entry
						IF(@IsCnfmHndOvr = 'Y')
						BEGIN
							SELECT @UNODB = CmpUNODB + '.dbo.PrcShflReceiptAccEntry' 
							FROM GenCmpMas 
							WHERE CmpDelId = 0

							EXEC @UNODB @LeadPk,'LeadReceipt'
						END
					END	
			END

		--EXEC PrcShflGenLog @LogDtls,1000,@DocPk,@Query,0

	
	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	

		SELECT	@ErrMsg = ERROR_MESSAGE() ,--+ ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()	

	
		RAISERROR('%s', @ErrSeverity, 1 ,@ErrMsg) 		
		RETURN
		
	END CATCH

		

END

