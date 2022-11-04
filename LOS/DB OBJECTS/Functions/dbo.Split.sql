/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 6/8/2016 10:23:04 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[Split](@String varchar(8000), @Delimiter char(1),@Type varchar(50))        
returns @temptable TABLE (items varchar(8000),Types varchar(50))        
as        
begin        
    declare @idx int        
    declare @slice varchar(8000)        
       
    select @idx = 1        
        if len(@String)<1 or @String is null  return        
       
    while @idx!= 0        
    begin        
        set @idx = charindex(@Delimiter,@String)        
        if @idx!=0        
            set @slice = left(@String,@idx - 1)        
        else        
            set @slice = @String        
           
        if(len(@slice)>0)   
            insert into @temptable(Items,Types) values(@slice,@Type)   
  
        set @String = right(@String,len(@String) - @idx)        
        if len(@String) = 0 break        
    end    
return    
end  


GO
