USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[shfl_procedure]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[shfl_procedure]
(
	@Action			VARCHAR(100)		=	NULL ,
	@GlobalJSON		VARCHAR(MAX)		=	NULL ,
	@DataJSON		VARCHAR(MAX)		=	NULL
)
AS
BEGIN
	SET NOCOUNT ON
	SET ANSI_WARNINGS ON

	DECLARE @XmlId INT , @ErrorNo INT, @RwCnt INT, @UsrPk BIGINT, @CstmVal1 BIGINT, @NoOfMsg BIGINT

	DECLARE @CurDt DATETIME, @TranCount INT = 0, @ErrSeverity INT, @ErrMsg VARCHAR(MAX), @Error INT, @RowCount INT
	
	DECLARE @FlowFk BIGINT,@ElemPk VARCHAR(200),@CurPage BIGINT,@TgtPage BIGINT, @PrtTreeId VARCHAR(100),@DataMasPk BIGINT

	SET @CurDt = GETDATE()
	
	CREATE TABLE #GlobalDetails
	(
		xx_id BIGINT, TempFlowFk BIGINT, TempFlowXml VARCHAR(MAX),TempElemId VARCHAR(200),CurPage BIGINT,FwdDataPk BIGINT,
		CreatePageType TINYINT,TgtPageID VARCHAR(200), UsrFk BIGINT,VerFlowPk BIGINT,CurVerFlowPk BIGINT,HisPK BIGINT
	)

	CREATE TABLE #ApplData(
		xx_id BIGINT, LtFk BIGINT,AptTyp INT,AptFrstNm VARCHAR(100),AptMdlNm VARCHAR(100),AptLstNm VARCHAR(100),Gender INT,
		DOB	VARCHAR(100),MobNo	BIGINT,Email	VARCHAR(100),Addr1	VARCHAR(100),AptPk BIGINT
)

	IF @GlobalJSON !='[]' AND @GlobalJSON != ''
	BEGIN
		INSERT INTO #GlobalDetails
		EXEC PrcParseJSON @GlobalJSON,'FlowFk,FlowXml,ElemId,CurPage,FwdDataPk,CreatePageType,TgtPageID,UsrPk,VerFlowPk,CurVerFlowPk,HisPK'
	END


	IF @DataJSON !='[]' AND @DataJSON != ''
	BEGIN	
		INSERT INTO #ApplData
		EXEC PrcParseJSON @DataJSON,'LtFk,AptTyp,AptFrstNm,AptMdlNm,AptLstNm,Gender,DOB,MobNo,Email,Addr1,AptPk'
	END

	BEGIN TRY
	 
		IF @@TRANCOUNT = 0
			SET @TranCount = 1
	
		IF @TranCount = 1
			BEGIN TRAN
								
				IF @Action = 'GET_APPL_DATA'
				BEGIN

					SELECT @FlowFk = CurVerFlowPk, @DataMasPk = FwdDataPk FROM #GlobalDetails

					SELECT	LtFk,AptTyp,AptPk,AptFrstNm,AptMdlNm,AptLstNm,Gender,CONVERT(VARCHAR(10), DOB, 105) AS DOB,MobNo,Email,Addr1
					FROM SHFL_ApplicantDetails (NOLOCK) 
					WHERE	LtFk = @DataMasPk AND DelID = 0 
				END

				IF @Action='ADD_APPL_DATA'
				BEGIN
					UPDATE A
					SET A.DelId = 1
					FROM SHFL_ApplicantDetails (NOLOCK) A					
					JOIN #ApplData B ON A.LtFk = B.LtFk AND A.AptTyp = B.AptTyp
					WHERE A.AptTyp = 1 AND A.DelId = 0 

					INSERT INTO SHFL_ApplicantDetails(LtFk,AptTyp,AptFrstNm,AptMdlNm,AptLstNm,Gender,DOB,MobNo,Email,Addr1,ActDt,DelId)
					SELECT	LtFk,AptTyp,AptFrstNm,AptMdlNm,AptLstNm,Gender,dbo.gefgChar2Date(DOB),MobNo,Email,Addr1,@CurDt,0
					FROM #ApplData

					SELECT @@IDENTITY AS AptPk
				END

				
				IF @Action = 'UPDATE_APPL_DATA'
				BEGIN

					UPDATE A
					SET A.LtFk = B.LtFk, A.AptTyp = B.AptTyp, A.AptFrstNm = B.AptFrstNm, A.AptMdlNm = B.AptMdlNm , A.AptLstNm = B.AptLstNm, A.Gender = B.Gender,
					A.DOB = dbo.gefgChar2Date(B.DOB), A.MobNo = B.MobNo, A.Email = B.Email, A.Addr1 = B.Addr1, A.ActDt = @CurDt
					FROM SHFL_ApplicantDetails (NOLOCK) A					
					JOIN #ApplData B ON A.LtFk = B.LtFk AND A.AptTyp = B.AptTyp
					WHERE A.DelId = 0 AND A.AptPk = B.AptPk
					
					SELECT AptPk FROM #ApplData

				END

				IF @Action = 'DELETE_APPL_DATA'
				BEGIN
					UPDATE A
					SET A.DelId = 1
					FROM SHFL_ApplicantDetails (NOLOCK) A					
					JOIN #ApplData B ON A.LtFk = B.LtFk AND A.AptTyp = B.AptTyp
					WHERE B.AptPk = A.AptPk AND A.DelId = 0 
					
					SELECT @@ROWCOUNT result;
				END

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
GO
