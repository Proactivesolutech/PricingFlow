USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[PrcMenuDetils]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PrcMenuDetils]
(
	@Action Varchar(20)=NULL,
	@UserNm    varchar(20)=NULL,
    @UserId    Bigint =0,
    @Sesid    varchar(50)= null
)
AS 
BEGIN
	DECLARE @Lop_St int,@LopCnt Int
				,@Menu_Id Int,@nodeStr varchar(max)
				,@MenuStr varchar(max),@Grp_Ref_Id int
	CREATE TABLE #TM_MENU_DETAILS
	( 
	  TM_MN_LVL_NO   VARCHAR(10),  TM_MN_MNU_NM   VARCHAR(500),  TM_MN_MNU_KEY  Bigint,
	  TM_MNU_ID      VARCHAR(50),  TM_PARENT_ID   Bigint,  TM_MNU_SWF     VARCHAR(500),
	  TM_SESSID      VARCHAR(500),  TM_TRS_FLG     VARCHAR(5)
	)
	CREATE TABLE #TM_MENU_TREE_BUILD
	(
	  BT_MN_LVL_NO   VARCHAR(4),BT_MN_MNU_NM   VARCHAR(500),
	  BT_MN_MNU_KEY  Bigint, BT_PARANT_ID Bigint, BT_TREEID  VARCHAR(1000),
	  BT_MNU_ID		VARCHAR(50),BT_MNU_SWF VARCHAR(500),
	  BT_MNU_XML     VARCHAR(4000), BT_SESSID  VARCHAR(500 ),
	  BT_TRS_FLG     VARCHAR(5)
	)
					
	SET @Lop_St=1 SET @nodeStr='' SET @MenuStr=''
	
	IF @Action='S_Menu' --Search Screen Help
	BEGIN
		SELECT  ISNULL(MN_MNU_ID ,'') AS "MENU_ID", RTRIM(MN_MNU_NM)AS "MENU", RTRIM(ISNULL(MN_MNU_SWF,'')) AS "hdn_SwfF" 
        FROM  symenu 
        WHERE MN_MNU_SWF  is not null   AND MN_MNU_NO<>'XTH'
        order by MN_MNU_ID ;		
	END 
	IF @Action='MENU'
	BEGIN
	
	 ---MD-===> Menu Details ,BT==> Build Treeid
     ---P_Id ==> Parent Id Calculate
		SELECT  @Grp_Ref_Id=UP_GRP_PID FROM SYUSRPRF  where UP_USR_PID=@UserId
		INSERT INTO #tm_Menu_Details
		(tm_MN_LVL_NO ,tm_MN_MNU_NM , tm_Mn_Mnu_Key ,tm_Mnu_Id ,tm_Mnu_Swf ,tm_Trs_Flg,tm_sessid)
		SELECT CASE MN_LVL_NO WHEN 'M00' THEN '1' WHEN 'M01' THEN '2' WHEN 'M02' THEN '3' WHEN 'M03' THEN '4' END AS MN_LVL_NO, 
				MN_MNU_NM,  Mn_Mnu_Key ,ISNULL(MN_MNU_ID,''),ISNULL(MN_MNU_SWF,''),'MD',@Sesid
		FROM symenu    
		WHERE SUBSTRING(MN_MNU_NM,1,1) <> '-'  
		--AND SUBSTRING(mn_mnu_str,@Grp_Ref_Id,1)<>0   
		AND MN_MNU_NO<>'XTH'
		ORDER BY Mn_Mnu_Key;

          INSERT INTO #tm_Menu_Details
        (tm_MN_LVL_NO ,tm_MN_MNU_NM , tm_Mn_Mnu_Key ,tm_parent_id, tm_Mnu_Id ,tm_Mnu_Swf ,tm_Trs_Flg,tm_sessid)
        SELECT 
            Chd.tm_MN_LVL_NO, Chd.tm_MN_MNU_NM, Chd.tm_Mn_Mnu_Key, MAX(Prt.tm_Mn_Mnu_Key) AS PrdKey,Chd.tm_Mnu_Id,Chd.tm_Mnu_Swf
            ,'P_ID',@Sesid
        FROM #tm_Menu_Details Chd, #tm_Menu_Details Prt
        WHERE Chd.tm_MN_Mnu_Key >= Prt.tm_MN_Mnu_Key
                AND Chd.tm_MN_LVL_NO = Prt.tm_MN_LVL_NO + 1
                AND Chd.tm_sessid=@Sesid and Prt.tm_sessid=@Sesid
                AND Rtrim(Chd.tm_Trs_Flg)='MD'and Rtrim(Prt.tm_Trs_Flg)='MD'  
        GROUP BY Chd.tm_MN_LVL_NO, Chd.tm_MN_MNU_NM, Chd.tm_Mn_Mnu_Key,Chd.tm_Mnu_Id,Chd.tm_Mnu_Swf
        ORDER BY Chd.tm_Mn_Mnu_Key;
        
         INSERT INTO #tm_Menu_Tree_Build 
        (BT_MN_LVL_NO ,BT_MN_MNU_NM ,BT_Mn_Mnu_Key ,BT_Parant_id,BT_Treeid,BT_Mnu_Id ,BT_Mnu_Swf,BT_sessid,BT_Trs_Flg)
        SELECT 
            tm_MN_LVL_NO, tm_MN_MNU_NM,tm_Mn_Mnu_Key, 0, RIGHT('00000' + RTRIM(tm_Mn_Mnu_Key),5) ,tm_Mnu_Id ,tm_Mnu_Swf,@Sesid,'BT'
        FROM #tm_Menu_Details 
        WHERE  Rtrim(tm_sessid)=@Sesid and tm_Trs_Flg='MD' and tm_Mn_Lvl_No = 1  
        
        Delete    from #tm_Menu_Details where Rtrim(tm_sessid)=@Sesid and tm_Trs_Flg='MD' 
        
       
        INSERT INTO #tm_Menu_Tree_Build 
            (BT_MN_LVL_NO ,BT_MN_MNU_NM ,BT_Mn_Mnu_Key ,BT_Parant_id,BT_Treeid,BT_Mnu_Id ,BT_Mnu_Swf,BT_sessid,BT_Trs_Flg)
        SELECT 
            A.tm_MN_LVL_NO, A.tm_MN_MNU_NM, A.tm_Mn_Mnu_Key, B.BT_Mn_Mnu_Key, RTRIM(B.BT_Treeid) + RIGHT('00000' + RTRIM(A.tm_Mn_Mnu_Key),5),A.tm_Mnu_Id,A.tm_Mnu_Swf
            ,@Sesid,'BT'
        FROM #tm_Menu_Details A, #tm_Menu_Tree_Build B
        WHERE A.tm_parent_id= B.BT_Mn_Mnu_Key AND A.tm_Mn_Lvl_No = 2
            and Rtrim(tm_sessid)=@Sesid and tm_Trs_Flg='P_ID'
            and Rtrim(BT_sessid)=@Sesid  and BT_Trs_Flg='BT';
        
       INSERT INTO #tm_Menu_Tree_Build 
             (BT_MN_LVL_NO ,BT_MN_MNU_NM ,BT_Mn_Mnu_Key ,BT_Parant_id,BT_Treeid,BT_Mnu_Id ,BT_Mnu_Swf,BT_sessid,BT_Trs_Flg)
        SELECT 
            A.tm_MN_LVL_NO, A.tm_MN_MNU_NM, A.tm_Mn_Mnu_Key, B.BT_Mn_Mnu_Key, RTRIM(B.BT_Treeid) + RIGHT('00000' + RTRIM(A.tm_Mn_Mnu_Key),5),A.tm_Mnu_Id,A.tm_Mnu_Swf
            ,@Sesid,'BT'
        FROM #tm_Menu_Details A, #tm_Menu_Tree_Build B
        WHERE A.tm_parent_id= B.BT_Mn_Mnu_Key AND A.tm_Mn_Lvl_No = 3
            and Rtrim(tm_sessid)=@Sesid and tm_Trs_Flg='P_ID'
            and Rtrim(BT_sessid)=@Sesid  and BT_Trs_Flg='BT';

         INSERT INTO #tm_Menu_Tree_Build 
            (BT_MN_LVL_NO ,BT_MN_MNU_NM ,BT_Mn_Mnu_Key ,BT_Parant_id,BT_Treeid,BT_Mnu_Id ,BT_Mnu_Swf,BT_sessid,BT_Trs_Flg)
        SELECT 
            A.tm_MN_LVL_NO, A.tm_MN_MNU_NM, A.tm_Mn_Mnu_Key, B.BT_Mn_Mnu_Key, RTRIM(B.BT_Treeid) + RIGHT('00000' + RTRIM(A.tm_Mn_Mnu_Key),5),A.tm_Mnu_Id,A.tm_Mnu_Swf
            ,@Sesid,'BT'
        FROM #tm_Menu_Details A, #tm_Menu_Tree_Build B
        WHERE A.tm_parent_id= B.BT_Mn_Mnu_Key AND A.tm_Mn_Lvl_No = 4
            and Rtrim(tm_sessid)=@Sesid and tm_Trs_Flg='P_ID'
            and Rtrim(BT_sessid)=@Sesid  and BT_Trs_Flg='BT';

			---NO ACCESS MENU TREE ID 		
			SELECT BT_TREEID AS 'EX_TREE'
			INTO #TEM_EXTree
			 FROM #tm_Menu_Tree_Build ,symenu
			WHERE 
			SUBSTRING(MN_MNU_NM,1,1) <> '-'  
					AND SUBSTRING(mn_mnu_str,@Grp_Ref_Id,1)=0  
					--and SUBSTRING(mn_mnu_str,@Grp_Ref_Id,1) not in ('0' , 'X')
			AND BT_MN_LVL_NO=CASE MN_LVL_NO WHEN 'M00' THEN '1' WHEN 'M01' THEN '2' WHEN 'M02' THEN '3' WHEN 'M03' THEN '4' END 
			 AND BT_MN_MNU_NM=MN_MNU_NM AND BT_Mn_Mnu_Key=Mn_Mnu_Key
			 
        
            INSERT INTO #tm_Menu_Tree_Build (BT_MNU_XML,BT_Treeid,BT_Mn_Mnu_Key,BT_sessid,BT_Trs_Flg )
            SELECT '<root><node label="ABIS" SwfF="Abis_DashBoard.swf" Sid="0">','00000',0,@Sesid,'M_XML' 

            INSERT INTO #tm_Menu_Tree_Build (BT_MNU_XML,BT_Treeid,BT_Mn_Mnu_Key,BT_sessid,BT_Trs_Flg )
            SELECT '</node></root>','9999999A',0,@Sesid,'M_XML' 


            INSERT INTO #tm_Menu_Tree_Build (BT_MNU_XML,BT_Treeid,BT_Mn_Mnu_Key,BT_sessid,BT_Trs_Flg )
            Select 
            '<node label="'+RTRIM(BT_MN_MNU_NM)+'" SwfF="'+RTRIM(BT_Mnu_Swf)+'" Sid="'+RTRIM(BT_Mnu_Id)+'" >',BT_Treeid,BT_Mn_Mnu_Key
            ,@Sesid,'M_XML'
            FROM  #tm_Menu_Tree_Build
            WHERE Rtrim(BT_sessid)=@Sesid  and BT_Trs_Flg='BT'  
					AND NOT EXISTS(Select Null from   #TEM_EXTree  
						where BT_TREEID   like EX_TREE+'%' )  
            order by BT_Mn_Mnu_Key;
      
            INSERT INTO #tm_Menu_Tree_Build (BT_MNU_XML,BT_Treeid,BT_Mn_Mnu_Key,BT_sessid,BT_Trs_Flg )
            Select 
            '</node>',RTRIM(BT_Treeid)+'A',BT_Mn_Mnu_Key,@Sesid,'M_XML'
            FROM  #tm_Menu_Tree_Build
            WHERE Rtrim(BT_sessid)=@Sesid  and BT_Trs_Flg='BT'  
					AND NOT EXISTS(Select Null from   #TEM_EXTree  
						where BT_TREEID   like EX_TREE+'%' )  
            order by BT_Mn_Mnu_Key;
            
		SELECT  BT_MNU_XML AS "MenuXml"   from #tm_Menu_Tree_Build where BT_Trs_Flg='M_XML' order by BT_TREEID;
			
			--SELECT 
			--	Menu_Id,Menu_Name,Row_Number()OVER(Order by Menu_Id) AS 'M_Ord'  
			--INTO #TEM_Menu_Header
			--FROM Menu_Header WITH (NOLOCK)

			--SELECT @LopCnt=COUNT(*) FROM #TEM_Menu_Header
			
			--WHILE @Lop_St<=@LopCnt
			--BEGIN
			--	SET @nodeStr=''
			--	SELECT 
			--		@nodeStr=@nodeStr+'<node label="'+RTRIM(Screen_Nm)+'" SwfF="'+RTRIM(SwfFile)+'"  Sid="' +RTRIM(ISNULL(SCreen_ID,0))+ '" />'
			--	FROM 
			--	#TEM_Menu_Header
			--	JOIN  Screen_Details WITH (NOLOCK) ON Menu_Id=Menu_RId
			--	WHERE M_Ord=@Lop_St ORDER BY Screen_order
				
			--	SELECT 
			--		@MenuStr=@MenuStr+'<node label="'+RTRIM(Menu_Name)+'" >' +@nodeStr+'</node>'
			--	FROM #TEM_Menu_Header 
			--	WHERE M_Ord=@Lop_St
				
			--	SET @Lop_St=@Lop_St+1
			--END
			
			--SELECT '<root><node label="ABIS" SwfF="Abis_DashBoard.swf" Sid="0">'+@MenuStr+'</node></root>' AS 'MenuXml'
		 
	END 
END 








GO
