USE [BPM]
GO
/****** Object:  StoredProcedure [dbo].[Pr_HTMLTree_Rpt]    Script Date: 9/16/2017 2:14:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[Pr_HTMLTree_Rpt]
		(@param varchar(max) )
	as
	begin
	declare @xmlid int
	declare @row_count int
	declare @row1_count int
	declare @t_name varchar(max)
	declare @i_name varchar(max)
	declare @r1 varchar(max)
	declare @r2 varchar(max)
	declare @r3 varchar(max)
	declare @cast varchar(max)
	declare @rd varchar(20) 
	declare @sd varchar(20)
		declare @d1 varchar(max)
		declare @d2 varchar(max)
		declare @d3 varchar(max)
		declare @d4 varchar(max)
		declare @d5 varchar(max)
	declare @lv1 varchar(max)
	declare @lv2 varchar(max)
	declare @cnt int
	declare @q2 varchar(max)


	exec sp_xml_preparedocument @xmlid output , @param

	 create table #row1(Name varchar(max),QryFrom varchar(max),rowid int identity(1,1))
	 create table #row2(datcol varchar(max),datname varchar(max),roundval varchar(20), scaleval varchar(20),rowid int identity(1,1))

insert into #row1 select * from (select *   from openxml (@xmlid,'/XML/ColList/NODE')
	 with (Name varchar(max)))sub1,
(select *  from openxml (@xmlid,'/XML')
	 with (QryFrom varchar(max)))sub2


	 insert into #row2(datcol,datname,roundval,scaleval) select *  from openxml (@xmlid,'/XML/Datalist/NODE')
	 with (Name varchar(max),Field varchar(max),RoundVal int,ScaleVal int)
	 
	 
	 exec sp_xml_removedocument @xmlid
	
	 set @row1_count=(select count(rowid) from #row2)
	 print @row1_count
	 set @cnt=1
	 set @d1=''
	 set @d2=''
	 set @d3=''
	 set @d4=''
	 set @d5=''
	  while @cnt<= @row1_count
	  begin
	  set @d3=@cnt
		set @r1=(select datcol from #row2 where rowid=@cnt )
		set @r2=(select datname from #row2 where rowid=@cnt )
		set @rd=(select roundval from #row2 where rowid=@cnt )
		set @sd=(select scaleval from #row2 where rowid=@cnt )
--		print @r2
	--	print @rd
	print @sd
		set @cast='cast (('+@r2+')/'+@sd+' as decimal(27,'+@rd+'))'
		print @cast
		set @d1=@d1+',data'+@d3
		set @d2=@d2+','+@r1			
		set @d4=@d4+','+@cast +' as '+@r1 	
		set @d5=@d5+',data'+@d3+' as '+@r1	
		set @cnt=@cnt+1
	  end
	  print @d1
	  print @d2
	  print @d3
	  print @d4
	  print @d5
	  set @i_name=('insert into #tab1(field,idstring,name,parent,levels'+@d1+')')
	  print @i_name

	  --new
	set @row_count=( select count(name) from #row1)
	set @t_name=(select replace(QryFrom,'@|~D','''') from #row1 group by QryFrom )
	print @row_count 
	set @cnt=1
	create table #tab1(id int identity(1,1) primary key,idstring varchar(1000),field varchar(1000),Name varchar(500),parent varchar(500),levels Int , xtreeid varchar(2000),data1 varchar(500),data2 varchar(500),data3 varchar(500),data4 varchar(500),
	data5 varchar(500),data6 varchar(500),data7 varchar(500),data8 varchar(500),data9 varchar(500),data10 varchar(500),data11 varchar(500),data12 varchar(500),data13 varchar(500),data14 varchar(500),data15 varchar(500),data16 varchar(500),data17 varchar(500)
,
	data18 varchar(500),data19 varchar(500),data20 varchar(500))

	
 
		set @r1=(select rtrim(name) from #row1 where rowid=@cnt)
		set @r2=(select rtrim(name) from #row1 where rowid=@cnt+1)
		set @lv1=(select rowid from #row1 where name=@r1)
		set @lv2=(select rowid from #row1 where name=@r2)

	 exec( @i_name+'    select   '''+@r1+''',rtrim('+@r1 +'),rtrim('+@r1+'),0 ,'+@lv1+' '+@d4+'   '+@t_name +'  group by  '+@r1 )
	print @r1+'  boom'
	 
			set @q2=(@i_name+ ' select '''+@r2+''',#tab1.idstring +'':''+rtrim(sub2.'+@r2+' )  ,sub2.'+@r2+',#tab1.id,'+@lv2+' as levels '+@d4+'  from #tab1 join (select *  '+@t_name+') sub2 on #tab1.idstring=sub2.'+@r1+' group by #tab1.idstring,sub2.'+@r2+',#tab1.id')
			print @q2
			print @r2+' bing'
	  exec(@q2)
			set @cnt=2
			set @r3='rtrim(sub1.'+@r1+')'
				
 		
			while @cnt < @row_count
			begin

				set @r1=(select rtrim(name) from #row1 where rowid=@cnt)
				set @r2=(select rtrim(name) from #row1 where rowid=@cnt+1)
				set @r3=@r3+'+'':''+rtrim(sub1.'+@r1+')'
				set @lv2=(select rowid from #row1 where name=@r2)
			
				print @r1
				print @r2+' eeee '+@lv2 
				print @r3
				print @lv1
				print @lv2


				set @q2=( @i_name+'  select '''+@r2+''',#tab1.idstring +'':''+rtrim(sub1.'+@r2+'), sub1.'+@r2+',#tab1.id,'+@lv2+''+@d4+'   from #tab1 join (select * '+@t_name+') sub1 on #tab1.idstring='+@r3+' group by #tab1.idstring,sub1.'+@r2+',#tab1.id' )
				print @q2
		       exec( @q2) 
				set @cnt=@cnt+1
			end
	
		
	   create table #path(id int identity(1,1) primary key,tree varchar(max))

			set @row_count=(select count(name) from #row1)
			print @row_count
			

	 update #tab1 set xtreeid = id where levels = 1;
			set @lv1=1
		while @lv1<@row_count
		begin

			update currlevel set currlevel.xtreeid = parent.xtreeid + ':' + rtrim(currlevel.id)
			from #tab1 parent , #tab1 currlevel
			where parent.levels = @lv1 and currlevel.levels=@lv1+1 and parent.id = currlevel.parent;
			set @lv1 =@lv1+1
		end
		
			exec('SELECT     field,Name as disp,id,parent,levels,xtreeid '+@d5+' FROM      #tab1 ORDER BY  xtreeid')

				
	end



	

 





GO
