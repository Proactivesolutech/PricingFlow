IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflManualDeviation' AND [type]='P')
	DROP PROC PrcShflManualDeviation
GO
CREATE PROCEDURE PrcShflManualDeviation
(
	@Action			VARCHAR(MAX)		=	NULL,
	@GlobalJson		VARCHAR(MAX)		=	NULL,
	@DetailsJSON	VARCHAR(MAX)		=	NULL,
	@Stage			CHAR(1)				=	NULL
)
AS
BEGIN
--RETURN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40);

	
	DECLARE	@DocPk BIGINT, @LeadPk BIGINT, @GeoFk BIGINT, @UsrPk BIGINT, @UsrDispNm VARCHAR(100), @UsrNm VARCHAR(100),@PrdFk BIGINT,@AgtFk BIGINT,
			@selActor TINYINT, @Query VARCHAR(MAX),@AppFk BIGINT,@LapFk BIGINT,@NHBdepndtFk BIGINT,
			@CreditPk BIGINT,@CreditJson VARCHAR(MAX)  ,@SalType  VARCHAR(3) ,  @SalPrf  VARCHAR(3),@PrdType  VARCHAR(3),@PrdGrpType VARCHAR(2);

	DECLARE @FeedPk BIGINT , @pop_text VARCHAR(500);
	
	DECLARE @DeviationJson VARCHAR(MAX);

	CREATE TABLE #GlobalDtls(xx_id BIGINT,LeadPk BIGINT, GeoFk BIGINT, UsrPk BIGINT, UsrDispNm VARCHAR(100),UsrNm VARCHAR(100), PrdCd VARCHAR(100),DocDelPK BIGINT,
				RoleFk BIGINT, BrnchFk BIGINT, PrdNm VARCHAR(100), LeadNm VARCHAR(200), LeadID VARCHAR(100), PrdFk BIGINT, AgtNm VARCHAR(100), AgtFk BIGINT, 
				Branch VARCHAR(200),SalType VARCHAR(3),SalPrf VARCHAR(3),PrdType VARCHAR(3),PrdGrpType VARCHAR(3))
	
	CREATE TABLE #DetailsTbl(xx_Id BIGINT,DeviationJson VARCHAR(MAX));

	CREATE TABLE #DeviationTable (xx_Id BIGINT, Pk BIGINT , Devtext VARCHAR(MAX),devlevel TINYINT);

	--FOR PRODUCT RESTRICTION			
	DECLARE @PI_PNI VARCHAR(20) , @PROD_GRP VARCHAR(20)	, @SELECTED_PRD VARCHAR(20)	,  @IS_BTTOP VARCHAR(20), @PROD_ERROR VARCHAR(MAX) = ''

	SELECT @CurDt = GETDATE(), @RowId = NEWID()	
	
	IF @GlobalJson != '[]' AND @GlobalJson != ''
	BEGIN					
	
		INSERT INTO #GlobalDtls
		EXEC PrcParseJSON @GlobalJson,'LeadPk,GeoFk,UsrPk,UsrDispNm,UsrNm,PrdCd,DocDelPK,RoleFk,BrnchFk,PrdNm,LeadNm,LeadID,PrdFk,AgtNm,AgtFk,Branch,SalType,SalPrf,PrdType,GrpType'
	
		SELECT	@LeadPk = LeadPk, @AppFk = AppPk, @UsrDispNm = G.UsrDispNm, @UsrNm = G.UsrNm, @SalType = SalType ,
				@PrdType = PrdType, @PrdGrpType = PrdGrpType, @SalPrf = SalPrf , @UsrPk = G.UsrPk , @AgtFk = G.AgtFk ,
				@GeoFk = GeoFk , @PrdFk = AppPrdFk	
		FROM	#GlobalDtls  G
		JOIN	LosApp (NOLOCK) ON AppLedFk = LeadPk AND AppDelId = 0
		JOIN    LosAppProfile (NOLOCK) ON LapLedFk = AppLedFk AND LapDelId = 0	

	END
	
	IF @DetailsJSON != '[]' AND @DetailsJSON != ''
	BEGIN
			
		INSERT INTO #DetailsTbl
		EXEC PrcParseJSON @DetailsJSON,'DeviationJson';		

		SELECT	@DeviationJson = DeviationJson
		FROM	#DetailsTbl		
		
		IF @DeviationJson != '' AND @DeviationJson != '[]'
		BEGIN 
			INSERT INTO #DeviationTable
			EXEC PrcParseJSON @DeviationJson,'Pk,text,level';		
		END
																					
	END
	
	BEGIN TRY
	 

	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN					
		
		IF @Action = 'ADD_MANUALDEV'
		BEGIN			
				
			DELETE T FROM LosDeviation T (NOLOCK)
			JOIN	LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId= 0 AND LnaCd = 'MANUALDEV'
			JOIN	LosManualDeviation (NOLOCK) ON LmdPk = LdvLmdFk AND LmdDelId = 0 AND LmdTyp = @Stage
			WHERE	LdvLedFk = @LeadPk AND LdvLmdFk IS NOT NULL 

			INSERT INTO LosDeviation (LdvLedFk,LdvAppFk,LdvUsrFk,LdvStage,LdvLnaFk,LdvLapFk,LdvArrVal,LdvDevVal,LdvInpSts,LdvDevSts,LdvAppBy,LdvRmks,
									LdvRowId,LdvCreatedBy,LdvCreatedDt,LdvModifiedBy,LdvModifiedDt,LdvDelFlg,LdvDelId,LdvMarginVal,LdvLmdFk)
			OUTPUT	INSERTED.*
			SELECT	@LeadPk,@AppFk,@UsrPk,@Stage,LnaPk,NULL,NULL,NULL,'','D',devlevel,Devtext,@RowId,@UsrDispNm,@CurDt,@UsrDispNm,@CurDt,NULL,0,NULL,Pk
			FROM	#DeviationTable,LosLnAttributes (NOLOCK) 
			WHERE	LnaCd = 'MANUALDEV' AND LnaDelId = 0

		END

		IF @Action = 'MANUALDEV_DATA'
		BEGIN 			
			-- 1 Deviation details			
			SELECT	ISNULL(LmdCategory,'') AS 'category',ISNULL(LmdDeviation,'') AS 'text' ,LmdPk 'Pk'
			FROM	LosManualDeviation (NOLOCK) WHERE LmdDelId = 0 AND LmdTyp = @Stage
			ORDER BY LmdCategory

			-- 2 SELECTED Manual Deviation Details

			SELECT  ISNULL(LmdCategory,'') 'Category' , LmdPk 'Selected' , ISNULL(LdvAppBy,0) 'Level'
			FROM	LosDeviation (NOLOCK)
			JOIN	LosManualDeviation (NOLOCK) ON  LmdPk = LdvLmdFk AND LmdDelid = 0 AND LmdTyp = @Stage
			JOIN	LosLnAttributes (NOLOCK) ON LnaCd = 'MANUALDEV' AND LnaDelId = 0
			WHERE	LdvStage = @Stage AND  LdvLedFk = @LeadPk

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


