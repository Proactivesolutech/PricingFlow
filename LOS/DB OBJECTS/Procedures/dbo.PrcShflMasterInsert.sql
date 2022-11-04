IF OBJECT_ID('PrcShflMasterInsert','P') IS NOT NULL
	DROP PROCEDURE PrcShflMasterInsert
GO
CREATE PROCEDURE PrcShflMasterInsert
(
	 @Action	VARCHAR(20),
	 @UsrNm		VARCHAR(50)	=	NULL,
	 @UsrDispNm	VARCHAR(100)=	NULL,
	 @BrnFk		BIGINT		=	NULL,
	 @ZoneFk	BIGINT		=	NULL,
	 @StFk		BIGINT		=	NULL,
	 @CenFk		BIGINT		=	NULL,
	 @OldUsrNm	VARCHAR(50)	=	NULL,
	 @RolesFk	VARCHAR(100) =	NULL,
	 @GeosFk	VARCHAR(100) =	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	
	DECLARE @Dt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@RowId VARCHAR(40), @UsrNms VARCHAR(100) , @NewUsrFk BIGINT, @UsrFk BIGINT
	DECLARE @Roles TABLE(RoleFk BIGINT)
	DECLARE @GeoPks TABLE(GeoFk BIGINT)
	
	BEGIN TRY
	
		SELECT	@Dt = GETDATE(), @RowId = NEWID(), @UsrNms = 'ADMIN'

		IF @Action = 'MapInsert'
		BEGIN
			INSERT INTO GenGeoMap
			(
				GemGeoBFk,GemGeoZFk,GemGeoSFk,GemGeoCFk,GemRowId,GemCreatedDt,
				GemCreatedBy,GemModifiedDt,GemModifiedBy,GemDelFlg,GemDelId
			)
			OUTPUT INSERTED.*
			SELECT @BrnFk,@ZoneFk,@StFk,@CenFk,@RowId,@Dt,@UsrNms,@Dt,@UsrNms,NULL,0
			
		END
		
		IF @Action = 'PrdInsert'
			BEGIN
				INSERT INTO GenPrdMas(PrdCd,PrdNm,PrdRowId,PrdCreatedDt,PrdCreatedBy,PrdModifiedDt,PrdModifiedBy,PrdDelFlg,PrdDelId)
				OUTPUT INSERTED.*
				SELECT 'HL','Home Loan',@RowId,@Dt,@UsrNms,@Dt,@UsrNms,NULL,0
					UNION ALL
				SELECT 'ML','Mortgage Loan',@RowId,@Dt,@UsrNms,@Dt,@UsrNms,NULL,0
					UNION ALL
				SELECT 'TP','Top Up',@RowId,@Dt,@UsrNms,@Dt,@UsrNms,NULL,0
					UNION ALL
				SELECT 'BT','Balance Transfer',@RowId,@Dt,@UsrNms,@Dt,@UsrNms,NULL,0
			END
			
		IF @Action = 'UsrInsert'
			BEGIN
				INSERT INTO GenUsrMas(UsrNm,UsrDispNm,UsrPwd,UsrRowId,UsrCreatedDt,UsrCreatedBy,UsrModifiedDt,UsrModifiedBy,UsrDelFlg,UsrDelId)
				OUTPUT INSERTED.*
				SELECT @UsrNm,@UsrDispNm,dbo.fnAllocWS(@UsrNm),@RowId,@Dt,@UsrNms,@Dt,@UsrFk,NULL,0
	
				SET @NewUsrFk = SCOPE_IDENTITY()

				INSERT INTO @Roles
				SELECT items FROM split(@RolesFk,'~','')
				
				INSERT INTO @GeoPks
				SELECT items FROM split(@GeosFk,'~','')
				
				INSERT INTO GenUsrBrnDtls(UbdUsrFk,UbdGeoFk,UbdRowId,UbdCreatedDt,UbdCreatedBy,UbdModifiedDt,UbdModifiedBy,UbdDelFlg,UbdDelId)
				OUTPUT INSERTED.*
				SELECT	@NewUsrFk,GeoFk, @RowId,@Dt, @UsrNms, @Dt, @UsrNms,NULL,0
				FROM	@GeoPks
				
				INSERT INTO GenUsrRoleDtls(UrdUsrFk,UrdRolFk,UrdRowId,UrdCreatedDt,UrdCreatedBy,UrdModifiedDt,UrdModifiedBy,UrdDelFlg,UrdDelId)
				OUTPUT INSERTED.*
				SELECT	@NewUsrFk,RoleFk, @RowId,@Dt, @UsrNms, @Dt, @UsrNms,NULL,0
				FROM	@Roles
			END
		
		IF @Action = 'AdminUsrInsert'
			BEGIN
				INSERT INTO GenUsrMas(UsrNm,UsrDispNm,UsrPwd,UsrRowId,UsrCreatedDt,UsrCreatedBy,UsrModifiedDt,UsrModifiedBy,UsrDelFlg,UsrDelId)
				OUTPUT INSERTED.*
				SELECT 'ADMIN','Administrator',dbo.fnAllocWS('admin'),@RowId,@Dt,0,@Dt,0,NULL,0
				
				SET @UsrFk = SCOPE_IDENTITY()
				
				INSERT INTO GenRole(RolNm,RolLvlNo,RolRowId,RolCreatedDt,RolCreatedBy,RolModifiedDt,RolModifiedBy,RolDelFlg,RolDelId)
				OUTPUT INSERTED.*
				SELECT 'Branch Ops',1,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'Branch Credit',1,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'Zonal Ops',2,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'Zonal Credit',2,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'State Operations',3,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0			
					UNION ALL
				SELECT 'Central Ops',4,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'Central Credit',4,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
				
				INSERT INTO GenGeoMas(GeoNm,GeoLvlNo,GeoRowId,GeoCreatedDt,GeoCreatedBy,GeoModifiedDt,GeoModifiedBy,GeoDelFlg,GeoDelId)
				OUTPUT INSERTED.*
				SELECT 'Mylapore',1,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'T.Nagar',1,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'Goripalayam',1,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'Madiwala',1,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'White Field',1,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL					
				SELECT 'Tamil Nadu',2,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'South East',2,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL	
				SELECT 'Chennai',3,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL
				SELECT 'Madurai',3,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL			
				SELECT 'Karnataka',3,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
					UNION ALL			
				SELECT 'Mumbai',4,@RowId,@Dt,@UsrFk,@Dt,@UsrFk,NULL,0
				
				INSERT INTO GenUsrBrnDtls(UbdUsrFk,UbdGeoFk,UbdRowId,UbdCreatedDt,UbdCreatedBy,UbdModifiedDt,UbdModifiedBy,UbdDelFlg,UbdDelId)
				OUTPUT INSERTED.*
				SELECT	@UsrFk,GeoPk, @RowId,@Dt, @UsrFk, @Dt, @UsrFk,NULL,0
				FROM	GenGeoMas (NOLOCK)
				WHERE	GeoDelid = 0
				
				INSERT INTO GenUsrRoleDtls(UrdUsrFk,UrdRolFk,UrdRowId,UrdCreatedDt,UrdCreatedBy,UrdModifiedDt,UrdModifiedBy,UrdDelFlg,UrdDelId)
				OUTPUT INSERTED.*
				SELECT	@UsrFk,RolPk, @RowId,@Dt, @UsrFk, @Dt, @UsrFk,NULL,0
				FROM	GenRole(NOLOCK)
				WHERE	RolDelId = 0
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
