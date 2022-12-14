USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcShflCamPrint]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcShflCamPrint]
(
	@LeadFk BIGINT
)
AS
BEGIN
	CREATE TABLE #ApplDet(FirstCol VARCHAR(MAX), SecondCol VARCHAR(MAX) , LineNumber INT,Actor TINYINT, LapFk BIGINT)
	CREATE TABLE #LoanDet(PrdNm VARCHAR(100), Location VARCHAR(100), EligCal VARCHAR(100), RiskCat VARCHAR(100), LnAmt VARCHAR(100), ROI VARCHAR(10), Tenure VARCHAR(100))	
	CREATE TABLE #TechnicalDet(Terms VARCHAR(100), Value VARCHAR(100))
	CREATE TABLE #ObligationsDet(OblType VARCHAR(100), Appl VARCHAR(100), CoApp VARCHAR(100))
	CREATE TABLE #FinalLnDet(FirstCol VARCHAR(MAX), SecondCol VARCHAR(MAX),LineNumber INT)

	BEGIN TRY
		--------------------------------- START - PERSONAL INFO SELECT ---------------------------------------------

		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	CASE	WHEN LapActor = 0 THEN 'Applicant Name '
						WHEN LapActor = 1 THEN 'CoApplicant Name '
						WHEN LapActor = 2 THEN 'Guarantor Name ' 
				END + ' : ' + 
				CASE	WHEN LapTitle = 0 THEN 'Mr. '
						WHEN LapTitle = 1 THEN 'Ms. '
						WHEN LapTitle = 2 THEN 'Mrs. '
						ELSE	'-' 
				END + ISNULL(LapFstNm,'-') +' ' + ISNULL(LapMdNm,'-') + ' ' + ISNULL(LapLstNm,'-'), 'Done By : Admin ' 
				,1,LapActor,LapPk 
		FROM	LosAppProfile(NOLOCK) 
		WHERE	LapLedFk =  @LeadFk  AND LapDelId = 0

		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	'Name of ' + 
				CASE	WHEN  A.LapEmpTyp = 0 THEN ' Employer : ' + ISNULL(B.LaeNm,'-')
						WHEN  A.LapEmpTyp = 1 THEN ' Business : ' + ISNULL(C.LabNm,'-') 
						ELSE	'Business : - '
				END, 'Date : ' + CONVERT(VARCHAR,GETDATE(),103),2,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0


		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	'Nature of ' + 
				CASE	WHEN  A.LapEmpTyp = 0 THEN ' Employment : ' + ISNULL(B.LaeNat,'-')
						WHEN  A.LapEmpTyp = 1 THEN ' Business : ' + 
							CASE WHEN C.LabNat = 0 THEN 'Trader' 
								WHEN C.LabNat = 1 THEN 'Manufacturer' 
								WHEN C.LabNat = 2 THEN 'Services' 
								WHEN C.LabNat = 3 THEN 'Contractor' 
								WHEN C.LabNat = 4 THEN 'Transporter' 
								WHEN C.LabNat = 5 THEN 'Real Estate' 
								WHEN C.LabNat = 6 THEN 'Shop Keeper' 
								WHEN C.LabNat = 7 THEN 'Consultancy' 
								ELSE 'Others'
							END
						ELSE	'Business : - '
				END, 
				CASE	WHEN  A.LapEmpTyp = 0 THEN 'No of Months in Employment : ' + ISNULL(RTRIM(B.LaeExp),'-')
						WHEN  A.LapEmpTyp = 1 THEN 'No of years in Business : ' + ISNULL(RTRIM(C.LabCurBusiPrd),'-')	
						ELSE	' - '
				END
				,3,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0


		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	CASE	WHEN  A.LapEmpTyp = 0 THEN 'Total No of Months in Employment : ' + ISNULL(RTRIM(B.LaeTotExp),'-')
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
				CASE	WHEN  A.LapEmpTyp = 0 THEN 
							CASE	WHEN B.LaeTyp = 0 THEN 'Public' 
									WHEN B.LaeTyp = 1 THEN 'Private' 
									WHEN B.LaeTyp = 2 THEN 'State' 
									WHEN B.LaeTyp = 3 THEN 'Central' 
									WHEN B.LaeTyp = 4 THEN 'Semi Government' 
									ELSE '-'
							END									
						WHEN  LapEmpTyp = 1 THEN 
							CASE	WHEN C.LabOrgTyp = 0 THEN 'Public' 
									WHEN C.LabOrgTyp = 1 THEN 'Private' 
									WHEN C.LabOrgTyp = 2 THEN 'State' 
									WHEN C.LabOrgTyp = 3 THEN 'Central' 
									WHEN C.LabOrgTyp = 4 THEN 'Semi Government' 
									ELSE '-'
							END					
						ELSE	'-'
				END, 
				'Others: ',4,A.LapActor,A.LapPk 
		FROM	LosAppProfile(NOLOCK) A
		LEFT OUTER JOIN	LosAppOffProfile B (NOLOCK) ON B.LaeLapFk = A.LapPk AND B.LaeDelId = 0
		LEFT OUTER JOIN	LosAppBusiProfile C (NOLOCK) ON C.LabLapFk = A.LapPk AND C.LabDelId = 0
		WHERE	A.LapLedFk =  @LeadFk  AND A.LapDelId = 0
	
		INSERT INTO #ApplDet(FirstCol,SecondCol,LineNumber,Actor,LapFk)
		SELECT	CASE	WHEN  A.LapEmpTyp = 0 THEN 'Designation : ' + ISNULL(B.LaeDesig,'-')
						WHEN  A.LapEmpTyp = 1 THEN 'Ownership type : ' + 
							CASE	WHEN C.LabOwnShip = 0 THEN 'Partnership'
									WHEN C.LabOwnShip = 1 THEN 'Sole Proprietorship'
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
		SELECT	'Bureau Report : ' , 'CIBIL SCORE : ' + RTRIM(ISNULL(LapCibil,'-1')) , 6,LapActor,LapPk 
		FROM	LosAppProfile(NOLOCK)
		WHERE	LapLedFk =  @LeadFk  AND LapDelId = 0


		------------------------------- END - PERSONAL INFO SELECT ---------------------------------------------
	
	
		------------------------------- START - LOAN INFO SELECT ---------------------------------------------


		INSERT INTO #LoanDet(PrdNm,Location,EligCal,RiskCat,LnAmt,ROI,Tenure)	
		SELECT	B.PrdNm,C.GeoNm,
				CASE	WHEN A.AppSalPrf = 0 THEN 'Income Proof Scheme' 
						WHEN A.AppSalPrf = 1 THEN 'Non Income Proof Scheme' 
						ELSE '-'
				END,'-' , CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(L.LedLnAmt,0)),1),ISNULL(L.LedROI,'-'),ISNULL(L.LedTenure,'-')
		FROM	LosApp (NOLOCK) A
		JOIN	LosLead (NOLOCK) L ON L.LedPk = A.AppLedFk AND L.LedDelId = 0
		LEFT OUTER JOIN GenPrdMas B (NOLOCK) ON B.PrdPk =  A.AppPrdFk AND B.PrdDelId = 0 
		LEFT OUTER JOIN	GenGeoMas C (NOLOCK) ON C.GeoPk = A.AppBGeoFK AND C.GeoDelId = 0
		WHERE	A.AppLedFk = @LeadFk AND A.AppDelID = 0

		------------------------------- END - LOAN INFO SELECT ---------------------------------------------

		------------------------------- START - INCOME INFO SELECT ---------------------------------------------
		
		
		CREATE TABLE #TempIncomList(component VARCHAR(100),periodNm VARCHAR(100),amount NUMERIC,sumAmount NUMERIC,
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
		SELECT A.LoiDesc,
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

		DECLARE @HeadPk BIGINT, @IncomeTable CHAR(5),@LapFk BIGINT,@Usrname VARCHAR(200),@Actor INT,@incomeName VARCHAR(200);
		DECLARE @Inc_ExecQuery  NVARCHAR(MAX), @Inc_ColumnList  VARCHAR(MAX) , @Inc_NulltoZeroCol NVARCHAR(MAX),
					@ColTitle VARCHAR(MAX);

		DECLARE @INSERT_COL NVARCHAR(MAX) , @PrevActor INT = 9;
		CREATE TABLE #PeriodTable (Period VARCHAR(200),	ID INT IDENTITY(1,1),columnNm AS 'Column'+convert(varchar,ID) PERSISTED PRIMARY KEY)


		DECLARE IncomeCursor CURSOR FOR  	
			SELECT DISTINCT HeadPk,IncomeType,LapFk,Usrname,Actor,incomeName FROM #TempIncomList
		OPEN IncomeCursor
		FETCH NEXT FROM IncomeCursor INTO @HeadPk,@IncomeTable,@LapFk,@Usrname,@Actor,@incomeName

		WHILE @@FETCH_STATUS = 0   
		BEGIN     
			TRUNCATE TABLE #PeriodTable
	
			SELECT @Inc_ColumnList = ''
	
			SET @Inc_ColumnList = STUFF(
			(
				SELECT N',' + QUOTENAME(y) AS [text()]
				FROM (
						SELECT DISTINCT periodNm AS y FROM #TempIncomList WHERE HeadPk = @HeadPk
						) AS Y
				ORDER BY y
				FOR XML PATH('')
			),1, 1, N'');


			SELECT @Inc_NulltoZeroCol = ''

			SELECT @Inc_NulltoZeroCol = SUBSTRING((SELECT ',ISNULL(['+periodNm+'],0) AS ['+periodNm+']' 
			FROM (SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average' )TAB  
			ORDER BY periodNm FOR XML PATH('')),2,8000) 			

			IF @IncomeTable <> 'OT'
				SELECT @Inc_NulltoZeroCol = 'Average,'+@Inc_NulltoZeroCol;
	
			SELECT @ColTitle = SUBSTRING((SELECT ',''' + periodNm + '~HeaderRow'''
			FROM (SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average' )TAB  
			ORDER BY periodNm FOR XML PATH('')),2,8000) 		
	
			INSERT INTO #PeriodTable
			SELECT DISTINCT periodNm FROM #TempIncomList WHERE HeadPk = @HeadPk AND periodNm <> 'Average'	

			IF @IncomeTable <> 'OT'
				INSERT INTO #PeriodTable
				VALUES ('component'),('Average')
			ELSE
				INSERT INTO #PeriodTable
				VALUES ('component')
	
			SELECT @INSERT_COL = ''

			SELECT @INSERT_COL = SUBSTRING((SELECT ',' + columnNm  
			FROM (SELECT DISTINCT columnNm FROM #PeriodTable)COL_TAB  
			ORDER BY columnNm FOR XML PATH('')),2,8000) 	

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
					FROM #TempIncomList WHERE HeadPk = ' + RTRIM(@HeadPk) + N'
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
					FROM #TempIncomList WHERE HeadPk = ' + RTRIM(@HeadPk) + N'
				) PIVOTTABLE_INC
				PIVOT(
					MIN(amount) FOR periodNm IN ('+RTRIM(@Inc_ColumnList) + N')
				)
				AS PIVOTTABLE_INC
				ORDER BY seqNo,comppk,CompType';	
			END

			EXEC SP_EXECUTESQL @Inc_ExecQuery			
			
			SET @PrevActor = @Actor

			FETCH NEXT FROM IncomeCursor INTO @HeadPk,@IncomeTable,@LapFk,@Usrname,@Actor,@incomeName
		END   

		CLOSE IncomeCursor   
		DEALLOCATE IncomeCursor	

		------------------------------- END - INCOME INFO SELECT ---------------------------------------------

		------------------------------- START - TECH VALUATION SELECT ---------------------------------------------

		INSERT INTO #TechnicalDet(Terms,Value )
		VALUES('Technical~HeaderRow','Amount~HeaderRow')
	

		IF EXISTS(SELECT 'X' FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0)
		BEGIN
			INSERT INTO #TechnicalDet(Terms,Value )
			SELECT 'Valuation ' + RTRIM(ROW_NUMBER() OVER (ORDER BY LptPk)), CONVERT(VARCHAR, CONVERT(MONEY, LptMktVal),1)
			FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0	
		END
		ELSE
		BEGIN 
			INSERT INTO #TechnicalDet(Terms,Value )
			SELECT 'Valuation : ' ,' Valuation not done '
		END
	
		INSERT INTO #TechnicalDet(Terms,Value )
		SELECT 'Lower Valuation' , CONVERT(VARCHAR, CONVERT(MONEY, ISNULL(Min(LptMktVal),0)),1)
		FROM	LosPropTechnical (NOLOCK) WHERE LptLedFk = @LeadFk AND LptDelId = 0

		INSERT INTO #TechnicalDet(Terms,Value )
		SELECT 'LTV to MV','-'
		UNION ALL
		SELECT  'CLIR','-'
	
		------------------------------- END - TECH VALUATION SELECT ---------------------------------------------


		------------------------------- START - OBLIGATIONS SELECT ---------------------------------------------

		INSERT INTO #ObligationsDet(OblType, Appl, CoApp)
		VALUES	('OBLIGATIONS~Title','',''),
				('Existing Loan EMI','Applicant','Co-Applicant')
	
		DECLARE @ExecQuery  NVARCHAR(MAX), @ColumnList  VARCHAR(MAX);
	

		IF NOT EXISTS(SELECT 'X' FROM LosAppIncObl (NOLOCK) WHERE LioLedFk = @LeadFk AND LioDelId = 0 AND LioType = 'OB')
		BEGIN				
			CREATE TABLE  [tempdb].[dbo].[tempOBLtable] 
			(samplecol VARCHAR(100),Obltype VARCHAR(200))				
		END
		ELSE
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


			SELECT @ExecQuery = N' SELECT Obltype, ' + @NullToZeroCols + N'
			INTO [tempdb].[dbo].[tempOBLtable]
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
			ORDER BY CASE WHEN (Obltype=''Total'') THEN 1 ELSE 0 END,Obltype';				
			
			IF ISNULL(@ExecQuery,'') = ''
			BEGIN 
				CREATE TABLE  [tempdb].[dbo].[tempOBLtable] 
				(samplecol VARCHAR(100),Obltype VARCHAR(200))	
			END
			 			
			EXEC SP_EXECUTESQL @ExecQuery				

		END

		
		------------------------------- END - OBLIGATIONS SELECT ---------------------------------------------


		------------------------------- START - CREDIT DETAILS SELECT ---------------------------------------------
		
			INSERT INTO #FinalLnDet
			SELECT	CASE
						WHEN LnaCd = 'OBL' THEN 'Obligations' 
						WHEN LnaCd = 'IIR' THEN 'IIR' 
						WHEN LnaCd = 'FOIR' THEN 'FOIR' 
						WHEN LnaCd = 'NET_INC' THEN 'Total Income' 
						WHEN LnaCd = 'CBL' THEN 'Cibil Score' 
						WHEN LnaCd = 'TENUR' THEN 'Tenure' 
						WHEN LnaCd = 'LOAN_AMT' THEN 'Eligible Loan Amount' 					
						WHEN LnaCd = 'ROI' THEN 'ROI' 
						WHEN LnaCd = 'EMI' THEN 'EMI' 
						ELSE '-'				
					END
					,
					CASE
						WHEN LnaCd  IN ('OBL','NET_INC','LOAN_AMT','EMI') THEN CONVERT(VARCHAR,CONVERT(MONEY,ISNULL(LcaVal,0)),1)
						WHEN LnaCd	IN ('IIR','ROI','FOIR') THEN  CONVERT(VARCHAR,CONVERT(NUMERIC(5,2),ISNULL(LcaVal,0)))		
						WHEN LnaCd	IN ('CBL','TENUR') THEN CONVERT(VARCHAR,CONVERT(NUMERIC(5,0),ISNULL(LcaVal,0)))								
					END
					 ,
					CASE
						WHEN LnaCd = 'OBL' THEN 2
						WHEN LnaCd = 'IIR' THEN  4
						WHEN LnaCd = 'FOIR' THEN  4
						WHEN LnaCd = 'NET_INC' THEN 1
						WHEN LnaCd = 'CBL' THEN 5
						WHEN LnaCd = 'TENUR' THEN 6
						WHEN LnaCd = 'LOAN_AMT' THEN 7					
						WHEN LnaCd = 'ROI' THEN 8
						WHEN LnaCd = 'EMI' THEN 7					
						ELSE 100
					END
			FROM	LosCreditAttr (NOLOCK) A
			JOIN	LosLnAttributes (NOLOCK) B ON B.LnaPk = A.LcaLnaFk AND B.LnaDelId = 0
			JOIN	LosCredit (NOLOCK) C ON C.LcrPk = A.LcaLcrFk AND C.LcrDelId = 0		
			WHERE	C.LcrLedFk = @LeadFk AND A.LcaDelId = 0  AND C.LcrDocRvsn = (SELECT MAX(T.LcrDocRvsn) FROM LosCredit T (NOLOCK) WHERE T.LcrLedFk = @LeadFk AND T.LcrDelId = 0 )		
					AND  B.LnaCd IN ('OBL','IIR','FOIR','NET_INC','CBL','TENUR','LOAN_AMT','ROI','EMI')
	
		------------------------------- END - CREDIT DETAILS SELECT ---------------------------------------------

		-- PERSONAL INFO SELECT 
		SELECT	FirstCol , SecondCol 
		FROM	#ApplDet 
		ORDER BY Actor,LapFk,LineNumber			
		-- LAON DETAILS SELECT 
		SELECT * FROM #LoanDet
		--INCOME DETAILS		
		SELECT	ISNULL(Column1,'') 'col1',ISNULL(Column2,'') 'col2',ISNULL(Column3,'') 'col3',ISNULL(Column4,'') 'col4',ISNULL(Column5,'') 'col5',
				ISNULL(Column6,'') 'col6',ISNULL(Column7,'') 'col7',ISNULL(Column8,'') 'col8',ISNULL(Column9,'') 'col9',ISNULL(Column10,'')	'col10' 
		FROM #IncomeDataSet
		ORDER BY idColumn

		-- TECH VALUATIONS
		SELECT * FROM #TechnicalDet	
		-- OBLIGATION SELECT

		
		SELECT * FROM [tempdb].[dbo].[tempOBLtable]
		ORDER BY CASE WHEN (Obltype='Total') THEN 1 ELSE 0 END,Obltype
		DROP TABLE [tempdb].[dbo].[tempOBLtable]
		-- FINAL LOAN DETAILS
		SELECT	FirstCol , SecondCol  
		FROM	#FinalLnDet ORDER BY LineNumber
	END TRY
	BEGIN CATCH
		SELECT ERROR_MESSAGE()
		DEALLOCATE IncomeCursor
		DROP TABLE [tempdb].[dbo].[tempINCtable]
		DROP TABLE [tempdb].[dbo].[tempOBLtable]
	END CATCH
END


GO
