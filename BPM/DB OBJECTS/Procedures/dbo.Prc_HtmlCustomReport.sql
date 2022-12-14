USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[Prc_HtmlCustomReport]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE Proc [dbo].[Prc_HtmlCustomReport]

(

	@Action              Varchar(50)=null,
	@HeaderGridXml       Text = Null ,	
	@MasterXml           Text = Null ,
	@RowId               Varchar(50) = null , --New RowId.
	@OldRowId            Varchar(50) = null , -- Old RowId for edit mode.
	@DocRef              BigInt = Null,
	@DpdRef              BigInt = Null,
	@AddParam1           Text=Null,
	@AddParam2           Text=Null,
	@AddParam3           Text=Null
)

As

Begin

	Set noCount on;

	/*Variable Declaration Part*/

	DECLARE @TranCount INT ,@ErrMsg Varchar(8000),@Flag varchar(50),@XmlId int,@FilterVal varchar(500),
	@reportType varchar(50),@userId bigint,@param varchar(max),@param1 varchar(500),@param2 varchar(1000),@updateState bigint

	/*Variable Declaration Part Ends*/

	/*Temp Table and Table variable(# and @) Createion/Declaration Part*/

	Declare @TabVar Table (id bigint)

	/*Temp Table and Table variable(# and @) Createion/Declaration Part*/

	--Transaction Count Check

	IF @@TranCount=0

	 	SET @TranCount=1

	BEGIN TRY

		/*Un Wrap dats from XML,Temp Tables etc..*/

		/*Un Wrap dats from XML,Temp Tables etc.. Ends*/

		/*Validation Part*/

		/*Validation Part Ends*/

		--Transaction Starts

		IF @TRANCOUNT = 1

		begin

			BEGIN TRAN

		end

		--Manual Error raise

		If 1 = 2

			Raiserror('Manual error.',16,1)

		--Add Mode
		if @Action='1'
		begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportType
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportType varchar(300)					 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 	
			
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @MasterXml	
				select @userId=1
				/*select @userId= UserId
				From    Openxml(@XmlId, 'xml', 2) With
						(
							UserId bigint
						)  */
			Exec SP_XML_REMOVEDOCUMENT @XmlId 		

			
			select hp_rpt_nm,hp_typ,hp_unq_id from cs_Html_Pvt 
			/*if @reportType='TL0028'
				begin
				
					/*set @param2=(select grp.UG_GRP_PID from syusrgrp grp where grp.UG_GRP_PID=(select usr.up_grp_pid from SYUSRPRF usr where up_usr_pid=@param1))
					set @param2=@q_id -- this is used only for substring purpose
					select hp_rpt_nm,hp_typ,hp_unq_id 
					From symenu , cs_html_pvt 
					where substring(MN_MNU_STR,@q_id ,1) not in ('X' , '0')
					and Mn_Mnu_pid = HP_UNQ_ID and HP_TYP in (1000 , 1100);*/
			
					select hp_rpt_nm,hp_typ,hp_unq_id from cs_Html_Pvt where Hp_Typ in(1100,1000)
				end

			if @reportType='TL0030'
				select hp_rpt_nm,hp_typ,hp_unq_id from cs_Html_Pvt where Hp_Typ in(1101,1001)
			if @reportType='TL0029'
				select hp_rpt_nm,hp_typ,hp_unq_id from cs_Html_Pvt where Hp_Typ in(1102,1002)
			if @reportType='TL0032'
				select hp_rpt_nm,hp_typ,hp_unq_id from cs_Html_Pvt where Hp_Typ in(1103,1003)*/
		end
		if @Action='2'
		begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportId
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportId varchar(300)					 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 
			
			select HP_Rpt_Ori,isnull(hp_rpt_cust_ori,'') hp_rpt_cust_ori  from cs_Html_Pvt where HP_Rpt_Nm= @reportType	
		end
		
		if @Action='7'
		begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportType
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportType varchar(300)	
							
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 
			
			update  cs_html_pvt
			set HP_Rpt_Ori=@AddParam1
			where Hp_Unq_Id=@reportType

			select 'SUCCESS' as 'MESSAGE'

		end

		if @Action='8'
		begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportType
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportType varchar(300)	
							
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 
			
			update  cs_html_pvt
			set HP_Rpt_Ori=@AddParam2,
				hp_rpt_cust_ori=@AddParam1
			where Hp_Unq_Id=@reportType

			select 'SUCCESS' as 'MESSAGE'

		end

		if @Action='10'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportType,@param1=ReportName,@param=Query,@updateState=UpdateReport
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportName varchar(300)	,
							Query varchar(max)	,
							ReportType varchar(25),
							UpdateReport bigint
										 
		 				) 
	
				if(@updateState=0)
					begin
						Insert into cs_html_pvt(HP_Rpt_Nm,HP_Rpt_Qry,HP_Rpt_Ori,Hp_Typ)
						select @param1,@param,@AddParam1,@reportType
					end
				else
					begin
						update  cs_html_pvt
						set HP_Rpt_Nm=@param1,
							HP_Rpt_Qry=@param,
							HP_Rpt_Ori=@AddParam1
						where Hp_Unq_Id=@updateState

					end				


			Exec SP_XML_REMOVEDOCUMENT @XmlId 

			select hp_rpt_qry 'QUERY' from cs_html_pvt where hp_unq_id=@reportType
		end
		

		if @Action='12'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportId
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportId varchar(300)					 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 

			select hp_rpt_qry 'QUERY' from cs_html_pvt where hp_unq_id=@reportType
		end
		if @Action='13'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportType,@param1=ReportName,@param=Query,@updateState=UpdateReport
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportName varchar(300)	,
							Query varchar(max)	,
							ReportType varchar(25),
							UpdateReport bigint
										 
		 				) 
	
				if(@updateState=0)
					begin
						Insert into cs_html_pvt(HP_Rpt_Nm,HP_Rpt_Qry,HP_Rpt_Ori,Hp_Typ)
						select @param1,@param,@AddParam1,@reportType
					end
				else
					begin
						update  cs_html_pvt
						set HP_Rpt_Nm=@param1,
							HP_Rpt_Qry=@param,
							HP_Rpt_Ori=@AddParam1
						where Hp_Unq_Id=@updateState

					end				


			Exec SP_XML_REMOVEDOCUMENT @XmlId 

			select hp_rpt_qry 'QUERY' from cs_html_pvt where hp_unq_id=@reportType
		end
		if @Action='15'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @param1=ReportId
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportId varchar(300)		
							
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 
			
			select  HP_RPT_ORI,HP_RPT_QRY from cs_html_pvt where hp_unq_id=@param1
		end


		if @Action='17'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportId
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportId varchar(300)					 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 

			select @param=HP_RPT_QRY from cs_html_pvt where hp_unq_id=@reportType
			select SUBSTRING(@param, PATINDEX('%from%', @param), len(@param)) 'QUERY'


		end
		
		
		if @Action='18'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportType,@param1=SearchQuery
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportType varchar(300)	,	
							SearchQuery varchar(500)			 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 
			
			SELECT HP_RPT_NM,Hp_Typ,Hp_Unq_Id FROM CS_HTML_PVT WHERE HP_RPT_NM LIKE '%'+@param1 +'%' AND HP_TYP=(select  cast(@reportType as int )  )
			
		
		end
		if @Action='19'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @reportType=ReportType
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportType varchar(300)					 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 

			SELECT HP_RPT_NM,Hp_Typ,Hp_Unq_Id FROM CS_HTML_PVT WHERE  HP_TYP=(select  cast(@reportType as bigint )  )
		
		end

		if @Action='23'
		Begin
		/*	Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @param=XmlText
				From    Openxml(@XmlId, 'xml', 2) With
						(
							XmlText varchar(300)					 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId */

			set @param=@HeaderGridXml;

			select @param=replace(@param,'a!b@c$','"')
			exec Pr_HTMLTree_Rpt @param
		
		end
		if @Action='24'
		Begin
		/*	Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @param=XmlText
				From    Openxml(@XmlId, 'xml', 2) With
						(
							XmlText varchar(300)					 
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId */

			set @param=@HeaderGridXml;			
			exec (@param)
		
		end
		if @Action='25'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @param1=ReportType,@param2=ReportName,@reportType=ReportId
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportType varchar(300),		
							ReportName varchar(500),
							ReportId varchar(10)
							
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 
			
			insert into cs_html_pvt(hp_rpt_nm,hp_rpt_ori,hp_typ,hp_rpt_cust_ori,hp_rpt_qry)
			select @param2,@AddParam1,@param1,@AddParam2,hp_rpt_qry
			from cs_html_pvt
			where Hp_Unq_Id=@reportType

		end
		if @Action='26'
		Begin
			Exec SP_XML_PREPAREDOCUMENT @XmlId OUTPUT, @HeaderGridXml	
				select @param1=ReportType,@param2=ReportName,@reportType=ReportId
				From    Openxml(@XmlId, 'xml', 2) With
						(
							ReportType varchar(300),		
							ReportName varchar(500),
							ReportId varchar(10)
							
		 				) 
			Exec SP_XML_REMOVEDOCUMENT @XmlId 
			
			insert into cs_html_pvt(hp_rpt_nm,hp_rpt_ori,hp_rpt_qry,hp_typ) 
			select @param2,@AddParam1,hp_rpt_qry,@param1
			from cs_html_pvt
			where Hp_Unq_Id=@reportType

		end
		

		-- Transaction Ends

		IF @TRANCOUNT = 1 and @@TranCount = 1

			Commit TRAN

	END TRY

	BEGIN CATCH

		IF @TRANCOUNT = 1 and @@TranCount = 1

			Rollback TRAN

		DECLARE @ErrSeverity int

		SELECT @ErrMsg = ERROR_MESSAGE() + ',' + ERROR_PROCEDURE() + ':' + RTrim(ERROR_LINE()),

			 @ErrSeverity = ERROR_SEVERITY()

		Raiserror(@ErrMsg, @ErrSeverity, 1)

		Return

	End Catch

	

End









GO
