IF OBJECT_ID('PrcShflRuleCheck','P') IS NOT NULL
	DROP PROCEDURE PrcShflRuleCheck
GO
CREATE PROCEDURE PrcShflRuleCheck
(
	@QdeFk		VARCHAR(20)	=	NULL,
	@CusFk		VARCHAR(20)	=	NULL
)
AS
BEGIN

	SET NOCOUNT ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	DECLARE @Where VARCHAR(200);
	
	DECLARE @ParentMinFk BIGINT, @ParentMaxFk BIGINT,@MinPk BIGINT, @MaxPk BIGINT , @QryString VARCHAR(MAX)
	DECLARE @TblNms VARCHAR(MAX), @ColNms VARCHAR(MAX), @EmptyCols VARCHAR(MAX),@SplitCol1Val VARCHAR(250), @SplitCol2Val VARCHAR(250), @Operator VARCHAR(10),
			@ColBuilder VARCHAR(500), @RulNm VARCHAR(500), @NullBuilder VARCHAR(MAX)
	DECLARE @ColNmsTbl TABLE(RowNo BIGINT, ColNm VARCHAR(100), Typ VARCHAR(10))
	
	CREATE TABLE #RuleList(RuleNm VARCHAR(500),ParentPk BIGINT, RowNo BIGINT, Col1 VARCHAR(500), Col2 VARCHAR(500), Operator VARCHAR(10))
	CREATE TABLE #LoopRuleList(RuleNm VARCHAR(500),ParentPk BIGINT, RowNo BIGINT, Col1 VARCHAR(500), Col2 VARCHAR(500), Operator VARCHAR(10))
	CREATE TABLE #FinalResult(SNo BIGINT IDENTITY(1,1), RuleNm VARCHAR(500), Operator VARCHAR(100),CusFk BIGINT, CusNo BIGINT)	

	IF (1=2)
		CREATE TABLE #RtnResult(SNo BIGINT IDENTITY(1,1), RuleNm VARCHAR(500), QdeFk BIGINT, CusFk BIGINT,Operator VARCHAR(100))

	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN
			
				INSERT INTO #RuleList(RuleNm, ParentPk, RowNo, Col1, Col2, Operator)
				SELECT		LdrRuleNm, LdrPk, ROW_NUMBER() OVER (PARTITION BY LdrPk ORDER BY LddPk) 'RowNo', 
							LdcSrcCol, LdcDestCol ,LddOperator
				FROM		LosDedRulHdr (NOLOCK)
				JOIN		LosDedRulDtls (NOLOCK) ON LddLdrFk = LdrPk 
				JOIN		LosDedColMat (NOLOCK) ON LddLdcFk = LdcPk 
				ORDER BY	LdrPk
				
				SELECT @ParentMinFk = MIN(ParentPk), @ParentMaxFk = MAX(ParentPk) FROM #RuleList

		WHILE @ParentMinFk <= @ParentMaxFk
			BEGIN
				
				DELETE FROM #LoopRuleList
				DELETE FROM @ColNmsTbl
				SELECT @MinPk = 0, @MaxPk = 0, @ColNms = '', @TblNms = '',@QryString = '', @RulNm = '', @EmptyCols = '';
				
				INSERT	INTO #LoopRuleList
				SELECT	RuleNm, ParentPk, RowNo, Col1, Col2, Operator
				FROM	#RuleList
				WHERE	ParentPk = @ParentMinFk

				SELECT	@MinPk = MIN(RowNo) , @MaxPk = MAX(RowNo), @RulNm = RuleNm
				FROM	#LoopRuleList GROUP BY RuleNm 

				WHILE @MinPk <= @MaxPk
					BEGIN
						SELECT	@SplitCol1Val = '', @SplitCol2Val = '', @Operator = '', @ColBuilder = '', @NullBuilder = '';
						
						SELECT	@SplitCol1Val = REPLACE(Col1,'~','_Tbl~'),@SplitCol2Val = REPLACE(Col2,'~','_Tbl~'),
								@Operator = Operator
						FROM	#LoopRuleList WHERE RowNo = @MinPk
						
						INSERT INTO @ColNmsTbl
						SELECT	@MinPk,REPLACE(items,'_Tbl',' (NOLOCK)'), CASE WHEN items LIKE '%_Tbl' THEN 'T' ELSE types END
						FROM	dbo.split(@SplitCol1Val,'~','C')
						WHERE	NOT EXISTS(SELECT 'X' FROM @ColNmsTbl WHERE ColNm = REPLACE(items,'_Tbl',' (NOLOCK)'))
						
						INSERT	INTO @ColNmsTbl
						SELECT	@MinPk,REPLACE(items,'_Tbl',' (NOLOCK)'), CASE WHEN items LIKE '%_Tbl' THEN 'T' ELSE types END
						FROM	dbo.split(@SplitCol2Val,'~','Q')
						WHERE	NOT EXISTS(SELECT 'X' FROM @ColNmsTbl WHERE ColNm = REPLACE(items,'_Tbl',' (NOLOCK)'))
						
						SELECT	@ColBuilder =  ColNm FROM @ColNmsTbl WHERE RowNo = @MinPk AND Typ = 'C'
									
						SELECT	@ColBuilder = @ColBuilder + ' ' + @Operator + ' '  + 
											  CASE @Operator WHEN 'LIKE' THEN '''%''+' + ColNm + '+''%''' ELSE ColNm END + 
											  CASE WHEN @MinPk = @MaxPk THEN  '' ELSE ' AND ' END,
								@NullBuilder = @NullBuilder + 'ISNULL(NULLIF('+ ColNm + ',''''),'''') <> ''''' +
											   CASE WHEN @MinPk = @MaxPk THEN  '' ELSE ' AND ' END
						FROM	@ColNmsTbl WHERE RowNo = @MinPk AND Typ = 'Q'
						
						SELECT	@ColNms = ISNULL(@ColNms,'') + @ColBuilder
						SELECT  @EmptyCols = ISNULL(@EmptyCols,'') + @NullBuilder
						
						SELECT  @MinPk = MIN(RowNo)FROM #LoopRuleList WHERE RowNo > @MinPk
					END

					SELECT @ColNms = ISNULL(@ColNms,'') + ' AND ' + ISNULL(@EmptyCols,'')

					SELECT	@TblNms = ISNULL(@TblNms,'') +  ColNm + ',' FROM  @ColNmsTbl WHERE Typ = 'T'
					SET		@TblNms = LEFT(@TblNms, (LEN(@TblNms) - 1))
					SET		@Where = ''
					
					IF CHARINDEX('LosQdeAddress',@TblNms) > 0
						SELECT @Where = ' AND QdaQdeFk = QdePk '
					
					IF CHARINDEX('LosCustomerAddress',@TblNms) > 0
						SELECT @Where = ISNULL(@Where,'') + ' AND CadCusFk = CusPk '
			
					SELECT @QryString = 'SELECT '''+ @RulNm + ''' ''RuleNm'', '''+ @Operator + ''' ''Operator'',CusPk,0 FROM '+ @TblNms +' WHERE ' + @ColNms + ' AND QdePk = '+ @QdeFk + ' ' + ISNULL(@Where,'') +' AND CusPk NOT IN (' + ISNULL(@CusFk,'0') + ')'
	
					INSERT INTO #FinalResult
					EXEC(@QryString)
				
					--IF @@ROWCOUNT > 0
					--	PRINT @QryString
					
					SELECT @ParentMinFk = MIN(ParentPk)FROM #RuleList WHERE ParentPk > @ParentMinFk
			END
			
			INSERT INTO #FinalResult(RuleNm, Operator, CusFk, CusNo)
			SELECT	RuleNm, Operator, CusFk, ROW_NUMBER() OVER(PARTITION BY CusFk ORDER BY Operator)
			FROM	#FinalResult
			
			IF OBJECT_ID('tempdb..#RtnResult') IS NOT NULL
				BEGIN
					INSERT INTO #RtnResult
					SELECT RuleNm 'RuleNm', @QdeFk 'QdeFk', CusFk 'CusFk' ,Operator 'Operator'FROM #FinalResult 
					WHERE	CusNo = 1
					ORDER BY Operator
				END
			ELSE
				SELECT	RuleNm 'RuleNm', @QdeFk 'QdeFk', CusFk 'CusFk' ,Operator 'Operator' FROM #FinalResult 
				WHERE	CusNo = 1 
				ORDER BY Operator

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
