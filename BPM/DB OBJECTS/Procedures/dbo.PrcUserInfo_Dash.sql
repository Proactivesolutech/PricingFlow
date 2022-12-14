USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcUserInfo_Dash]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[PrcUserInfo_Dash]
(
	@Action varchar(50),
	@UsrNm varchar(20)=null,
	@UsrPwd varchar(20)=null,
	@Locid varchar(20)='0'
)
AS
BEGIN
	Declare		@Usr_Sel_Loc_Desc varchar(200),@CurId INT,@ConvCurId INT,
				@Usr_Sel_Loc_Cd varchar(50) , @CurCd VARCHAR(10),@CurNm VARCHAR(10),@CurRt NUMERIC(27,6)
				
    SELECT @CurId = Gn_Gen_CurrId FROM Cs_GenTab_Mas WHERE GN_UNQ_ID = @Locid AND Gn_Gen_Type = 0 AND Gn_Inact_Flg = 0
	SELECT @CurCd = Cr_Curr_CD ,@CurNm = Cr_Curr_Name , @CurRt = Cr_Curr_Rate FROM CS_Curren_Mas WHERE Cr_Unq_Id = @CurId
				

	IF @Action='LOC_DTLS' 
	BEGIN
	
         Select Gn_Gen_Code AS "Loc_Code", Gn_Gen_Desc AS "Loc_Desc", Gn_Unq_id as "hdn_LocId" 
         from CS_GENTAB_MAS join SyUsrLoc on Ul_Loc_Id = GN_UNQ_ID
                            join SYUSRPRF on UP_USR_PID = Ul_Usr_Id 
		 where GN_GEN_TYPE = 0 and UL_Loc_Ass = 1 and UP_USR_PID = @Locid
		 ORDER BY Gn_Gen_Code ;

    END 
    IF @Action='LOGINUSR_DTLS' 
	BEGIN
  
        IF NOT EXISTS (Select null FROM SyUsrLoc WHERE Ul_Usr_Id=@UsrNm and UL_Loc_Ass = 1 and Ul_Loc_Id = @Locid )
		BEGIN
			Raiserror('User do not have access rights to this Location',16,1)
			Return
		END
		
		
	      Select @Usr_Sel_Loc_Cd=GN_GEN_Code,@Usr_Sel_Loc_Desc=Gn_Gen_Desc 
		  FROM Cs_GenTab_Mas where Gn_Gen_Type = 0 and Gn_Inact_Flg = 0
		  AND Gn_Unq_id=@Locid;
		 
          SELECT RTRIM(UP_USR_NM) AS "hdnUsrnm",RTRIM(UP_PWD_STR) AS "hdnPwd",
                 RTRIM(CP_COMP_NAME) AS "hdnCompNm",Rtrim(Newid()) AS "hdnSesid",UP_USR_PID AS "hdnUsr_Id"
                ,RTRIM(datepart(DD,GETDATE())) +'/'+ RTRIM(datepart(MM,GETDATE())) +'/'+  RTRIM(datepart(YYYY,GETDATE())) AS "gCurDt"
                ,@CurCd AS "Cur_Cd", @CurNm AS "Cur_Nm",1 AS "Cur_Rate",
				--Combo Selection Loc
				@Locid AS "Sel_Loc_Id",@Usr_Sel_Loc_Cd AS "Sel_Loc_Cd",
                @Usr_Sel_Loc_Desc AS "Sel_Loc_Desc",
                --Default Location
                Ul_Loc_Id AS "Def_Loc_Id", GN_GEN_Code AS "Def_Loc_Cd" 
                ,CS_GENTAB_MAS.GN_GEN_DESC AS "Def_Loc_Desc" ,
				--Ul_Loc_Id AS "Loc_Id", GN_GEN_Code AS "Loc_Desc" ,
				RTRIM(@@SERVERNAME)+'~'+RTRIM(db_Name())+'(SQL)' AS "Server_Detls"
				,'SQL' AS "STYPE" 
			FROM SYUSRPRF, SyUsrLoc ,Cs_GenTab_Mas ,cs_comp_mas 
			WHERE 
			GN_GEN_TYPE=0 and GN_INACT_FLG=0 and  Ul_Loc_Id=GN_UNQ_ID
			AND  Ul_Usr_Id =UP_USR_PID    AND UL_DEF_LOC=1
			AND UP_USR_PID = @UsrNm ; 
	
    END

	IF @Action='USRINFO'
	BEGIN
		
		IF NOT EXISTS(Select NULL FROM SYUSRPRF WHERE Rtrim(UP_USR_NM)=Rtrim(@UsrNm) and Rtrim(UP_PWD_STR)=Rtrim(@UsrPwd))
		BEGIN
			Raiserror('Wrong User Name or Password',16,1)
			Return
		END
		
		select UP_USR_PID as 'USERID',UP_USR_CD AS 'USERCODE',UP_USR_NM AS 'USERNAME'
		from SYUSRPRF where  Rtrim(UP_USR_NM)=Rtrim(@UsrNm) and Rtrim(UP_PWD_STR)=Rtrim(@UsrPwd);
	END
	
END





GO
