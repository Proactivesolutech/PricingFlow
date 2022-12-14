USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflleadBranchhelp]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShflleadBranchhelp]
(
@Branchname VARCHAR(MAX)	= NULL,
@brnch VARCHAR(MAX)	= NULL
)
AS
BEGIN 

	IF ISNULL(@Branchname,'0') = '0'
	BEGIN
	SELECT	Distinct GeoCd 'Location',GeoPk 'BranchPk' 
	FROM	GenGeoMas (NOLOCK)
	WHERE	GeoLvlNo = 1 AND GeoDelid = 0
	AND		EXISTS(SELECT 'X' FROM GenGeoMap (NOLOCK) WHERE GemGeoBFk = GeoPk AND GemDelid = 0)
	END
	ELSE
	BEGIN
	SELECT	Distinct GeoCd 'Location',GeoPk 'BranchPk' 
	FROM	GenGeoMas (NOLOCK) 
	WHERE	GeoLvlNo = 1 AND GeoDelid = 0 AND GeoCd LIKE  '%' + @Branchname + '%'
	AND		EXISTS(SELECT 'X' FROM GenGeoMap (NOLOCK) WHERE GemGeoBFk = GeoPk AND GemDelid = 0)
	END


END


GO
