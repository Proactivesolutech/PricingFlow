IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflRejectionRemark' AND [type]='P')
	DROP PROC PrcShflRejectionRemark
GO
CREATE PROCEDURE PrcShflRejectionRemark
(
    @Action			VARCHAR(100)		=	NULL,
    @LeadPk			VARCHAR(100)		=	NULL,
	@remarks		VARCHAR(MAX),
	@UsrNm			VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON
	--RETURN
	DECLARE	@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT,
			@UsrPk BIGINT, @UsrDispNm VARCHAR(100);
			
	DECLARE	@CurDt DATETIME ,@RowId VARCHAR(40),@MaxLedNo BIGINT,@ledpk BIGINT,@LedFk BIGINT,@IsExs BIT = 0;
		
		
	SELECT @CurDt = GETDATE(), @RowId = NEWID()	
	
	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
		
		IF @TranCount = 1
			BEGIN TRAN			

				IF @Action = 'REJECTION_REMARKS'
					BEGIN
						DELETE FROM LosAppNotes WHERE LanLedFk = @LeadPk AND LanTyp = 'R'
						
						INSERT INTO LosAppNotes (LanLedFk,LanAppFk,LanLapFk,LanTyp,LanNotes,
									LanRowId,LanCreatedBy,LanCreatedDt,LanModifiedBy,LanModifiedDt,LanDelFlg,LanDelId,LanTitle)
						SELECT @LeadPk,AppPk,NULL,'R',@remarks,@RowId,@UsrNm,@CurDt,@UsrNm,@CurDt,NULL,0,NULL
						FROM LosApp(NOLOCK) WHERE AppLedFk = @LeadPk AND AppDelId = 0
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
