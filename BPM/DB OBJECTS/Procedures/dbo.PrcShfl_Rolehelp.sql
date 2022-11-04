USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShfl_Rolehelp]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShfl_Rolehelp]
(
@Rolename VARCHAR(MAX)	= NULL,
@brnch VARCHAR(MAX)	= NULL
)
AS
BEGIN 

	IF ISNULL(@Rolename,'0') = '0'
	BEGIN
	SELECT	RolNm 'RoleName',RolLvlNo 'Level',RolPk 'Pk'
	FROM	GenRole (NOLOCK) 
	WHERE	RolDelId = 0 
	END
	ELSE
	BEGIN
    SELECT	RolNm 'RoleName',RolLvlNo 'Level',RolPk 'Pk'
	FROM	GenRole (NOLOCK) 
	WHERE	RolDelId = 0  AND RolNm LIKE  '%' + @Rolename + '%'
	END

END









GO
