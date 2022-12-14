USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[Prc_AvgCalc]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Prc_AvgCalc]
(
	@Action		VARCHAR(1)		=	NULL,
	@RowJson	VARCHAR(MAX)	=	NULL,
	@ColJson	VARCHAR(MAX)	=	NULL,
	@ValJson	VARCHAR(MAX)	=	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	
	SET @CurDt = GETDATE()
	
	/*
	CREATE TABLE RowColJson(RowNm VARCHAR(100), ColNm VARCHAR(100), ColIndex BIGINT, MnthIndex INT, RowIndex BIGINT, RowColPk BIGINT PRIMARY KEY IDENTITY(1,1),InpVal BIGINT)
	CREATE TABLE ColJson(ColNm VARCHAR(100), ColIndex BIGINT, MnthIndex INT, ColPk BIGINT PRIMARY KEY IDENTITY(1,1))
	CREATE TABLE ValJson(RowId BIGINT, ColId BIGINT, RowFk BIGINT, ColFk BIGINT, InpVal BIGINT, ValPk BIGINT PRIMARY KEY IDENTITY(1,1))
	*/
	
	CREATE TABLE #RowJson(xx_id BIGINT,RowNm VARCHAR(100), RowIndex BIGINT)
	CREATE TABLE #ColJson(xx_id BIGINT,ColNm VARCHAR(100), ColIndex BIGINT, MnthIndex INT)
	CREATE TABLE #ValJson(xx_id BIGINT,RowId BIGINT, ColId BIGINT, InpVal BIGINT)
	
	IF @RowJson !='[]'
		BEGIN
			INSERT INTO #RowJson
			EXEC PrcParseJSON @RowJson,'RowNm,RowIndex'
		END

	IF @ColJson !='[]'
		BEGIN
			INSERT INTO #ColJson
			EXEC PrcParseJSON @ColJson,'ColNm,ColIndex,MnthIndex'
		END
	
	IF @ValJson !='[]'
		BEGIN
			INSERT INTO #ValJson
			EXEC PrcParseJSON @ValJson,'RowId,ColId,InpVal'
		END
	
	IF @Action = 'A'
	BEGIN
		
		SELECT		RowNm, ColNm,ColIndex,MnthIndex, RowIndex,InpVal 
		INTO		#FinalVal
		FROM		#RowJson
		CROSS JOIN	#ColJson
		
		INSERT INTO RowColJson(RowNm,ColNm,ColIndex,MnthIndex,RowIndex,InpVal)
		SELECT	RowNm, ColNm,ColIndex,MnthIndex, RowIndex,0 FROM #FinalVal
		WHERE	MnthIndex = -1
		
		INSERT INTO RowColJson(RowNm,ColNm,ColIndex,MnthIndex,RowIndex,InpVal)
		SELECT	RowNm, ColNm,ColIndex,MnthIndex, RowIndex,InpVal 
		FROM	#FinalVal
		JOIN	#ValJson ON ColId = ColIndex AND RowId = RowIndex
	END
	
	SELECT RowNm, RowIndex FROM RowColJson GROUP BY RowIndex, RowNm 
	SELECT ColNm,ColIndex,MnthIndex,1 'IsNew' FROM RowColJson GROUP BY ColIndex,ColNm,MnthIndex
	SELECT RowIndex,ColIndex,InpVal FROM RowColJson WHERE ISNULL(InpVal,0) <> 0
	
	SELECT * FROM RowColJson ORDER BY RowIndex, ColIndex
END
GO
