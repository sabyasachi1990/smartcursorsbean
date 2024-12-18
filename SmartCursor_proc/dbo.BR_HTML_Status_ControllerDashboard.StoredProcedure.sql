USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_HTML_Status_ControllerDashboard]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[BR_HTML_Status_ControllerDashboard]  
 @FromDate Datetime,  
 @ToDate Datetime,  
 @CompanyId BIGINT,  
 @Role varchar(100) 

 -- EXEC [dbo].[BR_HTML_Status_ControllerDashboard] '2020-01-01','2020-05-01',689,null

 AS  
 BEGIN  
 SET @ToDate = CONVERT(DATETIME, CONVERT(varchar(11),@ToDate, 103 ) + ' 23:59:59', 103)

 
-- Status KPI's


Select SUM(Approved) Approved,SUM(Opens) 'Open',Sum([For Review]) 'For Review',
Sum(Cancelled) Cancelled,Sum(Completed) Completed
from
(

Select Case When CH.Status='Approved' and IsCurrentstate=1 then Count(CH.DocumentId) end as 'Approved',
	   Case When CH.State='Draft' and IsCurrentstate=1 then Count(CH.DocumentId) end as 'Draft',
	   Case When CH.Status='Open' and IsCurrentstate=1 then Count(CH.DocumentId) end as 'Opens',
	   Case When CH.Status='For Review' and IsCurrentstate=1 then Count(CH.DocumentId) end as 'For Review',
	   Case When CH.Status='Cancelled' and IsCurrentstate=1 then Count(CH.DocumentId) end as 'Cancelled',
	   Case When CH.Status='Completed' and IsCurrentstate=1 then Count(CH.DocumentId) end as 'Completed',
	   Case when ExistingCompany in ('New','Existing') then ED.CreatedDate 
	        when ExistingCompany='Takeover' then TakeOverDate end as Date,ED.CompanyId

from Common.ChangesHistory CH
Inner Join Common.EntityDetail ED on ED.Id=CH.DocumentId

where IsCurrentstate<>0 --EntityId
Group By CH.Status,CH.State,IsCurrentstate,ExistingCompany,ED.CreatedDate,TakeOverDate,ED.CompanyId

) as AAY

Where CompanyId=@CompanyId and Date between @FromDate and @ToDate 


-- Status Left Side

--Declare @FromDate Datetime='2019-01-01',
--        @ToDate Datetime='2019-12-31'

Select Name,MonthYear,sum(Cnt) as 'Cnt',Status from
(

Select Case when Date=PP.CreatedDate then Sum(Cnt) else 0 end as 'Cnt',MONTH(CreatedDate) As Month,Year(CreatedDate) as 'Year',  
       Left(DateName(Month,CreatedDate),3)+'-'+ Right(year(CreatedDate),2) AS 'MonthYear',ExistingCompany as Name,Status from 
(
Select Case when CH.Status='Approved' and IsCurrentstate=1  then 'Approved'
		    When CH.State='Draft' and IsCurrentstate=1 then 'Draft'
			When CH.Status='Open' and IsCurrentstate=1 then 'Open'
		    When CH.Status='For Review' and IsCurrentstate=1 then 'For Review'
			When CH.Status='Cancelled' and IsCurrentstate=1 then 'Cancelled'
			When CH.Status='Completed' and IsCurrentstate=1 then 'Completed' end as 'Status',
	 COUNT (DocumentId) Cnt,Case when ExistingCompany in ('New','Existing') then ED.CreatedDate 
	        when ExistingCompany='Takeover' then TakeOverDate end as Date,ED.CompanyId,ED.ExistingCompany

from Common.ChangesHistory CH
Inner Join Common.EntityDetail ED on ED.Id=CH.DocumentId

where IsCurrentstate<>0 --EntityId
Group By CH.Status,CH.State,IsCurrentstate,ExistingCompany,ED.CreatedDate,TakeOverDate,ED.CompanyId,ED.ExistingCompany

) as AAD
 Cross JOIN  
      (  
	  
 SELECT  TOP (DATEDIFF(DAY, @FromDate, @Todate) + 1)
        CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate))
  FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b
  
    ) AS PP   
	Where CompanyId=@CompanyId and Date between @FromDate and @ToDate 
	Group By Date,ExistingCompany,PP.CreatedDate,Status

) as AAL

Group BY Name,Month,Year,MonthYear,Status
Order BY Year,Month

-- Status Right Side

--Declare @FromDate Datetime='2019-01-01',
--        @ToDate Datetime='2019-12-31'

Select Name,MonthYear,sum(Cnt) as 'Cnt' from
(

Select Case when Date=PP.CreatedDate then Sum(Cnt) else 0 end as 'Cnt',MONTH(CreatedDate) As Month,Year(CreatedDate) as 'Year',  
       Left(DateName(Month,CreatedDate),3)+'-'+ Right(year(CreatedDate),2) AS 'MonthYear',Status as Name from 
(
Select Case when CH.Status='Approved' and IsCurrentstate=1  then 'Approved'
		    When CH.State='Draft' and IsCurrentstate=1 then 'Draft'
			When CH.Status='Open' and IsCurrentstate=1 then 'Open'
		    When CH.Status='For Review' and IsCurrentstate=1 then 'For Review'
			When CH.Status='Cancelled' and IsCurrentstate=1 then 'Cancelled'
			When CH.Status='Completed' and IsCurrentstate=1 then 'Completed' end as 'Status',
	 COUNT (DocumentId) Cnt,Case when ExistingCompany in ('New','Existing') then ED.CreatedDate 
	        when ExistingCompany='Takeover' then TakeOverDate end as Date,ED.CompanyId,ED.ExistingCompany

from Common.ChangesHistory CH
Inner Join Common.EntityDetail ED on ED.Id=CH.DocumentId

where IsCurrentstate<>0 --EntityId
Group By CH.Status,CH.State,IsCurrentstate,ExistingCompany,ED.CreatedDate,TakeOverDate,ED.CompanyId,ED.ExistingCompany

) as AAD
 Cross JOIN  
      (  
	  
 SELECT  TOP (DATEDIFF(DAY, @FromDate, @Todate) + 1)
        CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate))
  FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b
  
    ) AS PP   
	Where CompanyId=@CompanyId and Date between @FromDate and @ToDate 
	Group By Date,PP.CreatedDate,Status

) as AAL

Group BY Name,Month,Year,MonthYear
Order BY Year,Month


 End
GO
