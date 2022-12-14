USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[BPMDashboard]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BPMDashboard]
(
	@FLAG    	VARCHAR(100),
	@XMLDoc		TEXT	=	NULL,
	@LOCID		BIGINT	=	NULL
)
 AS
 BEGIN
  SET NOCOUNT ON; 
	 DECLARE @FlowFk BIGINT,@DcdPk BIGINT,@RejFk BIGINT,@EndFk BIGINT,@AcptFk BIGINT,@RejFk1 BIGINT,@QcAprv BIGINT,@QcAcpt BIGINT,@FlowFk2 BIGINT
	 SELECT @FlowFk = 2242,@FlowFk2 = 2275

	CREATE TABLE #DataPk(BioFk BIGINT,Stat VARCHAR(20))
	CREATE TABLE #StsTbl([status] VARCHAR(25),Cnt BIGINT,BrnchFk BIGINT)
	CREATE TABLE #FinalStatus(finstatus VARCHAR(25),Cnt BIGINT,BrnchName VARCHAR(100))
	CREATE TABLE #TmpGeoMas(TGeoFk BIGINT,TGeoNm VARCHAR(100),TGeoLvlNo BIGINT,TGeoCd VARCHAR(10),TGeoStatFlg VARCHAR(5),TGeoBusLoc VARCHAR(5))

	CREATE TABLE #Acpted(AKeyFk BIGINT,ABioPk BIGINT)
	CREATE TABLE #EnqVal(EnqDataFk BIGINT,EnqKeyFk BIGINT,EnqBrnchFk BIGINT)
	CREATE TABLE #AcptEstVal(EstDataFk BIGINT,EstKeyFk BIGINT,EstBrnchFk BIGINT)
	CREATE TABLE #TotEnqVsAcp(BranchName VARCHAR(100),Cost BIGINT,AppOrEnq VARCHAR(25))
	CREATE TABLE #FinalAcpt(FkeyFk BIGINT,FBioPk BIGINT,FBexFk BIGINT)
	CREATE TABLE #ProcessSts(DcdPk BIGINT, AcptFk BIGINT ,EndFk BIGINT,RejFk BIGINT,QcAprv BIGINT,QcAcpt BIGINT)

	INSERT INTO #ProcessSts (DcdPk)
	--SELECT BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Decider' AND BfwBvmFk = @FlowFk
	SELECT BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Decider' AND BfwBvmFk IN (@FlowFk,@FlowFk2)

	INSERT INTO #ProcessSts (AcptFk)
	SELECT BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Production Acceptance' AND BfwBvmFk IN (@FlowFk,@FlowFk2)--= @FlowFk

	INSERT INTO #ProcessSts (EndFk)
	SELECT BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'END' AND BfwBvmFk IN (@FlowFk,@FlowFk2)--= @FlowFk

	INSERT INTO #ProcessSts (RejFk)
	SELECT BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Sales Request' AND BfwBvmFk IN (@FlowFk,@FlowFk2)--= @FlowFk

	INSERT INTO #ProcessSts (QcAprv)
	SELECT BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Qc Approve' AND BfwBvmFk IN (@FlowFk,@FlowFk2)--= @FlowFk

	INSERT INTO #ProcessSts (QcAcpt)
	SELECT BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'QcApprove' AND BfwBvmFk IN (@FlowFk,@FlowFk2)--= @FlowFk

	
		SELECT @DcdPk = BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Decider' AND BfwBvmFk = @FlowFk
		SELECT @AcptFk = BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Production Acceptance' AND BfwBvmFk = @FlowFk
		SELECT @EndFk = BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'END' AND BfwBvmFk = @FlowFk
		SELECT @RejFk = BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Sales Request' AND BfwBvmFk = @FlowFk
		SELECT @QcAprv =  BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'Qc Approve' AND BfwBvmFk = @FlowFk
		SELECT @QcAcpt =  BfwPk FROM BpmFlow(NOLOCK) WHERE BfwLabel = 'QcApprove' AND BfwBvmFk = @FlowFk

		INSERT INTO #TmpGeoMas
		SELECT GeoPk,GeoNm,GeoLvlNo,GeoCd,GeoStatFlg,GeoBusLoc FROM GenGeoMas(NOLOCK) WHERE GeoDelId = 0

		UPDATE #ProcessSts SET AcptFk = 18054,EndFk = 18033,RejFk = 18052,QcAprv = 18053,QcAcpt = 18034 WHERE DcdPk = 18035
		UPDATE #ProcessSts SET AcptFk = 18541,EndFk = 18520,RejFk = 18539,QcAprv = 18540,QcAcpt = 18521 WHERE DcdPk = 18522

		DELETE FROM #ProcessSts WHERE DcdPk IS NULL

	IF @FLAG='EnqRej'
	BEGIN
		
		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Rejected' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @RejFk
		--UNION ALL
		--SELECT BioPk,'Cancelled' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @EndFk
		--UNION ALL
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @AcptFk
		--UNION ALL
		--SELECT BioPk,'TotalEnquiries' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Rejected' FROM BpmObjInOut 
		 JOIN #ProcessSts ON BioBfwFk = ISNULL(DcdPk,'')
		WHERE   BioOutBfwFk = ISNULL(RejFk ,'')
		UNION ALL
		SELECT BioPk,'Cancelled' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = ISNULL(DcdPk,'')
		WHERE   BioOutBfwFk = ISNULL(EndFk ,'')
		UNION ALL
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = ISNULL(DcdPk,'')
		WHERE   BioOutBfwFk = ISNULL(AcptFk ,'')
		UNION ALL
		SELECT BioPk,'TotalEnquiries' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = ISNULL(DcdPk,'')
		WHERE   DcdPk IS NOT NULL

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

		--SELECT BrnchName,ISNULL([Cancelled],0)'Cancelled',ISNULL([Accepted],0)'Accepted',
		--		ISNULL([Rejected],0)'Rejected' ,ISNULL([TotalEnquiries],0)'TotalEnquiries'
		SELECT BrnchName,ISNULL([Rejected],0)'Rejected' ,ISNULL([TotalEnquiries],0)'TotalEnquiries'
		FROM
		(
		SELECT * FROM #FinalStatus
		)A
		PIVOT
		(
		SUM(Cnt) FOR [finstatus] IN ([Cancelled],[Accepted],[Rejected],[TotalEnquiries])
		) B
	END

	IF @FLAG='RegAcpted'
	BEGIN
		DECLARE @PvtCol VARCHAR(MAX),@ExecQry VARCHAR(MAX)
		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @QcAprv AND BioOutBfwFk = @QcAcpt
		
		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = QcAprv AND BioOutBfwFk = QcAcpt 

		INSERT INTO #FinalAcpt(FKeyFk,FBioPk,FBexFk)
		SELECT BexKeyFk,BexBioFk,BexPk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk
		WHERE BexIsRej = 0
		
		INSERT INTO #AcptEstVal(EstDataFk,EstKeyFk,EstBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0sxifdt 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0sxifdt] 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #EnqVal(EnqDataFk,EnqKeyFk,EnqBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #TotEnqVsAcp(Cost,AppOrEnq)
		SELECT 0,'Start'
		UNION ALL
		SELECT 20000,'4ActualVal'
		UNION ALL
		SELECT ((CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7)))),CAST(ROW_NUMBER()OVER(ORDER BY DataPk) AS VARCHAR(5))+'ApprovedCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0sxifdt
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT SUM(CAST(Val AS NUMERIC(27,2))),'3EnquiredCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0p9y4kh_hdp3
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		
		

		SELECT @PvtCol = ISNULL(@PvtCol,'')+'['+ AppOrEnq + '],' FROM #TotEnqVsAcp
		
		SELECT @PvtCol=SUBSTRING(@PvtCol,1,LEN(@PvtCol)-1)   

		SELECT @ExecQry = 
		'SELECT '+@PvtCol+' 
		FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ('+@PvtCol+')--([ApprovedCost],[EnquiredCost])
		)B'

		EXEC(@ExecQry)

	END
	IF @FLAG='AprvdVal'
	BEGIN
		
		

		--INSERT INTO #DataPk(BioFk,Stat)
		----SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @AcptFk
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @QcAprv AND BioOutBfwFk = @QcAcpt

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = QcAprv AND BioOutBfwFk = QcAcpt
	
		INSERT INTO #Acpted(AKeyFk,ABioPk)
		SELECT BexKeyFk,BexBioFk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk

		INSERT INTO #AcptEstVal(EstDataFk,EstKeyFk,EstBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0sxifdt--GEN_2242_Task_0ug76k4_93zt 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0sxifdt]--GEN_2242_Task_0ug76k4_93zt 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #EnqVal(EnqDataFk,EnqKeyFk,EnqBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #TotEnqVsAcp(BranchName,Cost,AppOrEnq)
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr' FROM 
		--GEN_2242_Task_0ug76k4_93zt
		GEN_2242_Task_0sxifdt
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0p9y4kh_hdp3
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr' FROM 
		--GEN_2242_Task_0ug76k4_93zt
		[GEN_2275_Task_0sxifdt]
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		[GEN_2275_Task_0p9y4kh_hdp3]
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		
		SELECT BranchName,ISNULL([ApprovedCost],0)'ApprovedCost',ISNULL([EnquiredCost],0) 'EnquiredCost' FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ([ApprovedCost],[EnquiredCost])
		)B

	END

	IF @FLAG='RjctdVal'
	BEGIN
		
		CREATE TABLE #Rjcted(RKeyFk BIGINT,RBioPk BIGINT,RBexPk BIGINT)

		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Rejected' FROM BpmObjInOut WHERE BioInBfwFk = @DcdPk AND BioBfwFk = @RejFk 

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Rejected' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioInBfwFk = DcdPk AND BioBfwFk = RejFk 

		INSERT INTO #Rjcted(RKeyFk,RBioPk,RBexPk)
		SELECT BexKeyFk,BexBioFk,BexPk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk AND BexIsRej = 1

		INSERT INTO #EnqVal(EnqDataFk,EnqKeyFk,EnqBrnchFk)
		SELECT DataPk,KeyFk,BranchFk FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #Rjcted ON KeyFk = RKeyFk AND RBexPk = HisPk
		GROUP BY BranchFk,DataPk,KeyFk
		UNION ALL
		SELECT DataPk,KeyFk,BranchFk FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #Rjcted ON KeyFk = RKeyFk AND RBexPk = HisPk
		GROUP BY BranchFk,DataPk,KeyFk

		INSERT INTO #TotEnqVsAcp(BranchName,Cost,AppOrEnq)
		SELECT TGeoNm,Val,'Rejected' FROM 
		GEN_2242_Task_0p9y4kh_hdp3
		JOIN #EnqVal ON EnqDataFk = DataPk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		UNION ALL 
		SELECT TGeoNm,Val,'Rejected' FROM 
		[GEN_2275_Task_0p9y4kh_hdp3]
		JOIN #EnqVal ON EnqDataFk = DataPk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		--UNION ALL
		--SELECT TGeoNm,Val,'Enquired' AS 'EnqVsApr' FROM 
		--GEN_2242_Task_0p9y4kh_hdp3
		--JOIN #EnqVal ON EnqDataFk = DataPk
		--JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		
		
		SELECT BranchName,ISNULL([Rejected],0)'RejectedCost'FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ([Rejected])
		)B

	END

	IF @FLAG='First_P_AND_L'
	BEGIN
		
		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @DcdPk AND BioOutBfwFk = @AcptFk

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = DcdPk AND BioOutBfwFk = AcptFk

		INSERT INTO #Acpted(AKeyFk,ABioPk)
		SELECT BexKeyFk,BexBioFk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk

		INSERT INTO #AcptEstVal(EstDataFk,EstKeyFk,EstBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0ug76k4_93zt 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0ug76k4_93zt] 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #EnqVal(EnqDataFk,EnqKeyFk,EnqBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #Acpted ON KeyFk = AKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #TotEnqVsAcp(BranchName,Cost,AppOrEnq)
		SELECT TGeoNm,Estimated_Cost,'ApprovedCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0ug76k4_93zt
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0p9y4kh_hdp3
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Estimated_Cost,'ApprovedCost' AS 'EnqVsApr' FROM 
		[GEN_2275_Task_0ug76k4_93zt]
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		[GEN_2275_Task_0p9y4kh_hdp3]
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
	
		SELECT BranchName,ISNULL([ApprovedCost],0)'ApprovedCost',ISNULL([EnquiredCost],0) 'EnquiredCost' INTO #PftLss 
		FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ([ApprovedCost],[EnquiredCost])
		)B

		SELECT BranchName,EnquiredCost 'Sales',EnquiredCost-ApprovedCost 'Cost' FROM #PftLss
	END

	IF @FLAG='Final_P_AND_L'
	BEGIN
		

		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @QcAprv AND BioOutBfwFk = @QcAcpt

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = QcAprv AND BioOutBfwFk = QcAcpt

		INSERT INTO #FinalAcpt(FKeyFk,FBioPk,FBexFk)
		SELECT BexKeyFk,BexBioFk,BexPk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk
		WHERE BexIsRej = 0
		
		INSERT INTO #AcptEstVal(EstDataFk,EstKeyFk,EstBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0sxifdt 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0sxifdt] 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #EnqVal(EnqDataFk,EnqKeyFk,EnqBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk


		INSERT INTO #TotEnqVsAcp(BranchName,Cost,AppOrEnq)
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0sxifdt
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0p9y4kh_hdp3
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr' FROM 
		[GEN_2275_Task_0sxifdt]
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		[GEN_2275_Task_0p9y4kh_hdp3]
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk

		SELECT BranchName,ISNULL([ApprovedCost],0)'ApprovedCost',ISNULL([EnquiredCost],0) 'EnquiredCost' INTO #FinalPftLss 
		FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ([ApprovedCost],[EnquiredCost])
		)B

		SELECT BranchName,EnquiredCost 'Sales',EnquiredCost-ApprovedCost 'Cost' FROM #FinalPftLss
	END

	IF @FLAG='AprvdSales'
	BEGIN
		CREATE TABLE #FinalAprvd(FkeyFk BIGINT,FBioPk BIGINT,FBexFk BIGINT)
		CREATE TABLE #ApprovedEnqVal(ADataFk BIGINT,AkeyFk BIGINT,ABioPk BIGINT,ABexFk BIGINT,Cost NUMERIC(27,2),AbrnchFk BIGINT)

		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @QcAprv AND BioOutBfwFk = @QcAcpt

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = QcAprv AND BioOutBfwFk = QcAcpt
		
		INSERT INTO #FinalAprvd(FKeyFk,FBioPk,FBexFk)
		SELECT BexKeyFk,BexBioFk,BexPk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk
		WHERE BexIsRej = 0
		
		INSERT INTO #AcptEstVal(EstDataFk,EstKeyFk,EstBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0sxifdt 
		JOIN #FinalAprvd ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0sxifdt] 
		JOIN #FinalAprvd ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk

		--INSERT INTO #EnqVal(EnqDataFk,EnqKeyFk,EnqBrnchFk)
		--SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0p9y4kh_hdp3 
		--JOIN #FinalAprvd ON KeyFk = FKeyFk
		--GROUP BY KeyFk,BranchFk

		INSERT INTO #ApprovedEnqVal(ADataFk,AkeyFk,AbrnchFk,Cost)
		SELECT Max(DataPk),KeyFk,BranchFk,Val FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #FinalAprvd ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk,Val
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk,Val FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #FinalAprvd ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk,Val

		INSERT INTO #TotEnqVsAcp(BranchName,Cost,AppOrEnq)
		SELECT TGeoNm,Cost,'ApprovedCost' AS 'EnqVsApr' FROM 
		#ApprovedEnqVal
		--JOIN #AcptEstVal ON ADataFk = EstDataFk
		JOIN #TmpGeoMas ON AbrnchFk = TGeoFk
	
		SELECT BranchName,ISNULL([ApprovedCost],0)'ApprovedCost' 		
		FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ([ApprovedCost])
		)B

	
	END

	IF @FLAG='RegPrd'
	BEGIN
		
		CREATE TABLE #PrdWise(PrdDataFk BIGINT,PrdKeyFk BIGINT,PrdBrnchFk BIGINT,PrdName VARCHAR(50))
		CREATE TABLE #PrdAcpted(PrdBranchName VARCHAR(100),PrdCost NUMERIC(27,7),AppOrEnq VARCHAR(20),PrdAcptName VARCHAR(50),
								PrdBranchFk BIGINT,PrdDataPk BIGINT,PrdKeyFk BIGINT)
		CREATE TABLE #PrdEnquired(EBranchName VARCHAR(100),ECost NUMERIC(27,7),EAppOrEnq VARCHAR(20),EAcptName VARCHAR(50),
								EBranchFk BIGINT,EDataPk BIGINT,EKeyFk BIGINT)

		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @QcAprv AND BioOutBfwFk = @QcAcpt

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = QcAprv AND BioOutBfwFk = QcAcpt

		INSERT INTO #FinalAcpt(FKeyFk,FBioPk,FBexFk)
		SELECT BexKeyFk,BexBioFk,BexPk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk
		WHERE BexIsRej = 0
		
		INSERT INTO #AcptEstVal(EstDataFk,EstKeyFk,EstBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0sxifdt 
		JOIN #FinalAcpt ON KeyFk = FKeyFk AND FBexFk = HisPk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0sxifdt] 
		JOIN #FinalAcpt ON KeyFk = FKeyFk AND FBexFk = HisPk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #PrdWise(PrdDataFk,PrdKeyFk,PrdBrnchFk,PrdName)
		SELECT Max(DataPk),KeyFk,BranchFk,Items FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #AcptEstVal ON KeyFk = EstKeyFk --AND EstDataFk = DataPk
		GROUP BY KeyFk,BranchFk,Items 
		UNION ALL 
		SELECT Max(DataPk),KeyFk,BranchFk,Items FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #AcptEstVal ON KeyFk = EstKeyFk --AND EstDataFk = DataPk
		GROUP BY KeyFk,BranchFk,Items 
		
		INSERT INTO #PrdAcpted(PrdBranchName,PrdCost,AppOrEnq,PrdAcptName,PrdBranchFk,PrdDataPk,PrdKeyFk)
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr','',TGeoFk,MAX(DataPk),KeyFk FROM 
		GEN_2242_Task_0sxifdt
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		GROUP BY TGeoNm,TGeoFk,KeyFk,Raw_Material,Overhead
		UNION ALL
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr','',TGeoFk,MAX(DataPk),KeyFk FROM 
		[GEN_2275_Task_0sxifdt]
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		GROUP BY TGeoNm,TGeoFk,KeyFk,Raw_Material,Overhead

		INSERT INTO #PrdEnquired(EBranchName,ECost,EAppOrEnq,EAcptName,EBranchFk,EDataPk,EKeyFk)
		SELECT TGeoNm,(Val),'EnquiredCost' AS 'EnqVsApr',Items,TGeoFk,MAX(DataPk),KeyFk FROM 
		GEN_2242_Task_0p9y4kh_hdp3
		JOIN #PrdWise ON PrdDataFk = DataPk AND PrdKeyFk = KeyFk
		JOIN #TmpGeoMas ON PrdBrnchFk = TGeoFk
		GROUP BY TGeoNm,Items,TGeoFk,KeyFk,Val
		UNION ALL
		SELECT TGeoNm,(Val),'EnquiredCost' AS 'EnqVsApr',Items,TGeoFk,MAX(DataPk),KeyFk FROM 
		[GEN_2275_Task_0p9y4kh_hdp3]
		JOIN #PrdWise ON PrdDataFk = DataPk AND PrdKeyFk = KeyFk
		JOIN #TmpGeoMas ON PrdBrnchFk = TGeoFk
		GROUP BY TGeoNm,Items,TGeoFk,KeyFk,Val
	
		UPDATE  #PrdAcpted SET PrdAcptName = EAcptName
		FROM #PrdAcpted
		JOIN #PrdEnquired ON PrdKeyFk = EkeyFk

		SELECT PrdBranchName 'BranchName',ECost - PrdCost 'Cost',PrdAcptName 'Product' INTO #FinalPvtTbl
		FROM #PrdAcpted
		JOIN #PrdEnquired ON PrdKeyFk = EkeyFk

		SELECT BranchName,CAST(ISNULL([Product1],0) AS NUMERIC(27,2))'Product1',CAST(ISNULL([Product2],0) AS NUMERIC(27,2))'Product2'
		,CAST(ISNULL([Product3],0) AS NUMERIC(27,2))'Product3'
		FROM 
		(
		SELECT * FROM #FinalPvtTbl
		)A
		PIVOT
		(
		SUM(Cost) FOR Product IN ([Product1],[Product2],[Product3])
		)B

		SELECT *
		FROM
		(
			SELECT 0 limit,'lime' color  UNION
			SELECT 12000*0.20 limit,'#80C31C' color  UNION
			SELECT 12000*0.40 limit,'YELLOW' color  UNION
			SELECT 12000*0.60 limit,'#FBB36B' color  UNION
			SELECT 12000*0.80 limit,'ORANGE' color  UNION
			SELECT 12000 limit,'#F44336' color  
		)COLOR ;


		--SELECT BranchName,EnquiredCost 'Sales',EnquiredCost-ApprovedCost 'Cost' FROM #FinalPftLss
	END

	IF @FLAG='RegSales'
	BEGIN
		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @QcAprv AND BioOutBfwFk = @QcAcpt

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = QcAprv AND BioOutBfwFk = QcAcpt

		INSERT INTO #FinalAcpt(FKeyFk,FBioPk,FBexFk)
		SELECT BexKeyFk,BexBioFk,BexPk FROM BpmExec
		JOIN  #DataPk ON BioFk = BexBioFk
		WHERE BexIsRej = 0
		
		INSERT INTO #AcptEstVal(EstDataFk,EstKeyFk,EstBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0sxifdt 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0sxifdt] 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #EnqVal(EnqDataFk,EnqKeyFk,EnqBrnchFk)
		SELECT Max(DataPk),KeyFk,BranchFk FROM GEN_2242_Task_0p9y4kh_hdp3 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk
		UNION ALL 
		SELECT Max(DataPk),KeyFk,BranchFk FROM [GEN_2275_Task_0p9y4kh_hdp3] 
		JOIN #FinalAcpt ON KeyFk = FKeyFk
		GROUP BY KeyFk,BranchFk

		INSERT INTO #TotEnqVsAcp(BranchName,Cost,AppOrEnq)
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0sxifdt
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		GEN_2242_Task_0p9y4kh_hdp3
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,(CAST(Raw_Material AS NUMERIC(27,7)) + CAST(Overhead AS NUMERIC(27,7))),'ApprovedCost' AS 'EnqVsApr' FROM 
		[GEN_2275_Task_0sxifdt]
		JOIN #AcptEstVal ON EstDataFk = DataPk AND EstKeyFk = KeyFk
		JOIN #TmpGeoMas ON EstBrnchFk = TGeoFk
		UNION ALL
		SELECT TGeoNm,Val,'EnquiredCost' AS 'EnqVsApr' FROM 
		[GEN_2275_Task_0p9y4kh_hdp3]
		JOIN #EnqVal ON EnqDataFk = DataPk AND EnqKeyFk = KeyFk
		JOIN #TmpGeoMas ON EnqBrnchFk = TGeoFk
	
		SELECT BranchName,ISNULL([ApprovedCost],0)'ApprovedCost',ISNULL([EnquiredCost],0) 'EnquiredCost' 
		FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ([ApprovedCost],[EnquiredCost])
		)B
	END

	IF @FLAG='NotDispatched'
	BEGIN
		CREATE TABLE #Apprvd(AKeyFk BIGINT,ABioPk BIGINT,ABexFk BIGINT,ABexBrnchFk BIGINT)
		CREATE TABLE #NotDispatched(NKeyFk BIGINT,NBioPk BIGINT,NBexFk BIGINT,NBexBrnchFk BIGINT)

		--INSERT INTO #DataPk(BioFk,Stat)
		--SELECT BioPk,'Accepted' FROM BpmObjInOut WHERE BioBfwFk = @AcptFk AND BioOutBfwFk = @QcAprv

		INSERT INTO #DataPk(BioFk,Stat)
		SELECT BioPk,'Accepted' FROM BpmObjInOut 
		JOIN #ProcessSts ON BioBfwFk = AcptFk AND BioOutBfwFk = QcAprv

		INSERT INTO #NotDispatched(NKeyFk,NBioPk,NBexFk,NBexBrnchFk)
		SELECT BexKeyFk,BexBioFk,BexPk,BexBrnchFk FROM BpmExec
		JOIN	#DataPk ON BioFk = BexBioFk
		JOIN	BpmNextOpUsr(NOLOCK) ON BnoBexFk = BexPk 
		WHERE BexIsRej = 0 AND NOT EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)

		INSERT INTO #Apprvd(AKeyFk,ABioPk,ABexFk,ABexBrnchFk)
		SELECT BexKeyFk,BexBioFk,BexPk,BexBrnchFk FROM BpmExec
		JOIN	#DataPk ON BioFk = BexBioFk
		JOIN	BpmNextOpUsr(NOLOCK) ON BnoBexFk = BexPk 
		WHERE BexIsRej = 0 AND EXISTS (SELECT NULL FROM BpmExecStatus(NOLOCK) WHERE BesBexFk = BnoBexFk AND BesDelId = 0)


		INSERT INTO #TotEnqVsAcp(BranchName,Cost,AppOrEnq)
		SELECT TGeoNm,COUNT(NKeyFk),'NotDispatched' AS 'EnqVsApr' FROM 
		#NotDispatched
		JOIN #TmpGeoMas ON NBexBrnchFk = TGeoFk
		GROUP BY TGeoNm
		UNION ALL
		SELECT TGeoNm,COUNT(AKeyFk),'Approved' AS 'EnqVsApr' FROM 
		#Apprvd
		JOIN #TmpGeoMas ON ABexBrnchFk = TGeoFk
		GROUP BY TGeoNm
	
	--SELECT * FROM #TotEnqVsAcp

		SELECT BranchName,ISNULL([Approved],0)'Approved',ISNULL([NotDispatched],0) 'NotDispatched' 
		FROM 
		(
		SELECT * FROM #TotEnqVsAcp
		)A
		PIVOT
		(
		SUM(Cost) FOR AppOrEnq IN ([Approved],[NotDispatched])
		)B

		
	END
END







GO
