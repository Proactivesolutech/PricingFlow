IF OBJECT_ID('PrcShflQueryLog','P') IS NOT NULL
	DROP PROCEDURE PrcShflQueryLog
GO
CREATE PROCEDURE PrcShflQueryLog
(
	@Action			VARCHAR(100) ,
	@GlobalJson		VARCHAR(MAX) = NULL
)
AS
BEGIN
--RETURN
	SET NOCOUNT ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,@RowId VARCHAR(MAX)
	DECLARE @DBNAME VARCHAR(50) = db_name() 	

	SELECT @CurDt = GETDATE(), @RowId = NEWID()	

	CREATE TABLE #GlobalDtls(xx_id BIGINT,UsrPk BIGINT, Qrytxt VARCHAR(MAX) , IpAddr VARCHAR(100), UsrDispNm VARCHAR(200), QryRowId VARCHAR(MAX))

	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN					
	
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'UsrPk,QryTxt,IpAddr,UsrDispNm,QryRowId'

	END
	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN
			
			IF @Action = 'QUERY_LOG'
			BEGIN
				INSERT	INTO LosQueryLog(QLUsrFk,QLQuery,QLIpAddress,QLisCommitted,QLRowId,QLExecDt,QLExecBy,QLDelid	)
						OUTPUT	INSERTED.QLRowId
				SELECT	UsrPk,QryTxt,IpAddr,'Y',@RowId,@CurDt,UsrDispNm,0
				FROM	#GlobalDtls
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