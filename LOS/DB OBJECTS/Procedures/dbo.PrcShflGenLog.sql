IF OBJECT_ID('PrcShflGenLog','P') IS NOT NULL
	DROP PROCEDURE PrcShflGenLog
GO
CREATE  PROCEDURE PrcShflGenLog
(
	@LogJson	VARCHAR(MAX)	=	NULL,
	@ScrId		INT				=	NULL,
	@DocPk		FkId			=	NULL,
	@Query		VARCHAR(MAX)	=	NULL,
	@Sts		TINYINT			=	0,
	@LogErrMsg	VARCHAR(MAX)	=	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40);
	
	SELECT @CurDt = GETDATE(), @RowId = NEWID()
			
	CREATE TABLE #LogDtls
	(
		id BIGINT,LgUsr VARCHAR(100), LgTrsTyp TINYINT,LgIpDynAdd VARCHAR(20),LgIpMcAdd VARCHAR(20),LgMobRDesk TINYINT, 
		LgBrowser VARCHAR(MAX), RLgLatitude VARCHAR(50),RLgLongitude VARCHAR(50),RLgArea VARCHAR(MAX),RLgCity VARCHAR(100),
		RLgState VARCHAR(100),RLgCountry VARCHAR(100)
	)
		
	IF @LogJson != '[]' AND @LogJson != ''
		BEGIN
			INSERT INTO #LogDtls
			EXEC PrcParseJSON @LogJson,'LgUsr,LgTrsTyp,LgIpDynAdd,LgIpMcAdd,LgMobRDesk,LgBrowser,RLgLatitude,RLgLongitude,RLgArea,RLgCity,RLgState,RLgCountry'
		END
		
	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN
				INSERT INTO GenLog
				(
					LogActDate,LogUser,LogTrsTyp,LogSID,LogRefFk,LogQry,LogSts,LogErrMsg,LogIpDynAdd,LogIpMcAdd,LogMobRDesk,
					LogBrowser,LogLongitude,LogLatitude,LogArea,LogCity,LogState,LogCountry
				)
				--OUTPUT INSERTED.*
				SELECT	@CurDt,LgUsr,LgTrsTyp,@ScrId,@DocPk,@Query,ISNULL(@Sts,0),ISNULL(@LogErrMsg,''),LgIpDynAdd,LgIpMcAdd,LgMobRDesk,LgBrowser,
						RLgLatitude,RLgLongitude,RLgArea,RLgCity,RLgState,RLgCountry
				FROM	#LogDtls
				
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
	