USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Support_Testing_PBI]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[Support_Testing_PBI]
AS
BEGIN

-- Exec [dbo].[Support_Testing_PBI]

 --Select Distinct TicketStatus from Support.TicketHistory


select TicketId,cast(HH_replay1 as varchar(50))  +':'+cast(MM_replay1 as varchar(50))+':'+cast(SS_replay1 as varchar(50)) AS replay1,
cast(HH_replay2 as varchar(50))  +':'+cast(MM_replay2 as varchar(50))+':'+cast(SS_replay2 as varchar(50)) AS replay2,
cast(HH_Above as varchar(50))  +':'+cast(MM_Above as varchar(50))+':'+cast(SS_Above as varchar(50)) AS Above,
UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,CreatedDate,Year,Month,MonthOrder
,Unread,Opend,Replied,Closed,ReOpen,[Total Count]
 from 
(
select isnull(sum(HH_replay1),0)HH_replay1,isnull(sum(MM_replay1),0)MM_replay1,isnull(SUm(SS_replay1),0)SS_replay1,
isnull(sum(HH_replay2),0)HH_replay2,isnull(sum(MM_replay2),0)MM_replay2,isnull(SUm(SS_replay2),0)SS_replay2,
isnull(sum(HH_Above),0)HH_Above,isnull(sum(MM_Above),0)MM_Above,isnull(SUm(SS_Above),0)SS_Above,
UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,TicketId
,     Left(datename(MONTH,CreatedDate),3)+'-'+Right(Year(CreatedDate),2) as 'Month',Year(CreatedDate) Year,
  Case When Len(month(CreatedDate))=1 then Cast(Concat(YEAR(CreatedDate),'1',month(CreatedDate)) As Int) Else cast(Concat(YEAR(CreatedDate),month(CreatedDate)+10) As int) End As MonthOrder

,CreatedDate,Case when TicketStatusString='Unread' then Count(Distinct TicketsNumber) end as 'Unread',
		 Case when TicketStatusString='Open' then Count(Distinct TicketsNumber) end as 'Opend',
		 Case when TicketStatusString='Replied' then Count(Distinct TicketsNumber) end as 'Replied',
		 Case when TicketStatusString='Closed' then Count(Distinct TicketsNumber) end as 'Closed',
		 Case when TicketStatusString='Reopen' then Count(Distinct TicketsNumber) end as 'Reopen',
		 Count(Distinct TicketsNumber) 'Total Count'



 from 
(
select  ( isnull (case when Reposnes='1st_Replay' then isnull(sum(isnull(Hourse,0)),0) end,0)) as HH_replay1,
(ISNULL(case when Reposnes='1st_Replay' then isnull(sum(isnull(MMM,0)),0) end,0)) as MM_replay1,
(iSNULL(case when Reposnes='1st_Replay' then isnull(sum(isnull(SSS,0)),0) end,0)) as SS_replay1,

ISNULL(case when Reposnes='2st_Replay' then isnull(sum(isnull(Hourse,0)),0) end,0) as HH_replay2,
isnull(case when Reposnes='2st_Replay' then isnull(sum(isnull(MMM,0)),0) end,0) as MM_replay2,
isnull(case when Reposnes='2st_Replay' then isnull(sum(isnull(SSS,0)),0) end,0) as SS_replay2,

isnull(case when Reposnes='Above' then isnull(sum(isnull(Hourse,0)),0) end,0) as HH_Above,
isnull(case when Reposnes='Above' then isnull(sum(isnull(MMM,0)),0) end,0) as MM_Above,
isnull(case when Reposnes='Above' then isnull(sum(isnull(SSS,0)),0) end,0) as SS_Above,
--Convert(varchar(50),Hourse)+':'+convert(varchar(50),MMM)+':'+convert(varchar(50),SSS) AS TotalHours,
UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,TicketId,CreatedDate

 from 
(
select TicketId,isnull(HH_repones1,0)+isnull(HH_repones2,0)+isnull(HH_Above,0) AS Hourse,isnull(mm_repones1,0)+isnull(MM_repones2,0)+isnull(MM_Above,0) as MMM,
isnull(SS_repones1,0)+isnull(SS_repones2,0)+isnull(SS_Above,0)AS SSS,
UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,Reposnes,CreatedDate
 from
(
select TicketId,sum(isnull(HH_repones1,0))HH_repones1,sum(isnull(mm_repones1,0))mm_repones1,sum(isnull(SS_repones1,0))SS_repones1,
sum(isnull(HH_repones2,0))HH_repones2,sum(isnull(MM_repones2,0))MM_repones2,sum(isnull(SS_repones2,0))SS_repones2,
sum(isnull(HH_Above,0))HH_Above,sum(isnull(MM_Above,0))MM_Above,sum(isnull(SS_Above,0))SS_Above,
UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,Reposnes,CreatedDate
 from 
(
select  Distinct TicketId,Reposnes,
Case when Reposnes='1st_Replay' then isnull(sum(cast(HH as int)),0) end HH_repones1,
Case when Reposnes='1st_Replay' then isnull(sum(cast(mm as int)),0) end MM_repones1,
Case when Reposnes='1st_Replay' then isnull(sum(cast(ss as int)),0) end SS_repones1,

Case when Reposnes='2st_Replay' then isnull(sum(cast(HH as int)),0) end HH_repones2,
Case when Reposnes='2st_Replay' then isnull(sum(cast(mm as int)),0) end MM_repones2,
Case when Reposnes='2st_Replay' then isnull(sum(cast(ss as int)),0) end SS_repones2,

Case when Reposnes='Above' then isnull(sum(cast(HH as int)),0) end HH_Above,
Case when Reposnes='Above' then isnull(sum(cast(mm as int)),0) end MM_Above,
Case when Reposnes='Above' then isnull(sum(cast(ss as int)),0) end SS_Above,

UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,CreatedDate

from
(
select Rank,Case when Rank=1 then '1st_Replay'
when Rank=2 then '2st_Replay'
when rank<15 then 'Above' end as Reposnes,TicketId,aa.UserId,aa.CompanyId,
isnull(Convert(varchar(50),SUM(Cast(HH as int))),0) HH,isnull(COnvert(varchar(50),SUM(Cast(MiN AS int))),0) MM,
isnull(Convert(varchar(50),SUM(Cast(SS AS int))),0) SS ,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,Aa.UserCreated,Priority,CreatedDate
--,FirstName,Username,CompanyName,PaternerCompane
 from 
(
select Rank,ticketid,CompanyId,

 case when TicketStatus='Unread' and rank=1 then 'Unread'
      when TicketStatus='Unread' and rank=2 then 'C1_Unread'
      when TicketStatus='Unread' and rank=3 then 'C2_Unread'
      when TicketStatus='Unread' and rank=4 then 'C3_Unread'
      when TicketStatus='Unread' and rank=5 then 'C4_Unread'
      when TicketStatus='Unread' and rank=6 then 'C5_Unread'
      when TicketStatus='Unread' and rank=7 then 'C6_Unread'
	  when TicketStatus='Unread' and rank=8 then 'C7_Unread'
	  when TicketStatus='Unread' and rank=9 then 'C8_Unread'
	  when TicketStatus='Unread' and rank=10 then 'C9_Unread'
	  when TicketStatus='Unread' and rank=11 then 'C10_Unread'
	  when TicketStatus='Unread' and rank=12 then 'C11_Unread'
	  when TicketStatus='Unread' and rank=13 then 'C12_Unread'
      when TicketStatus='Unread' and rank=14 then 'C13_Unread'
	  when TicketStatus='Unread' and rank=15 then 'C14_Unread' end AS Unread,

 case when TicketStatus='Open' and rank=1 then 'Open'
      when TicketStatus='Open' and rank=2 then 'C1_Open'
      when TicketStatus='Open' and rank=3 then 'C2_Open'
      when TicketStatus='Open' and rank=4 then 'C3_Open'
      when TicketStatus='Open' and rank=5 then 'C4_Open'
      when TicketStatus='Open' and rank=6 then 'C5_Open'
      when TicketStatus='Open' and rank=7 then 'C6_Open'
	  when TicketStatus='Open' and rank=8 then 'C7_Open'
	  when TicketStatus='Open' and rank=9 then 'C8_Open'
	  when TicketStatus='Open' and rank=10 then 'C9_Open'
	  when TicketStatus='Open' and rank=11 then 'C10_Open'
	  when TicketStatus='Open' and rank=12 then 'C11_Open'
	  when TicketStatus='Open' and rank=13 then 'C12_Open'
      when TicketStatus='Open' and rank=14 then 'C13_Open'
	  when TicketStatus='Open' and rank=15 then 'C14_Open' end AS 'Open',

case when TicketStatus='Replied' and rank=1 then 'Replied'
      when TicketStatus='Replied' and rank=2 then 'C1_Replied'
      when TicketStatus='Replied' and rank=3 then 'C2_Replied'
      when TicketStatus='Replied' and rank=4 then 'C3_Replied'
      when TicketStatus='Replied' and rank=5 then 'C4_Replied'
      when TicketStatus='Replied' and rank=6 then 'C5_Replied'
      when TicketStatus='Replied' and rank=7 then 'C6_Replied'
	  when TicketStatus='Replied' and rank=8 then 'C7_Replied'
	  when TicketStatus='Replied' and rank=9 then 'C8_Replied'
	  when TicketStatus='Replied' and rank=10 then 'C9_Replied'
	  when TicketStatus='Replied' and rank=11 then 'C10_Replied'
	  when TicketStatus='Replied' and rank=12 then 'C11_Replied'
	  when TicketStatus='Replied' and rank=13 then 'C12_Replied'
      when TicketStatus='Replied' and rank=14 then 'C13_Replied'
	  when TicketStatus='Replied' and rank=15 then 'C14_Replied' end AS Replied,

case when TicketStatus='Closed' and rank=1 then 'Closed'
      when TicketStatus='Closed' and rank=2 then 'C1_Closed'
      when TicketStatus='Closed' and rank=3 then 'C2_Closed'
      when TicketStatus='Closed' and rank=4 then 'C3_Closed'
      when TicketStatus='Closed' and rank=5 then 'C4_Closed'
      when TicketStatus='Closed' and rank=6 then 'C5_Closed'
      when TicketStatus='Closed' and rank=7 then 'C6_Closed'
	  when TicketStatus='Closed' and rank=8 then 'C7_Closed'
	  when TicketStatus='Closed' and rank=9 then 'C8_Closed'
	  when TicketStatus='Closed' and rank=10 then 'C9_Closed'
	  when TicketStatus='Closed' and rank=11 then 'C10_Closed'
	  when TicketStatus='Closed' and rank=12 then 'C11_Closed'
	  when TicketStatus='Closed' and rank=13 then 'C12_Closed'
      when TicketStatus='Closed' and rank=14 then 'C13_Closed'
	  when TicketStatus='Closed' and rank=15 then 'C14_Closed' end AS Closed,

	  case when TicketStatus='Reopen' and rank=1 then 'Reopen'
      when TicketStatus='Reopen' and rank=2 then 'C1_Reopen'
      when TicketStatus='Reopen' and rank=3 then 'C2_Reopen'
      when TicketStatus='Reopen' and rank=4 then 'C3_Reopen'
      when TicketStatus='Reopen' and rank=5 then 'C4_Reopen'
      when TicketStatus='Reopen' and rank=6 then 'C5_Reopen'
      when TicketStatus='Reopen' and rank=7 then 'C6_Reopen'
	  when TicketStatus='Reopen' and rank=8 then 'C7_Reopen'
	  when TicketStatus='Reopen' and rank=9 then 'C8_Reopen'
	   when TicketStatus='Reopen' and rank=10 then 'C9_Reopen'
	  when TicketStatus='Reopen' and rank=11 then 'C10_Reopen'
	  when TicketStatus='Reopen' and rank=12 then 'C11_Reopen'
	  when TicketStatus='Reopen' and rank=13 then 'C12_Reopen'
      when TicketStatus='Reopen' and rank=14 then 'C13_Reopen'
	  when TicketStatus='Reopen' and rank=15 then 'C14_Reopen' end AS Reopen,

	convert(varchar(5),DateDiff(s, CreatedDate, TktHistory)/3600) HH,convert(varchar(5),DateDiff(s,CreatedDate, TktHistory)%3600/60) 'MIN',
	convert(varchar(5),(DateDiff(s,CreatedDate, TktHistory)%60)) as SS,
	convert(varchar(5),DateDiff(s, CreatedDate, TktHistory)/3600)+':'+convert(varchar(5),DateDiff(s,CreatedDate,TktHistory)%3600/60)+':'+convert(varchar(5),(DateDiff(s, CreatedDate, TktHistory)%60)) as [hh:mm:ss],
	CursorName,TicketCategoryId,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,CategoryName,UserId,CreatedDate

 from 
(
select  Rank,ticketid,p.TicketStatus,TktHistory,t.CompanyId,t.CreatedDate,CursorName,TicketCategoryId,Subject,IsUnRead,TicketsNumber,TicketStatusString,t.UserCreated,Priority ,tc.Name AS CategoryName,UserId
from
  (
     SELECT RANK() OVER (PARTITION BY ticketid,TicketStatus ORDER BY createdDate ASC) AS Rank,ticketid,TicketStatus,CreatedDate as TktHistory
     FROM  Support.TicketHistory 

   --  order by createdDate

 ) P
inner join Support.Ticket  t on t.Id=p.TicketId
inner join Support.TicketCategory tc on tc.id=t.TicketCategoryId


)as AA
   )as Aa
    ---where TicketId='B4929CA0-151B-457F-8363-05F9CC923FA3'
  Group by TicketId,aa.CompanyId,Aa.Rank,
   CursorName,TicketCategoryId,Subject,IsUnRead,TicketsNumber,TicketStatusString,Aa.UserCreated,Priority,CategoryName,aa.UserId,Aa.CreatedDate--,PaternerCompane,FirstName,Username,CompanyName
   )as ll
 
 group by TicketId,UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,ll.Reposnes,CreatedDate--,FirstName,Username,CompanyName,PaternerCompane
 )as pp
  group by UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,TicketId,Reposnes,CreatedDate
  )as KK

)as t
group by UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,TicketId,Reposnes,CreatedDate
) as JJ
Group by UserId,CompanyId,CursorName,CategoryName,Subject,IsUnRead,TicketsNumber,TicketStatusString,UserCreated,Priority,TicketId,CreatedDate
 )as RR
 order by TicketId
   
   END
GO
