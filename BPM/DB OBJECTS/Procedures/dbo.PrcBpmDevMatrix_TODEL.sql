USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcBpmDevMatrix_TODEL]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PrcBpmDevMatrix_TODEL]
(
	@Action			VARCHAR(50)		=	NULL,
	@ProcessJSON	VARCHAR(MAX)	=	NULL,
	@AprTyp			CHAR(1)			=	NULL
)
AS
BEGIN
--RAISERROR('Wait',16,1)
--RETURN

	SET NOCOUNT ON
	SET ANSI_WARNINGS ON
	
	/*************************** Global Datas ********************************/
	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @UsrNm VARCHAR(100),@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	
	DECLARE @HisPk BIGINT, @UsrPk BIGINT, @LvlNo TINYINT, @BrnchFk BIGINT, 
			@NewHisFk BIGINT, @AsgndUsrFk BIGINT;
	CREATE TABLE #GlobalDetails
	(
		xx_id BIGINT, UsrPk BIGINT,HisPK BIGINT, LvlNo INT, BrnchFk BIGINT
	)
	CREATE TABLE #TempRights_RolePages_Next(UsrFk BIGINT,UsrBGeoFk BIGINT)
	CREATE TABLE #TempRights_Geo_Next(UsrRef BIGINT,GeoFk BIGINT)
	
	DECLARE @PendingUsrWorks TABLE(PendUsrFk BIGINT,AsgndWork BIGINT,Flg INT)
	
	SELECT @CurDt = GETDATE(), @RowId = NEWID(), @UsrNm = 'ADMIN'
	
	IF @ProcessJSON !='[]' AND @ProcessJSON != ''
	BEGIN
		INSERT INTO #GlobalDetails
		EXEC PrcParseJSON @ProcessJSON,'UsrPk,HisPK,LvlNo,BrnchFk'
	END

	BEGIN TRY

	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	
	IF @TranCount = 1
		BEGIN TRAN	
				IF @Action = 'DEV_FORWARD_DATA'
					BEGIN

						SELECT	@HisPk = HisPk, @UsrPk = UsrPk, @BrnchFk = BrnchFk, @LvlNo = ISNULL(LvlNo,0) + 1
						FROM	#GlobalDetails;

						INSERT	INTO BpmExecStatus
						(
							BesBexFk,BesKeyFk,BesBioFk,BesAutoPass,BesRtnBfwFk,BesRoundNo,BesBvmFk,BesUsrFk,BesBrnchFk,BesDpdFk,
							BesRowId,BesCreatedBy,BesCreatedDt,BesDelFlg,BesDelId
						)
						SELECT	BexPk,BexKeyFk,BexBioFk,BexAutoPass,BexRtnBfwFk,BexRoundNo,BexBvmFk,@UsrPk,BexBrnchFk,BexDpdFk,
								@RowId,@UsrNm,@CurDt,NULL,0
						FROM	BpmExec (NOLOCK)
						WHERE	BexPk = @HisPk AND BexDelId = 0
						
						INSERT	INTO BpmExec
						(
							BexKeyFk,BexBvmFk,BexBioFk,BexUsrFk,BexBrnchFk,BexRtnBfwFk,BexAutoPass,BexRoundNo,BexRowId,
							BexCreatedBy,BexCreatedDt,BexDelFlg,BexDelId,BexDpdFk
						)
						SELECT	BexKeyFk,BexBvmFk,BexBioFk,@UsrPk,BexBrnchFk,BexRtnBfwFk,BexAutoPass,BexRoundNo,
								@RowId,@UsrNm,@CurDt,NULL,0,BexDpdFk
						FROM	BpmExec (NOLOCK)
						WHERE	BexPk = @HisPk AND BexDelId = 0
						
						SELECT @NewHisFk = SCOPE_IDENTITY()

						-- Get the Flow Pages with Roles with the User Filter.			
							INSERT INTO #TempRights_RolePages_Next(UsrFk)
							SELECT		UrdUsrFk
							FROM		LosApprover(NOLOCK)
							JOIN		GenUsrRoleDtls(NOLOCK) ON UrdRolFk =  AprRolFk AND UrdDelid = 0
							WHERE		AprTyp = ISNULL(@AprTyp,'') AND AprLvl = @LvlNo 

							IF NOT EXISTS(SELECT 'X' FROM #TempRights_RolePages_Next)
								BEGIN
									RAISERROR('%s',16,1,'Page Rights not Available for Next Task')
									RETURN
								END
										
						-- Get All the Geo Locations attached to the User
							INSERT INTO #TempRights_Geo_Next(UsrRef,GeoFk)
							SELECT		UbdUsrFk, GeoPk
							FROM		GenUsrBrnDtls(NOLOCK) 
							JOIN		GenGeoMas(NOLOCK) ON GeoPk = UbdGeoFk AND GeoDelid = 0
							WHERE		UbdDelid = 0
							AND			EXISTS(SELECT 'X' FROM #TempRights_RolePages_Next WHERE UsrFk = UbdUsrFk)
							AND			EXISTS
							(
								SELECT	'X' FROM GenGeoMap(NOLOCK) WHERE GemGeoBFk = @BrnchFk
								AND		GeoPk = CASE ISNULL(GeoLvlNo,0) WHEN 1 THEN GemGeoBFk WHEN 2 THEN GemGeoZFk
												WHEN 3 THEN GemGeoSFk WHEN 4 THEN GemGeoCFk END
								AND		GeoDelid = 0
							)
						
							UPDATE		#TempRights_RolePages_Next SET UsrBGeoFk = GeoFk FROM #TempRights_Geo_Next WHERE UsrFk = UsrRef
							DELETE FROM #TempRights_RolePages_Next WHERE ISNULL(UsrBGeoFk,0) = 0
									
							SET @ErrMsg = '';
									
							SELECT @ErrMsg = @ErrMsg + dbo.gefgGetDesc(UsrFk,1) + ',' FROM #TempRights_RolePages_Next  
							WHERE  NOT EXISTS(SELECT 'X' FROM #TempRights_Geo_Next WHERE UsrRef = UsrFk)
							GROUP BY UsrFk

							IF ISNULL(@ErrMsg,'') <> ''
								BEGIN
									SELECT @ErrMsg = 'Branch Rights not Available for User(s)  - ' + LEFT(@ErrMsg,LEN(@ErrMsg)-1) + '.';
									RAISERROR('%s',16,1,@ErrMsg)
									RETURN
								END
										
						INSERT INTO @PendingUsrWorks
						SELECT		BnoUsrFk,COUNT(BnoUsrFk),0
						FROM		BpmNextOpUsr(NOLOCK)
						WHERE		NOT EXISTS(SELECT 'X' FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelid = 0)
						AND			NOT EXISTS(SELECT 'X' FROM GenUsrMas(NOLOCK) WHERE UsrNm = 'ADMIN' AND UsrPk = BnoUsrFk AND UsrDelid = 0)
						AND			EXISTS(SELECT 'X' FROM #TempRights_Geo_Next WHERE UsrRef = BnoUsrFk)
						GROUP BY	BnoUsrFk
						
						INSERT INTO @PendingUsrWorks
						SELECT		UsrRef,0,0
						FROM		#TempRights_Geo_Next
						WHERE		NOT EXISTS(SELECT 'X' FROM @PendingUsrWorks WHERE PendUsrFk = UsrRef)
						AND			NOT EXISTS(SELECT 'X' FROM GenUsrMas(NOLOCK) WHERE UsrNm = 'ADMIN' AND UsrPk = UsrRef AND UsrDelid = 0)
						GROUP BY	UsrRef
						
						INSERT INTO @PendingUsrWorks
						SELECT		PendUsrFk, ROW_NUMBER() OVER(ORDER BY AsgndWork,PendUsrFk), 1
						FROM		@PendingUsrWorks
						
						SELECT @AsgndUsrFk = PendUsrFk FROM @PendingUsrWorks WHERE AsgndWork = 1 AND Flg = 1
						
						IF ISNULL(@AsgndUsrFk,0) = 0
							BEGIN
								RAISERROR('%s',16,1,'No User Exists in Next Level. Create User and Try Again')
								RETURN
							END
							
						INSERT INTO BpmNextOpUsr
						(
							BnoUsrFk,BnoBexFk,BnoBvmFk,BnoBioFk,BnoBudFk,BnoStatus,BnoDataPk,BnoBfwFk
						)
						--OUTPUT INSERTED.*
						SELECT		@AsgndUsrFk, @NewHisFk, BnoBvmFk, BnoBioFk, BnoBudFk, BnoStatus,BnoDataPk,BnoBfwFk
						FROM		BpmNextOpUsr(NOLOCK)
						WHERE		BnoBexFk = @HisPk
						
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
GO
