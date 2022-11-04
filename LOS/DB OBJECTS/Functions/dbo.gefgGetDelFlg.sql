CREATE Function dbo.gefgGetDelFlg(@tDt datetime)
Returns char(14)
--with encryption
as
Begin

/*

Purpose		: To get the Del Flag with seconds
Spl. Comments	: 
Remarks		: 
*/

 declare @retDt char(25)
 select @retdt=convert(char(25), @Tdt,121)
 select @retdt = substring(substring(@retdt,1,4)+substring(@retdt,6,2)+substring(@retdt,9,2)+substring(@retdt,12,2)+substring(@retdt,15,2)+substring(@retdt,18,2)+substring(@retdt,21,3),1,15)
 Return(@retdt)
End