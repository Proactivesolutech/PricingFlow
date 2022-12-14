USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcLeadListing_todel]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[PrcLeadListing_todel]
(
	@FlowFk		BIGINT,
	@LeadDtls	VARCHAR(MAX),
	@UsrCd		VARCHAR(50)	=	NULL
)
AS
BEGIN
--RETURN

	SET NOCOUNT ON
	
	DECLARE @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX)
	
	DECLARE @CurSeqFk BIGINT, @UsrFk BIGINT, @CurDt DATETIME, @HisPk BIGINT, 
			@MinFk BIGINT, @MaxFk BIGINT, @BrnchFk BIGINT,
			@RowId VARCHAR(40), @UsrNm VARCHAR(100);
			
	CREATE TABLE #LeadJsonDtls(xx_id BIGINT,LeadPk BIGINT, BrnchFk BIGINT, Branch VARCHAR(100))
	CREATE TABLE #LeadDtls(LeadPk BIGINT, BrnchFk BIGINT, Branch VARCHAR(100))
	CREATE TABLE #FlowDtls(VerFk BIGINT, VerNo TINYINT)

	BEGIN TRY

	IF @@TRANCOUNT = 0
		SET @TranCount = 1

	IF @TranCount = 1
		BEGIN TRAN	

			SELECT	@UsrFk = UsrPk,@CurDt = GETDATE(),@RowId = NEWID(),@UsrNm = ISNULL(@UsrCd,'ADMIN')
			FROM	GenUsrMas (NOLOCK) WHERE UsrNm = ISNULL(@UsrCd,'ADMIN') AND UsrDelid = 0

			IF @LeadDtls !='[]' AND @LeadDtls != ''
			BEGIN
				INSERT INTO #LeadJsonDtls
				EXEC PrcParseJSON @LeadDtls,'LeadPk,BrnchFk,Branch'

				INSERT		INTO #FlowDtls
				SELECT		BvmPk, BvmVerNo
				FROM		BpmVersions(NOLOCK) 
				WHERE		BvmBpmFk = @FlowFk AND BvmDelid = 0
				
				INSERT INTO #LeadDtls
				SELECT	LeadPk,GeoPk,Branch
				FROM	#LeadJsonDtls
				JOIN	GenGeoMas (NOLOCK) ON LTRIM(RTRIM(GeoNm)) = LTRIM(RTRIM(Branch)) AND GeoDelid = 0
				WHERE	NOT EXISTS(SELECT 'X' FROM BpmExec WHERE EXISTS(SELECT 'X' FROM #FlowDtls WHERE BexBvmFk = VerFk) AND BexKeyFk = LeadPk)
				
				SELECT	TOP 1 @FlowFk = VerFk FROM #FlowDtls ORDER BY VerNo DESC
			END

			SELECT	@CurSeqFk = BioPk FROM BpmObjInOut (NOLOCK) 
			JOIN	BpmToolBox (NOLOCK) ON BtbPk = BioBtbFk AND BtbToolNm = 'bpmn:StartEvent' AND BtbDelid = 0
			WHERE	BioBvmFk = @FlowFk AND BioDelId = 0 AND ISNULL(BioSubBfwFk,0) = 0

			SELECT @MinFk = MIN(LeadPk), @MaxFk = MAX(LeadPk) FROM #LeadDtls

			WHILE @MinFk <= @MaxFk
				BEGIN
					SELECT @HisPk = NULL, @BrnchFk = NULL
					
					SELECT @BrnchFk = BrnchFk FROM #LeadDtls WHERE LeadPk = @MinFk
					
					-- Delete the History of Previous Records with Different Flow.
					IF EXISTS(SELECT 'X' FROM BpmExec(NOLOCK) WHERE BexKeyFk = @MinFk AND BexBvmFk <> @FlowFk AND BexDelid = 0)
						EXEC PrcFlushBpmData 'DEL_DATA',@MinFk
				
					INSERT	INTO BpmExec
					(
						BexKeyFk,BexBvmFk,BexBioFk,BexBrnchFk,BexUsrFk,BexRtnBfwFk,BexAutoPass,BexRoundNo,
						BexRowId,BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId
					)
					OUTPUT INSERTED.*
					SELECT	@MinFk,@FlowFk,@CurSeqFk,@BrnchFk,@UsrFk,NULL,0,1,@RowId,@UsrNm,@CurDt,NULL,0
			
					SET @HisPk = SCOPE_IDENTITY()

					EXEC PrcBpmArvNextSeq_todel 'FORWARD_DATA', @UsrFk, @FlowFk, @MinFk, @HisPk,NULL,NULL,NULL,NULL,NULL,NULL,@BrnchFk

					SELECT @MinFk = MIN(LeadPk) FROM #LeadDtls WHERE LeadPk > @MinFk
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
