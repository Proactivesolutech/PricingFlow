IF EXISTS(SELECT NULL FROM sysobjects WHERE name='PrcSyncLdfrmUNO' AND [type]='P')
	DROP PROC PrcSyncLdfrmUNO
GO
CREATE PROCEDURE PrcSyncLdfrmUNO
AS
BEGIN
	SET NOCOUNT ON;

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

	BEGIN TRY
	
	IF @@TRANCOUNT = 0
		SET @Trancount = 1
					
		IF @Trancount = 1
			BEGIN TRAN
		
				INSERT INTO #LeadInsert
				(
					Product ,Lead_id ,Branch ,applicant_name ,mobile ,dob ,agent ,
					income_type ,market_value ,loan_amt ,tenure ,income ,obligation ,previous_loan ,
					haveyoudefault ,hasproof ,cibil ,purpose ,roi ,ledmobno, LdAgtCd, AgtFk
				)
				SELECT		NULL,A.LeadID,GeoPk,CustomerName,CustomerMobile,DateofBirth,ChannelShrtDescr,
							EmpType,EstdMarketValue,LoanAmount,Tenure,MonthlyIncome,MonthlyObligations,
							PreviousLoan,HaveYouDefault,NULL,CIBILScore,NULL,InitalROIRange,AlternateContactno,A.CrtdBy,Agt.AgtPk
				FROM		[SHFL_LOS_ACC].dbo.Loln_MBLead A
				JOIN		( SELECT DISTINCT UnoUnit,Pincode FROM [SHFL_LOS_ACC].dbo.IGen_PinCode_BranchMapping ) B ON A.Pincode = B.Pincode
				JOIN		GenGeoMas C ON	B.UnoUnit = C.GeoCd
				JOIN		[SHFL_LOS_ACC].dbo.Loln_T_RiskCalcLeadWise D ON A.LeadID = D.LeadID
				LEFT JOIN	GenAgents Agt(NOLOCK) ON A.CrtdBy = ISNULL(Agt.AgtCd,'')
				WHERE		Status = 'I'
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
						CASE WHEN income_type= 'All Self Employed' THEN 1 ELSE 0 END,market_value,
						CASE WHEN previous_loan ='No' THEN 1 ELSE 0 END,
						loan_amt,tenure,0,income,0,obligation,cibil,0,REPLACE(roi,'%',''),
						@RowId,@UsrNm, @CurDt,@UsrNm, @CurDt,NULL, 0,AgtFk,mobile,@GrpFk,NULL,NULL 
				FROM	#LeadInsert

			IF @Trancount = 1 AND @@TRANCOUNT = 1
			COMMIT TRAN
			
	END TRY
	BEGIN CATCH

		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN	
		
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTRIM(ERROR_LINE()),
				@ErrSeverity = ERROR_SEVERITY()
		
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg) 		
		RETURN
			
	END CATCH
END