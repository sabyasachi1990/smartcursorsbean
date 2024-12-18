USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Sp_WorkingHours]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Exec Sp_WorkingHours 19,'madhu@yopmail.com'
CREATE Procedure [dbo].[Sp_WorkingHours]
@CompanyValue Int,
@username varchar(max)

As
Begin
Select Weekday,case 
                    When left(CONCAT(morningstart,' To ',MorningEnd),2)=00 then 'Non Working Day' Else CONCAT(morningstart,' To ',MorningEnd) End As MorningShift,
               Case 
			        When Left(Concat(EvngStart,' To ',Evngend),2)=00 then 'Non Working Day' Else Concat(EvngStart,' To ',Evngend) End As EveningShift
 from
(
--Select Name As CompanyName,Weekday,case when left(AMFromTime,2) <12 then concat(left(AMFromTime,2),' ','Am' ) end As morningstart ,
--                           case when left(AMToTime,2)>12 and left(AMToTime,2)<24 then concat(left(AMToTime,2),' ','Pm') Else concat(left(AMToTime,2),' ','Am') End As MorningEnd  ,
--						   Case when left(PMFromTime,2)>12 And left(PMFromTime,2)<24then CONCAT(left(PMFromTime,2),' ','Pm') Else CONCAT(left(PMFromTime,2),' ','Am') End As EvngStart,
--						   Case When left(PMToTime,2)<24 and left(PMToTime,2)>12 then concat(left(PMToTime,2),' ','Pm') End As Evngend,
--						   Case Weekday When 'Monday' Then 1 
--						                When 'Tuesday' Then 2
--						                When 'Wednesday' Then 3
--						                When 'Thursday' Then 4
--						                When 'Friday' Then 5 
--						                When 'Saturday' Then 6 
--						                When 'Sunday' Then 7 End As Weeknum 
--from common.WorkWeekSetUp As Wrk
--inner join Common.Company As C on C.id=Wrk.CompanyId where CompanyId=@CompanyValue 
Select /*Name As CompanyName,*/Weekday,case when left(AMFromTime,2) <12 then concat(left(AMFromTime,2),' ','Am' ) end As morningstart ,
                           case when left(AMToTime,2)>12 and left(AMToTime,2)<24 then concat(left(AMToTime,2),' ','Pm') Else concat(left(AMToTime,2),' ','Am') End As MorningEnd  ,
						   Case when left(PMFromTime,2)>12 And left(PMFromTime,2)<24then CONCAT(left(PMFromTime,2),' ','Pm') Else CONCAT(left(PMFromTime,2),' ','Am') End As EvngStart,
						   Case When left(PMToTime,2)<24 and left(PMToTime,2)>12 then concat(left(PMToTime,2),' ','Pm') End As Evngend,
						   Case Weekday When 'Monday' Then 1 
						                When 'Tuesday' Then 2
						                When 'Wednesday' Then 3
						                When 'Thursday' Then 4
						                When 'Friday' Then 5 
						                When 'Saturday' Then 6 
						                When 'Sunday' Then 7 End As Weeknum 
from common.WorkWeekSetUp where companyid=@CompanyValue and employeeid in (select id from  Common.Employee where CompanyId=@CompanyValue and Username=@username)

) As A  group by Weekday,
case When left(CONCAT(morningstart,' To ',MorningEnd),2)=00 then 'Non Working Day' Else CONCAT(morningstart,' To ',MorningEnd) End,
Case When Left(Concat(EvngStart,' To ',Evngend),2)=00 then 'Non Working Day' Else Concat(EvngStart,' To ',Evngend) End,Weeknum order by Weeknum

End
GO
