ALTER FUNCTION dbo.fnCalcROI
(
	@SAL_TYPE	BIT,
	@SAL_PRF	BIT,
	@LTV		NUMERIC(27,7),
	@CIBIL		INT ,
	@FOIR		NUMERIC(27,7)	
)
RETURNS NUMERIC(27,7)
AS 
BEGIN 
	--DEFAULT VALUE
		DECLARE @ROI NUMERIC(27,7) = 15;
        
		IF (@SAL_TYPE = 0)
		BEGIN             
            IF (@CIBIL > 800 AND @FOIR < 55)
                SET @ROI = 11; 
            ELSE IF (@CIBIL >= 751 AND @CIBIL <= 800 AND @FOIR < 55)
                SET @ROI = 12; 
            ELSE IF (@CIBIL >= 700 AND @CIBIL <= 750 AND @FOIR < 55)
                SET @ROI = 13; 
            ELSE IF (@CIBIL > 750 AND @FOIR > 55)
                SET @ROI = 14; 
            ELSE IF (@CIBIL < 750 AND @FOIR < 55)
                SET @ROI = 14.5;
            ELSE IF (@CIBIL < 750 AND @FOIR > 55)
                SET @ROI = 15; 
        END
        ELSE IF (@SAL_TYPE = 1)
        BEGIN
		   IF (@SAL_PRF = 0 AND @LTV <= 50 AND @CIBIL > 750 AND @FOIR <= 40)
                SET @ROI = 11; 
            ELSE IF (@SAL_PRF = 0 AND @LTV <= 50 AND @CIBIL > 750 AND @FOIR > 40 AND @FOIR <= 60)
                SET @ROI = 12; 
            ELSE IF (@SAL_PRF = 0 AND @LTV <= 50 AND @CIBIL > 750 AND @FOIR > 60)
                SET @ROI = 13; 
            ELSE IF (@SAL_PRF = 0 AND @LTV <= 50 AND @CIBIL <= 750)
                SET @ROI = 13.5;
            ELSE IF (@SAL_PRF = 0 AND @LTV > 50 AND @CIBIL > 750)
                SET @ROI = 14; 
            ELSE IF (@SAL_PRF = 0 AND @LTV > 50 AND @CIBIL <= 750)
                SET @ROI = 15.5; 
            ELSE IF (@SAL_PRF = 1 AND @LTV <= 50 AND @CIBIL > 800)
                SET @ROI = 13; 
            ELSE IF (@SAL_PRF = 1 AND @LTV <= 50 AND @CIBIL > 750 AND @FOIR <= 800)
                SET @ROI = 14; 
            ELSE IF (@SAL_PRF = 1 AND @LTV <= 50 AND @CIBIL <= 750)
                SET @ROI = 14.5; 
            ELSE IF (@SAL_PRF = 1 AND @LTV > 50 AND @CIBIL > 750)
                SET @ROI = 15; 
            ELSE IF (@SAL_PRF = 1 AND @LTV > 50 AND @CIBIL <= 750)
                SET @ROI = 16; 
		END     
		ELSE        
		     SET @ROI = 15;  

		RETURN(@ROI);	
END

