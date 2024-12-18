USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_HTML_Entity_ControllerDashboard]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Procedure [dbo].[BR_HTML_Entity_ControllerDashboard]  
 @FromDate Datetime,  
 @ToDate Datetime,  
 @CompanyId BIGINT,  
 @Role varchar(100) 

 -- EXEC [dbo].[BR_HTML_Entity_ControllerDashboard] '2020-01-01','2020-11-01',1,null

 AS  
 BEGIN  
 SET @ToDate = CONVERT(DATETIME, CONVERT(varchar(11),@ToDate, 103 ) + ' 23:59:59', 103)

 
 -- Entity KPI's

Select Isnull(Sum(Total),0) 'Total',Isnull(Sum(New),0) 'New',Isnull(Sum(Takeover),0) 'Takeover',Isnull(Sum(Existing),0) 'Existing'
from
(
Select COUNT(Id) 'Total',Case when ExistingCompany='New' then COUNT(Id) end as 'New',
       Case when ExistingCompany='Takeover' then COUNT(Id) end as 'Takeover',
	   Case when ExistingCompany='Existing' then COUNT(Id) end as 'Existing',
	   Case when ExistingCompany in ('New','Existing') then CreatedDate 
	        when ExistingCompany='Takeover' then TakeOverDate end as Date,CompanyId

	   from Common.EntityDetail 
	  -- Where CompanyId=689
	   Group By ExistingCompany,CreatedDate,TakeOverDate,CompanyId
) as AAD

Where CompanyId=@CompanyId and Date between @FromDate and @ToDate

-- Entity Left Side

--Declare @FromDate Datetime='2003-01-01',
--        @ToDate Datetime='2004-09-20'

Select Name,MonthYear,sum(Total) as 'Cnt',Source from
(
Select Case when Date=PP.CreatedDate then Sum(Total) else 0 end as 'Total',MONTH(CreatedDate) As Month,Year(CreatedDate) as 'Year',  
   Left(DateName(Month,CreatedDate),3)+'-'+ Right(year(CreatedDate),2) AS 'MonthYear',Source as Name,CompanyType as 'Source'
from
(
Select COUNT(Id) 'Total',Case when ExistingCompany='New' then COUNT(Id) end as 'New',
       Case when ExistingCompany='Takeover' then COUNT(Id) end as 'Takeover',
	   Case when ExistingCompany='Existing' then COUNT(Id) end as 'Existing',
	   Case when ExistingCompany in ('New','Existing') then CreatedDate 
	        when ExistingCompany='Takeover' then TakeOverDate end as Date,CompanyId,CompanyType,ExistingCompany as Source

	   from Common.EntityDetail 
	 --  Where CompanyId=689
	   Group By ExistingCompany,CreatedDate,TakeOverDate,CompanyId,CompanyType
) as AAD
 Cross JOIN  
      (  
	  
 SELECT  TOP (DATEDIFF(DAY, @FromDate, @Todate) + 1)
        CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate))
  FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b
  
    ) AS PP    
Where CompanyId=@CompanyId and Date between @FromDate and @ToDate
Group By Date,CompanyType,PP.CreatedDate,Source
) as AAL

Group BY Name,Month,Year,MonthYear,Source
Order BY Year,Month

-- Entity Right Side

--Declare @FromDate Datetime='2003-01-01',
--        @ToDate Datetime='2004-09-20'

Select Name,MonthYear,sum(Total) as 'Cnt' from
(
Select Case when Date=PP.CreatedDate then Sum(Total) else 0 end as 'Total',MONTH(CreatedDate) As Month,Year(CreatedDate) as 'Year',  
   Left(DateName(Month,CreatedDate),3)+'-'+ Right(year(CreatedDate),2) AS 'MonthYear',ExistingCompany as Name
from
(
Select COUNT(Id) 'Total',Case when ExistingCompany='New' then COUNT(Id) end as 'New',
       Case when ExistingCompany='Takeover' then COUNT(Id) end as 'Takeover',
	   Case when ExistingCompany='Existing' then COUNT(Id) end as 'Existing',
	   Case when ExistingCompany in ('New','Existing') then CreatedDate 
	        when ExistingCompany='Takeover' then TakeOverDate end as Date,CompanyId,ExistingCompany

	   from Common.EntityDetail 
	  -- Where CompanyId=689
	   Group By ExistingCompany,CreatedDate,TakeOverDate,CompanyId,ExistingCompany
) as AAD
 Cross JOIN  
      (  
	  
 SELECT  TOP (DATEDIFF(DAY, @FromDate, @Todate) + 1)
        CreatedDate = convert(Date,DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY a.object_id) - 1, @FromDate))
  FROM    sys.all_objects a
        CROSS JOIN sys.all_objects b
  
    ) AS PP    
Where CompanyId=@CompanyId and Date between @FromDate and @ToDate
Group By Date,ExistingCompany,PP.CreatedDate
) as AAL

Group BY Name,Month,Year,MonthYear
Order BY Year,Month



 End
GO
