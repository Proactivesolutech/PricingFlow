IF OBJECT_ID('PrcShflPaymentSchedule','P') IS NOT NULL
DROP PROC PrcShflPaymentSchedule
GO
CREATE PROC [dbo].[PrcShflPaymentSchedule] 
(  
	@LoanAmount				DECIMAL(27,7),
	@InterestRate			DECIMAL(27,7),
	@Tenure					INT,
	@EmiDueDt				INT,
	@PymntScheduleArriveDT	DATETIME = NULL
)
AS  
BEGIN  
	SET NOCOUNT ON  

	IF EXISTS(SELECT object_id FROM tempdb.sys.objects WHERE name LIKE '#EMI%')     
	BEGIN     
		DROP TABLE #EMI     
	END   
  
	CREATE TABLE #EMI(PERIOD INT, PAYDATE DATETIME, PAYMENT DECIMAL(27,7), CURRENT_BALANCE DECIMAL(27,7), INTEREST DECIMAL(27,7), PRINCIPAL DECIMAL(27,7), OPENING_BAL DECIMAL(27,7))   	  	

	DECLARE   @Payment DECIMAL(27,7), @Period FLOAT, 
			  @EmiInterest FLOAT, @CurrentBalance DECIMAL(27,7), @Principal FLOAT, @Interest FLOAT, @LoanPayDate DATETIME, 
		      @LoanDueDate DATETIME, @OpeningBalance DECIMAL(27,7), @IsPreEMI Char(1), @PreEmiInterest FLOAT, @GapDays FLOAT,@PreEmiPayment DECIMAL(27,7),
			  @StartPaymentDate DATETIME

	SET @PymntScheduleArriveDT = GETDATE()

	--Payment Start Date
	IF (@EmiDueDt > DATEPART(D,@PymntScheduleArriveDT)) --Pre-EMI from current month
		SET @StartPaymentDate = DATEADD(D,@EmiDueDt-1,DATEADD(month, DATEDIFF(month, 0, @PymntScheduleArriveDT), 0))

	ELSE IF (@EmiDueDt < DATEPART(D,@PymntScheduleArriveDT)) --Pre-EMI from next month
		SET @StartPaymentDate = DATEADD(D,@EmiDueDt-1,DATEADD(month, DATEDIFF(month, 0, @PymntScheduleArriveDT)+1, 0))

	ELSE --EMI
		SET @StartPaymentDate = @PymntScheduleArriveDT

	IF(@EmiDueDt = DATEPART(D,@PymntScheduleArriveDT))
	BEGIN
		SET @IsPreEMI = 'N'	
		SET @Period = 1		 
		SET @OpeningBalance = @LoanAmount
	END
	ELSE
	BEGIN
		SET @IsPreEMI = 'Y'
		SET @Period = -1
	END
	
	--EMI     
	SET @EmiInterest = @InterestRate/(12 * 100)     
	SET @Payment = ROUND((((@EmiInterest) * @LoanAmount)/(1- (POWER((1 + (@EmiInterest)),(-1 * @Tenure))))),0) 

	--SET @Payment = ROUND(@LoanAmount * @EmiInterest * (POWER((1 + @EmiInterest) , @Tenure)  / (POWER((1 + @EmiInterest) , @Tenure) - 1)),0)

	--Pre-EMI
	IF @IsPreEMI = 'Y'
	BEGIN	     		
		SET @GapDays =  DATEDIFF(D,@PymntScheduleArriveDT,@StartPaymentDate)

		SET @PreEmiInterest = @InterestRate/(365 * 100) 
		SET @PreEmiPayment = (ROUND((((@PreEmiInterest) * @LoanAmount)/(1- (POWER((1 + (@PreEmiInterest)),(-1 * @Tenure * 365))))),0)) * @GapDays
	END

	SET @LoanPayDate = @StartPaymentDate  

	WHILE (@Period < = @Tenure)     
	BEGIN   
		SET @LoanDueDate = @LoanPayDate  

		IF (@IsPreEMI = 'Y' AND @Period = -1)
		BEGIN				
			INSERT INTO #EMI (PERIOD, PAYDATE, OPENING_BAL, PAYMENT,INTEREST, PRINCIPAL, CURRENT_BALANCE)  
			SELECT  @Period, @LoanDueDate,@LoanAmount, @PreEmiPayment, @PreEmiPayment, 0,@LoanAmount
			
			SET @CurrentBalance = @LoanAmount
		END
		ELSE
		BEGIN
			SET @CurrentBalance = ROUND (@LoanAmount * POWER((1+ @EmiInterest), @Period) - ((ROUND(@Payment,0)/@EmiInterest) * (POWER((1 + @EmiInterest),@Period ) - 1)),0)
  
			SET @Principal =   CASE WHEN @Period = 1 THEN ROUND((ROUND(@LoanAmount,0) - ROUND(@CurrentBalance,0)),0)   
									ELSE ROUND ((SELECT ABS(ROUND(CURRENT_BALANCE,0) - ROUND(@CurrentBalance,0))   
												 FROM #EMI   
												 WHERE PERIOD = @Period -1),0)   
							   END   
  
			SET @Interest = ROUND(ABS(ROUND(@Payment,0) - ROUND(@Principal,2)),0)     

			IF @Period = @Tenure
			BEGIN
				SET @Payment =  @Payment + @CurrentBalance
				SET @Principal = @Principal + @CurrentBalance
				SET @CurrentBalance = 0
			END
			 
			INSERT INTO #EMI (PERIOD, PAYDATE, OPENING_BAL, PAYMENT,INTEREST, PRINCIPAL, CURRENT_BALANCE) 
			SELECT  @Period, @LoanDueDate, @OpeningBalance,@Payment, @Interest, @Principal, @CurrentBalance  
		END
				
		IF @Period = -1
			SET @Period = 1
		ELSE
			SET @Period = @Period + 1  

		SET @LoanPayDate = DATEADD(MM,1,@LoanPayDate)  
		SET @OpeningBalance = @CurrentBalance 
	END   
	
	SELECT PERIOD, CONVERT(VARCHAR(25),PAYDATE,103) PAYDATE, OPENING_BAL, PAYMENT, INTEREST, PRINCIPAL, CURRENT_BALANCE
	FROM #EMI  	   
END 


