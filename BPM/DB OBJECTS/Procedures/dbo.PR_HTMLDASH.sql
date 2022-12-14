USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PR_HTMLDASH]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PR_HTMLDASH]
(
  @FLAG VARCHAR(50),
  @DASHNAME VARCHAR(100) =NULL,
  @FILENAME VARCHAR(100)=NULL
  )
  AS
  BEGIN
  DECLARE
  @UNQID INT,
  @MNKEY INT
	IF @FLAG='FINDXML'
	BEGIN
		SELECT HP_RPT_QRY FROM CS_HTML_PVT 
		WHERE HP_UNQ_ID=@DASHNAME AND HP_TYP=1616;	
	END

	IF @FLAG='NEWDASH'
	BEGIN
	 
     
     INSERT INTO CS_HTML_PVT(HP_RPT_NM,HP_RPT_QRY,HP_TYP)     
     SELECT @DASHNAME,@FILENAME,1616  ;    
    SELECT @UNQID= MAX(HP_UNQ_ID)  FROM CS_HTML_PVT;   
     SELECT @MNKEY= MAX(MN_MNU_KEY)+1   FROM SYMENU WHERE MN_MNU_KEY LIKE '23%';
    
     INSERT INTO SYMENU
     SELECT @UNQID,'m12' ,	@DASHNAME	,1,	'1XX1XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',	'000=70?m0',	'm1'   ,	'm12' , 	0,	@MNKEY,	'M01',	'T

L'+cast(@UNQID as varchar(20)) ,	'DashRender.aspx'
     
	END
/*
	IF @FLAG='EnqRej'
	BEGIN
		
		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Rejected' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @RejFk
		UNION ALL
		SELECT BioPk,'Cancelled' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @EndFk
		UNION ALL
		SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @AcptFk
		UNION ALL
		SELECT BioPk,'TotalEnquiries' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk

		INSERT INTO #StsTbl
		SELECT Stat,
		 COUNT(BexBioFk)'Cnt',BexBrnchFk  
		FROM BpmExec(NOLOCK) 
		JOIN #DataPk ON BioFk = BexBioFk
		GROUP  BY BexBrnchFk,BexBioFk,Stat

		INSERT INTO #FinalStatus
		SELECT [status],SUM(Cnt)'Cnt',TGeoNm 
		FROM #StsTbl 
		JOIN #TmpGeoMas(NOLOCK) ON TGeoFk = BrnchFk 
		GROUP BY [status],TGeoNm

		SELECT BrnchName,ISNULL([Cancelled],0)'Cancelled',ISNULL([Accepted],0)'Accepted',
				ISNULL([Rejected],0)'Rejected' ,ISNULL([TotalEnquiries],0)'TotalEnquiries' 
		FROM
		(
		SELECT * FROM #FinalStatus
		)A
		PIVOT
		(
		SUM(Cnt) FOR [finstatus] IN ([Cancelled],[Accepted],[Rejected],[TotalEnquiries])
		) B
		
		

	END

	*/
  
  END










GO
