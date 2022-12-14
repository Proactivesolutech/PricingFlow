USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[Loln_sp_bouncesupdate]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[Loln_sp_bouncesupdate](@asondate  DATETIME)
                                                    
AS
BEGIN
       --DECLARE @Asondate DATEtime ='2016-07-31'

	   Declare @date datetime =CONVERT(DATETIME, Substring(CONVERT(VARCHAR(15), CONVERT(DATE, CONVERT(VARCHAR(20), @asondate))), 1, 7) + '-07')

          DECLARE @filename VARCHAR(15)
          DECLARE @qry VARCHAR(max)
		  DECLARE @qry1 VARCHAR(max)


		  IF Object_id('tempdb..#bounces_total') IS NOT NULL
             DROP TABLE #bounces_total

			 CREATE TABLE #bounces_total
              (
			  pk_id int identity(1,1),
			  lnno    varchar(15),
			  chq_receiv   varchar(1)
			  )
			  INSERT INTO #bounces_total (lnno)
			  select LnNo from lgen_lnpdcdet  where InstDueDt = @date
			  union all
			  select LnNo from LGEN_LNecstran  where InstDate= @date
			  union all
			  select lnno from LGen_LnNACHTran  where InstDate = @date
			  union all
			  select LnNo from LGen_LnInstClln_h  a join LGen_LnInstCllnInstr_d b on  a.PK_Id = b.InstCllnHdr_FK
              where RcptMode='B' and ScreenID='30120223' and  EffDt = @date

			  update #bounces_total set chq_receiv = 'Y'

			 IF Object_id('tempdb..#bounces_cases') IS NOT NULL
               DROP TABLE #bounces_cases
             
			  CREATE TABLE #bounces_cases
              (
			  pk_id int identity(1,1),
			  lnno    varchar(15),
			  chq_bounc   varchar(1)
			  )

			  INSERT INTO #bounces_cases (lnno)
			  select lnno from lgen_lnpdcdet  where InstDueDt= @date and ChqDis='Y'
			  union all
			  select LnNo from LGEN_LNecstran  where InstDate= @date and ChqDis='Y'
			  union all
			  select LnNo from LGen_LnNACHTran  where InstDate= @date and ChqDis='Y'
			  union all
			  select LnNo from LGen_LnInstClln_h  a join LGen_LnInstCllnInstr_d b on  a.PK_Id = b.InstCllnHdr_FK
              where RcptMode='B' and ScreenID='30120223' and  EffDt = @date and isnull(ChqStat,'')='D'

			   update #bounces_cases set chq_bounc = 'Y'

          SET @filename = CONVERT(VARCHAR, @Asondate, 112)
          SET @qry = ( 'Update shfl_cms..collection_master_' + @filename  + ' set chq_received = b.chq_receiv from shfl_cms..collection_master_' + @filename  +
		   ' a join #bounces_total b on a.[Loan A/C No] = b.lnno ')

		    SET @qry1 = ( 'Update shfl_cms..collection_master_' + @filename  + ' set chq_bounced = b.chq_bounc from shfl_cms..collection_master_' + @filename  +
		   ' a join #bounces_cases b on a.[Loan A/C No] = b.lnno ')
		   
          EXEC(@qry)
		  EXEC(@qry1)

END


		  



GO
