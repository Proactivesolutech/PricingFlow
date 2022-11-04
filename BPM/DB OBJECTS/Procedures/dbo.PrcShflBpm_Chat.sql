IF OBJECT_ID('PrcShflBpm_Chat','P') IS NOT NULL
	DROP PROCEDURE PrcShflBpm_Chat
GO
CREATE PROCEDURE PrcShflBpm_Chat
(
	@Action			VARCHAR(50)		=	NULL,
	@MsgData		VARCHAR(MAX)	=	NULL,
	@RcptJSON		VARCHAR(MAX)	=	NULL,
	@GlobalXml		VARCHAR(MAX)	=	NULL,
	@HdrFk			BIGINT			=	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	DECLARE @FlowFk BIGINT, @PageFk BIGINT, @FrmUsrFk BIGINT , @DataPk BIGINT
	DECLARE @SbcFk BIGINT
	
	CREATE TABLE #GlobalDetails
	(
		xx_id BIGINT, TempFlowFk BIGINT, CurPage BIGINT, UsrNm VARCHAR(200),UsrPk BIGINT, DataPk BIGINT
	)
	
	CREATE TABLE #RcptDetails
	(
		xx_id BIGINT, UsrFk BIGINT
	)
	CREATE TABLE #ChatDtls(UsrFk BIGINT)
						
	IF @GlobalXml !='[]' AND @GlobalXml != ''
		BEGIN
			INSERT INTO #GlobalDetails
			EXEC PrcParseJSON @GlobalXml,'FlowFk,CurPage,UsrNm,UsrPk,FwdDataPk'
			
			SELECT @FlowFk = TempFlowFk,@PageFk = CurPage,@FrmUsrFk = UsrPk, @DataPk = DataPk FROM #GlobalDetails
		END

	IF @RcptJSON !='[]' AND @RcptJSON != ''
		BEGIN
			INSERT INTO #RcptDetails
			EXEC PrcParseJSON @RcptJSON,'UsrFk'
		END	

	SET @CurDt = GETDATE()

	BEGIN TRY
	 
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
			
		IF @TranCount = 1
		BEGIN TRAN
			
			--RAISERROR('SaveNwMsg',16,1)
			--RETURN
			IF @Action IN ('SaveNwMsg','RplyMsg')
				BEGIN
					
					IF @Action = 'SaveNwMsg'
						BEGIN
							INSERT INTO ProShflBpmChat(SbcFlowFk,SbcDelid,SbcActDt,SbcKeyVal, SbcIsClosed)
							SELECT	@FlowFk, 0, @CurDt, @DataPk , 0

							SELECT @SbcFk = SCOPE_IDENTITY(), @Error = @@ERROR, @RowCount = @@ROWCOUNT
						END
					
					IF ISNULL(@SbcFk,0) = 0
						SET @SbcFk = @HdrFk
						

					INSERT INTO #ChatDtls
					SELECT	UsrFk FROM #RcptDetails

					INSERT INTO ProShflBpmChatHis
					(
						SbchSbcFk,SbchChatMsg,SbcAttachFile,SbchFrmUsrFk,SbchToUsrFk,SbchIsRead,
						SbchDelid,SbchActDt,SbchFrmPageFk
					)
					--OUTPUT INSERTED.*
					SELECT	@SbcFk, @MsgData, NULL, @FrmUsrFk, UsrFk, 1, 0, @CurDt, @PageFk
					FROM	#ChatDtls

					--SELECT * FROM ProShflBpmChatHis
				END	
		
	IF @Trancount = 1 AND @@TRANCOUNT = 1
		COMMIT TRAN
			
	END TRY
	BEGIN CATCH

		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() ,--+ ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
			
	END CATCH
		
END

