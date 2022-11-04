USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcFileupldDetails]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcFileupldDetails] 
	(-- Add the parameters for the stored procedure here
	
	@ProcKey		int		=	NULL ,
	@RefKey		int		=	NULL ,
	@FileName		VARCHAR(MAX)		=	NULL ,
	@FileNameStamp		VARCHAR(MAX)		=	NULL ,
	@FileUpldPath		VARCHAR(MAX)		=	NULL,
	@FileupldRemarks		VARCHAR(MAX)		=	NULL)
AS
BEGIN	
	INSERT INTO FileupldAttachment 		
	VALUES (@ProcKey,@RefKey,@FileName,@FileNameStamp,@FileUpldPath,ISNULL(@FileupldRemarks,''), getdate()) 			
END

GO
