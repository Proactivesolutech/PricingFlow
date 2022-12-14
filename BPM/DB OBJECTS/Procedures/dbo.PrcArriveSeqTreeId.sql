USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcArriveSeqTreeId]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcArriveSeqTreeId]
(
	@VerPk		BIGINT	=	NULL,
	@UpdtID		INT		=	0
)
AS
BEGIN
	
	SET NOCOUNT ON
	
	DECLARE @PrtMinCnt INT, @PrtMaxCnt INT, @MinFk BIGINT, @MaxFk BIGINT, @SelId BIGINT, @Id BIGINT, @SrcId BIGINT, 
			@TrgId BIGINT, @seqTreeId VARCHAR(100), @LoopRwCnt INT = 0, @IsUpdt INT = 0, @IsUpdtCnt INT = 1,
			@LoopSrcFk BIGINT, @LoopFk BIGINT, @IsPrtUpdt INT = 0, @LoopFlg INT, @IsTreeExists INT = 0;
	DECLARE @Ids TABLE(Id BIGINT, NxtFlg INT, seqTree VARCHAR(100), seqFlg BIGINT)
	
	CREATE TABLE #SeqTbl_Loop
	(
		FinBioFk BIGINT, FinFlowFk BIGINT, FinProcFlg INT, FinId VARCHAR(100), FinSrcId VARCHAR(100), FinSrcFk BIGINT, 
		FinTrgId VARCHAR(100), FinTrgFk BIGINT, seqTreeId VARCHAR(100) , Flg INT, IsUpdt INT DEFAULT 0,
		PrtSNo INT,  BtbFk BIGINT
	)
		
	IF @VerPk IS NOT NULL
	BEGIN
		CREATE TABLE #SeqTbl
		(
			FinBioFk BIGINT, FinFlowFk BIGINT, FinProcFlg INT, FinId VARCHAR(100), FinSrcId VARCHAR(100), FinSrcFk BIGINT, 
			FinTrgId VARCHAR(100), FinTrgFk BIGINT, seqTreeId VARCHAR(100) , Flg INT, IsUpdt INT DEFAULT 0,
			PrtSNo INT,  BtbFk BIGINT
		)
		
		INSERT INTO #SeqTbl
		(
			FinBioFk, FinFlowFk, FinProcFlg, FinId, FinSrcId, FinSrcFk, FinTrgId, FinTrgFk , seqTreeId ,Flg , PrtSNo , IsUpdt, BtbFk
		)
		SELECT		A.BioPk, A.BioBfwFk, CASE	WHEN LOWER(C.BtbToolNm) = 'bpmn:startevent' AND ISNULL(A.BioInBfwFk,0) = 0 AND ISNULL(BioSubBfwFk,0) = 0 THEN 1 
												WHEN LOWER(C.BtbToolNm) = 'bpmn:endevent' AND ISNULL(A.BioOutBfwFk,0) = 0 AND ISNULL(BioSubBfwFk,0) = 0 THEN 999
												ELSE 0 END, 
					A.BioId,  A.BioInId, A.BioInBfwFk, A.BioOutId, A.BioOutBfwFk, 
					'001', ROW_NUMBER()OVER 
					(ORDER BY CASE	WHEN LOWER(C.BtbToolNm) = 'bpmn:startevent' AND ISNULL(A.BioInBfwFk,0) = 0 AND ISNULL(BioSubBfwFk,0) = 0 THEN 0 
									WHEN LOWER(C.BtbToolNm) = 'bpmn:endevent' AND ISNULL(A.BioOutBfwFk,0) = 0 AND ISNULL(BioSubBfwFk,0) = 0 THEN 999
									ELSE 1 END),
					DENSE_RANK() OVER(ORDER BY dbo.gefgGetPrtFk(B.BfwPrtRef)), 0,C.BtbPk
		FROM		BpmObjInOut(NOLOCK) A
		JOIN		BpmFlow(NOLOCK) B ON A.BioBfwFk = B.BfwPk AND B.BfwDelid = 0
		JOIN		BpmToolBox(NOLOCK) C ON B.BfwBtbFk = C.BtbPk AND C.BtbDelid = 0
		WHERE		A.BioBvmFk = @VerPk AND A.BioDelid = 0			
	END
	
	--SELECT * FROM #SeqTbl
	--RETURN
	--------------------------------- Sequence No. For Flow Work Starts -------------------------------------------
	
	--- If Multiple Pool or Participant Exists, then Loop through each one.
		SELECT @PrtMinCnt = MIN(PrtSNo) , @PrtMaxCnt = MAX(PrtSNo) FROM #SeqTbl WHERE IsUpdt = 0 
		
		WHILE @PrtMinCnt <= @PrtMaxCnt
			BEGIN
				DELETE FROM #SeqTbl_Loop
				
				SELECT @IsUpdt = 0, @seqTreeId = '', @IsUpdtCnt = 1
				
				-- Get Details about one Pool at a time from Main Table.
					INSERT INTO #SeqTbl_Loop
					(
						FinBioFk, FinFlowFk, FinProcFlg, FinId, FinSrcId, FinSrcFk, FinTrgId, FinTrgFk , seqTreeId ,Flg , PrtSNo , IsUpdt, BtbFk
					)
					SELECT FinBioFk, FinFlowFk, FinProcFlg, FinId, FinSrcId, FinSrcFk, FinTrgId, FinTrgFk, seqTreeId ,Flg , PrtSNo , IsUpdt, BtbFk
					FROM #SeqTbl WHERE PrtSNo = @PrtMinCnt
					
				-- Loops through till all the column is allocated with seq No.
					WHILE @IsUpdt = 0 
						BEGIN 
						
						-- To arrive seq No. from previous loop if available.
							SELECT	@LoopSrcFk = 0, @MinFk = 0, @MaxFk = 0 , @IsPrtUpdt = 0, @LoopFlg = 0,
									@IsTreeExists = 0
							
						-- Get Min Flag and Max Flag to determine Start and End.
							SELECT @MinFk = MIN(Flg), @MaxFk = MAX(Flg) FROM #SeqTbl_Loop WHERE IsUpdt = 0 

						-- Start Flow already has a seq No. so update to 1
							UPDATE #SeqTbl_Loop SET IsUpdt = 1 WHERE Flg = @MinFk AND FinProcFlg = 1 AND ISNULL(FinSrcFk,0) = 0;
										
						-- Get the Source Fk of the Loop Fk, which is already Updated to get the running seqNo.
							IF @IsUpdtCnt > 1
								BEGIN
									WHILE ISNULL(@LoopFlg,0) = 0
										BEGIN
											-- Get the Source Fk From the Min Flag.	
												SELECT @LoopSrcFk = FinFlowFk FROM #SeqTbl_Loop WHERE Flg = @MinFk
												
											-- Get SeqNo of the Parent and Add +1 to get the next seqNo.
												SELECT	@seqTreeId = ISNULL(seqTreeId,'') + '001', 
														@IsPrtUpdt = IsUpdt,
														@LoopFlg = Flg
												FROM #SeqTbl_Loop WHERE FinTrgFk = @LoopSrcFk
												
											-- Allocate New Tree Id which doesn't Exists already.	
												WHILE ISNULL(@IsTreeExists,0) = 0
													BEGIN
														IF EXISTS(SELECT 'X' FROM #SeqTbl_Loop WHERE (RTRIM(seqTreeId) = @seqTreeId OR LEFT(RTRIM(seqTreeId),3) = @seqTreeId))
															BEGIN
																SET @seqTreeId = LEFT(@seqTreeId,(LEN(@seqTreeId)-3)) 
																				+ dbo.gefgGetPadZero(3,(CONVERT(BIGINT,RIGHT(@seqTreeId,3)) + 1))
																SET @IsTreeExists = 0
															END
														ELSE
															SET @IsTreeExists = 1
													END
													
											IF ISNULL(@IsPrtUpdt,0) = 0
												BEGIN
													SELECT @MinFk = @LoopFlg, @seqTreeId = ''	
													SET @LoopFlg = 0
												END
										END
								END
							
						-- If SeqNo has No Value, then Loop runs for First Time, else update the seqNo to the Min Flag
							IF ISNULL(@seqTreeId,'') = ''
								BEGIN
									SELECT @seqTreeId = '002'
								END
							ELSE
								BEGIN
									UPDATE	#SeqTbl_Loop SET seqTreeId = @seqTreeId, IsUpdt = 1 
									WHERE	FinFlowFk = @LoopSrcFk AND Flg = @MinFk
									
									SET @seqTreeId = LEFT(@seqTreeId ,(LEN(@seqTreeId) - 3)) + dbo.gefgGetPadZero(3, (CONVERT(BIGINT,RIGHT(@seqTreeId,3)) + 1));
								END
						
						--- Loop For Arriving SeqNo with Min and Max Flg.							
						WHILE @MinFk < @MaxFk
							BEGIN
								-- Flush All Loop Variables to Empty
									DELETE FROM @Ids
									SELECT @TrgId = 0, @SelId = 0, @Id = 0;
									
								-- Get Target Fk and Loop Id From Min Flag.
									SELECT	@TrgId = FinTrgFk , @SelId = FinFlowFk
									FROM	#SeqTbl_Loop WHERE Flg = @MinFk

								-- If Loop has no Target, then it must be an End Event, So Get the Loop Values as such.
									IF ISNULL(@TrgId,0) = 0
										BEGIN
											INSERT INTO @Ids(Id, NxtFlg, seqFlg)
											SELECT @SelId, Flg , ROW_NUMBER() OVER (ORDER BY Flg)
											FROM #SeqTbl_Loop WHERE FinFlowFk = @SelId AND FinSrcFk = @LoopSrcFk AND IsUpdt = 0
											AND FinProcFlg NOT IN (999)
											
											SELECT @LoopRwCnt = @@ROWCOUNT
										END
								-- If it has Target Fk, then check the Table which has this Target Fk as Source Fk.
									ELSE
										BEGIN
											INSERT INTO @Ids(Id, NxtFlg, seqFlg)
											SELECT FinFlowFk, Flg , ROW_NUMBER() OVER (ORDER BY Flg) 
											FROM #SeqTbl_Loop WHERE FinFlowFk = @TrgId AND FinSrcFk = @SelId AND IsUpdt = 0
											AND FinProcFlg NOT IN (999)
											
											SELECT @LoopRwCnt = @@ROWCOUNT
										END
																				
								-- If Target has more than one source, then Append Row Number to the SeqNo to generate new SeqNo.
									IF @LoopRwCnt > 1
										UPDATE @Ids SET seqTree = @seqTreeId + dbo.gefgGetPadZero(3,seqFlg)
								-- If it is connected to one Source , then Increment the SeqNo
									ELSE
										BEGIN	
											IF EXISTS(SELECT 'X' FROM #SeqTbl_Loop WHERE FinTrgFk = @TrgId GROUP BY FinFlowFk,FinTrgFk HAVING COUNT(FinFlowFk) > 1)
												BEGIN
													IF NOT EXISTS(SELECT 'X' FROM #SeqTbl_Loop WHERE FinFlowFk = @TrgId AND FinProcFlg = 999)
														SET @seqTreeId = dbo.gefgGetPadZero(3,(CONVERT(BIGINT,LEFT(@seqTreeId,3)) + 1))
												END
											
											SET @IsTreeExists = 0;

											-- Allocate New Tree Id which doesn't Exists already.	
												WHILE ISNULL(@IsTreeExists,0) = 0
													BEGIN
														IF EXISTS(SELECT 'X' FROM #SeqTbl_Loop WHERE (RTRIM(seqTreeId) = @seqTreeId OR LEFT(RTRIM(seqTreeId),3) = @seqTreeId))
															BEGIN
																SET @seqTreeId = LEFT(@seqTreeId,(LEN(@seqTreeId)-3)) 
																				+ dbo.gefgGetPadZero(3,(CONVERT(BIGINT,RIGHT(@seqTreeId,3)) + 1))
																SET @IsTreeExists = 0
															END
														ELSE
															SET @IsTreeExists = 1
													END
											UPDATE @Ids SET seqTree = @seqTreeId
										END
										
								-- Update the Arrived SeqNo to the Table.
									UPDATE #SeqTbl_Loop SET seqTreeId = seqTree, IsUpdt = 1 
									FROM @Ids WHERE FinFlowFk = Id AND Flg = NxtFlg
								
								-- If Update Exists for the Condition , then Generate the next SeqNo for the upcoming Loop.
									IF @@ROWCOUNT > 0
										BEGIN
											SELECT	@seqTreeId = CASE @LoopRwCnt WHEN 1 THEN 
													LEFT(
														@seqTreeId, 
														(LEN(@seqTreeId) - 3)) + dbo.gefgGetPadZero(3,(CONVERT(BIGINT,RIGHT(@seqTreeId,3)) + 1)
														)  -- For Seq Flow.
													ELSE seqTree + '001'  END -- For Parellel Flow.
											FROM	@Ids;
										END
										
								-- Get the Next Min Fk to Loop through.	
									SELECT @MinFk = MAX(NxtFlg) FROM @Ids
									--SELECT * FROM #SeqTbl_Loop ORDER BY IsUpdt DESC,seqTreeId
							END
						-- If All Rows are updated then End the Loop	
							SELECT @IsUpdt = 1 WHERE NOT EXISTS(SELECT 'X' FROM #SeqTbl_Loop WHERE ISNULL(IsUpdt,0) = 0)
							SET @IsUpdtCnt = @IsUpdtCnt + 1;
					END
					
					SELECT @seqTreeId = dbo.gefgGetPadZero(3,MAX(CONVERT(BIGINT,RIGHT(seqTreeId,3)) + 1)) FROM #SeqTbl_Loop

				-- Insert Rows into Main Table with updated Data.
					INSERT INTO #SeqTbl
					(
						FinBioFk, FinFlowFk, FinProcFlg, FinId, FinSrcId, FinSrcFk, FinTrgId, FinTrgFk , seqTreeId ,Flg , PrtSNo , IsUpdt, BtbFk
					)
					SELECT	FinBioFk, FinFlowFk, FinProcFlg, FinId, FinSrcId, FinSrcFk, FinTrgId, FinTrgFk , 
							CASE FinProcFlg WHEN 999 THEN @seqTreeId ELSE seqTreeId END,Flg,PrtSNo , IsUpdt, BtbFk
					FROM	#SeqTbl_Loop
	
				-- Loop through till all the Pools are executed
					SELECT @PrtMinCnt = MIN(PrtSNo) FROM #SeqTbl WHERE PrtSNo > @PrtMinCnt AND IsUpdt = 1	
			END
	--------------------------------- Sequence No. For Flow Work Ends  -------------------------------------------
	DELETE FROM #SeqTbl WHERE IsUpdt = 0
	
	IF ISNULL(@UpdtID,0) = 0
		SELECT  ROW_NUMBER() OVER(ORDER BY seqTreeId) AS RowNo,seqTreeId, dbo.gefgGetToolNm(Src.BfwBtbFk) AS CompTyp, 
				ISNULL(Src.BfwLabel, '') AS [Source], ISNULL(Inc.BfwLabel, '') AS [Income], 
				ISNULL(Ou.BfwLabel,'') AS [Outgoing]--, BioId [SourceId], BioInId [IncomeId], BioOutId [OutgoingId] 
		FROM	BpmObjInOut A(NOLOCK)
				LEFT OUTER JOIN BpmFlow Src (NOLOCK) ON A.BioBfwFk = Src.BfwPk
				LEFT OUTER JOIN BpmFlow Inc (NOLOCK) ON A.BioInBfwFk = Inc.BfwPk
				LEFT OUTER JOIN BpmFlow Ou (NOLOCK) ON A.BioOutBfwFk = Ou.BfwPk
				JOIN #SeqTbl B ON A.BioPk = B.FinBioFk
		ORDER BY B.seqTreeId
	ELSE
		UPDATE BpmObjInOut SET BioTreeId = seqTreeId FROM #SeqTbl WHERE BioPk = FinBioFk

END


GO
