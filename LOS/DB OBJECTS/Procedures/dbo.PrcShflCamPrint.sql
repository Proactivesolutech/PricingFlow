-- EXEC PrcShflCamPrint  5022
--$~$
IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcShflCamPrint' AND [type]='P')
	DROP PROC PrcShflCamPrint
GO
CREATE PROCEDURE PrcShflCamPrint
(
	@LeadFk			BIGINT		=	NULL,
	@BTTOPflag		VARCHAR(5)		=	NULL -- 0 - BT , 1- Topup
)
AS
BEGIN
	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT;
	DECLARE @ApplicableIIRFOIR NUMERIC , @WaiverROI INT = 0, @NAMI NUMERIC(27,2), @TopBTEMI NUMERIC(27,2)
	DECLARE @ConstVal TABLE(Estmt NUMERIC(27,2), MktVal NUMERIC(27,2), Rno INT)
	
	CREATE TABLE #ApplDet(FirstCol VARCHAR(MAX), SecondCol VARCHAR(MAX) , LineNumber INT,Actor TINYINT, LapFk BIGINT)
	CREATE TABLE #LoanDet
	(
		PrdNm VARCHAR(100), Location VARCHAR(100), EligCal VARCHAR(100), RiskCat VARCHAR(100), 
		LnAmt VARCHAR(100), ROI VARCHAR(10), Tenure VARCHAR(100), LnTyp VARCHAR(100)
	)	
	CREATE TABLE #TechnicalDet(Terms VARCHAR(100), Value VARCHAR(100))
	CREATE TABLE #ObligationsDet(OblType VARCHAR(100), Appl VARCHAR(100), CoApp VARCHAR(100))
	CREATE TABLE #FinalLnDet(FirstCol VARCHAR(MAX), SecondCol VARCHAR(MAX),LineNumber INT)
	CREATE TABLE #Order(Component VARCHAR(50), Ord INT)
	
	CREATE TABLE #TempCreditTable
	(
		OBL NUMERIC,IIR NUMERIC(27,2),NET_INC NUMERIC,FOIR NUMERIC(27,2),CBL NUMERIC,TENUR NUMERIC,LOAN_AMT NUMERIC,ROI NUMERIC(27,2),
		EMI NUMERIC,SPREAD NUMERIC(27,2),EST_PRP NUMERIC,ACT_PRP NUMERIC,LTV NUMERIC(27,2), ACT_LTV NUMERIC(27,2),LI NUMERIC,GI NUMERIC,ROIType VARCHAR(200),
		SHPLR NUMERIC(27,2),LOAN_LI NUMERIC, LOAN_LI_EMI NUMERIC,LOAN_GI NUMERIC, LOAN_GI_EMI NUMERIC,LOAN_LIGI NUMERIC, LOAN_LIGI_EMI NUMERIC, 
		CMB_MKLTV NUMERIC(27,2), CMB_OBL NUMERIC(27,2),OBL_TOPUP NUMERIC(27,7) 
	)


	DECLARE @ProductCode VARCHAR(20),@Count INT,@GrpCd VARCHAR(50),@ExistLoan NUMERIC(27,2)

	BEGIN TRY
		
		SELECT @ProductCode = PrdCd, @GrpCd = GrpCd FROM LosApp (NOLOCK) 
		JOIN GenPrdMas(NOLOCK) ON PrdPk = AppPrdFk AND PrdDelId = 0
		JOIN GenLvlDefn (NOLOCK) ON PrdGrpFk = GrpPk AND GrpDelid = 0
		WHERE AppLedFk = @LeadFk AND AppDelId = 0 
			
		SET @ExistLoan = 0
		SELECT @ExistLoan= ISNULL(SUM (LelOutstandingAmt),0) FROM LosAppExistLn(NOLOCK) WHERE LelLedFk = @LeadFk AND LelDelId = 0
		--------------------------------- START - PERSONAL INFO SELECT ---------------------------------------------
	
		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	CASE	WHEN LapActor = 0 THEN 'Applicant Name '
						WHEN LapActor = 1 THEN 'CoApplicant Name '
						WHEN LapActor = 2 THEN 'Guarantor Name ' 
				END + ' : ' + '<strong>' + 
				CASE	WHEN LapTitle = 0 THEN 'Mr. '
						WHEN LapTitle = 1 THEN 'Ms. '
						WHEN LapTitle = 2 THEN 'Mrs. '
						ELSE	'' 
				END + RTRIM(ISNULL(LapFstNm,'')) +' ' + RTRIM(ISNULL(LapMdNm,'')) + ' ' + RTRIM(ISNULL(LapLstNm,'')) + '</strong>', 'Done By : Admin ' 
				,1,LapActor,LapPk 
		FROM	LosAppProfile(NOLOCK) 
		WHERE	LapLedFk =  @LeadFk  AND LapDelId = 0
		
		SELECT @Count = (COUNT(*) - 1) FROM #ApplDet
		
		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	'Name of ' + 
				CASE	WHEN  A.LapEmpTyp = 0 THEN ' Employer : ' + RTRIM(ISNULL(B.LaeNm,''))
						WHEN  A.LapEmpTyp = 1 THEN ' Business : ' + RTRIM(ISNULL(C.LabNm,''))
						ELSE	'Business : - '
				END, 'Date : ' + CONVERT(VARCHAR,GETDATE(),103),2,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0
		
		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	'Nature of ' + 
				CASE	WHEN  A.LapEmpTyp = '0' THEN ' Employment : ' + RTRIM(ISNULL(B.LaeNat,'-'))
						WHEN  A.LapEmpTyp = '1' THEN ' Business : ' + 
							CASE WHEN C.LabNat = '0' THEN 'Trader' 
								WHEN C.LabNat = '1' THEN 'Manufacturer' 
								WHEN C.LabNat = '2' THEN 'Services' 
								WHEN C.LabNat = '3' THEN 'Contractor' 
								WHEN C.LabNat = '4' THEN 'Transporter' 
								WHEN C.LabNat = '5' THEN 'Real Estate' 
								WHEN C.LabNat = '6' THEN 'Shop Keeper' 
								WHEN C.LabNat = '7' THEN 'Consultancy' 
								ELSE 'Others'
							END
						ELSE	'Business : - '
				END, 
				CASE	WHEN  A.LapEmpTyp = 0 THEN 'No Years in Employment : ' + ISNULL(RTRIM(CONVERT(INT,ISNULL(B.LaeExp,0)/12) ) +'.' + RTRIM(ISNULL(B.LaeExp,0) % 12) , 0)
						WHEN  A.LapEmpTyp = 1 THEN 'No of years in Business : ' + ISNULL(RTRIM(C.LabCurBusiPrd),'-')	
						ELSE	' - '
				END
				,3,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0

		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	CASE	WHEN  A.LapEmpTyp = 0 THEN 'Total No of years in Employment : ' + ISNULL(RTRIM(CONVERT(INT,ISNULL(B.LaeTotExp,0)/12) ) +'.' + RTRIM(ISNULL(B.LaeTotExp,0) % 12) , 0)
						WHEN  A.LapEmpTyp = 1 THEN 'Total No of years in Business : ' + ISNULL(RTRIM(C.LabBusiPrd),'-')	
						ELSE	' - '
				END
				,'',3,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0

		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	'Type of Organization : ' + 
				--CASE	WHEN  A.LapEmpTyp = 0 THEN 
				--			CASE	WHEN B.LaeTyp = 0 THEN 'Public' 
				--					WHEN B.LaeTyp = 1 THEN 'Private' 
				--					WHEN B.LaeTyp = 2 THEN 'State' 
				--					WHEN B.LaeTyp = 3 THEN 'Central' 
				--					WHEN B.LaeTyp = 4 THEN 'Semi Government' 
				--					ELSE '-'
				--			END									
				--		WHEN  LapEmpTyp = 1 THEN 
				--			CASE	WHEN C.LabOrgTyp = 0 THEN 'Public' 
				--					WHEN C.LabOrgTyp = 1 THEN 'Private' 
				--					WHEN C.LabOrgTyp = 2 THEN 'State' 
				--					WHEN C.LabOrgTyp = 3 THEN 'Central' 
				--					WHEN C.LabOrgTyp = 4 THEN 'Semi Government' 
				--					ELSE '-'
				--			END					
				--		ELSE	'-'
				--END, 
				CASE	WHEN  A.LapEmpTyp = 0 THEN 'Salaried' 
						WHEN  A.LapEmpTyp = 1 THEN 'Self Employed' 
						WHEN  A.LapEmpTyp = 2 THEN 'House Wife' 
						WHEN  A.LapEmpTyp = 3 THEN 'Pensioner' 
						WHEN  A.LapEmpTyp = 0 THEN 'Student'
						ELSE	'-'
				END,
				'Others: ',4,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0

		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	CASE	WHEN  A.LapEmpTyp = 0 THEN 'Designation : ' + RTRIM(ISNULL(B.LaeDesig,'-'))
						WHEN  A.LapEmpTyp = 1 THEN 'Ownership type : ' + 
							CASE	WHEN C.LabOwnShip = 0 THEN 'Partnership'
									WHEN C.LabOwnShip = 1 THEN 'Sole Proprietorship'
									WHEN C.LabOwnShip = 2 THEN 'HUF'
									WHEN C.LabOwnShip = 3 THEN 'Company'
									ELSE '-'
							END
						ELSE '-'
				END,
				'DOB : ' + RTRIM(ISNULL(CONVERT (VARCHAR,A.LapDOB,103),'-')) + '  AGE : ' + 
				RTRIM(CASE	WHEN DATEADD(YEAR, DATEDIFF (YEAR, A.LapDOB, GETDATE()), A.LapDOB) > GETDATE()
						THEN DATEDIFF(YEAR, A.LapDOB, GETDATE()) - 1
						ELSE DATEDIFF(YEAR, A.LapDOB, GETDATE()) 
				END),5,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0

		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	'Bureau Report : ' , 'CIBIL SCORE : ' + ISNULL(RTRIM(LapCibil),'-1') , 6,LapActor,LapPk 
		FROM	LosAppProfile(NOLOCK)
		WHERE	LapLedFk =  @LeadFk  AND LapDelId = 0
					
		--Vishali	
		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	TOP (@Count) '<br>','<br>',7,LapActor,LapPk
		FROM	LosAppProfile(NOLOCK)
		WHERE	LapLedFk =  @LeadFk  AND LapDelId = 0


		
		------------------------------- END - PERSONAL INFO SELECT ---------------------------------------------
	
	
		------------------------------- START - LOAN INFO SELECT ---------------------------------------------
		INSERT INTO #LoanDet(PrdNm,Location,EligCal,RiskCat,LnAmt,ROI,Tenure,LnTyp)	
		SELECT	CASE	WHEN @ProductCode = 'HLBTTopup' THEN 
							CASE	WHEN @BTTOPflag = '0' THEN 'HL - BT Loan' 
									WHEN @BTTOPflag = '1' THEN 'HL - Topup Loan' 
							END
						WHEN @ProductCode = 'LAPBTTopup' THEN 					
							CASE	WHEN @BTTOPflag = '0' THEN 'LAP - BT Loan' 
									WHEN @BTTOPflag = '1' THEN 'LAP - Topup Loan' 
							END
				ELSE B.PrdNm				
				END,
				C.GeoNm,
				CASE	WHEN A.AppSalPrf = 0 THEN 'Income Proof Scheme' 
						WHEN A.AppSalPrf = 1 THEN 'Non Income Proof Scheme' 
						ELSE '-'
				END,
				CASE	WHEN ISNULL(E.LrcTxtVal,'') = 'V' THEN 'Very High Risk'
						WHEN ISNULL(E.LrcTxtVal,'') = 'H' THEN 'High Risk'
						WHEN ISNULL(E.LrcTxtVal,'') = 'M' THEN 'Moderate Risk'
						WHEN ISNULL(E.LrcTxtVal,'') = 'L' THEN 'Low Risk'
						WHEN ISNULL(E.LrcTxtVal,'') = 'N' THEN 'Very Low Risk'
						ELSE '-'
				END, '-','-','-', 
				'Loan Calculation' + CASE	WHEN A.AppSalTyp = 0 THEN ' for Salaried' 
											WHEN A.AppSalTyp = 1 THEN ' for SelfEmployed'
				ELSE ''	END
				/*CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(L.LedLnAmt,0)),1),ISNULL(L.LedROI,'-'),ISNULL(L.LedTenure,'-')*/
		FROM	LosApp (NOLOCK) A
		JOIN	LosLead (NOLOCK) L ON L.LedPk = A.AppLedFk AND L.LedDelId = 0
		LEFT OUTER JOIN GenPrdMas B (NOLOCK) ON B.PrdPk =  A.AppPrdFk AND B.PrdDelId = 0 		
		LEFT OUTER JOIN	GenGeoMas C (NOLOCK) ON C.GeoPk = A.AppBGeoFK AND C.GeoDelId = 0
		LEFT OUTER JOIN	GenLvlDefn D (NOLOCK) ON D.GrpPk = B.PrdGrpFk AND D.GrpDelId = 0
		LEFT OUTER JOIN LosRiskCalc E (NOLOCK) ON E.LrcLedFk = L.LedPk AND E.LrcDelId = 0 AND E.LrcParameter = 'R'
		WHERE	A.AppLedFk = @LeadFk AND A.AppDelID = 0 


		------------------------------- END - LOAN INFO SELECT ---------------------------------------------

		------------------------------- START - INCOME INFO SELECT ---------------------------------------------		
		
		CREATE TABLE #TempIncomList(PKID INT IDENTITY(1,1),component VARCHAR(100),periodNm VARCHAR(100),amount NUMERIC,sumAmount NUMERIC,
						AppFk BIGINT,LapFk BIGINT,Usrname VARCHAR(200),IncomeType CHAR(5),HeadPk BIGINT,comppk BIGINT,
						CompType INT,Actor INT,incomeName VARCHAR(200),seqNo INT)
	
		INSERT INTO #TempIncomList(component,periodNm,amount,sumAmount,AppFk,LapFk,Usrname,IncomeType,HeadPk,comppk,CompType,Actor,incomeName,seqNo)
		SELECT	 CASE	WHEN A.LioType = 'Bk' THEN 
								CASE 
									WHEN H.LcmIsTot = 1 THEN H.LcmNm
									ELSE 'On ' + H.LcmNm +'th'
								END
						ELSE H.LcmNm 
				END,
				ISNULL(CASE 
					WHEN A.LioType = 'S' THEN C.LsiMon
					WHEN A.LioType = 'B' THEN D.LbiYr
					WHEN A.LioType = 'C' THEN E.LciYr
					WHEN A.LioType = 'Bk' THEN F.LbbMon
					ELSE '-'
				END,'-'),
				ISNULL(CASE 
					WHEN A.LioType = 'S' THEN C.LsiVal
					WHEN A.LioType = 'B' THEN D.LbiVal
					WHEN A.LioType = 'C' THEN E.LciVal
					WHEN A.LioType = 'Bk' THEN F.LbbVal
					ELSE 0
				END,0) ,A.LioSumAmt ,
				A.LioAppFk ,A.LioLapFk ,ISNULL(B.LapPrefNm,'-') ,A.LioType ,A.LioPk , H.LcmPk,H.LcmTyp,B.LapActor,A.LioName,H.LcmSeq
		FROM	LosAppIncObl (NOLOCK) A
		JOIN	LosAppProfile(NOLOCK)	B ON B.LapPk = A.LioLapFk AND B.LapDelId = 0
		LEFT OUTER JOIN LosAppSalInc (NOLOCK) C ON C.LsiLioFk = A.LioPk AND C.LsiDelId = 0 AND C.LsiIncExl = 0
		LEFT OUTER JOIN LosAppBusiInc (NOLOCK) D ON D.LbiLioFk = A.LioPk AND D.LbiDelId = 0 AND D.LbiIncExl = 0
		LEFT OUTER JOIN LosAppCshInc (NOLOCK) E ON  E.LciLioFk = A.LioPk AND E.LciDelId = 0 AND E.LciIncExl = 0
		LEFT OUTER JOIN LosAppBnkBal (NOLOCK) F ON F.LbbLioFk = A.LioPk AND F.LbbDelId = 0  
		JOIN	LosComp(NOLOCK) H ON H.LcmPk = C.LsiLcmFk OR H.LcmPk = C.LsiLcmFk OR H.LcmPk = D.LbiLcmFk 
				OR H.LcmPk = E.LciLcmFk OR H.LcmPk = F.LbbLcmFk AND H.LcmDelId = 0
		WHERE	 A.LioLedFk = @LeadFk AND A.LioType NOT IN ('OB','OT')
		ORDER BY B.LapPk		
		

		INSERT INTO #TempIncomList(component,periodNm,amount,sumAmount,AppFk,LapFk,Usrname,IncomeType,HeadPk,comppk,CompType,Actor,incomeName,seqNo)
		SELECT ISNULL(NULLIF(A.LoiDesc,''),'others'),
				CASE	WHEN A.LoiPeriod = 0 THEN 'Yearly'
						WHEN A.LoiPeriod = 1 THEN 'Monthly'
						ELSE ''
				END
				,A.LoiAmt,C.LioSumAmt,B.LapAppFk,B.LapPk,ISNULL(B.LapPrefNm,'-'),C.LioType,C.LioPk,NULL,NULL,B.LapActor,C.LioName,99
		FROM	LosAppOthInc (NOLOCK)  A
		JOIN	LosAppProfile (NOLOCK) B ON B.LapLedFk = A.LoiLedFk AND B.LapPk = A.LoiLapFk
		JOIN	LosAppIncObl (NOLOCK) C ON C.LioLapFk = B.LapPk AND C.LioDelId = 0 AND C.LioType = 'OT'
		WHERE	A.LoiLedFk = @LeadFk AND A.LoiDelId = 0		

		UPDATE #TempIncomList SET periodNm = 'Average' WHERE periodNm = '-1'


		CREATE TABLE #IncomeDataSet(Column1 VARCHAR(MAX),Column2 VARCHAR(MAX),Column3 VARCHAR(MAX),Column4 VARCHAR(MAX),Column5 VARCHAR(MAX),
									Column6 VARCHAR(MAX),Column7 VARCHAR(MAX),Column8 VARCHAR(MAX),Column9 VARCHAR(MAX),Column10 VARCHAR(MAX),idColumn INT IDENTITY(1,1))

		DECLARE @HeadPk VARCHAR(MAX), @IncomeTable CHAR(5),@LapFk BIGINT,@Usrname VARCHAR(200),@Actor INT,@incomeName VARCHAR(200);
		DECLARE @Inc_ExecQuery  NVARCHAR(MAX), @Inc_ColumnList  VARCHAR(MAX) , @Inc_NulltoZeroCol NVARCHAR(MAX),
					@ColTitle VARCHAR(MAX);

		DECLARE @INSERT_COL NVARCHAR(MAX) , @PrevActor INT = 9;

		CREATE TABLE #PeriodTable (Period VARCHAR(200),	ID INT IDENTITY(1,1),columnNm AS 'Column'+convert(varchar,ID) PERSISTED PRIMARY KEY)

		CREATE TABLE #TEMPPeriodTable (PKID INT IDENTITY(1,1) , LapFk BIGINT,Usrname VARCHAR(200),IncomeType CHAR(5),HeadPk VARCHAR(MAX),
						Actor INT,incomeName VARCHAR(200));
		
		
		INSERT INTO #TEMPPeriodTable(HeadPk,IncomeType,LapFk,Usrname,Actor,incomeName)
		SELECT DISTINCT HeadPk,IncomeType,LapFk,Usrname,Actor,incomeName FROM #TempIncomList

		DECLARE @LoopNumber INT = 0 ,@LoopRowCount INT = 0
		
		SELECT @LoopRowCount = COUNT('X') FROM #TEMPPeriodTable
		
		CREATE TABLE #TmpPrdTbl(periodNm VARCHAR(200),pkid INT)

		WHILE  @LoopNumber < @LoopRowCount
		BEGIN     
			TRUNCATE TABLE #PeriodTable
			TRUNCATE TABLE #TmpPrdTbl

			SELECT @HeadPk = HeadPk ,@IncomeTable =IncomeType ,@LapFk = LapFk ,@Usrname = Usrname ,@Actor = Actor ,@incomeName = incomeName
			FROM #TEMPPeriodTable WHERE PKID = (@LoopNumber+1)
			

			INSERT INTO #TmpPrdTbl
			SELECT DISTINCT periodNm, MIN(PKID) 
			FROM #TempIncomList 
			WHERE HeadPk = @HeadPk 
			GROUP BY periodNm 
			ORDER BY MIN(PKID) , periodNm
			
			INSERT INTO #PeriodTable
			SELECT periodNm FROM #TmpPrdTbl ORDER BY pkid			
			
			SELECT @Inc_ColumnList = ''
	
			SET @Inc_ColumnList = STUFF(
			(
				SELECT N',' + QUOTENAME(y) AS [text()]
				FROM (
						--SELECT DISTINCT periodNm AS y FROM #TempIncomList WHERE HeadPk = @HeadPk
						SELECT Period AS y FROM #PeriodTable
						) AS Y				
				FOR XML PATH('')
			),1, 1, N'');


			SELECT @Inc_NulltoZeroCol = ''

			SELECT @Inc_NulltoZeroCol = SUBSTRING((SELECT ',ISNULL(['+periodNm+'],0) AS ['+periodNm+']' 
			--FROM (SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average' )TAB  
			FROM (SELECT Period AS periodNm FROM #PeriodTable WHERE Period <> 'Average'	)TAB  
			FOR XML PATH('')),2,8000) 			

			IF @IncomeTable <> 'OT'
				SELECT @Inc_NulltoZeroCol = 'Average,'+@Inc_NulltoZeroCol;

			SELECT @ColTitle = SUBSTRING((SELECT ',''' + periodNm + '~HeaderRow'''
			FROM (SELECT Period AS periodNm FROM #PeriodTable WHERE Period <> 'Average')TAB  
			FOR XML PATH('')),2,8000) 		


		--INSERT INTO #PeriodTable
		--SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average'							

			INSERT INTO #PeriodTable
			VALUES ('component')
	
			SELECT @INSERT_COL = ''

			SELECT @INSERT_COL = SUBSTRING((SELECT ',' + columnNm  
			FROM (SELECT DISTINCT columnNm FROM #PeriodTable)COL_TAB  
			FOR XML PATH('')),2,8000) 	


			SELECT @INSERT_COL = '(' + @INSERT_COL + ')'

			IF @PrevActor <> @Actor
			BEGIN
				INSERT INTO  #IncomeDataSet(Column1)
				SELECT CASE 
						WHEN @Actor = 0 THEN 'Applicant'
						WHEN @Actor = 1 THEN 'CoApplicant'
						WHEN @Actor = 2 THEN 'Guarantor'
						ELSE '-' 
					END + '~Title'
			END

			IF @IncomeTable <> 'OT'
			BEGIN
				SELECT @Inc_ExecQuery = N'		
				INSERT INTO  #IncomeDataSet(Column1)
				SELECT '' ~Title''
				INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
				SELECT '''+ @incomeName + ' - '+ @Usrname + N'~HeaderRow'', ''Average~HeaderRow'', ' + @ColTitle + N' ;
	
				INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
				SELECT component,' + @Inc_NulltoZeroCol + N'	
				FROM	
				(		
					SELECT component,
							CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(amount,0)),1)amount,periodNm,IncomeType,HeadPk,comppk,CompType,seqNo
					FROM #TempIncomList WHERE amount > 0 AND HeadPk = ' + RTRIM(@HeadPk) + N'
				) PIVOTTABLE_INC 
				PIVOT(
					MIN(amount) FOR periodNm IN ('+RTRIM(@Inc_ColumnList) + N')
				)
				AS PIVOTTABLE_INC 
				ORDER BY seqNo,comppk,CompType';																		

			END
			ELSE
			BEGIN
				SELECT @Inc_ExecQuery = N'		
				INSERT INTO  #IncomeDataSet(Column1)
				SELECT '' ~Title''
				INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
				SELECT '''+ @incomeName + ' - '+ @Usrname + N'~HeaderRow'',' + @ColTitle + N' ;
	
				INSERT INTO #IncomeDataSet'+ @INSERT_COL + N'
				SELECT component,' + @Inc_NulltoZeroCol + N'	
				FROM	
				(		
					SELECT component,
							CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(amount,0)),1)amount,periodNm,IncomeType,HeadPk,comppk,CompType,seqNo
					FROM #TempIncomList WHERE amount > 0 AND HeadPk = ' + RTRIM(@HeadPk) + N'
				) PIVOTTABLE_INC
				PIVOT(
					MIN(amount) FOR periodNm IN ('+RTRIM(@Inc_ColumnList) + N')
				)
				AS PIVOTTABLE_INC
				ORDER BY seqNo,comppk,CompType';	
			END				
			
			EXEC SP_EXECUTESQL @Inc_ExecQuery			
			
			SET @PrevActor = @Actor
			SET @LoopNumber = @LoopNumber + 1
		END   		

		------------------------------- END - INCOME INFO SELECT ---------------------------------------------

		------------------------------- START - TECH VALUATION SELECT ---------------------------------------------

		INSERT INTO #TechnicalDet(Terms,Value )
		VALUES('Technical~HeaderRow','Amount~HeaderRow')
	

		IF EXISTS(SELECT 'X' FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0)
		BEGIN
			INSERT INTO #TechnicalDet(Terms,Value )
			SELECT 'Valuation ' + RTRIM(ROW_NUMBER() OVER (ORDER BY LptPk)), CONVERT(VARCHAR, CONVERT(MONEY, LptMktVal),1)
			FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0	
			
			--IF @ProductCode = 'HLImp' OR @ProductCode = 'HLExt'
			--BEGIN
			--	INSERT INTO #TechnicalDet(Terms,Value )
			--	SELECT 'Existing Construction Value ' + RTRIM(ROW_NUMBER() OVER (ORDER BY LptPk)), CONVERT(VARCHAR, CONVERT(MONEY, LptExsConsVal),1)
			--	FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0	

			--	INSERT INTO #TechnicalDet(Terms,Value )
			--	SELECT 'Proposed Construction Value ' + RTRIM(ROW_NUMBER() OVER (ORDER BY LptPk)), CONVERT(VARCHAR, CONVERT(MONEY, LptPrpConsVal),1)
			--	FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0
			--END
		END
		ELSE
		BEGIN 
			INSERT INTO #TechnicalDet(Terms,Value )
			SELECT 'Valuation : ' ,' Valuation not done '
		END
	
		INSERT INTO #TechnicalDet(Terms,Value )
		SELECT 'Lower Valuation' , CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(Min(LptMktVal),0)),1)
		FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0
		
	
		------------------------------- END - TECH VALUATION SELECT ---------------------------------------------

		------------------------------- START - CREDIT DETAILS SELECT ---------------------------------------------
		--SELECT @ProductCode ,@BTTOPflag		
			SELECT @WaiverROI = ISNULL(LdvDevVal,0) FROM LosDeviation (NOLOCK) 
			JOIN LosLnAttributes (NOLOCK) ON LnaPk = LdvLnaFk AND LnaDelId = 0
			WHERE  LdvLedFk = @LeadFk AND LdvDelId = 0 AND LnaCd IN ('ROI','BT_ROI')

			INSERT INTO #TempCreditTable(OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
								ACT_LTV,LI,GI,ROIType,SHPLR,CMB_MKLTV,CMB_OBL,OBL_TOPUP)
			SELECT OBL,ISNULL(IIR,0),NET_INC,ISNULL(FOIR,0),CBL,
					CASE	WHEN @BTTOPflag = '0' THEN ISNULL(TENUR,0)
							WHEN @BTTOPflag = '1' THEN ISNULL(TENUR_TOP,0)
							ELSE TENUR
					END,
					CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(LOAN_AMT,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_AMT,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(LOAN_AMT,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_AMT,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_AMT,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_AMT,0)
								END
							ELSE LOAN_AMT
					END, 
					(CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(ROI,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_ROI,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(ROI,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_ROI,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_ROI,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_ROI,0)
								END
							ELSE ROI
					END) ,
					CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(EMI,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_EMI,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(EMI,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_EMI,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_EMI,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_EMI,0)
								END
							ELSE EMI
					END,
					CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(ROI -15 ,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_ROI - 15,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(ROI -15 ,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_ROI - 15,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_ROI - 15 ,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_ROI - 15,0)
								END
							ELSE ROI -15
					END,
					EST_PRP , ACT_PRP,										
					CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(LTV,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_LTV_M,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LTV_M,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LTV_M,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_LTV_M,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_LTV_M,0)
								END
							WHEN @ProductCode IN('HLImp','HLExt') AND @ExistLoan > 0 THEN TOPUP_LTV_M
							ELSE LTV
					END,
					CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(ACT_LTV,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_LTV_A,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LTV_A,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LTV_A,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_LTV_A,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_LTV_A,0)
								END
								WHEN @ProductCode IN('HLImp','HLExt') AND @ExistLoan > 0 THEN TOPUP_LTV_A
							ELSE ACT_LTV
					END,
					CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(LI ,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_LI,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(LI ,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_LI,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_LI ,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_LI,0)
								END
							ELSE LI
					END,
					CASE	WHEN @ProductCode IN ('HLBT','LAPBT') THEN ISNULL(GI ,0)
							WHEN Prdcd IN('HLBT','LAPBT') THEN ISNULL(BT_GI,0)
							WHEN @ProductCode IN ('HLTopup','LAPTopup') THEN ISNULL(GI ,0)
							WHEN Prdcd IN('HLTopup','LAPTopup') THEN ISNULL(TOPUP_GI,0)
							WHEN @ProductCode IN('HLBTTopup','LAPBTTopup') THEN 
								CASE	WHEN @BTTOPflag = '0' THEN ISNULL(BT_GI ,0)
										WHEN @BTTOPflag = '1' THEN ISNULL(TOPUP_GI,0)
								END
							ELSE GI
					END ,'Floating Interest Rate' 'ROIType' , 15 'SHPLR' , LTV, ISNULL(OBL,0) + ISNULL(BT_EMI,0), ISNULL(BT_EMI,0)
			FROM 
			(
				SELECT	LnaCd 'AttrCode',LcaVal 'Value',Prdcd
				FROM	LosCreditAttr (NOLOCK) A
				JOIN	LosLnAttributes (NOLOCK) B ON B.LnaPk = A.LcaLnaFk AND B.LnaDelId = 0
				JOIN	LosCredit (NOLOCK) C ON C.LcrPk = A.LcaLcrFk AND C.LcrDelId = 0		
				LEFT OUTER JOIN GenPrdMas (NOLOCK) G ON G.PrdPk = C.LcrPrdFk AND G.PrdDelId = 0
				WHERE	C.LcrLedFk = @LeadFk AND A.LcaDelId = 0 AND C.LcrDocRvsn = (SELECT MAX(T.LcrDocRvsn) FROM LosCredit T (NOLOCK) WHERE T.LcrLedFk = @LeadFk AND T.LcrDelId = 0 )		 
				AND LnaCd IN ('OBL','IIR','NET_INC','FOIR','CBL','TENUR','LOAN_AMT','ROI','EMI','SPREAD','EST_PRP','ACT_PRP','LTV',
							'ACT_LTV','LI','GI','TOPUP_AMT','BT_AMT','BT_ROI','BT_EMI','TOPUP_EMI','BT_LI','TOPUP_LI','BT_GI','TOPUP_GI','TOPUP_ROI','TENUR_TOP','BT_LTV_A',
							'TOPUP_LTV_A','BT_LTV_M','TOPUP_LTV_M')
			)
			PIVOTTABLE
			PIVOT (MAX(Value) FOR AttrCode IN (OBL,IIR,NET_INC,FOIR,CBL,TENUR,LOAN_AMT,ROI,EMI,SPREAD,EST_PRP,ACT_PRP,LTV,
							ACT_LTV,LI,GI,TOPUP_AMT,BT_AMT,BT_ROI,BT_EMI,TOPUP_EMI,BT_LI,TOPUP_LI,BT_GI,TOPUP_GI,TOPUP_ROI,TENUR_TOP,
							BT_LTV_A,TOPUP_LTV_A,BT_LTV_M,TOPUP_LTV_M) )
			AS PIVOTTABLE
			
			SELECT @TopBTEMI = OBL_TOPUP FROM #TempCreditTable
			
			UPDATE L SET LnAmt = CONVERT(VARCHAR,ISNULL(CONVERT(MONEY,ISNULL(C.LOAN_AMT,0)),'-'),1), 
						 ROI = ISNULL(CONVERT(VARCHAR,CONVERT(NUMERIC(27,2),ISNULL(C.ROI,0))),'-'), 
						 Tenure = ISNULL(CONVERT(VARCHAR,ISNULL(C.TENUR,0)),'-')
			FROM #LoanDet L, #TempCreditTable C
			

			INSERT INTO #TechnicalDet(Terms,Value )
			SELECT 'LTV to MV', LTV
			FROM 	#TempCreditTable	
			
			IF ISNULL(@BTTOPflag,0) = 1
				BEGIN
					INSERT INTO #TechnicalDet(Terms,Value)
					SELECT 'Combined LTV', CMB_MKLTV
					FROM 	#TempCreditTable	
				END
			
			INSERT INTO #TechnicalDet(Terms,Value )
			SELECT  'CLIR',RTRIM( ISNULL(LTV,0) +   
									( CASE	WHEN ISNULL(IIR,0) <> 0 THEN IIR WHEN ISNULL(FOIR,0) <> 0 THEN FOIR  END )
								)
			FROM	#TempCreditTable

			IF @ProductCode = 'HLConst'
				BEGIN
					INSERT INTO @ConstVal
					SELECT	ISNULL(LptEstmt,0) 'Estmt', LptMktVal 'MktVal', ROW_NUMBER() OVER(PARTITION BY LptPrpFk ORDER BY LptMktVal) 'Rno'
					FROM	LosPropTechnical(NOLOCK)
					WHERE	LptLedFk = @LeadFk AND LptDelid = 0
					
					IF EXISTS(SELECT 'X' FROM @ConstVal)
						INSERT INTO #TechnicalDet(Terms,Value )
						SELECT  'Estimate Value - Property ' + CONVERT(VARCHAR,ROW_NUMBER() OVER(ORDER BY Rno)),MktVal
						FROM	@ConstVal WHERE Rno = 1
					ELSE
						INSERT INTO #TechnicalDet(Terms,Value )
						SELECT  'Estimate Value', '-'
				END

		--KANI
			--IF @ProductCode = 'HLImp' OR @ProductCode = 'HLExt' AND @ProductCode = 'HLConst'
			--	BEGIN
			--		INSERT INTO @ConstVal
			--		SELECT	ISNULL(LptExsConsVal,0) 'Estmt', LptMktVal 'MktVal', ROW_NUMBER() OVER(PARTITION BY LptPrpFk ORDER BY LptMktVal) 'Rno'
			--		FROM	LosPropTechnical(NOLOCK)
			--		WHERE	LptLedFk = @LeadFk AND LptDelid = 0
					
			--		IF EXISTS(SELECT 'X' FROM @ConstVal)
			--			INSERT INTO #TechnicalDet(Terms,Value )
			--			SELECT  'Estimate Value - Property ' + CONVERT(VARCHAR,ROW_NUMBER() OVER(ORDER BY Rno)),MktVal
			--			FROM	@ConstVal WHERE Rno = 1
			--		ELSE
			--			INSERT INTO #TechnicalDet(Terms,Value )
			--			SELECT  'Estimate Value', '-'
			--	END
			--KANI
				
			IF @GrpCd = 'LAP'
				BEGIN
					SELECT @NAMI = ISNULL(ISNULL(NET_INC,0) - ISNULL(OBL,0),0) FROM #TempCreditTable
					
					SELECT  @ApplicableIIRFOIR = CASE	WHEN @NAMI <= 10000 THEN 40
							WHEN @NAMI > 10000 AND @NAMI <= 15000 THEN 40
							WHEN @NAMI > 15000 AND @NAMI <= 30000 THEN 45
							WHEN @NAMI > 30000 THEN  50 
						END FROM #TempCreditTable
					
					INSERT INTO #Order
						SELECT	'TMC',  1	UNION ALL	SELECT	'OBL', 2	UNION ALL 		SELECT	'AppIR', 3		UNION ALL
						SELECT	'NAMI', 4	UNION ALL	SELECT	'AI', 5		UNION ALL		SELECT	'EPL', 6		UNION ALL	
						SELECT	'TIM', 7	UNION ALL	SELECT	'IRate', 8	UNION ALL		SELECT	'LE', 9			UNION ALL	
						SELECT	'EMI', 10	UNION ALL	SELECT	'RL', 11	UNION ALL		SELECT	'FinalIR', 12	UNION ALL
						SELECT	'OR', 12	UNION ALL	SELECT	'DEV', 13
				END
			ELSE
				BEGIN
					SELECT  @ApplicableIIRFOIR = CASE WHEN NET_INC > 30000 THEN 60 ELSE 50 END FROM #TempCreditTable
					
					INSERT INTO #Order
					SELECT	'TMC',1		UNION ALL		SELECT	'AppIR', 2	UNION ALL			SELECT	'NAMI',  3		UNION ALL
					SELECT	'OBL', 4	UNION ALL		SELECT	'AI', 5		UNION ALL			SELECT	'EPL', 6		UNION ALL
					SELECT	'TIM', 7	UNION ALL		SELECT	'IRate', 8	UNION ALL			SELECT	'LE', 9			UNION ALL		
					SELECT	'EMI', 10	UNION ALL		SELECT	'RL', 11	UNION ALL			SELECT	'FinalIR', 12	UNION ALL
					SELECT	'OR', 12	UNION ALL		SELECT	'DEV', 13
				END
		
		
			INSERT INTO #FinalLnDet
			SELECT	'Total Monthly Income', CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(NET_INC,0)),1),Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'TMC'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'Applicable ' + CASE	WHEN ISNULL(IIR,0) <> 0 THEN 'IIR'
										WHEN ISNULL(FOIR,0) <> 0 THEN 'FOIR'  
									END
						, CAST(@ApplicableIIRFOIR AS VARCHAR) + '%', Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'AppIR'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'NAMI' , CASE	WHEN ISNULL(IIR,0) <> 0	THEN CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(ISNULL(NET_INC,0) - ISNULL(OBL,0),0)),1)
									WHEN ISNULL(FOIR,0) <> 0 THEN CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(NET_INC,0)),1)
							END , Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'NAMI'

			INSERT INTO #FinalLnDet
			SELECT	'Obligation',CASE @BTTOPflag WHEN 1 THEN CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(CMB_OBL,0)),1) ELSE CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(OBL,0)),1) END ,Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'OBL'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'Adjusted Income' , 
					CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(
							CASE	WHEN ISNULL(IIR,0)	<> 0 THEN (ISNULL(NET_INC,0) - ISNULL(OBL,0)) * @ApplicableIIRFOIR / 100 
									WHEN ISNULL(FOIR,0) <> 0 THEN (ISNULL(NET_INC,0) * @ApplicableIIRFOIR / 100 ) - ISNULL(OBL,0)		
							END 
					,0)),1)
					, Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'AI'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'EMI Per Lakh' , 
			CASE	WHEN ISNULL(LOAN_AMT,0) <> 0 THEN CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(ISNULL(EMI * 100000  / LOAN_AMT ,0),0)),1)				
					ELSE '0' 
			END
			, Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'EPL'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'Tenure (In Months)',TENUR, Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'TIM'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'Interest Rate( %)',CAST(ROI AS VARCHAR) + '%',Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'IRate'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'Eligible Loan Amount ', CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(LOAN_AMT ,0),0),1) , Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'LE'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'EMI on Eligible Amount', CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(EMI  ,0),0),1), Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'EMI'

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT 'Loan Amount Requested' ,CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(LedLnAmt ,0),0),1) , Ord
			FROM LosLead (NOLOCK), #Order WHERE LedPk = @LeadFk AND LedDelId = 0 AND Component = 'RL'

/*
			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT	CASE	WHEN ISNULL(IIR,0) <> 0 THEN 'Final IIR'
							WHEN ISNULL(FOIR,0) <> 0 THEN 'Final FOIR'
					END, 
					CASE	WHEN ISNULL(IIR,0) <> 0 THEN CAST(IIR AS VARCHAR) + '%'
							WHEN ISNULL(FOIR,0) <> 0 THEN CAST(FOIR AS VARCHAR) + '%'
					END , Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'FinalIR'
*/

			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT	CASE	WHEN ISNULL(IIR,0) <> 0 THEN 'Final IIR'
							WHEN ISNULL(FOIR,0) <> 0 THEN 'Final FOIR'
					END, 
					CASE	WHEN ISNULL(IIR,0) <> 0 THEN 
								CASE	WHEN ISNULL(@BTTOPflag,'') = '0' THEN CAST(CONVERT(NUMERIC(5,2),EMI / (NET_INC - OBL) * 100) AS VARCHAR) + '%'
										ELSE	CAST(IIR AS VARCHAR) + '%'
								END
							WHEN ISNULL(FOIR,0) <> 0 THEN 
								CASE	WHEN ISNULL(@BTTOPflag,'') = '0' THEN CAST(CONVERT(NUMERIC(5,2),(EMI + OBL)/NET_INC * 100) AS VARCHAR) + '%'
										ELSE CAST(FOIR AS VARCHAR) + '%'
								END
					END , Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'FinalIR'
						
			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT	'Obligation Ratio',CAST(@ApplicableIIRFOIR AS VARCHAR) + ' : ' + 
					CASE	WHEN ISNULL(IIR,0) <> 0 THEN 
								CASE	WHEN ISNULL(@BTTOPflag,'') = '0' THEN CAST(CONVERT(NUMERIC(5,2),EMI / (NET_INC - OBL) * 100) AS VARCHAR)
										ELSE	CAST(IIR AS VARCHAR)
								END
							WHEN ISNULL(FOIR,0) <> 0 THEN 
								CASE	WHEN ISNULL(@BTTOPflag,'') = '0' THEN CAST(CONVERT(NUMERIC(5,2),(EMI + OBL)/NET_INC * 100) AS VARCHAR)
										ELSE CAST(FOIR AS VARCHAR)
								END
					END, Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'OR'
			
			--IF HOST_NAME() = 'SVSCHNDT1002OLR'
			--	SELECT CONVERT(NUMERIC,FOIR) FROM #TempCreditTable
			INSERT INTO #FinalLnDet(FirstCol, SecondCol,LineNumber)
			SELECT	'Deviation', 
					CASE	WHEN ISNULL(IIR,0) <> 0 THEN 
								CASE	WHEN ISNULL(@BTTOPflag,'') = '0' THEN CAST(CONVERT(NUMERIC(5,2),(EMI / (NET_INC - OBL) * 100) - @ApplicableIIRFOIR ) AS VARCHAR) + '%'
										ELSE	CAST(IIR - @ApplicableIIRFOIR AS VARCHAR) + '%'
								END
							WHEN ISNULL(FOIR,0) <> 0 THEN 
								CASE	WHEN ISNULL(@BTTOPflag,'') = '0' THEN CAST(CONVERT(NUMERIC(5,2),((EMI + OBL)/NET_INC * 100) - @ApplicableIIRFOIR) AS VARCHAR) + '%'
										ELSE  CAST(FOIR - @ApplicableIIRFOIR AS VARCHAR) + '%'
								END
					END ,
					--CASE	WHEN ISNULL(IIR,0) <> 0 THEN CAST(IIR - @ApplicableIIRFOIR AS VARCHAR) + '%'
					--		WHEN ISNULL(FOIR,0) <> 0 THEN CAST(FOIR - @ApplicableIIRFOIR AS VARCHAR) + '%'
					--END , 
					Ord
			FROM	#TempCreditTable, #Order WHERE Component = 'DEV'															
		------------------------------- END - CREDIT DETAILS SELECT ---------------------------------------------

		------------------------------- START - OBLIGATIONS SELECT ---------------------------------------------

		INSERT INTO #ObligationsDet(OblType, Appl, CoApp)
		VALUES	('OBLIGATIONS~Title','',''),
				('Existing Loan EMI','Applicant','Co-Applicant')
	
		DECLARE @ExecQuery  NVARCHAR(MAX), @ColumnList  VARCHAR(MAX);
	

		IF EXISTS(SELECT 'X' FROM LosAppIncObl (NOLOCK) WHERE LioLedFk = @LeadFk AND LioDelId = 0 AND LioType = 'OB')		
		BEGIN 

			CREATE TABLE #TempObligation (Obltype VARCHAR(200),OblEmi NUMERIC(27,7),OblAppNm VARCHAR(200))

			INSERT INTO #TempObligation(Obltype,OblEmi,OblAppNm)
			SELECT		CASE	WHEN A.LaoTyp = 0 THEN 'Auto Loan' 
								WHEN A.LaoTyp = 1 THEN 'Car Loan' 
								WHEN A.LaoTyp = 2 THEN 'Twowheeler Loan' 
								WHEN A.LaoTyp = 3 THEN 'Bank' 
								WHEN A.LaoTyp = 4 THEN 'Loan Against Property' 
								WHEN A.LaoTyp = 5 THEN 'Gold Loan' 
								WHEN A.LaoTyp = 6 THEN 'Personal Loan'
								WHEN A.LaoTyp = 7 THEN 'Business Loan' 
								WHEN A.LaoTyp = 8 THEN 'Term Loan'
								WHEN A.LaoTyp = 9 THEN 'Consumer Loan'
								WHEN A.LaoTyp = 10 THEN 'Other Loan'
						ELSE 'Others' END,
						A.LaoEMI,B.LapPrefNm + '-' +
						CASE	WHEN B.LapActor = 0 THEN 'Applicant'
								WHEN B.LapActor = 1 THEN 'CoApplicant'
								WHEN B.LapActor = 2 THEN 'Guarantor'
								 
						END 
			FROM	LosAppObl A (NOLOCK)  
			JOIN	LosAppProfile B (NOLOCK) ON B.LapLedFk = A.LaoLedFk AND B.LapDelId = 0
			JOIN	LosAppIncObl C (NOLOCK) ON C.LioPk = A.LaoLioFk AND C.LioLedFk = A.LaoLedFk AND C.LioDelId = 0
			WHERE	C.LioLedFk  = @LeadFk AND A.LaoDelId = 0 AND A.LoaIsIncl = 0
		
			IF @BTTOPflag = 1 AND ISNULL(@TopBTEMI,0) > 0
				BEGIN
					INSERT	INTO #TempObligation(Obltype,OblEmi,OblAppNm)
					SELECT	CASE @ProductCode  WHEN 'LAPBTTopup' THEN 'LAP Balance Transfer' ELSE 'HL Balance Transfer' END ,@TopBTEMI,'-Applicant'
				END
			
			SET @ColumnList = STUFF(
			(
				SELECT N',' + QUOTENAME(y)
				FROM (
						SELECT DISTINCT OblAppNm AS y FROM #TempObligation
					 ) AS Y
				ORDER BY y
				FOR XML PATH('')
			),1, 1, N'');

			SELECT @ColumnList = @ColumnList + ',[Total]'


			DECLARE @NulltoZeroCols NVARCHAR (MAX)

			SELECT @NullToZeroCols = SUBSTRING((SELECT ',ISNULL(['+OblAppNm+'],0) AS ['+OblAppNm+']' 
			FROM (SELECT DISTINCT OblAppNm FROM #TempObligation)TAB  
			ORDER BY OblAppNm FOR XML PATH('')),2,8000) 

			--INTO [tempdb].[dbo].[tempOBLtable]
			SELECT @ExecQuery = N' SELECT Obltype, ' + @NullToZeroCols + N'
			INTO #tempOBLtable
			FROM	
			(		
				SELECT ISNULL(CAST(Obltype AS VARCHAR(30)),''Total'')Obltype,
						CONVERT(VARCHAR, CONVERT(MONEY, SUM(OblEmi)), 1)OblEmi,
						ISNULL(OblAppNm,''Total'')OblAppNm
				FROM #TempObligation		
				GROUP BY Obltype,OblAppNm
				WITH CUBE
			) PIVOTTABLE 		
			PIVOT(
				MIN(OblEmi) FOR OblAppNm IN ('+RTRIM(@ColumnList) + N')
			)
			AS PIVOTTABLE 
			ORDER BY CASE WHEN (Obltype=''Total'') THEN 1 ELSE 0 END,Obltype; 
			SELECT * FROM #tempOBLtable ORDER BY CASE WHEN (Obltype=''Total'') THEN 1 ELSE 0 END,Obltype';				
							 					
		END

		------------------------------- END - OBLIGATIONS SELECT ---------------------------------------------
		
		-- PERSONAL INFO SELECT 
		SELECT	FirstCol , SecondCol 
		FROM	#ApplDet 
		ORDER BY Actor,LapFk,LineNumber			
		-- LAON DETAILS SELECT 
		SELECT * FROM #LoanDet
		--INCOME DETAILS		
		
		SELECT	ISNULL(Column1,'$~$') 'col1',ISNULL(Column2,'$~$') 'col2',ISNULL(Column3,'$~$') 'col3',ISNULL(Column4,'$~$') 'col4',ISNULL(Column5,'$~$') 'col5',
				ISNULL(Column6,'$~$') 'col6',ISNULL(Column7,'$~$') 'col7',ISNULL(Column8,'$~$') 'col8',ISNULL(Column9,'$~$') 'col9',ISNULL(Column10,'$~$')	'col10' 
		FROM #IncomeDataSet		
		ORDER BY idColumn

		-- TECH VALUATIONS
		SELECT * FROM #TechnicalDet	
		-- OBLIGATION SELECT

		--SELECT * FROM [tempdb].[dbo].[tempOBLtable]
		--ORDER BY CASE WHEN (Obltype='Total') THEN 1 ELSE 0 END,Obltype

		IF ISNULL(@ExecQuery,'') = '' OR NOT EXISTS(SELECT 'X' FROM LosAppIncObl (NOLOCK) WHERE LioLedFk = @LeadFk AND LioDelId = 0 AND LioType = 'OB') 
		BEGIN 			
			CREATE TABLE  #tempOBLtable(
			samplecol VARCHAR(100),Obltype VARCHAR(200))

			SELECT * FROM #tempOBLtable
			DROP TABLE #tempOBLtable
		END	
		ELSE
			EXEC SP_EXECUTESQL @ExecQuery						

		--DROP TABLE [tempdb].[dbo].[tempOBLtable]
		-- FINAL LOAN DETAILS
		SELECT	FirstCol , SecondCol  
		FROM	#FinalLnDet ORDER BY LineNumber
	END TRY
	BEGIN CATCH
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()				
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 				
	END CATCH
END

