USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BSGLFromDateLink]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
 CREATE PROCEDURE [dbo].[BSGLFromDateLink]
 @CompanyId INT
 ,@AsOfDate dateTime
 --EXEC [dbo].[BSGLFromDateLink] 248
 as
Begin
 --Declare @CompanyId Bigint= 258
 
 

 /*
Set @FromDate= (SELECT Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @AsOfDate) as char(4)) as date))) < @AsOfDate 
				  		 then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @AsOfDate) as char(4)) as date)))else
				  		 dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @AsOfDate) as char(4)) as date))) end 
				  FROM [Common].[Localization] Where CompanyId=@CompanyId)

Select @FromDate*/
Declare @FromDate dateTime
declare  @FY varchar(50)

select @FY=BusinessYearEnd FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId


Set @FromDate= (SELECT case when @FY='28-Feb' Then Case when dateadd(YEAR, 0, dateadd(day, 1, EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @AsOfDate) as char(4)) as date)))) < @AsOfDate 
                          						then dateadd(YEAR, 0, dateadd(day, 1,EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @AsOfDate) as char(4)) as date))))
										 Else
                          					DateAdd(Day,1,EOMONTH(dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @AsOfDate) as char(4)) as date)))))
									End else

Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @AsOfDate) as char(4)) as date))) < @AsOfDate 
				  		 then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @AsOfDate) as char(4)) as date)))else
				  		 dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @AsOfDate) as char(4)) as date))) end  end
				  FROM [Common].[Localization] Where CompanyId=@CompanyId)

Select @FromDate

END

GO
