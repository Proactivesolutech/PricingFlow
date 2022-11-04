USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflLeadDetails]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShflLeadDetails]
(
@Action VARCHAR(MAX)	= NULL
)
AS 
BEGIN 
    IF @Action ='Load'
	BEGIN
	SELECT	distinct LedPk 'LeadPk' ,LedNm 'Leadname',LedId 'Leadid',GeoNm 'branchname'
	FROM	LosLead (NOLOCK) 
	JOIN    GenGeoMas(NOLOCK) ON GeoPk=LedBGeoFk
	WHERE	LedDelId = 0 
	END

END
GO
