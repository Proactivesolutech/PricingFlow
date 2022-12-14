USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[GeoMapDetails]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GeoMapDetails]
(
	@ACTION		VARCHAR(100)	=	NULL,
	@GemGeoBFk INT				=	NULL,
	@GemGeoZFk INT				=	NULL,
	@GemGeoSFk INT				=	NULL,
	@GemGeoCFk INT				=	NULL,
	@GemPk		INT				=	NULL
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
	
				IF @ACTION='SAVE'
					BEGIN
					
						INSERT INTO GenGeoMap (GemGeoBFk,GemGeoZFk,GemGeoSFk,GemGeoCFk,GemRowID,GemCreatedDt,GemCreatedBy,GemModifiedDt,GemModifiedBy,GemDelFlg,GemDelId)
						VALUES (@GemGeoBFk,@GemGeoZFk,@GemGeoSFk,@GemGeoCFk,@RowId,@CurDt,@UsrNm,@CurDt,@UsrNm,0,0)
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Geo Map Header Insert.',16,1)
								RETURN
							END	
						IF @Rowcount = 0
							BEGIN
								RAISERROR('Geo Map - No Data Found to Insert.',16,1)
								RETURN
							END						
					END

				IF @ACTION='SELECT'
					BEGIN
						SELECT  Branch.GeoNm 'Branch', Zone.GeoNm 'Zone', States.GeoNm 'State', Centre.GeoNm 'Centre',
								GemPk 'Fk'
						FROM	GenGeoMap(NOLOCK)
						JOIN	GenGeoMas Branch (NOLOCK) ON Branch.GeoPk = GemGeoBFk AND Branch.GeoDelId = 0
						JOIN	GenGeoMas Zone   (NOLOCK) ON Zone.GeoPk	= GemGeoZFk AND Zone.GeoDelId	 = 0
						JOIN	GenGeoMas States (NOLOCK) ON States.GeoPk = GemGeoSFk AND States.GeoDelId = 0
						JOIN	GenGeoMas Centre (NOLOCK) ON Centre.GeoPk = GemGeoCFk AND Centre.GeoDelId = 0
						WHERE	GemDelId = 0
					END
			   IF @ACTION = 'SET_VAL'
				BEGIN
				  DECLARE @BRG BIGINT,@ZON BIGINT,@STA BIGINT,@CEN BIGINT
                  SELECT @BRG=GemGeoBFk,@ZON=GemGeoZFk,@STA=GemGeoSFk,@CEN=GemGeoCFk FROM GenGeoMap  WHERE  GemPk=@GemPk
                  SELECT GeoNm,@BRG 'pk'FROM GenGeoMas WHERE GeoPk=@BRG
                  SELECT GeoNm,@ZON 'pk' FROM GenGeoMas WHERE GeoPk=@ZON
                  SELECT GeoNm,@STA 'pk' FROM GenGeoMas WHERE GeoPk=@STA
                  SELECT GeoNm,@CEN 'pk' FROM GenGeoMas WHERE GeoPk=@CEN
				  SELECT @GemPk 'pk'
				END
					
				IF @Action = 'UPDATE'
					BEGIN
						UPDATE	GenGeoMap  SET 
								GemGeoBFk=@GemGeoBFk,
								GemGeoZFk=@GemGeoZFk,
								GemGeoSFk=@GemGeoSFk,
								GemGeoCFk=@GemGeoCFk,
								GemModifiedDt = @CurDt
						WHERE GemPk=@GemPk AND GemDelid = 0
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Geo Map Header Update.',16,1)
								RETURN
							END	
					END
				IF @Action = 'DELETE'
					BEGIN
						UPDATE  GenGeoMap SET GemDelId=1,GemModifiedDt = @CurDt , GemDelFlg = dbo.gefgGetDelFlg(@CurDt) 
						WHERE	GemPk=@GemPk AND GemDelid = 0
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Geo Map Header Delete.',16,1)
								RETURN
							END	
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
