IF OBJECT_ID('PrcShflInsurar','P') IS NOT NULL
	DROP PROCEDURE PrcShflInsurar
GO
CREATE PROCEDURE PrcShflInsurar
(
           @Action VARCHAR(100) = NULL,
		   @GlobalJson VARCHAR(100)= NULL,
		   @AppJson  VARCHAR(MAX) = NULL,
		   @Pk  VARCHAR(MAX) = NULL
    )
    AS
    BEGIN 
    DECLARE	 @CurDt DATETIME,@TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), 
			     @Error INT, @RowCount INT,@RowId VARCHAR(40),@InsPk BIGINT,@USERNAME VARCHAR(100)

   
    CREATE TABLE #Dtls
     (
		dd_id BIGINT,Inscode VARCHAR(100),InsName VARCHAR(100),InsDispName VARCHAR(100),InPk BIGINT
	 )

	 CREATE TABLE #GLOBALDTLS
	 (
	 GID BIGINT,USERNAME VARCHAR(100)
	 )
   
	 SELECT @CurDt = Getdate(), @RowId = Newid()

	 IF @GlobalJson !='[]' AND @GlobalJson != ''
	 BEGIN
	    INSERT INTO #GLOBALDTLS
		EXEC PrcParseJSON @GlobalJson,'USERNAME'
		SELECT @USERNAME=USERNAME FROM #GLOBALDTLS
	 END
	
	IF @AppJson != '[]' AND @AppJson != ''
	BEGIN					
		INSERT INTO #Dtls
		EXEC PrcParseJSON @AppJson,'Inscode,InsName,InsDispName,InPk'
		SELECT @InsPk=InPk FROM #Dtls
	END



	BEGIN TRY
	IF @@TRANCOUNT = 0
		SET @TranCount = 1
	IF @TranCount = 1
		BEGIN TRAN
			IF @Action = 'Load'
		      BEGIN
				    SELECT	  InsPk 'InPk',InsCd 'Inscode',InsNm 'InsName',InsDispNm 'InsDispName'
					FROM      GenInsCmp(NOLOCK)  
					WHERE     InsDelId=0
		    END
			IF @Action = 'Select'
		      BEGIN
				    SELECT	  InsPk 'InPk',InsCd 'Inscode',InsNm 'InsName',InsDispNm 'InsDispName'
					FROM      GenInsCmp(NOLOCK)  
					WHERE     Inspk=@Pk AND InsDelId=0
		    END
			IF @Action = 'Save'
			BEGIN
                     INSERT INTO GenInsCmp(InsCd,InsNm,InsDispNm,InsRowId,InsCreatedBy,InsCreatedDt,InsModifiedBy,InsModifiedDt,InsDelFlg,InsDelId)

				     SELECT	     Inscode,InsName,InsDispName,@RowId,@USERNAME,@CurDt,@USERNAME,@CurDt,NULL,0
				     FROM		 #Dtls
					 WHERE	     ISNULL(InPk,0) = 0
					 SELECT	     @Error = @@ERROR, @RowCount = @@ROWCOUNT
					 IF @Error > 0
								BEGIN
									RAISERROR('%s',16,1,'Error : Insurar Insert')
									RETURN
								END

						UPDATE 	A
						SET		InsCd = Inscode, InsNm = InsName,InsDispNm=InsDispName,
								InsRowId = @RowId, InsModifiedBy = @USERNAME, InsModifiedDt = @CurDt
						FROM	GenInsCmp A 
						JOIN    #Dtls B ON A.InsPk = B.InPk
						WHERE   B.InPk > 0

			END	
			IF @Action='Delete'
			BEGIN
			          UPDATE	GenInsCmp
					  SET		InsDelId = 1, InsDelFlg = dbo.gefgGetDelFlg(@CurDt),InsRowId=@RowId,InsModifiedBy=@USERNAME,InsModifiedDt=@CurDt
					  WHERE	    Inspk=@Pk AND InsDelId=0
			END

	   IF @Trancount = 1 AND @@TRANCOUNT = 1
				COMMIT TRAN

	END TRY
	BEGIN CATCH
		IF @Trancount = 1 AND @@TRANCOUNT = 1
			ROLLBACK TRAN
		SELECT	@ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + Rtrim(ERROR_LINE()), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR('%s', @ErrSeverity, 1,@ErrMsg)
		RETURN

	END CATCH

	END


