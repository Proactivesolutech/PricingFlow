
BEGIN TRAN

	DECLARE @CurDt DATETIME, @RowId VARCHAR(40), @UsrNm VARCHAR(100),@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			@Error INT, @RowCount INT, @ConnectDB VARCHAR(100), @CmpFk BIGINT
	DECLARE @GrpFk BIGINT
	
	CREATE TABLE #LeadInsert
	(
		Product VARCHAR(100),Lead_id VARCHAR(100),Branch VARCHAR(100),applicant_name VARCHAR(100),mobile VARCHAR(100),dob VARCHAR(100),agent VARCHAR(100),
		income_type VARCHAR(100),market_value VARCHAR(100),loan_amt VARCHAR(100),tenure VARCHAR(100),income VARCHAR(100),obligation VARCHAR(100),
		previous_loan VARCHAR(100),haveyoudefault VARCHAR(100),hasproof VARCHAR(100),cibil VARCHAR(100),purpose VARCHAR(100),roi VARCHAR(100),
		ledmobno VARCHAR(100), LdAgtCd VARCHAR(100), AgtFk BIGINT
	)

	SELECT	@UsrNm = 'UNOSYNC', @CurDt = GETDATE(), @RowId = NEWID();
--LGen_MktngAgent

	INSERT INTO #LeadInsert
	(
		Product ,Lead_id ,Branch ,applicant_name ,mobile ,dob ,agent ,
		income_type ,market_value ,loan_amt ,tenure ,income ,obligation ,previous_loan ,
		haveyoudefault ,hasproof ,cibil ,purpose ,roi ,ledmobno, LdAgtCd, AgtFk
	)
	SELECT		NULL,A.LeadID,C.GeoPk,CustomerName,CustomerMobile,DateofBirth,ChannelShrtDescr,
				EmpType,EstdMarketValue,LoanAmount,Tenure,MonthlyIncome,MonthlyObligations,
				PreviousLoan,HaveYouDefault,NULL,CIBILScore,NULL,InitalROIRange,AlternateContactno,A.CrtdBy,Agt.AgtPk
	FROM		[ShrihomeUNO].dbo.Loln_MBLead A
	JOIN		GenGeoMas C ON	A.Location = C.GeoNm
	LEFT JOIN	[ShrihomeUNO].dbo.Loln_T_RiskCalcLeadWise D ON A.LeadID = D.LeadID
	LEFT JOIN	GenAgents Agt(NOLOCK) ON A.CrtdBy = ISNULL(Agt.AgtCd,'')
	WHERE		A.LeadId IN('PMC00000030000148','PMC00000030000155', 'SHFS2940000030','shfk0330000054')
	AND			NOT EXISTS(SELECT 'X' FROM LosLead(NOLOCK) WHERE LedId = A.LeadID)

	SELECT @GrpFk = GrpPk FROM GenLvlDefn (NOLOCK) WHERE GrpCd = 'HL'
	
	INSERT INTO LosLead
	(
	  LedId,LedBGeoFk,LedNm,LedDOB,LedPrdFk,LedEmpCat,LedMrktVal,LedPrvLnCrd,LedLnAmt,LedTenure,LedDflt,LedMonInc,LedIncPrf,LedMonObli,
	  LedCIBILScr,LedEMI,LedROI,LedRowId,LedCreatedBy,LedCreatedDt,LedModifiedBy,LedModifiedDt,LedDelFlg,LedDelId,LedAgtFk,LedMobNo,
	  LedPGrpFk,LedPNI,LedBT
	)
	OUTPUT INSERTED.*
	SELECT  Lead_id,Branch,applicant_name,dob,Product,
			CASE WHEN income_type= 'All Self Employed' THEN 1 ELSE 0 END,ISNULL(market_value,0),
			CASE WHEN previous_loan ='No' THEN 1 ELSE 0 END,
			ISNULL(loan_amt,0),(ISNULL(tenure,0) * 12),0,ISNULL(income,0),0,ISNULL(obligation,0),ISNULL(cibil,0),0,REPLACE(ISNULL(roi,''),'%',''),
			@RowId,@UsrNm, @CurDt,@UsrNm, @CurDt,NULL, 0,AgtFk,mobile,@GrpFk,NULL,NULL 
	FROM	#LeadInsert
	
	

ROLLBACK TRAN