USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcGenUsrMaster]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcGenUsrMaster]
(
	@Action				VARCHAR(100)=	NULL,
	@json_usrEntryData	VARCHAR(MAX)=	NULL,
	@json_roledata		VARCHAR(MAX)=	NULL,
	@json_Geodata		VARCHAR(MAX)=	NULL,
	@UsrPk				BIGINT		=	NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT

	DECLARE @UstTempFk BIGINT, @UsrCode NVARCHAR(100) = NULL, @UsrNm VARCHAR(100) = NULL,@UsrPwd VARCHAR(100) = NULL, @UsrRolNm VARCHAR(100) = NULL,
			@UsrGeoNm VARCHAR(100) = NULL, @UsrRolPk BIGINT = NULL,@UsrGeoPk BIGINT = NULL,@UsrRolFk BIGINT = NULL,@UsrGeoFk BIGINT = NULL,
			@RoleFk BIGINT = NULL, @GeoFk BIGINT = NULL


	CREATE TABLE #UsrTempTbl
	(
		xx_id BIGINT,
		UsrCode NVARCHAR(100) NULL,
		UsrNm VARCHAR(100) NULL,
		UsrPwd VARCHAR(100) NULL
	)
	CREATE TABLE #UsrTempRole
	(
		xx_id BIGINT,
		UsrRolFK VARCHAR(100) NULL
	)
	CREATE TABLE #UsrTempGeo
	(
		xx_id BIGINT,
		UsrGeoFk VARCHAR(100) NULL
	)
	
	SELECT @UsrNm = 'ADMIN', @CurDt = GETDATE(), @RowId = NEWID()
	
	IF @json_usrEntryData !='[]' AND @json_usrEntryData != ''
		BEGIN
				INSERT INTO #UsrTempTbl
				EXEC PrcParseJSON @json_usrEntryData,'UserCode,UserName,UserPassword'
		END

	IF @json_roledata !='[]' AND @json_roledata!=''
		BEGIN
				INSERT INTO #UsrTempRole
				EXEC PrcParseJSON @json_roledata,'roledesc'
		END

	IF @json_Geodata !='[]' AND @json_Geodata!=''
		BEGIN
				INSERT INTO #UsrTempGeo
				EXEC PrcParseJSON @json_Geodata,'geodesc'
		END
	
	SET @UstTempFk = @UsrPk;
	
	BEGIN TRY
	
		IF @@TRANCOUNT = 0
			SET @Trancount = 1
					
		IF @Trancount = 1
			BEGIN TRAN
			
				IF @Action = 'SAVE'
				BEGIN
				
					INSERT INTO GenUsrMas(UsrNm,UsrDispNm,UsrPwd,UsrRowId,UsrCreatedDt,UsrCreatedBy,UsrModifiedDt,UsrModifiedBy,UsrDelFlg,UsrDelId) 
					SELECT	UsrCode,UsrNm,dbo.fnAllocWS(UsrPwd),@RowId,@CurDt,@UsrNm,@CurDt,@UsrNm,NULL,0 
					FROM	#UsrTempTbl
					
					SELECT @UstTempFk = SCOPE_IDENTITY(), @Error = @@ERROR, @Rowcount = @@ROWCOUNT
					IF @Error <> 0
						BEGIN
							RAISERROR('Error - User Master Header Insert.',16,1)
							RETURN
						END	
					ELSE IF @Rowcount = 0
						BEGIN
							RAISERROR('User Master - No Data Found to Insert.',16,1)
							RETURN
						END
					ELSE
						BEGIN
							SELECT @UstTempFk 'userpk'
						END

				END
	
				IF @Action = 'UPDATE'
					BEGIN
						
						UPDATE A SET A.UsrNm = B.UsrCode, A.UsrDispNm=B.UsrNm, A.UsrPwd = dbo.fnAllocWS(B.UsrPwd) 
						FROM	GenUsrMas A 
						JOIN	#UsrTempTbl B ON UsrPk = @UstTempFk AND UsrDelid = 0

						SELECT  @Error = @@ERROR
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - User Master Details Update.',16,1)
								RETURN
							END	
					END
				
				IF @Action = 'DELETE'
					BEGIN
					
						UPDATE	GenUsrMas 
						SET		UsrDelId=1, UsrModifiedDt = @CurDt,UsrDelFlg = dbo.gefgGetDelFlg(@CurDt)
						WHERE	UsrPk = @UstTempFk AND UsrDelid = 0

						SELECT  @Error = @@ERROR
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - User Master Details Delete.',16,1)
								RETURN
							END
					END
					
				IF @Action IN ('UPDATE', 'DELETE')
					BEGIN
						UPDATE	GenUsrRoleDtls SET UrdDelId = 1, UrdDelFlg = dbo.gefgGetDelFlg(@CurDt), UrdModifiedDt = @CurDt
						WHERE	UrdUsrFk = @UstTempFk AND UrdDelid = 0
						
						SELECT  @Error = @@ERROR
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - User Role Details Delete.',16,1)
								RETURN
							END
						
						UPDATE	GenUsrBrnDtls SET UbdDelId = 1, UbdDelFlg = dbo.gefgGetDelFlg(@CurDt), UbdModifiedDt = @CurDt
						WHERE	UbdUsrFk = @UstTempFk AND UbdDelid = 0
						
						SELECT  @Error = @@ERROR
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - User Geo Details Delete.',16,1)
								RETURN
							END
					END
					
				IF @Action IN ('SAVE','UPDATE')
					BEGIN
					
						INSERT INTO GenUsrRoleDtls (UrdUsrFk,UrdRolFk,UrdRowId,UrdCreatedDt,UrdCreatedBy,UrdModifiedDt,UrdModifiedBy,UrdDelFlg,UrdDelId) 
						SELECT	@UstTempFk,UsrRolFK,@RowId,@CurDt,@UsrNm,@CurDt,@UsrNm,NULL,0 
						FROM	#UsrTempRole
						
						SELECT  @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - User Role Details Insert.',16,1)
								RETURN
							END	
						IF @Rowcount = 0
							BEGIN
								RAISERROR('User Role Details - No Data Found to Insert.',16,1)
								RETURN
							END	
							

						INSERT INTO GenUsrBrnDtls (UbdUsrFk,UbdGeoFk,UbdRowId,UbdCreatedDt,UbdCreatedBy,UbdModifiedDt,UbdModifiedBy,UbdDelFlg,UbdDelId) 
						SELECT	@UstTempFk,UsrGeoFk,@RowId,@CurDt,@UsrNm,@CurDt,@UsrNm,NULL,0 
						FROM	#UsrTempGeo
						
						SELECT  @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - User Geo Details Insert.',16,1)
								RETURN
							END	
						IF @Rowcount = 0
							BEGIN
								RAISERROR('User Geo Details - No Data Found to Insert.',16,1)
								RETURN
							END
					END
				
				IF @Action='SELECT'
					BEGIN
						SELECT	UsrNm 'UsrCode', UsrDispNm 'UsrNm',UsrPk 'UsrPk',dbo.gefgGetDecPass(UsrPwd) 'UsrPwd'
						FROM	GenUsrMas (NOLOCK) WHERE UsrDelId=0
					END

				IF @Action='SELTBL'
					BEGIN

						SELECT	UsrNm 'UsrCode', UsrDispNm 'UsrNm',UsrPk 'UsrPk',dbo.gefgGetDecPass(UsrPwd) 'UsrPwd'
						INTO	#TempTl
						FROM	GenUsrMas(NOLOCK) WHERE UsrPk=@UstTempFk AND UsrDelId=0
						
						SELECT	UsrCode,UsrNm,UsrPk,UsrPwd FROM #TempTl
						
						SELECT  UrdRolFk 'RoleFk', RolNm ,UrdPk 'UsrRolPk'
						FROM	GenRole(NOLOCK) A 
						JOIN	GenUsrRoleDtls B ON A.RolPk = B.UrdRolFk AND UrdDelid = 0 
						JOIN	#TempTl C ON C.UsrPk = B.UrdUsrFk 
						WHERE	RolDelid = 0

						SELECT  UbdGeoFk 'GeoFk', GeoNm ,UbdPk 'UsrGeoPk'
						FROM	GenGeoMas(NOLOCK) A 
						JOIN	GenUsrBrnDtls B ON A.GeoPk = B.UbdGeoFk AND UbdDelid = 0 
						JOIN	#TempTl C ON C.UsrPk = B.UbdUsrFk 
						WHERE	GeoDelid = 0

						SELECT @UsrPk 'PK'
						
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
