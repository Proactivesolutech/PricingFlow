USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[colDesc]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[colDesc](
	@TableName VARCHAR(100) = NULL
)
AS
BEGIN
	SET NOCOUNT ON

	SET ANSI_WARNINGS ON
	DECLARE @Err VARCHAR(MAX)
	BEGIN TRY 
		SELECT c.name AS [Column Name], value AS [Description]
		FROM sys.extended_properties AS ep
		INNER JOIN sys.tables AS t ON ep.major_id = t.object_id 
		INNER JOIN sys.columns AS c ON ep.major_id = c.object_id AND ep.minor_id = c.column_id
		WHERE class = 1 AND t.name = @TableName
	END TRY
	BEGIN CATCH	
		SELECT @Err = ERROR_MESSAGE()
		RAISERROR(@Err,16,1)
	END CATCH
END


GO
