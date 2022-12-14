USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflsaleOfzhelp]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PrcShflsaleOfzhelp]
(
@Ofzname VARCHAR(MAX)	= NULL,
@OFZ BIGINT				= NULL
)
AS
BEGIN 

					IF ISNULL(@Ofzname,'0') = '0'
					BEGIN
				    SELECT	GblBGeoFk 'BGeoPk',GblCd 'Code', GblNm 'Location',GblPk 'Gblpk'
					FROM    GenBusiLocation(NOLOCK)
					WHERE	GblDelId = 0    
					END
					ELSE
					BEGIN
					SELECT	GblBGeoFk 'BGeoPk',GblCd 'Code', GblNm 'Location',GblPk 'Gblpk'
					FROM    GenBusiLocation(NOLOCK)
					WHERE	GblDelId = 0  AND GblNm LIKE  '%' + @Ofzname + '%'
					END
END

GO
