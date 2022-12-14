USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcDocMgr]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcDocMgr](
	@Action					VARCHAR(20)			OUTPUT,
	@ImageId				VARCHAR(50),
    @ImagePath				VARCHAR(MAX)		= NULL
)
AS BEGIN
	
	DECLARE @err_message NVARCHAR(255)
	
	IF @Action='Insert'	
	BEGIN
		INSERT INTO DocMgr(LtFk,DocGrp,DocPath)
		SELECT 0,@ImageId,@ImagePath
	END
		
	ELSE IF @Action = 'View'
	BEGIN		
		IF EXISTS (Select 'X' from DocMgr(NOLOCK) WHERE DocGrp=@ImageId)
			SELECT @err_message = DocPath FROM DocMgr(NOLOCK) WHERE DocGrp = @ImageId
		ELSE
			SET @err_message =    'ImagePath Not Exist'
		SELECT @err_message						
	END
		
	ELSE IF @Action = 'Update'
	BEGIN			
		SELECT @err_message		
	END

	ELSE IF @Action = 'Delete'
	BEGIN

		--IF EXISTS (SELECT 'X' FROM DocMgr WHERE ImageId=@ImageId)
		--BEGIN
		--	INSERT INTO ScanImageTracker (FolderName, ImageName, Status)
		--		VALUES (@ImagePath,  @ImageId, 'D');

						
		--	RETURN SELECT ImagePath FROM DocMgr WHERE ImageId = @ImageId;
		--	--UPDATE DocMgr SET  ImagePath = @ImagePath WHERE ImageId = @ImageId;
		--	--SELECT ImagePath FROM DocMgr WHERE ImageId = @ImageId
		--END
		--ELSE
		--	SET @err_message =    'ImagePath Not Exist'
    	SELECT @err_message						
	END
END


GO
