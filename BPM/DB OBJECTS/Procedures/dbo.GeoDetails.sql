USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[GeoDetails]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GeoDetails]
(
	@Action		VARCHAR(100)	=	NULL, 
	@GeoNm		VARCHAR(100)	=	NULL,
	@GeoLvlNo	INT				=	NULL,
	@GeoPk		INT				=	NULL,
	@ISACTIVE	BIT				= 	NULL
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @UsrNm VARCHAR(100),@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			@Error INT, @RowCount INT, @LvlNo INT
	
	SELECT @UsrNm = 'ADMIN', @CurDt = GETDATE(), @RowId = NEWID()

	BEGIN TRY
	
		IF @@TRANCOUNT = 0
			SET @Trancount = 1
					
		IF @Trancount = 1
			BEGIN TRAN
				
				IF @Action = 'INSERT'
					BEGIN
						INSERT INTO GenGeoMas (GeoNm,GeoLvlNo,GeoRowId,GeoCreatedDt,GeoCreatedBy,GeoModifiedDt,GeoModifiedBy,GeoDelFlg,GeoDelId)
						VALUES(@GeoNm,@GeoLvlNo,@RowId,@CurDt,@UsrNm,@CurDt,@UsrNm,0,0)
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Geo Master Header Insert.',16,1)
								RETURN
							END	
						IF @Rowcount = 0
							BEGIN
								RAISERROR('Geo Master - No Data Found to Insert.',16,1)
								RETURN
							END	
					END
				
				IF @Action = 'SELECT'
					BEGIN
						SELECT GeoLvlNo, GeoNm,GeoPk  FROM GenGeoMas (NOLOCK) WHERE GeoDelId = 0
					END
				
				IF @Action = 'SEL_ROW'
					BEGIN
						SELECT GeoLvlNo, GeoNm,GeoPk  FROM GenGeoMas (NOLOCK) WHERE GeoDelId = 0 AND GeoPk=@GeoPk 

						SELECT @GeoPk 'PK'
					END

				IF @Action = 'UPDATE'
					BEGIN
						UPDATE	GenGeoMas SET GeoLvlNo=@GeoLvlNo, GeoNm=@GeoNm, GeoModifiedDt = @CurDt 
						WHERE	GeoPk=@GeoPk AND GeoDelid = 0
						
						SELECT @Error = @@ERROR
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Geo Master Header Update.',16,1)
								RETURN
							END		
					END
				
				IF @Action = 'DELETE'
					BEGIN
						UPDATE	GenGeoMas SET GeoDelId = 1, GeoModifiedDt = @CurDt , GeoDelFlg = dbo.gefgGetDelFlg(@CurDt) 
						WHERE	GeoPk=@GeoPk AND GeoDelid = 0
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Geo Master Header Deletes.',16,1)
								RETURN
							END	
					END
					
				IF @Action IN ('LVL1','LVL2','LVL3','LVL4')
					BEGIN
						SELECT @LvlNo = CASE @Action WHEN 'LVL1' THEN 1 WHEN 'LVL2' THEN 2 WHEN 'LVL3' THEN 3 WHEN 'LVL4' THEN 4 END
						SELECT GeoNm,GeoPk FROM GenGeoMas (NOLOCK) WHERE GeoLvlNo = @LvlNo AND GeoDelid = 0
					END
				
				IF @Action = 'ADDROLE'
					BEGIN
						SELECT RolPk,RolNm FROM GenRole (NOLOCK) WHERE RolDelId=0
					END

				IF @Action = 'ADDGEO'
					BEGIN
						SELECT GeoPk,GeoNm FROM GenGeoMas (NOLOCK) WHERE GeoDelId=0
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
