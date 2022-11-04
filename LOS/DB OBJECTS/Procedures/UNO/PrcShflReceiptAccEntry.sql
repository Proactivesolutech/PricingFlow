--EXEC PrcShflReceiptAccEntry 95362, 'LeadRealized'--,'LeadReceipt'
IF OBJECT_ID('PrcShflReceiptAccEntry','P') IS NOT NULL
	DROP PROCEDURE PrcShflReceiptAccEntry
GO
CREATE PROCEDURE PrcShflReceiptAccEntry
(
	@LeadPk BIGINT		= NULL,
	@Action VARCHAR(50)	= ''
)
AS
BEGIN
	DECLARE @ErrMsg VARCHAR(MAX), @ErrSeverity INT
	BEGIN TRY	
		BEGIN TRAN	
			DECLARE @AccPerd_FK BIGINT, @CompDesc VARCHAR(5)
			
			--Company Shrt Description
			SET @CompDesc = 'SHFL'

			------------------------------------------------------Accounting Entry Details------------------------------------------------------
			CREATE TABLE #AccEntryMap
			(
				Id BIGINT IDENTITY(1,1), AccEntryType VARCHAR(50), Comp VARCHAR(50), AccCd VARCHAR(15), PayType VARCHAR(1),
				DocType VARCHAR(5), SubDocType VARCHAR(5), Account VARCHAR(100), SubAccCdAttr VARCHAR(30)
			)

			------------------------------------------------------Account Code Details------------------------------------------------------------
			CREATE TABLE #AccCodeMap
			(
				Id BIGINT IDENTITY(1,1), Account VARCHAR(100), AccCd VARCHAR(15), PrdCd VARCHAR(100), PrdFK BIGINT
			)

			--------------------------------------------------------- Instrumentwise Data --------------------------------------------------------
			CREATE TABLE #InstrDetails
			(
				Id BIGINT, RcptPK BIGINT, Unit VARCHAR(6), AccEntryType VARCHAR(50), 
				RcptNo VARCHAR(20),InstrAmt NUMERIC(27,2),  RcptDt DATETIME, RcptType VARCHAR(5),
				CustName VARCHAR(100), LeadId VARCHAR(50), LeadPk BIGINT, UsrNm VARCHAR(10), DepBankFK BIGINT,
				PrdFK BIGINT, SancNo VARCHAR(50), DrCr CHAR(1), LoanNo VARCHAR(50), LpcDpdFk BIGINT
			)

			--------------------------------------------------- Instrument Data with splitup ------------------------------------------------------
			CREATE TABLE #RecptDetails 
			(
				Id BIGINT, RcptPK BIGINT, Unit VARCHAR(6), AccEntryType VARCHAR(50), Comp VARCHAR(50), AccCode VARCHAR(15),
				RcptNo VARCHAR(20),RcptAmt NUMERIC(27,2), RcptBankShrtDesc VARCHAR(5), RcptDt DATETIME, RcptType VARCHAR(5),
				CustName VARCHAR(100), LeadId VARCHAR(50), LeadPk BIGINT, UsrNm VARCHAR(10), InstrAmt NUMERIC(27,2),
				BRSMatchRefNo INT, BRSBatchNo INT, BRSMode CHAR(1), PrdFK BIGINT, SancNo VARCHAR(50), DrCr CHAR(1), LoanNo VARCHAR(50), DpdFk BIGINT
			)
			
			------------------------------------------ Final Table for passing Accounting Entries ---------------------------------------------------
			CREATE TABLE #AccEntries 
			(	
				Id BIGINT IDENTITY(1,1), SrcCompShrtDescr	VARCHAR(5),	SrcUnitShrtDescr VARCHAR(5), CompShrtDescr VARCHAR(5), UnitShrtDescr VARCHAR(5),			
				PaidToRecdFrm  VARCHAR(50),	DocDt	DATETIME, LinkRefNum	VARCHAR(60), Narration VARCHAR(150),
				Amt NUMERIC(20,2),SubAccCd VARCHAR(30), SubAcc_Fk INT, AccCode VARCHAR(15), AccCd_FK INT, DrCr CHAR(1), 
				DocType VARCHAR(5), DocType_Fk INT, SubDocType VARCHAR(5), SubDocType_Fk INT, CrtdUsr VARCHAR(15),
				EntrySet INT				
			)

			------------------------------------------------Instrument Details Table-----------------------------------------------------------------
			CREATE TABLE #TmpInStr_d 
			( 
				Instr_RefHdrFK   BIGINT,	     Instr_BnkShrtDescr  VARCHAR(6),  Instr_TypeFK	            INT,
				Instr_ShrtDescr  VARCHAR(5),	 Instr_No			VARCHAR(20), Instr_Dt				    DATETIME,
				Instr_Amt        NUMERIC(20,2),  AcccdShrtDescr		VARCHAR(15), 
				ApprvdBy			VARCHAR(10), ApprvdDt 			DATETIME,
				Instr_LinkRefNum VARCHAR(30),
				BRSMatchRefNo INT, BRSBatchNo INT, BRSMode CHAR(1)
			)
			
			INSERT INTO #AccEntryMap( AccEntryType, Comp, AccCd, PayType, DocType, SubDocType, Account, SubAccCdAttr)
			VALUES('LeadReceipt','PFVAL','','D','SBR','HLIMB','Bank', 'Lead'),--Receipt - Against Lead	
				  ('LeadReceipt','PF','839555','C','SBR','HLIMB','Lead Contra', 'Lead'),
				  ('LeadReceipt','ST','744510','C','SBR','HLIMB','Service Tax Lead', 'Lead'),
				  ('LeadReceipt','KKC','744510','C','SBR','HLIMB','Cess1 Lead', 'Lead'),
				  ('LeadReceipt','SBC','744510','C','SBR','HLIMB','Cess2 Lead', 'Lead'),
				  				  				  
				  ('LeadReceipt','ST','744510','D','SJV','HLIMB','Service Tax Lead', 'Lead'),
				  ('LeadReceipt','ST','745048','C','SJV','HLIMB','Service Tax Lead Payable', 'Lead'),

				  ('LeadReceipt','KKC','744510','D','SJV','HLIMB','Cess1 Lead', 'Lead'),
				  ('LeadReceipt','KKC','745048','C','SJV','HLIMB','Cess1 Lead Payable', 'Lead'),

				  ('LeadReceipt','SBC','744510','D','SJV','HLIMB','Cess2 Lead', 'Lead'),			  				 				  
				  ('LeadReceipt','SBC','745048','C','SJV','HLIMB','Cess2 Lead Payable', 'Lead'),

				  ('LeadRealized','PF','839555','D','SJV','HLIMB','Lead Contra', 'Lead'),--Realized - Against Lead	
				  ('LeadRealized','PF','839556','C','SJV','HLIMB','Income at Lead', 'Lead'), 

				  ('SanctionAdj','PF','839556','D','SJV','HLIMB','Income at Lead', 'Lead'),--Sanction Adjustment	
				  ('SanctionAdj','PF','','C','SJV','HLIMB','Income at Sanction', 'Sanction'),

				  ('SancReceipt','PFVAL','','D','SBR','HLIMB','Bank', 'Sanction'),--Receipt - Against Sanction	
				  ('SancReceipt','PF','','C','SBR','HLIMB','Sanction Contra', 'Sanction'),
				  ('SancReceipt','ST','744504','C','SBR','HLIMB','Service Tax Sanction', 'Sanction'),
				  ('SancReceipt','KKC','744504','C','SBR','HLIMB','Cess1 Sanction', 'Sanction'),
				  ('SancReceipt','SBC','744504','C','SBR','HLIMB','Cess2 Sanction', 'Sanction'),
				  				  				  
				  ('SancReceipt','ST','744504','D','SJV','HLIMB','Service Tax Sanction', 'Sanction'),
				  ('SancReceipt','ST','745048','C','SJV','HLIMB','Service Tax Sanction Payable', 'Sanction'),

				  ('SancReceipt','KKC','744504','D','SJV','HLIMB','Cess1 Sanction', 'Sanction'),
				  ('SancReceipt','KKC','745048','C','SJV','HLIMB','Cess1 Sanction Payable', 'Sanction'),

				  ('SancReceipt','SBC','744504','D','SJV','HLIMB','Cess2 Sanction', 'Sanction'),			  				 				  
				  ('SancReceipt','SBC','745048','C','SJV','HLIMB','Cess2 Sanction Payable', 'Sanction'),

				  ('SancRealized','PF','','D','SJV','HLIMB','Sanction Contra', 'Sanction'),--Realized - Against Sanction	
				  ('SancRealized','PF','','C','SJV','HLIMB','Income at Sanction', 'Sanction'),

				  ('PFAdjWithLn','PFVAL','480090','D','SBR','HLIMB','Initial Money Collection Contra', 'Loan'),--PF Adjustment with Loan
				  ('PFAdjWithLn','PF','','C','SBR','HLIMB','Sanction Contra', 'Loan'),
				  ('PFAdjWithLn','ST','744504','C','SBR','HLIMB','Service Tax Sanction', 'Loan'),
				  ('PFAdjWithLn','KKC','744504','C','SBR','HLIMB','Cess1 Sanction', 'Loan'),
				  ('PFAdjWithLn','SBC','744504','C','SBR','HLIMB','Cess2 Sanction', 'Loan'),
				  				  				  
				  ('PFAdjWithLn','ST','744504','D','SJV','HLIMB','Service Tax Sanction', 'Loan'),
				  ('PFAdjWithLn','ST','745048','C','SJV','HLIMB','Service Tax Sanction Payable', 'Loan'),

				  ('PFAdjWithLn','KKC','744504','D','SJV','HLIMB','Cess1 Sanction', 'Loan'),
				  ('PFAdjWithLn','KKC','745048','C','SJV','HLIMB','Cess1 Sanction Payable', 'Loan'),

				  ('PFAdjWithLn','SBC','744504','D','SJV','HLIMB','Cess2 Sanction', 'Loan'),			  				 				  
				  ('PFAdjWithLn','SBC','745048','C','SJV','HLIMB','Cess2 Sanction Payable', 'Loan'),

				  ('PFAdjWithLn','PF','','D','SJV','HLIMB','Sanction Contra', 'Loan'),			  				 				  
				  ('PFAdjWithLn','PF','','C','SJV','HLIMB','Income at Sanction', 'Loan')
			
			-----------------------------------Sanction Contra & Income at Sanction AccCode with respective of Product----------------------------------------
			INSERT INTO #AccCodeMap(Account, AccCd, PrdCd)
			VALUES('Income at Sanction','839595','HLNew'),
				  ('Income at Sanction','839595','HLResale'),
				  ('Income at Sanction','839597','HLExt'),
				  ('Income at Sanction','839598','HLImp'),
				  ('Income at Sanction','839596','HLBT'),
				  ('Income at Sanction','839565','HLTopup'),
				  ('Income at Sanction','839595','HLPltConst'),
				  ('Income at Sanction','839595','HLConst'),
				  ('Income at Sanction','839595','HLRefin'),
				  ('Income at Sanction','839565','LAPResi'),
				  ('Income at Sanction','839565','LAPCom'),
				  ('Income at Sanction','839596','LAPBT'),
				  ('Income at Sanction','839565','LAPTopup'),
				  ('Income at Sanction','839599','PL'),

				  ('Sanction Contra','839583','HLNew'),
				  ('Sanction Contra','839583','HLResale'),
				  ('Sanction Contra','839585','HLExt'),
				  ('Sanction Contra','839586','HLImp'),
				  ('Sanction Contra','839584','HLBT'),
				  ('Sanction Contra','839563','HLTopup'),
				  ('Sanction Contra','839583','HLPltConst'),
				  ('Sanction Contra','839583','HLConst'),
				  ('Sanction Contra','839583','HLRefin'),
				  ('Sanction Contra','839563','LAPResi'),
				  ('Sanction Contra','839563','LAPCom'),
				  ('Sanction Contra','839584','LAPBT'),
				  ('Sanction Contra','839563','LAPTopup'),
				  ('Sanction Contra','839587','PL')
	
			UPDATE #AccCodeMap
			SET PrdFK = B.PrdPk
			FROM #AccCodeMap A
			JOIN [SHFL_LOS].dbo.GenPrdMas B On A.PrdCd = B.PrdCd

			-----------------------------------------------------PF AND BRS Details Insert------------------------------------------------------
			SELECT DISTINCT DENSE_RANK() OVER (order by A.LpcDocTyp,A.LpcLedFk) 'EntrySet',A.LpcPk, G.GeoCd, A.LpcInstrNo,  
						CASE A.LpcPayTyp WHEN 'C' THEN 'Chequ'
										WHEN 'D' THEN 'DD' 
										WHEN 'N' THEN 'RTGS' 
										WHEN 'R' THEN 'NEFT' 
						END 'LpcPayTyp', A.LpcInstrDt,  D.LedNm, D.LedId, LpcLedFk, 'Sync' CrtdUsr, A.LpcDepBankFK, A.LpcInstrAmt, 
						A.LpcPrdFk, ISNULL(A.LpcSancNo, '') 'LpcSancNo', ISNULL(A.LpcChqSts,'') 'LpcChqSts',	
						A.LpcDrCr, ISNULL(LpcAccEntry,'') 'LpcAccEntry', M.MasCd, A.LpcChrg, ISNULL(A.LpcLoanNo,'') 'LpcLoanNo',
						ISNULL(A.LpcDpdFK,0) 'LpcDpdFk'
			INTO #LOSInstrDetails
			FROM [SHFL_LOS].dbo.LosProcChrg(NOLOCK) A
			JOIN [SHFL_LOS].dbo.LosLead(NOLOCK) D ON A.LpcLedFk = D.LedPk 
			JOIN [SHFL_LOS].dbo.GenGeoMas(NOLOCK) G ON A.LpcBGeoFk = G.GeoPk AND G.GeoDelId = 0		
			JOIN [SHFL_LOS].dbo.GenMas(NOLOCK) M ON A.LpcDocTyp = M.MasPk AND M.MasDelId = 0
			WHERE A.LpcDelId = 0 AND A.LpcLedFk = ISNULL(@LeadPk,A.LpcLedFk) AND M.MasCd IN ('IMC', 'BPC', 'PCA', 'PCLA')

			IF(@Action = 'LeadReceipt' OR @Action = '')
			BEGIN
				INSERT INTO #InstrDetails(Id, RcptPK, Unit, AccEntryType, RcptNo, RcptType,RcptDt, CustName,
										  LeadId, LeadPk, UsrNm, DepBankFK,InstrAmt,PrdFK, SancNo)
				SELECT DISTINCT EntrySet,LpcPk, GeoCd, 'LeadReceipt', LpcInstrNo, LpcPayTyp, LpcInstrDt, LedNm,  
								LedId, LpcLedFk, CrtdUsr, LpcDepBankFK, LpcInstrAmt, LpcPrdFk, LpcSancNo
				FROM #LOSInstrDetails
				WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk)  AND MasCd IN ('IMC','BPC') AND LpcSancNo = '' AND LpcAccEntry = 'N'			
			END

			IF(@Action = 'LeadRealized' OR @Action = '')
			BEGIN
				INSERT INTO #InstrDetails(Id,RcptPK, Unit, AccEntryType, RcptNo, RcptType,RcptDt, CustName,
										  LeadId, LeadPk, UsrNm, DepBankFK,InstrAmt,PrdFK, SancNo)
				SELECT DISTINCT EntrySet,LpcPk, GeoCd, 'LeadRealized', LpcInstrNo,LpcPayTyp,LpcInstrDt, LedNm, 
								LedId, LpcLedFk, CrtdUsr, LpcDepBankFK, LpcInstrAmt, LpcPrdFk, LpcSancNo
				FROM #LOSInstrDetails					
				WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk) AND LpcAccEntry = 'Y' AND LpcChqSts = ''    
				AND MasCd IN ('IMC','BPC') AND LpcSancNo = '' 
				
				--Amt Realized after Santion adjustment(Lead COntra -> Income at Sanction)
				INSERT INTO #InstrDetails(Id,RcptPK, Unit, AccEntryType, RcptNo, RcptType,RcptDt, CustName,
										  LeadId, LeadPk, UsrNm, DepBankFK,InstrAmt,PrdFK, SancNo, LpcDpdFk, DrCr)
				SELECT DISTINCT EntrySet,LpcPk, GeoCd, 'SanctionAdj', LpcInstrNo,LpcPayTyp,LpcInstrDt, LedNm, 
							LedId, LpcLedFk, CrtdUsr, LpcDepBankFK, LpcChrg, LpcPrdFk, LpcSancNo, LpcDpdFk, LpcDrCr
				FROM #LOSInstrDetails 					
				WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk) AND LpcAccEntry = 'N' AND LpcChqSts = ''    
				AND MasCd IN ('PCA') AND LpcSancNo <> '' AND ISNULL(LpcDpdFk,0) <> 0
			END
			
			IF(@Action = 'SancReceipt' OR @Action = '')
			BEGIN
				INSERT INTO #InstrDetails(Id,RcptPK, Unit, AccEntryType, RcptNo, RcptType,RcptDt, CustName,
										  LeadId, LeadPk, UsrNm, DepBankFK,InstrAmt,PrdFK, SancNo)
				SELECT DISTINCT EntrySet,LpcPk, GeoCd,  'SancReceipt', LpcInstrNo,LpcPayTyp,LpcInstrDt, LedNm, 
								LedId, LpcLedFk, CrtdUsr, LpcDepBankFK, LpcInstrAmt, LpcPrdFk, LpcSancNo
				FROM #LOSInstrDetails
				WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk) AND LpcAccEntry = 'N' AND MasCd = 'BPC' AND LpcSancNo <> ''
			END
			
			IF(@Action = 'SancRealized' OR @Action = '')
			BEGIN					
				INSERT INTO #InstrDetails(Id,RcptPK, Unit, AccEntryType, RcptNo, RcptType,RcptDt, CustName,
										  LeadId, LeadPk, UsrNm, DepBankFK,InstrAmt,PrdFK, SancNo)
				SELECT DISTINCT EntrySet, LpcPk, GeoCd,   'SancRealized', LpcInstrNo, LpcPayTyp, LpcInstrDt, LedNm,   
								LedId, LpcLedFk, CrtdUsr, LpcDepBankFK, LpcInstrAmt, LpcPrdFk, LpcSancNo
				FROM #LOSInstrDetails				
				WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk) AND LpcAccEntry = 'Y' AND LpcChqSts = ''
				AND MasCd = 'BPC' AND LpcSancNo <> ''
			END

			IF(@Action IN ('SanctionAdj','LeadRealized',''))
			BEGIN
				--Adjusted cleared instrument details
				IF(@Action = 'SanctionAdj')
				BEGIN
					INSERT INTO #InstrDetails(Id,RcptPK, Unit, AccEntryType, RcptNo, RcptType,RcptDt, CustName,
											  LeadId, LeadPk, UsrNm, DepBankFK,InstrAmt,PrdFK, SancNo, DrCr)
					SELECT DISTINCT EntrySet, LpcPk, GeoCd, 'SanctionAdj', LpcInstrNo,LpcPayTyp,LpcInstrDt, LedNm,  
									LedId, LpcLedFk, CrtdUsr, LpcDepBankFK, LpcChrg, LpcPrdFk, LpcSancNo, LpcDrCr
					FROM #LOSInstrDetails	
					WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk) AND MasCd = 'PCA' AND LpcAccEntry = 'N' 
						  AND LpcDrCr = 'C' AND LpcChqSts = 'C'
				END

				--Sum of Cleared instrument amount as Debit
				;WITH CTE1
				AS
				(
					SELECT LeadPk 'CteLeadPk', MIN(RcptPK) 'CteRcptPK', SUM(InstrAmt) 'CteInstrAmt'
					FROM #InstrDetails
					WHERE AccEntryType = 'SanctionAdj'
					GROUP BY LeadPk
				)

				INSERT INTO #RecptDetails(Id, RcptPK, Unit, AccEntryType, Comp, AccCode,
									   RcptNo, RcptAmt, RcptBankShrtDesc, RcptType ,
									   RcptDt, CustName, LeadId, LeadPk, UsrNm, InstrAmt, PrdFK, SancNo, DrCr, DpdFk)
				SELECT DISTINCT Id, RcptPK, Unit, AccEntryType, 'PF', '' ,
					  RcptNo, B.CteInstrAmt, '', RcptType ,
					  RcptDt, CustName, LeadId, LeadPk, UsrNm, B.CteInstrAmt, PrdFK, SancNo, 'D', ISNULL(LpcDpdFk,0)
				FROM #InstrDetails A
				JOIN CTE1 B ON A.LeadPk = B.CteLeadPk AND A.RcptPK = B.CteRcptPK
				WHERE AccEntryType = 'SanctionAdj'

				INSERT INTO #RecptDetails(Id, RcptPK, Unit, AccEntryType, Comp, AccCode,
									   RcptNo, RcptAmt, RcptBankShrtDesc, RcptType ,
									   RcptDt, CustName, LeadId, LeadPk, UsrNm, InstrAmt, PrdFK, SancNo, DrCr, DpdFk)
				SELECT DISTINCT Id, RcptPK, Unit, AccEntryType, 'PF', '' ,
					  RcptNo, InstrAmt, '', RcptType ,
					  RcptDt, CustName, LeadId, LeadPk, UsrNm, InstrAmt, PrdFK, SancNo, DrCr, ISNULL(LpcDpdFk,0)
				FROM #InstrDetails 
				WHERE AccEntryType = 'SanctionAdj'

				UPDATE #RecptDetails 
				SET RcptPK = B.RcptPK
				FROM #RecptDetails A
				JOIN
				(
					SELECT DISTINCT LeadPk, MIN(RcptPK) RcptPK
					FROM #RecptDetails
					WHERE AccEntryType = 'SanctionAdj' 
					GROUP BY LeadPk
				) B ON A.LeadPk = B.LeadPk
				WHERE AccEntryType = 'SanctionAdj'				 
			END
		
			IF(@Action = 'PFAdjWithLn')
			BEGIN
				INSERT INTO #InstrDetails(Id, RcptPK, Unit, AccEntryType, RcptNo, RcptType,RcptDt, CustName,
										  LeadId, LeadPk, UsrNm, DepBankFK,InstrAmt,PrdFK, SancNo, DrCr, LoanNo)
				SELECT DISTINCT EntrySet, LpcPk, GeoCd, 'PFAdjWithLn', LpcInstrNo,LpcPayTyp,LpcInstrDt, LedNm,  
								LedId, LpcLedFk, CrtdUsr, LpcDepBankFK, LpcInstrAmt, LpcPrdFk, LpcSancNo, LpcDrCr, LpcLoanNo
				FROM #LOSInstrDetails	
				WHERE LpcLedFk = ISNULL(@LeadPk,LpcLedFk) AND MasCd = 'PCLA' AND LpcAccEntry = 'N' AND LpcLoanNo <> ''

				INSERT INTO #RecptDetails(Id, RcptPK, Unit, AccEntryType, Comp, AccCode,
										   RcptNo, RcptAmt, RcptBankShrtDesc, RcptType ,
										   RcptDt, CustName, LeadId, LeadPk, UsrNm, InstrAmt, PrdFK, SancNo, LoanNo)
				SELECT DISTINCT Id, RcptPK, Unit, AccEntryType, B.LpcdPcdCd, '',
					  RcptNo, B.LpcdAmt, '', RcptType ,
					  RcptDt, CustName, LeadId, LeadPk, UsrNm, A.InstrAmt, A.PrdFK, A.SancNo, A.LoanNo
				FROM #InstrDetails A
				JOIN [SHFL_LOS].dbo.LosProcChrgDtls B ON A.RcptPK = B.LpcdLpcFk AND B.LpcdDelId = 0	
				WHERE A.AccEntryType = 'PFAdjWithLn'
			END
		
			IF(@Action IN ('LeadReceipt','SancReceipt',''))
			BEGIN
				INSERT INTO #RecptDetails(Id, RcptPK, Unit, AccEntryType, Comp, AccCode,
										   RcptNo, RcptAmt, RcptBankShrtDesc, RcptType ,
										   RcptDt, CustName, LeadId, LeadPk, UsrNm, InstrAmt, PrdFK, SancNo, LoanNo)
				SELECT  DISTINCT Id, RcptPK, Unit, AccEntryType, B.LpcdPcdCd, 
					  CASE WHEN A.AccEntryType IN ('LeadReceipt','SancReceipt') AND B.LpcdPcdCd = 'PFVAL' THEN C.GabCd
						   ELSE '' END,
					  RcptNo, B.LpcdAmt, ISNULL(C.GabNm,''), RcptType ,
					  RcptDt, CustName, LeadId, LeadPk, UsrNm, A.InstrAmt, A.PrdFK, A.SancNo, A.LoanNo
				FROM #InstrDetails A
				JOIN [SHFL_LOS].dbo.LosProcChrgDtls B ON A.RcptPK  = B.LpcdLpcFk AND B.LpcdDelId = 0	
				JOIN [SHFL_LOS].dbo.GABnkMas C ON ISNULL(A.DepBankFK,0) = C.GabPk
				WHERE A.AccEntryType IN ('LeadReceipt','SancReceipt')
			END

			IF(@Action IN ('LeadRealized','SancRealized',''))
			BEGIN
				INSERT INTO #RecptDetails(Id, RcptPK, Unit, AccEntryType, Comp, AccCode,
										   RcptNo, RcptAmt, RcptType ,  RcptDt, 
										  CustName, LeadId, LeadPk, UsrNm, InstrAmt, PrdFK, SancNo, LoanNo)
				SELECT  DISTINCT Id, RcptPK, Unit, AccEntryType, B.LpcdPcdCd, '',
					  RcptNo, B.LpcdAmt, RcptType , RcptDt, 
					  CustName, LeadId, LeadPk, UsrNm, A.InstrAmt, A.PrdFK, A.SancNo, A.LoanNo
				FROM #InstrDetails A
				JOIN [SHFL_LOS].dbo.LosProcChrgDtls B ON A.RcptPK = B.LpcdLpcFk AND B.LpcdDelId = 0 --CASE WHEN ISNULL(A.LpcDpdFk,0) = 0 THEN A.RcptPK ELSE A.LpcDpdFk END 				
				WHERE A.AccEntryType IN ('LeadRealized','SancRealized')
			END
			
			-------------------------------Amt difference will be adjusted to Income(PF without Tax)------------------------------------------
			UPDATE #RecptDetails
			SET RcptAmt = RcptAmt + (A.InstrAmt - B.Amt)
			FROM #RecptDetails A
			JOIN
			( 
				SELECT Id, LeadPk, SUM(RcptAmt) 'Amt'
				FROM #RecptDetails 
				WHERE Comp <> 'PFVAL'
				GROUP BY Id, LeadPk
			) B ON A.Id = B.Id AND A.LeadPk = B.LeadPk AND A.AccEntryType IN ('LeadReceipt','LeadRealized','SancReceipt','SancRealized','PFAdjWithLn') 
			    AND A.Comp = 'PF'
			
			--------------------------------------------------BRS Details Insert----------------------------------------------------------------			
			UPDATE #RecptDetails 
			SET BRSMatchRefNo = I.BRSMatchRefInfo, BRSBatchNo = I.BRSbatchNo, BRSMode = I.BrsMode
			FROM #RecptDetails R
			JOIN GGAc_AccTran_h T(NOLOCK) ON CONVERT(VARCHAR(30),R.RcptPK) = T.LinkRefNum
			JOIN GGAc_AccInstr_d(NOLOCK) I ON T.Pk_Id = I.Hdr_FK			
			WHERE AccEntryType IN ('LeadRealized','SancRealized') 

			--Updating BRS status based on DpdFk(Lead receipt realized after sanc adjustment)
			UPDATE #RecptDetails 
			SET BRSMatchRefNo = I.BRSMatchRefInfo, BRSBatchNo = I.BRSbatchNo, BRSMode = I.BrsMode
			FROM #RecptDetails R
			JOIN GGAc_AccTran_h(NOLOCK) T ON CONVERT(VARCHAR(30),R.DpdFk) = T.LinkRefNum
			JOIN GGAc_AccInstr_d(NOLOCK) I ON T.Pk_Id = I.Hdr_FK			
			WHERE AccEntryType = 'SanctionAdj' AND ISNULL(DpdFk,0) > 0

			--Delete if bank statement is not generated  
			DELETE R 
			FROM #RecptDetails R
			WHERE AccEntryType IN ('LeadRealized','SancRealized') AND ISNULL(BRSMatchRefNo,0) = 0 AND ISNULL(BRSBatchNo,0) = 0

			--Delete if bank statement is not generated on DpdFk(Lead receipt realized after sanc adjustment)
			DELETE R 
			FROM #RecptDetails R
			WHERE AccEntryType ='SanctionAdj' AND ISNULL(DpdFk,0) > 0 AND ISNULL(BRSMatchRefNo,0) = 0 AND ISNULL(BRSBatchNo,0) = 0
					
			--Delete Other than Income entry 
			DELETE R 
			FROM #RecptDetails R
			WHERE AccEntryType IN ('LeadRealized','SancRealized') AND Comp <> 'PF'		
						
			--Accounting Period Checking
			SELECT @AccPerd_FK = PK_Id 
			FROM GGac_AccPeriod (NOLOCK) 
			WHERE CONVERT(VARCHAR(6), GETDATE(), 112) BETWEEN StYearMnth AND EndYearMnth 
			AND StatFlg = 'O'
			
			IF ISNULL(@AccPerd_FK,0) = 0
			BEGIN
				RAISERROR ('Invalid Accounting Period.',16,1)
			END		

			IF EXISTS (SELECT 'X' From #RecptDetails)
			BEGIN
				---------------------------------------------Mapping with Account Entry---------------------------------------------------
				SELECT  @CompDesc 'CompDesc', A.Unit, A.CustName, CONVERT(VARCHAR(60),A.RcptPK) 'RcptPk',
						CASE A.AccEntryType WHEN 'LeadReceipt' THEN 'PF Amount received towards Lead : ' + LeadId
						                    WHEN 'LeadRealized' THEN 'Income at Lead : ' + LeadId 
											WHEN 'SancReceipt' THEN 'PF Amount received towards Sanction : ' + SancNo
						                    WHEN 'SancRealized' THEN 'Income at Sanction : ' + SancNo 
											WHEN 'PFAdjWithLn' THEN 'Income at Proposal : ' + LoanNo 
						END 'Narration', RcptAmt, 
						CASE WHEN B.SubAccCdAttr = 'Lead' THEN LEFT(LeadId,15) 
							 WHEN B.SubAccCdAttr = 'Sanction' THEN LEFT(SancNo,15)
							 WHEN B.SubAccCdAttr = 'Loan' THEN LEFT(LoanNo,15) 
							 ELSE '' END 'SubAccCd', 
						CASE WHEN A.Comp = 'PFVAL' AND B.Account = 'Bank' THEN A.AccCode 
							 WHEN B.Account IN ('Income at Sanction','Sanction Contra') THEN C.AccCd
							 ELSE B.AccCd END 'AccCd', B.DocType, B.SubDocType, B.PayType, UsrNm,
						A.Id
				INTO #AccEntryWitAccCode
				FROM #RecptDetails A
				JOIN #AccEntryMap B ON A.AccEntryType = B.AccEntryType AND A.Comp = B.Comp	
				LEFT JOIN #AccCodeMap C ON A.PrdFK	= C.PrdFK AND B.Account = C.Account		
				WHERE A.AccEntryType <> 'SanctionAdj'
				UNION ALL
				SELECT  @CompDesc 'CompDesc', A.Unit, A.CustName, CONVERT(VARCHAR(60),A.RcptPK) 'RcptPk',
						'Income at Sanction : ' + LeadId 'Narration', RcptAmt, 
						CASE WHEN B.SubAccCdAttr = 'Lead' THEN LEFT(LeadId,15) 
							 WHEN B.SubAccCdAttr = 'Sanction' THEN LEFT(SancNo,15) 
							 ELSE '' END 'SubAccCd', 
						CASE WHEN B.Account IN ('Income at Sanction','Sanction Contra') THEN C.AccCd
							 ELSE B.AccCd END 'AccCd', B.DocType, B.SubDocType, B.PayType, UsrNm,
						A.Id
				FROM #RecptDetails A
				JOIN #AccEntryMap B ON A.AccEntryType = B.AccEntryType AND A.Comp = B.Comp	AND A.DrCr = B.PayType
				LEFT JOIN #AccCodeMap C ON A.PrdFK	= C.PrdFK AND B.Account = C.Account		
				WHERE A.AccEntryType = 'SanctionAdj'

				--Based On AccCode and PayType sum the amount
				INSERT INTO #AccEntries(SrcCompShrtDescr, CompShrtDescr,SrcUnitShrtDescr, UnitShrtDescr, PaidToRecdFrm, DocDt, LinkRefNum, 
										Narration, Amt,SubAccCd , AccCode, DocType, SubDocType, DrCr, CrtdUsr, EntrySet)
				SELECT  CompDesc, CompDesc, Unit, Unit, CustName, GETDATE(), RcptPk, 
						Narration, Sum(RcptAmt),SubAccCd, AccCd, DocType, SubDocType, PayType, UsrNm,Id
				FROM #AccEntryWitAccCode
				GROUP BY CompDesc, Unit, CustName, RcptPk, Narration, SubAccCd, AccCd, DocType, SubDocType, PayType, UsrNm,Id
				ORDER BY RcptPk,Id
		
				-- AccCode PK Updation
				UPDATE #AccEntries
				SET AccCd_FK = B.PK_Id
				FROM #AccEntries A
				JOIN GGAc_AccCode B ON A.AccCode = B.ShrtDescr

				-- DocType & SubDocType PK Updation
				UPDATE #AccEntries 
				SET DocType_Fk = B.PK_Id, SubDocType_Fk = C.PK_Id
				FROM #AccEntries A
				JOIN GGAc_DocumentType(NOLOCK) B ON  A.DocType = B.ShrtDescr 
				JOIN GGAc_SubDocumentType(NOLOCK) C ON B.PK_Id = C.DocType_FK AND A.SubDocType = C.ShrtDescr

				-- CtrlSubAccCode Insertion
				INSERT INTO GGAc_CtrlSubAcc(CtrlAcc_FK,CtrlAccCd,SubAccCdShrtDescr,SubAccCdDescr,StatFlg,CrtdDt,CrtdBy)
				SELECT DISTINCT AccCd_FK, AccCode, SubAccCd, '', 'L', GETDATE(), CrtdUsr  
				FROM #AccEntries A
				LEFT JOIN GGAc_CtrlSubAcc B ON A.AccCd_FK = B.CtrlAcc_FK  AND A.AccCode = B.CtrlAccCd AND A.SubAccCd = B.SubAccCdShrtDescr  
				WHERE ISNULL(A.SubAccCd,'') <> '' AND ISNULL(B.PK_Id,0) = 0

				UPDATE #AccEntries
				Set SubAcc_Fk = B.PK_Id
				FROM #AccEntries A
				JOIN GGAc_CtrlSubAcc B ON A.AccCd_FK = B.CtrlAcc_FK  AND A.AccCode = B.CtrlAccCd AND A.SubAccCd = B.SubAccCdShrtDescr

				--Instrument Details				
				INSERT INTO #TmpInStr_d( Instr_BnkShrtDescr,  Instr_TypeFK, Instr_ShrtDescr, Instr_No, Instr_Dt,
										 Instr_Amt, AcccdShrtDescr, ApprvdBy, ApprvdDt, Instr_LinkRefNum, BRSBatchNo, BRSMatchRefNo, BRSMode)
				SELECT DISTINCT A.RcptBankShrtDesc, B.PK_Id, A.RcptType, A.RcptNo, A.RcptDt,
								A.RcptAmt, A.AccCode, A.UsrNm, GETDATE(), CONVERT(VARCHAR(60),A.RcptPK),
								NULL, NULL, NULL
				FROM #RecptDetails A
				JOIN GGac_InstrumentType(NOLOCK) B ON A.RcptType = B.InstrShrtDescr
				WHERE A.AccEntryType IN ('LeadReceipt','SancReceipt') AND A.Comp = 'PFVAL'
							
				CREATE TABLE #Temp_Ggac_Hdr 
				(	
					Pk_id						BIGINT, 
					CompShrtDescr				VARCHAR(5),			UnitShrtDescr		VARCHAR(5),  
					SrcCompShrtDescr			VARCHAR(5),			SrcUnitShrtDescr	VARCHAR(5),  
					DocTypeFk					INT,				SubDocTypeFk		INT,
					DocTypeShrtDescr			VARCHAR(5),			SubDoctypShrtDescr	VARCHAR(5),  
					Docdt						DATETIME,			LinkRefNum			VARCHAR(60),
					Narration					VARCHAR(100),		PaidToRcvdFrm		varchar(250),
					EntrySet					Int
				)

				CREATE TABLE #Temp_Ggac_D	
				(	
					Det_RefHdr_Fk		BIGINT,				Det_AccCdFK      INT,
					Det_AccCd			VARCHAR(15),		Det_DrCr         CHAR(1),
					Det_Amt				NUMERIC(20, 2)
				)

				--Insert Data into Accounting Entries Table
				EXEC PrcShflAccEntry_Insert @p_AccPeriodFk = @AccPerd_FK, @p_SubAccFlg = 'Y'

				--Updating Status for AccEntries Passed or Not 
				UPDATE [SHFL_LOS].dbo.LosProcChrg 
				SET LpcAccEntry = 'Y'
				FROM #RecptDetails R 
				JOIN #Temp_Ggac_Hdr A ON R.RcptPK = A.LinkRefNum AND R.AccEntryType IN ('LeadReceipt','SancReceipt','PFAdjWithLn')
				JOIN [SHFL_LOS].dbo.LosProcChrg B ON A.LinkRefNum = B.LpcPk

				--Realized details Updation
				SELECT R.RcptPK, F.RDate
				INTO #InstrClrDet
				FROM #RecptDetails R 
				JOIN [SHFL_LOS].dbo.LosProcChrg A ON R.RcptPK = A.LpcPk AND R.AccEntryType IN ('LeadRealized','SancRealized') 
												  AND ISNULL(BRSBatchNo,0) <> 0 AND ISNULL(BRSMatchRefNo,0) <> 0				
			    JOIN GGAc_BankStatement_d(NOLOCK) F ON R.BRSBatchNo = F.BRSbatchNo AND R.BRSMatchRefNo = F.BRSMatchRefInfo AND R.BRSMode = F.BrsMode
											AND R.RcptNo = F.InstrNo AND A.LpcInstrAmt = (F.Debit + F.Credit)	
														
				UPDATE [SHFL_LOS].dbo.LosProcChrg 
				SET LpcChqSts = 'C', LpcChqClrDt = A.RDate
				FROM #InstrClrDet A
				JOIN [SHFL_LOS].dbo.LosProcChrg B ON A.RcptPK = B.LpcPk

				UPDATE [SHFL_LOS].dbo.LosProcChrg 
				SET LpcChqSts = 'C', LpcChqClrDt = A.RDate, LpcAccEntry = 'Y'
				FROM #InstrClrDet A
				JOIN [SHFL_LOS].dbo.LosProcChrg B ON A.RcptPK = B.LpcDpdFk

				UPDATE [SHFL_LOS].dbo.LosProcChrg 
				SET LpcAccEntry = 'Y'
				FROM #RecptDetails R 
				JOIN #Temp_Ggac_Hdr A ON R.RcptPK = A.LinkRefNum AND R.AccEntryType = 'SanctionAdj'
				JOIN [SHFL_LOS].dbo.LosProcChrg B ON R.LeadPk = B.LpcLedFk 
				JOIN [SHFL_LOS].dbo.GenMas(NOLOCK) M ON B.LpcDocTyp = M.MasPk AND M.MasDelId = 0
				WHERE B.LpcDelId = 0 AND MasCd = 'PCA' AND B.LpcChqSts = 'C' AND LpcAccEntry = 'N'

			END					
			--SELECT * FROM [SHFL_LOS].dbo.LosProcChrg --WHERE LpcLedFk = 5141

			--SELECT 'AccTran_H',* FROM GGAc_AccTran_h  WHERE LinkRefNum IN ( '5333','5334')
			--SELECT 'AccTran_D',B.* FROM GGAc_AccTran_h A JOIN GGAc_AccTran_d B ON A.PK_Id = B.Hdr_FK WHERE A.LinkRefNum IN ('5333','5334')
			--SELECT 'AccInstr_D',B.* FROM GGAc_AccTran_h A JOIN GGAc_AccInstr_d B ON A.PK_Id = B.Hdr_FK WHERE LinkRefNum IN ('5333','5334')
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN			
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()

		INSERT INTO [SHFL_LOS]..LosJobErrors(LjeErrMsg,LjeProc,LjeRowId,LjeCreatedBy,LjeCreatedDt,LjeModifiedBy,LjeModifiedDt,LjeDelId)
		VALUES(@ErrMsg, 'PrcShflReceiptAccEntry', NEWID(), 'Admin', GETDATE(), 'Admin', GETDATE(), 0) 

		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
	END CATCH
END
