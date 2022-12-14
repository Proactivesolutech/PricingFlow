USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[RoleDetails]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RoleDetails]
(
	@ACTION		VARCHAR(100)	=	NULL,
	@RolNm		VARCHAR(100)	=	NULL,
	@RolLvlNo	INT				=   NULL,
	@RolPk		INT				=	NULL
	
)
AS
BEGIN
		
	SET NOCOUNT ON;

	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @UsrNm VARCHAR(100),@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			@Error INT, @RowCount INT, @LvlNo INT, @SubLvlNo INT;
	
	SELECT @UsrNm = 'ADMIN', @CurDt = GETDATE(), @RowId = NEWID()

	BEGIN TRY
	
		IF @@TRANCOUNT = 0
			SET @Trancount = 1
					
		IF @Trancount = 1
			BEGIN TRAN
	
				IF @ACTION='INSERT' 
					BEGIN
						SELECT @SubLvlNo = ISNULL(MAX(RolSubLvlNo),0) + 1 FROM GenRole WHERE RolLvlNo = @RolLvlNo
						
						INSERT INTO GenRole (RolNm,RolLvlNo,RolSubLvlNo,RolRowId,RolCreatedDt,RolCreatedBy, RolModifiedDt, RolModifiedBy, RolDelFlg,RolDelId) values
						(@RolNm, @RolLvlNo,@SubLvlNo,@RowId, @CurDt,@UsrNm, @CurDt,@UsrNm, 0,0)
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Role Master Header Insert.',16,1)
								RETURN
							END	
						IF @Rowcount = 0
							BEGIN
								RAISERROR('Role Master - No Data Found to Insert.',16,1)
								RETURN
							END	
					END
					
				IF @ACTION = 'SELECT'
					BEGIN
						SELECT RolLvlNo, RolNm,RolPk FROM GenRole (NOLOCK) WHERE RolDelid = 0
					END

				IF @ACTION = 'SEL_ROW'
				 BEGIN
				      SELECT RolLvlNo, RolNm,RolPk FROM GenRole (NOLOCK) WHERE RolPk=@RolPk

					  SELECT @RolPk 'PK'
				 END

				IF @Action = 'UPDATE'
					BEGIN
						SELECT @SubLvlNo = ISNULL(MAX(RolSubLvlNo),0) + 1 FROM GenRole WHERE RolLvlNo = @RolLvlNo
						
						UPDATE	GenRole  SET RolLvlNo=@RolLvlNo,RolSubLvlNo = @SubLvlNo,RolNm=@RolNm,RolModifiedDt = @CurDt
						WHERE	RolPk=@RolPk AND RolDelid = 0
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Role Master Header Update.',16,1)
								RETURN
							END	
					END

				IF @Action = 'DELETE'
					BEGIN
					
						UPDATE	GenRole  SET RolDelid = 1, RolModifiedDt = @CurDt, RolDelFlg = dbo.gefgGetDelFlg(@CurDt) 
						WHERE	RolPk = @RolPk AND RolDelid = 0
						
						SELECT @Error = @@ERROR, @Rowcount = @@ROWCOUNT
						IF @Error <> 0
							BEGIN
								RAISERROR('Error - Role Master Header Delete.',16,1)
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
