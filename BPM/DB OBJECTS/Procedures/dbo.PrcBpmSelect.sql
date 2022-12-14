USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcBpmSelect]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcBpmSelect]
(
	@Action			VARCHAR(100)		=	NULL,
	@ProcessJSON	VARCHAR(MAX)		=	NULL,
	@ValData		VARCHAR(MAX)		=	NULL,
	@RtnOption		INT					=	0,
	@Branch			VARCHAR(100)		=	NULL
)
AS
BEGIN

	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	IF @Action = 'Location'
	BEGIN
		SELECT 'SELECT' AS 'GeoNm',0 AS 'GeoPk'
		UNION ALL
		SELECT Top 5 GeoNm,GeoPk FROM GenGeoMas(NOLOCK)
	END

END


GO
