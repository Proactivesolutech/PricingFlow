USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[sp_CountRows]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CountRows]
(
	@table_name SYSNAME = NULL -- If this null the all table scripts will generated
)
AS
BEGIN
SET NOCOUNT ON
	--DECLARE @Tables Table (table_name VARCHAR(MAX) ,RowCnt BIGINT, Iden INT IDENTITY(1,1)) 
	CREATE TABLE #Tables (table_name VARCHAR(MAX) ,RowCnt BIGINT, Iden INT IDENTITY(1,1)) 
	DECLARE @iLoop INT , @Cnt INT , @Exec VARCHAR(MAX) , @RowCnt BIGINT
	 

	IF @table_name IS NOT NULL
		INSERT INTO #Tables (table_name,RowCnt) VALUES('dbo.' + @table_name,0)
	ELSE 
		INSERT INTO #Tables (table_name,RowCnt) SELECT 'dbo.' + name,0 FROM Sys.Objects WHERE Type = 'U' 
		
	SELECT @Cnt = COUNT(*)	, @iLoop = 1 FROM #Tables

	--DECLARE @table_name SYSNAME
	--SELECT @table_name = 'dbo.ProWPBudget'

	WHILE (@iLoop <= @Cnt)
	BEGIN
		SELECT @table_name = table_name FROM #Tables WHERE Iden = @iLoop
		
		SELECT @Exec = ';WITH SQLTEMP AS
		(
			SELECT COUNT(*) RowCnts FROM ' + @table_name + ' (NOLOCK)
		)UPDATE #Tables SET RowCnt =  RowCnts FROM  SQLTEMP WHERE Iden = ' + RTRIM(@iLoop)
		 
		
		--SELECT @Exec = 'SELECT @RowCnt = COUNT(*) FROM ' + @table_name + ' (NOLOCK)'
		--EXEC(@Exec)
		--SELECT @Exec = 'UPDATE #Tables SET RowCnt =  ' + RTRIM(@RowCnt) + ' WHERE Iden = ' + @iLoop
		EXEC(@Exec)
		--PRINT @SQL
		SET @Iloop = @Iloop + 1
	END	
	SELECT table_name,RowCnt FROM #Tables ORDER BY RowCnt DESC
--EXEC sys.sp_executesql @SQL
END




GO
