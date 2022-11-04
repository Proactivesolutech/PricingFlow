
IF OBJECT_ID('PrcShflAccEntry_Insert','P') IS NOT NULL
	DROP PROCEDURE PrcShflAccEntry_Insert
GO
CREATE Procedure [dbo].[PrcShflAccEntry_Insert]
(
	@p_AccPeriodFk INT,
	@p_SubAccFlg   CHAR = 'N'
)
As
BEGIN
	DECLARE @m_Tot            NUMERIC(16, 2), @m_FinalErr       VARCHAR(300), @m_LFlag         CHAR,
			@m_CompShrtDescr  VARCHAR(5),     @m_UnitShrtDescr  VARCHAR(5),   @m_DocType       VARCHAR(15),
			@m_OFlag		  CHAR,		      @m_SDocType       VARCHAR(15),  @m_AccPerdStMnth INT,		   
			@m_AccPerdENDMnth INT,			  @m_YFlag		    CHAR,		  @m_AFlag		   CHAR,
			@m_Prefix         VARCHAR(20),	  @m_Sql		    VARCHAR(8000), @p_SysDate	   DATETIME

	CREATE TABLE #DocNo_H 
	(
		Hdr_CompShrtDescr    VARCHAR(5),		Hdr_UnitShrtDescr      VARCHAR(5),  
		Hdr_SrcCompShrtDescr VARCHAR(5),		Hdr_SrcUnitShrtDescr   VARCHAR(5),
		Hdr_DocTypeShrtDescr VARCHAR(5),		Hdr_SubDoctypShrtDescr VARCHAR(5),  
		Hdr_DocTypeFk		 INT,				Hdr_SubDocTypeFk	   INT,
		Hdr_Docdt            DateTime,			Hdr_LinkRefNum         VARCHAR(30), 
		Hdr_NarratiON        VARCHAR(100),		Hdr_Amount             NUMERIC(12, 2),
		Hdr_Id               INT,				NoMethodFlg			   CHAR(1),
		DailyNoFlg           TinyINT,			StartingNo             INT,
		DocNo                VARCHAR(25),		LastNo                 INT Default 0,
		Hdr_PaidToRecdFrm    VARCHAR(50),		EnTRYSET			   INT,
		UsrNm				 VARCHAR(15)
	)

	BEGIN TRY	

		SET @m_LFlag = 'L'
		SET @m_AFlag = 'A'
		SET @m_OFlag = 'O'
		SET @m_YFlag = 'Y'
		SET @p_SysDate= GETDATE()

		IF EXISTS(SELECT TOP 1 'X' FROM #AccEntries A 
				  LEFT JOIN GGac_AccCode B ON (B.ShrtDescr = A.AccCode)
				  WHERE B.ShrtDescr Is Null)
		BEGIN  
			RAISERROR('Error Code : IGEN00007 - GL Code not defined', 16, 1)  
		END
		  
		SELECT @m_Tot = Sum(CASE WHEN DrCr = 'D' THEN Amt ELSE - Amt END) FROM #AccEntries

		IF @m_Tot <> 0
		BEGIN
			RAISERROR('Error Code : IGEN00014 - Debit & Credit Amount MisMatching', 16, 1)  
		END

		IF EXISTS (SELECT Top 1 'X' FROM #AccEntries A 
					JOIN GGac_AccCode B ON A.AccCode = B.ShrtDescr
					LEFT JOIN GGac_AccCodeCompUnitLnk C ON C.AccCd_FK = B.Pk_Id And A.CompShrtDescr = C.CompShrtDescr And C.UnitShrtDescr = A.UnitShrtDescr 
					WHERE C.Pk_Id Is Null)
		BEGIN    
			SELECT  @m_FinalErr = 'Error Code : IGEN00009 - There is No AccCd CompUnitlink for the Comp.' + A.CompShrtDescr +     
				' /Unit.' + A.UnitShrtDescr + ' for the GLCode.' + CONVERT(VARCHAR(15),A.AccCode) + ''    
				FROM #AccEntries A 
				JOIN GGac_AccCode B ON A.AccCode = B.ShrtDescr
				LEFT JOIN GGac_AccCodeCompUnitLnk C ON C.AccCd_FK = B.Pk_Id And A.CompShrtDescr = C.CompShrtDescr And C.UnitShrtDescr = A.UnitShrtDescr 
				WHERE C.Pk_Id Is Null

			RAISERROR ('%s', 16, 1, @m_FinalErr)       
		END  

		IF EXISTS(SELECT Top 1 'X' FROM #AccEntries B LEFT OUTER JOIN DBO.GGac_DocNoCtrl_H A (NOLOCK)
						ON (A.CompShrtDescr = B.CompShrtDescr And A.UnitShrtDescr = B.UnitShrtDescr And 
							A.DocType_FK = B.DocType_Fk And A.SubDocType_FK = B.SubDocType_FK
						    And A.AccPerd_FK = @p_AccPeriodFk And A.StatFlg = @m_LFlag) WHERE A.Pk_Id Is Null)
		BEGIN
			SELECT @m_CompShrtDescr = B.CompShrtDescr, @m_UnitShrtDescr = B.UnitShrtDescr, 
				@m_DocType = B.DocType, @m_SDocType = B.SubDocType 
				FROM #AccEntries B 
				LEFT JOIN DBO.GGac_DocNoCtrl_H A (NOLOCK) ON (A.CompShrtDescr = B.CompShrtDescr And A.UnitShrtDescr = B.UnitShrtDescr And 
															  A.DocType_FK = B.DocType_Fk And A.SubDocType_FK = B.SubDocType_FK And
															  A.AccPerd_FK = @p_AccPeriodFk And A.StatFlg = @m_LFlag) 
				WHERE A.Pk_Id Is Null				
			RAISERROR ('Error Code : IGEN00010 - DocCtrl Settings not defined for Comp. %s/Unit. %s/Doctype. %s/SubDoctype. %s',16,1, 
						@m_CompShrtDescr, @m_UnitShrtDescr, @m_DocType, @m_SDocType)
		END  
				
		;With CTE_Hdr
		As
		(
			SELECT Distinct CompShrtDescr, UnitShrtDescr, SrcCompShrtDescr, SrcUnitShrtDescr, DocType_Fk, 
							DocType, SubDocType_Fk, SubDocType, DocDt, NarratiON, LinkRefnum, PaidToRecdFrm,
							Sum(CASE WHEN DrCr='D' THEN Amt ELSE 0.00 END) As Amt, EntrySet, CrtdUsr 
			FROM #AccEntries 
			Group By CompShrtDescr, UnitShrtDescr, SrcCompShrtDescr, SrcUnitShrtDescr, DocType_Fk, 
					DocType, SubDocType_Fk, SubDocType, DocDt, NarratiON, LinkRefnum, PaidToRecdFrm, EntrySet, CrtdUsr
		)
		
		INSERT INTO #DocNo_H (Hdr_CompShrtDescr, Hdr_UnitShrtDescr, Hdr_SrcCompShrtDescr, Hdr_SrcUnitShrtDescr, 
							  Hdr_DocTypeFk, Hdr_SubDocTypeFk, Hdr_DocTypeShrtDescr, Hdr_SubDoctypShrtDescr, Hdr_Docdt, 
							  Hdr_LinkRefNum, Hdr_NarratiON, Hdr_Amount, Hdr_PaidToRecdFrm, Hdr_Id, NoMethodFlg, 
							  DailyNoFlg, StartingNo, EnTRYSET, UsrNm)
		SELECT B.CompShrtDescr, B.UnitShrtDescr, B.SrcCompShrtDescr, B.SrcUnitShrtDescr, B.DocType_Fk, 
				B.SubDocType_Fk, B.DocType, B.SubDocType, B.DocDt, B.LinkRefnum, B.NarratiON, B.Amt, 
				B.PaidToRecdFrm, A.Pk_Id, A.NoMethodFlg, A.DailyNoFlg, A.StartingNo, B.EntrySet, B.CrtdUsr
		FROM CTE_Hdr B  
		JOIN DBO.GGac_DocNoCtrl_H A ON A.CompShrtDescr = B.CompShrtDescr And A.UnitShrtDescr = B.UnitShrtDescr And A.DocType_FK = B.DocType_Fk 
									And A.SubDocType_FK = B.SubDocType_Fk And A.AccPerd_FK = @p_AccPeriodFk And A.StatFlg = @m_LFlag

		IF NOT EXISTS (SELECT Top 1 'x' FROM GGac_AccPeriod WHERE PK_ID = @p_AccPeriodFk And StatFlg = @m_OFlag)  		    
		BEGIN      
			RAISERROR ('Error Code : IGEN00011 - Not a valid account period!',16,1)
			Return -1
		END      

		SELECT @m_AccPerdStMnth = CONVERT(INT, StYearMnth),  
			   @m_AccPerdENDMnth = CONVERT(INT, ENDYearMnth)       
		FROM GGac_AccPeriod (NOLOCK) 
		WHERE StatFlg  = @m_OFlag And PK_ID = @p_AccPeriodFk   

		IF EXISTS(SELECT Top 1 'X' FROM #DocNo_H WHERE CONVERT(VARCHAR(6),Hdr_DocDt,112) < @m_AccPerdStMnth Or CONVERT(VARCHAR(6),Hdr_DocDt,112) > @m_AccPerdENDMnth)
		BEGIN
			RAISERROR('Error Code : IGEN00012 - Invalid Start Month / End Month!',16,1)
			Return -1    
		END
		
		Insert INTo DBO.GGac_DocNoCtrl_d(DocHdr_FK, LastGenNo, DocNumCtrlDate, Locked, CrtdDt, CrtdBy)  
		SELECT A.Hdr_Id, A.StartingNo As StartingNo, @p_SysDate, '*', @p_SysDate, UsrNm 
		FROM #Docno_H A 
		LEFT JOIN GGac_DocNoCtrl_D B ON B.DocHdr_FK = A.Hdr_ID And  CONVERT(VARCHAR(10),B.DocNumCtrlDate, 112) = CONVERT(VARCHAR(10), @p_SysDate, 112)
		WHERE B.LastGenNo Is Null And A.NoMethodFlg = @m_AFlag And A.DailyNoFlg = 1
		GROUP BY A.Hdr_Id, A.StartingNo, A.UsrNm

		INSERT INTO DBO.GGac_DocNoCtrl_d(DocHdr_FK, LastGenNo, DocNumCtrlDate, Locked, CrtdDt, CrtdBy)  
		SELECT A.Hdr_Id, A.StartingNo As StartingNo, @p_SysDate, '*', @p_SysDate, UsrNm 
		FROM #Docno_H A 
		LEFT JOIN GGac_DocNoCtrl_D B ON B.DocHdr_FK = A.Hdr_ID 
		WHERE B.LastGenNo Is Null And A.NoMethodFlg = @m_AFlag And A.DailyNoFlg = 0
		Group By A.Hdr_Id, A.StartingNo, A.UsrNm

		Update #DocNo_H SET LastNo = 0

		Update #DocNo_H SET LastNo = B.LastGenNo 
		FROM #Docno_H A 
		LEFT JOIN GGac_DocNoCtrl_D B ON B.DocHdr_FK = A.Hdr_ID And CONVERT(VARCHAR(10),B.DocNumCtrlDate, 112) = CONVERT(VARCHAR(10), @p_SysDate, 112)
		WHERE A.NoMethodFlg = @m_AFlag And A.DailyNoFlg = 1

		Update #DocNo_H SET LastNo = B.LastGenNo 
		FROM #Docno_H A 
		LEFT JOIN GGac_DocNoCtrl_D B ON B.DocHdr_FK = A.Hdr_ID 
		WHERE A.NoMethodFlg = @m_AFlag And A.DailyNoFlg = 0

		;With CTE_Doc1
		As
		(
			SELECT Hdr_CompShrtDescr, Hdr_UnitShrtDescr, Hdr_SrcCompShrtDescr, Hdr_SrcUnitShrtDescr, Hdr_DocTypeFk, 
				   Hdr_DocTypeShrtDescr, Hdr_SubDocTypeFk, Hdr_SubDocTypShrtDescr, Hdr_DocDt, Hdr_NarratiON, Hdr_LinkRefnum, 
				   Hdr_Amount, Hdr_Id, NoMethodFlg, DailyNoFlg, LastNo, 
				   LastNo + Row_Number() Over (PartitiON By Hdr_Id Order By Hdr_Id, NoMethodFlg, DailyNoFlg) As DocNo 
			FROM #DocNo_H
		)
		SELECT Hdr_Id, NoMethodFlg, DailyNoFlg, Max(DocNo) As LastDocNo 
		INTO #DocNo_H1 
		FROM CTE_Doc1 
		Group By Hdr_Id, NoMethodFlg, DailyNoFlg

		Update GGac_DocNoCtrl_D SET LastGenNo = B.LastDocNo 
		FROM GGac_DocNoCtrl_D A 
		JOIN #DocNo_H1 B ON A.DocHdr_FK = B.Hdr_ID And CONVERT(VARCHAR(10),A.DocNumCtrlDate, 112) = CONVERT(VARCHAR(10), @p_SysDate, 112)
		WHERE B.NoMethodFlg = @m_AFlag And B.DailyNoFlg = 1

		Update GGac_DocNoCtrl_D SET LastGenNo = B.LastDocNo 
		FROM GGac_DocNoCtrl_D A JOIN #DocNo_H1 B ON A.DocHdr_FK = B.Hdr_ID 
		WHERE B.NoMethodFlg = @m_AFlag And B.DailyNoFlg = 0

		SELECT  @m_Prefix = CONVERT(VARCHAR(4), Year(@p_SysDate)) + Right('0' + CONVERT(VARCHAR(2), MONth(@p_SysDate)), 2) + Right('0' + CONVERT(VARCHAR(2), day(@p_SysDate)), 2)
		
		;With CTE_Doc
		As
		(
			SELECT Hdr_CompShrtDescr, Hdr_UnitShrtDescr, Hdr_SrcCompShrtDescr, Hdr_SrcUnitShrtDescr, Hdr_DocTypeFk, 
		        Hdr_SubDocTypeFk, Hdr_DocTypeShrtDescr, 
				Hdr_SubDocTypShrtDescr, Hdr_DocDt, Hdr_NarratiON, Hdr_LinkRefnum, Hdr_Amount, Hdr_Id, NoMethodFlg, 
				DailyNoFlg, LastNo, LastNo + Row_Number() Over (PartitiON By Hdr_Id Order By Hdr_Id, NoMethodFlg, DailyNoFlg) As DocNo,
				Hdr_PaidToRecdFrm, EnTRYSET 
				FROM #DocNo_H
		)
		INSERT INTO dbo.GGac_AccTran_H
		(      
			DocNoPS, StatFlg, CrtdDt, CrtdBy, DocNo, DocNoPrefix, DocNoSuffix, CompShrtDescr, UnitShrtDescr,  
		    SrcCompShrtDescr, SrcUnitShrtDescr, PaidToRcvdFrm, DocType_FK, DocTypeShrtDescr, SubDocType_FK,    
			SubDocTypShrtDescr, DocDt, BillDt, BillDueDt, VoucherAmt, NarratiON, EnTRYDt, LinkRefNum, PrINTCount,      
			ApprvdBy, ApprvdDt
		)
		OUTPUT Inserted.Pk_Id,
			Inserted.CompShrtDescr,  
			Inserted.UnitShrtDescr,  
			Inserted.SrcCompShrtDescr,
			Inserted.SrcUnitShrtDescr,
			Inserted.DocType_Fk,
			Inserted.SubDocType_Fk,
			Inserted.DocTypeShrtDescr,  
			Inserted.SubDoctypShrtDescr,  
			Inserted.DocDt,
			Inserted.LinkRefNum,
			Inserted.NarratiON,
			Inserted.PaidToRcvdFrm,
			Inserted.PrINTCount
			INTO #Temp_Ggac_hdr
		SELECT  0, 'L', @p_SysDate, A.UsrNm, CASE WHEN B.NoMethodFlg = @m_AFlag And B.DailyNoFlg = 0 THEN Right('000000' + ltrim(rtrim(str(B.DocNo))), 7) 
			ELSE @m_Prefix + Right('000000' + ltrim(rtrim(str(B.DocNo))), 7) END,
			'', '', A.Hdr_CompShrtDescr, A.Hdr_UnitShrtDescr, A.Hdr_SrcCompShrtDescr, 
			A.Hdr_SrcUnitShrtDescr, A.Hdr_PaidToRecdFrm, A.Hdr_DocTypeFK, A.Hdr_DocTypeShrtDescr, A.Hdr_SubDocTypeFK, 
			A.Hdr_SubDocTypShrtDescr, A.Hdr_DocDt, Null, Null, A.Hdr_Amount, A.Hdr_NarratiON,
			@p_SysDate, A.Hdr_LinkRefNum, A.EnTRYSET,
			 A.UsrNm, @p_SysDate
			FROM #DocNo_H A 
			JOIN CTE_Doc B ON A.Hdr_CompShrtDescr = B.Hdr_CompShrtDescr And A.Hdr_UnitShrtDescr = B.Hdr_UnitShrtDescr And A.Hdr_DocTypeShrtDescr = B.Hdr_DocTypeShrtDescr 
							  And A.Hdr_SubDocTypShrtDescr = B.Hdr_SubDocTypShrtDescr And A.Hdr_SrcCompShrtDescr = B.Hdr_SrcCompShrtDescr 
							  And A.Hdr_SrcUnitShrtDescr = B.Hdr_SrcUnitShrtDescr And A.Hdr_DocDt = B.Hdr_DocDt And A.Hdr_NarratiON = B.Hdr_NarratiON 
							  And A.Hdr_LinkRefnum = B.Hdr_LinkRefnum And A.Hdr_Amount = B.Hdr_Amount And A.Hdr_Id = B.Hdr_Id 
							  AND A.Hdr_PaidToRecdFrm = B.Hdr_PaidToRecdFrm And A.EnTRYSET = B.EnTRYSET
			ORDER BY A.Hdr_SrcCompShrtDescr, A.Hdr_SrcUnitShrtDescr, A.Hdr_LinkRefNum, A.EnTRYSET

		SET @m_Sql = ''
		SET @m_Sql = @m_Sql + 'Insert INTo dbo.GGac_AccTran_d(CrtdDt, CrtdBy, Hdr_FK, AccCd_FK, AccCd, DrCr, Amt, TranType_FK, TranType,' 
		SET @m_Sql = @m_Sql + 'SubAcc_FK, SubAccCd, BillRefNum) '
		SET @m_Sql = @m_Sql + 'OUTPUT Inserted.Hdr_Fk,'
		SET @m_Sql = @m_Sql + 'Inserted.AccCd_FK,'
		SET @m_Sql = @m_Sql + 'Inserted.AccCd,'
		SET @m_Sql = @m_Sql + 'Inserted.DrCr,'
		SET @m_Sql = @m_Sql + 'Inserted.Amt '
		SET @m_Sql = @m_Sql + 'INTO #Temp_Ggac_D '
		SET @m_Sql = @m_Sql + 'SELECT ' + '''' + CONVERT(VARCHAR, @p_SysDate) + '''' + ', A.CrtdUsr' --+ '''' + @p_UserId + '''' 
		SET @m_Sql = @m_Sql + ', C.Pk_Id, B.Pk_Id, A.AccCode, A.DrCr, A.Amt, Null,' + '''' + '''' + ','
		SET @m_Sql = @m_Sql + CASE WHEN @p_SubAccFlg = 'Y' THEN 'A.SubAcc_FK' ELSE 'Null' END + ' As SubAcc_Fk, '
		SET @m_Sql = @m_Sql + CASE WHEN @p_SubAccFlg = 'Y' THEN 'A.SubAccCd'  ELSE '''' + '''' END + ' As SubAccCd, '
		SET @m_Sql = @m_Sql + 'Null FROM  #AccEntries A JOIN GGac_AccCode B ON (B.ShrtDescr = A.AccCode) '
		SET @m_Sql = @m_Sql + 'JOIN #Temp_Ggac_hdr C ON (A.CompShrtDescr = C.CompShrtDescr And A.UnitShrtDescr = C.UnitShrtDescr And '
		SET @m_Sql = @m_Sql + 'A.SrcCompShrtDescr = C.SrcCompShrtDescr And A.SrcUnitShrtDescr = C.SrcUnitShrtDescr And '
		SET @m_Sql = @m_Sql + 'A.DocType = C.DocTypeShrtDescr And A.SubDocType = C.SubDocTypShrtDescr And '
		SET @m_Sql = @m_Sql + 'A.LinkRefNum = C.LinkRefNum And A.NarratiON = C.NarratiON and a.PaidToRecdFrm = c.PaidToRcvdFrm and a.EnTRYSET = c.EnTRYSET);'

		EXEC(@m_Sql)

		IF EXISTS (SELECT Top 1 A.CompShrtDescr, A.UnitShrtDescr, A.DocNo, A.Voucheramt, A.DocType_Fk, 
					A.SubDocType_Fk, Sum(CASE WHEN B.DrCr = 'D' THEN B.Amt ELSE 0.00 END) As Debit, 
					Sum(CASE WHEN B.DrCr = 'C' THEN B.Amt ELSE 0.00 END) As Credit
					FROM GGac_AccTran_H A JOIN #Temp_Ggac_hdr Hdr ON (A.Pk_Id = Hdr.Pk_Id) JOIN
					GGac_AccTran_D B ON (B.Hdr_Fk = A.Pk_Id) Group By A.CompShrtDescr, A.UnitShrtDescr, 
					A.DocNo, A.VoucherAmt, A.DocType_Fk, A.SubDocType_Fk
					Having Sum(CASE WHEN B.DrCr = 'D' THEN B.Amt ELSE 0.00 END) <> Sum(CASE WHEN B.DrCr = 'C' THEN B.Amt ELSE 0.00 END)
					And (Sum(CASE WHEN B.DrCr = 'C' THEN B.Amt ELSE 0.00 END) <> A.VoucherAmt Or
					Sum(CASE WHEN B.DrCr = 'D' THEN B.Amt ELSE 0.00 END) <> A.VoucherAmt))
		BEGIN
			RAISERROR('Error Code : IGEN00013 - Documentwise Debit & Credit Amount Mismatching', 16, 1)
		END		
		
		IF EXISTS(SELECT Top 1 'X' FROM #TmpInstr_d)
		BEGIN 
			Update #TmpInstr_d SET Instr_RefHdrFK = b.Det_RefHdr_Fk 
			FROM 
			(
				SELECT AcccdShrtDescr,Sum(Instr_Amt) as InStr_Amt, Instr_LinkRefNum--, instr_payblat 
				FROM #TmpInstr_d 
				Group by AcccdShrtDescr,Instr_LinkRefNum
			) A --, instr_payblat
			JOIN 
			(
				SELECT Det_RefHdr_Fk, Det_Acccd, Abs(Sum(CASE WHEN Det_DrCr ='D' THEN Det_Amt ELSE -Det_Amt END)) As Det_Amt 
				FROM #Temp_Ggac_D 
				Group by Det_RefHdr_Fk,Det_Acccd 
			) B ON B.Det_Acccd = A.AcccdShrtDescr And B.Det_Amt = A.Instr_Amt 
			JOIN #TmpInstr_d C ON c.AcccdShrtDescr =  B.Det_Acccd and c.Instr_Amt = B.Det_Amt
			JOIN 
			(
				SELECT pk_id, LinkRefNum, EnTRYSET 
				FROM #Temp_Ggac_hdr
			) D ON  B.Det_RefHdr_Fk = D.Pk_id And D.LinkRefNum = C.Instr_LinkRefNum	--and	D.EnTRYSET = c.instr_payblat 
				
				
			IF EXISTS(SELECT Top 1 'x' FROM #TmpInstr_d WHERE isnull(Instr_RefHdrFK,'') = '')
			BEGIN
				RAISERROR('Error Code : IGEN00041 - Error While Updating Instrument Details...', 16, 1)
			END
			INSERT INTO GGac_AccInstr_d        
			(
				Hdr_FK, BnkShrtDescr, InstrType_FK, InstrShrtDescr, InstrNo, InstrDt, InstrAmt, 
				--PayblAt,PayInSlipType_FK, PayInSlipShrtDescr, ChequeStat, StatDt, 
				AcccdShrtDescr, ApprvdDt, ApprvdBy,   
				CrtdDt, CrtdBy   
			)
			SELECT 	Instr_RefHdrFK,	Instr_BnkShrtDescr,	Instr_TypeFK, Instr_ShrtDescr, Instr_No, Instr_Dt,Instr_Amt, 
					--Instr_PayblAt, Instr_PayInSlipTypeFK, Instr_PayInSlipShrtDescr,Instr_ChequeStat, Instr_StatDt, 
					AcccdShrtDescr, @p_SysDate, ApprvdBy, @p_SysDate, ApprvdBy
					FROM #TmpInstr_d
			IF @@RowCount = 0
			BEGIN
				RAISERROR('Error Code : IGEN00041 - Error While Updating Instrument Details...', 16, 1)
			END
		END
	END TRY
	BEGIN Catch
		SELECT @m_FinalErr = ERROR_MESSAGE()
		RAISERROR(@m_FinalErr, 16, 1)
		Return -1
	END Catch
END










