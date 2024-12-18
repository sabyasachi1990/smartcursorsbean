USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_HTMLIncomeStatment]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--exec [dbo].[Bean_HTMLIncomeStatment] 1382,1383,'2021-01-01','2021-12-31',1,0,0,0
--exec [dbo].[Bean_HTMLIncomeStatment] 1,'3,4,5,6,7,8,9','2022-10-01','2022-10-31',0,0,0,0

CREATE PROCEDURE [dbo].[Bean_HTMLIncomeStatment]
@CompanyId INT,
@ServiceCompany varchar(max),
@FDate Datetime,
@Date  Datetime,
@Frequency int,
@Comparision int,
@SamePeriod int,
@ExcludeInterco bit
as
Begin

Declare  @ServEnt_TBL Table (ServEntity NVarchar(200))
Insert INTO @ServEnt_TBL 
select Distinct items from dbo.SplitToTable(@ServiceCompany,',')
	
	

--exec [dbo].[Bean_HTMLIncomeStatment] 487,'488','2020-01-05','2020-02-29',6,0,0

--Begin
--Declare @CompanyId INT=305,
--@ServiceCompany varchar(max)='305',
--@FDate Datetime='2019-02-01',
--@Date  Datetime='2020-01-31',
--@Frequency int=11,
--@Comparision int=0,
--@SamePeriod int=0
	
/*Declare  @TABLE_TEST  TABLE (id int identity(1,1),FromDate date,ToDate Date)

Declare  @COAName  TABLE (Row_ int,Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
Declare  @COAName_New  TABLE (Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),DocDate Date,FromDate date,ToDate Date)
Declare  @TBL  TABLE (Row_No Int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
DECLARE @SeqNum INT=0,@RowNum int,@Row_Id int=1,@JN INT=1,@KN INT=2,@COA Varchar(Max),@BusinessYearEnd Varchar(Max)
Declare @FromDate Datetime , @ToDate Datetime, @Row int,@FY varchar(25)
Declare @FEY DateTime,@EOF DateTime,@FyFlag bit,@FHDate datetime,@FH datetime,@FHY datetime
 
set @FY=(select BusinessYearEnd FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId)
set @FEY  = (SELECT CASE WHEN @Fy='28-Feb' THEN  DATEADD(d, 1, EOMONTH(@Date)) ELSE 
					Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, GetUTCDate()) as char(4)) as date))) < GetUTCDate() 
				  	then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, GetUTCDate()) as char(4)) as date)))else
					case when @Fy='31-Dec' then dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, GetUTCDate()) as char(4)) as date))) else
				  	dateadd(day,1,dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, GetUTCDate()) as char(4)) as date)))) end end end as FromDate 
			 FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId )
set @FYFlag =(case when @FEY = EOMONTH(@FEY) THEN 1 ELSE 0 END)
set @FHDate=(convert(varchar(50),year(@FDate))+'-'+right(cast(@FEY as Date),5))
set @FH =(Select DATEADD(mm,datediff(mm,0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @FDate) as char(4)) as date))+1,0) 
				 FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId)
--(select dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @FDate) as char(4)) as date)))
	--	  FROM [Common].[Localization] Where CompanyId=@CompanyId)

set @FHY=(select case when @FDate >= @FH then dateadd(year,1,@FH) else @FH end)

--Select @FHY FHY

DECLARE @TBLN TABLE(id int identity(1,1),[COA Name] Varchar(Max),[COA COde] Varchar(Max),[Class] Varchar(Max),Period Varchar(Max)
,Debit Decimal(17,2),Credit Decimal(17,2),Comparision Varchar(Max))
Declare @StartDate date=(select Top 1 JD.PostingDate from Bean.JournalDetail(NoLock) as JD 
join  Bean.Journal(NoLock) as J on J.Id=JD.journalId 
								 Where j.CompanyId=@CompanyId and JD.PostingDate is not null
						  Order by JD.PostingDate )

----FYE-04/14
--0-- Year
--1-- Semi-Anually
--2-- Quaterly
--3-- Month
WHILE @SeqNum <= @Frequency and @Frequency <=11
BEGIN

 Insert Into @TABLE_TEST
		SELECT  Case When @Comparision=0 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate) ELSE
				Case When @SeqNum=0 then 
					Case When @Fdate<=FromDate then @Fdate Else @FDate  END 
				Else  case when right(cast(@FEY as Date),5)='12-31' then DATEADD(YEAR, DATEDIFF(YEAR, 0, @FDate)-@SeqNum, 0)
			/* Else   case when @Fy='28-Feb' and  (DATEADD(d, 1, EOMONTH(@Date)))>=@FDate 
			 Then DATEADD(YEAR, -@SeqNum-1,(DATEADD(d, 1, EOMONTH(@Date))))
	-- else DATEADD(YEAR, -@SeqNum,(DATEADD(d, 1, EOMONTH(@Date))))  */
				Else case when (DATEADD(d, 1, EOMONTH(@Date)))>=@Date then cast(year(@FDate)-@SeqNum-1 as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50))
				Else cast(year(@FDate)-@SeqNum as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50)) END END  END END
		WHEN @Comparision=1 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate)  ELSE 
					 Case When @SeqNum=0 then @FDate Else  case when right(cast(@FEY as Date),5)='12-31' then 
					 DATEADD(MONTH,-@SeqNum * 6,CAST(CAST(((((MONTH(@FDate) - 1) / 6) * 6) + 1) AS VARCHAR) + '-1-' + CAST(YEAR(@FDate) AS VARCHAR) AS DATETIME))  
				ELSE case when DATEDIFF(day,@FDate,@FHY) < 180  then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6*(@SeqNum+1),@FEY)), 0) 
				ELSE Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6*(@SeqNum),@FEY)), 0) END End END END 
		WHEN @Comparision=2 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate) ELSE case when @SeqNum=0 then @FDate 
				ELSE  case when right(cast(@FEY as Date),5)='12-31' then DATEADD(qq, DATEDIFF(qq, 0, @FDate) - @SeqNum, 0) 
				 ELSE case 
				-- when month(@FDate)-month(@FHY) <= 0 then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum),@FEY)), 0)
				  when month(@FHY)-month(@FDate) between 1 and 3 OR month(@FHY)-month(@FDate) IN (-9,-10,-11)
				  --between -3 and -1 
				  then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+1),@FHY)), 0)
				  when (month(@FHY)-month(@FDate) between 4 and 6) OR (month(@FHY)-month(@FDate) IN (-6,-8,-7)
				  -- between -6 and -4
				   ) 
				   then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+2),@FHY)), 0)
				  when month(@FHY)-month(@FDate) between 7 and 9 OR month(@FHY)-month(@FDate) IN (-3,-4,-5)
				  --between -9 and -7 
				  then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+3),@FHY)), 0)
				  when month(@FHY)-month(@FDate) in (0,10,11,12) OR month(@FHY)-month(@FDate) in (-1,-2,-12) then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+4),@FHY)), 0)	  
				 /*when  month(@FDate)-month(@FEY) between 6 and 8 then dateadd(m,-3*(@SeqNum-1),(dateadd(m,3,@FHDate))) 
				 when  month(@FDate)-month(@FEY) between 9 and 11 then dateadd(m,-3*(@SeqNum-1),(dateadd(m,6,@FHDate)))
				 when   month(@FDate)-month(@FEY) =12 then dateadd(m,-3*(@SeqNum-1),(dateadd(m,9,@FHDate)))
				 ELSE dateadd(mm,-3*@SeqNum,
			     cast(year(@FDate) as Varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50)))*/
				END  END END  END
		When @Comparision=3 then  Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate)  ELSE
				 case when @SeqNum=0 then @FDate ELSE DATEADD(MONTH, DATEDIFF(MONTH, 0, @FDate)-@SeqNum, 0)  
				 END END END as 'FromDate' ,
		Case When @Comparision=0 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date) ELSE Case When @SeqNum=0 then cast(@Date as Date)  ELSE 
				 --DATEADD(YEAR,-@SeqNum, @Fdate)
				 case when right(cast(@FEY as Date),5)='12-31' then  dateadd(YEAR, datediff(YEAR, -1, @FDate) - @SeqNum, -1) 
				 ELSE case when (DATEADD(d, 1, EOMONTH(@Date)))>=@Date then
				  dateadd(day,datediff(day,1,cast(year(@FDate)-@SeqNum as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50))),0)
				 else  dateadd(day,datediff(day,1,cast(year(@FDate)-@SeqNum+1 as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50))),0) END END END END
			When @Comparision=1 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)  ELSE Case When @SeqNum = 0 then @Date 
				 ELSE case when right(cast(@FEY as Date),5)='12-31' then
				      DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, (DATEADD(MONTH,-@SeqNum * 6,CAST(CAST(((((MONTH(@FDate) - 1) / 6) * 6) + 6) AS VARCHAR) + '-1-' + 
					  CAST(YEAR(@FDate) AS VARCHAR) AS DATETIME))))+1,0)) 
				 ELSE case when DATEDIFF(day,@FDate,@FHY) < 180  then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, (-6*(@SeqNum+1)+6),@FEY)), 0))  
				 ELSE DATEADD(Day,-1, Dateadd(Month, Datediff(Month, 0, DATEADD(m, (-6*(@SeqNum)+6),@FEY)), 0) ) END End END END

		   When @Comparision=2 Then  Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date) ELSE Case When @SeqNum=0 then @Date
				 ELSE case when right(cast(@FEY as Date),5)='12-31' then dateadd(quarter, datediff(quarter, -1, @FDate) - @SeqNum, -1) Else 
				 case when month(@FHY)-month(@FDate) between 1 and 3 OR month(@FHY)-month(@FDate) IN (-9,-10,-11)
				 --between -3 and -1 
				 then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+1)+3,@FHY)), 0))
				  when (month(@FHY)-month(@FDate) between 4 and 6) OR (month(@FHY)-month(@FDate) IN (-6,-8,-7)
				  --between -6 and -4
				  ) 
				     then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+2)+3,@FHY)), 0))
			      when month(@FHY)-month(@FDate) between 7 and 9 OR (month(@FHY)-month(@FDate) IN (-3,-4,-5)
				  --between -9 and -7
				  )    then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+3)+3,@FHY)), 0))
				  when month(@FHY)-month(@FDate) in (0,10,11,12) Or month(@FHY)-month(@FDate) in (-1,-2,-12)  then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+4)+3,@FHY)), 0))
					/*case when month(@FDate)-month(@FEY) < 0 then dateadd(day,-1,dateadd(m,3,DATEADD(m, -3*(@SeqNum),dateadd(m,-3,@FHDate))))
				 --DATEADD(m, -3*(@SeqNum-1), @FHDate)when
				 month(@FDate)-month(@FEY) between 3 and 5 then dateadd(day,-1,dateadd(m,3,DATEADD(m, -3*(@SeqNum-1), @FHDate)))
				 when  month(@FDate)-month(@FEY) between 6 and 8 then dateadd(day,-1,dateadd(m,3,dateadd(m,-3*(@SeqNum-1),(dateadd(m,3,@FHDate))) ))
				 when  month(@FDate)-month(@FEY) between 9 and 11 then dateadd(day,-1,dateadd(m,3,dateadd(m,-3*(@SeqNum-1),(dateadd(m,6,@FHDate)))))
				 when   month(@FDate)-month(@FEY) =12 then dateadd(day,-1,dateadd(m,3,dateadd(m,-3*(@SeqNum-1),(dateadd(m,9,@FHDate)))))
				 ELSE DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,dateadd(mm,-3*@SeqNum+3,
					cast(year(@FDate) as Varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50)))) ,0)) */
					END END END END 
			When @Comparision=3 then  Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)
	 				 Else Case When @SeqNum=0 then @Date ELSE  DATEADD(MONTH, DATEDIFF(MONTH, -1, @FDate)-@SeqNum, -1) END END	
				 END as 'ToDate'
	 FROM 
		 (
          Select Case When @Comparision=0 Then FromDate 
                      When @Comparision=1 Then CASE  WHEN @Date  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN FromDate 
                                          WHEN @Date  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,6,FromDate)  END
                      When @Comparision=2 then CASE  WHEN @Date  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,3,FromDate)) THEN FromDate 
										  WHEN @Date  BETWEEN DATEADD(M,3,FromDate) AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN DATEADD(M,3,FromDate) 
										  WHEN @Date  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,9,FromDate)) THEN DATEADD(M,6,FromDate) 
                                          WHEN @Date  BETWEEN DATEADD(M,9,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,9,FromDate) END
                      When @Comparision=3 Then CASE WHEN DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) > @Date THEN DATEADD(M,-1,DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate))) 
											   ELSE DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) END END as 'FromDate',P.FromDate AS FD
           From 
				(
				  SELECT Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date 
				  		 then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))else
				  		 dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) end as FromDate 
				  FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId
				) AS P
		 ) AS PP
    SET @SeqNum = @SeqNum + 1;
END
*/
Declare  @TABLE_TEST  TABLE (id int identity(1,1),FromDate date,ToDate Date)

Declare  @COAName  TABLE (Row_ int,Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
Declare  @COAName_New  TABLE (Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),DocDate Date,FromDate date,ToDate Date)
Declare  @TBL  TABLE (Row_No Int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
DECLARE @SeqNum INT=0,@RowNum int,@Row_Id int=1,@JN INT=1,@KN INT=2,@COA Varchar(Max),@BusinessYearEnd Varchar(Max)
Declare @FromDate Datetime , @ToDate Datetime, @Row int,@FY varchar(25)
Declare @FEY DateTime,@EOF DateTime,@FyFlag bit,@FHDate datetime,@FH datetime,@FHY datetime
 
set @FY=(select BusinessYearEnd FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId)
set @FEY  = (SELECT case when @FY='31-Dec' then DATEADD(day,1,
												Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date
																then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))
													 Else dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) End)
						 When @FY='28-Feb' Then Case when dateadd(YEAR, 0, dateadd(day, 1, EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))) < @Date 
															then dateadd(YEAR, 0, dateadd(day, 1,EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date))))
															Else DateAdd(Day,1,EOMONTH(dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))))) End  
													 Else DATEADD(day,1,Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date
													then dateadd(YEAR, 0, dateadd(day, 0,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))
													Else dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, GetDate()) as char(4)) as date))) 
						End) END as FromDate  FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId )
set @FYFlag =(case when @FEY = EOMONTH(@FEY) THEN 1 ELSE 0 END)
set @FHDate=(convert(varchar(50),year(@FDate))+'-'+right(cast(@FEY as Date),5))
set @FH =(Select DATEADD(mm,datediff(mm,0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @FDate) as char(4)) as date))+1,0) 
				 FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId)
--(select dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @FDate) as char(4)) as date)))
	--	  FROM [Common].[Localization] Where CompanyId=@CompanyId)

set @FHY=(select case when @FDate >= @FH then dateadd(year,1,@FH) else @FH end)

--Select @FHY FHY

DECLARE @TBLN TABLE(id int identity(1,1),[COA Name] Varchar(Max),[COA COde] Varchar(Max),[Class] Varchar(Max),Period Varchar(Max)
,Debit Decimal(17,2),Credit Decimal(17,2),Comparision Varchar(Max))
Declare @StartDate date=(select Top 1 JD.PostingDate from Bean.JournalDetail(NoLock) as JD 
join  Bean.Journal(NoLock) as J on J.Id=JD.journalId 
								 Where j.CompanyId=@CompanyId and JD.PostingDate is not null
						  Order by JD.PostingDate )

----FYE-04/14
--0-- Year
--1-- Semi-Anually
--2-- Quaterly
--3-- Month
WHILE @SeqNum <= @Frequency and @Frequency <=11
BEGIN

 Insert Into @TABLE_TEST
		SELECT  Case When @Comparision=0 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate) ELSE
				Case When @SeqNum=0 then 
					Case When @Fdate<=FromDate then @Fdate Else @FDate  END 
				Else  case when right(cast(@FEY as Date),5)='12-31' then DATEADD(YEAR, DATEDIFF(YEAR, 0, @FDate)-@SeqNum, 0)
			/* Else   case when @Fy='28-Feb' and  (DATEADD(d, 1, EOMONTH(@Date)))>=@FDate 
			 Then DATEADD(YEAR, -@SeqNum-1,(DATEADD(d, 1, EOMONTH(@Date))))
	-- else DATEADD(YEAR, -@SeqNum,(DATEADD(d, 1, EOMONTH(@Date))))  */
				Else case when (DATEADD(d, 1, EOMONTH(@FDate)))>=@Date then cast(year(@FDate)-@SeqNum-1 as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50))
				Else cast(year(@FDate)-@SeqNum as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50)) END END  END END
		WHEN @Comparision=1 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate)  ELSE 
					 Case When @SeqNum=0 then @FDate Else  case when right(cast(@FEY as Date),5)='12-31' then 
					 DATEADD(MONTH,-@SeqNum * 6,CAST(CAST(((((MONTH(@FDate) - 1) / 6) * 6) + 1) AS VARCHAR) + '-1-' + 
					 CAST(YEAR(@FDate) AS VARCHAR) AS DATETIME))  
				  ELSE case when month(@FHY)-month(@FDate) between 1 and 6 OR month(@FHY)-month(@FDate) IN (-6,-8,-7,-9,-10,-11)
				  then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6*(@SeqNum+1),@FHY)), 0)
				 when month(@FHY)-month(@FDate) in (7,8,9,0,10,11,12) OR month(@FHY)-month(@FDate) IN (-3,-4,-5,-1,-2,-12)
				 then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6*(@SeqNum+2),@FHY)), 0) 
				 END End END END 
				 WHEN @Comparision=2 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate) ELSE case when @SeqNum=0 then @FDate 
				ELSE  case when right(cast(@FEY as Date),5)='12-31' then DATEADD(qq, DATEDIFF(qq, 0, @FDate) - @SeqNum, 0) 
				 ELSE case 
				-- when month(@FDate)-month(@FHY) <= 0 then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum),@FEY)), 0)
				  when month(@FHY)-month(@FDate) between 1 and 3 OR month(@FHY)-month(@FDate) IN (-9,-10,-11)
				  --between -3 and -1 
				  then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+1),@FHY)), 0)
				  when (month(@FHY)-month(@FDate) between 4 and 6) OR (month(@FHY)-month(@FDate) IN (-6,-8,-7)
				  -- between -6 and -4
				   ) 
				   then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+2),@FHY)), 0)
				  when month(@FHY)-month(@FDate) between 7 and 9 OR month(@FHY)-month(@FDate) IN (-3,-4,-5)
				  --between -9 and -7 
				  then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+3),@FHY)), 0)
				  when month(@FHY)-month(@FDate) in (0,10,11,12) OR month(@FHY)-month(@FDate) in (-1,-2,-12) then Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+4),@FHY)), 0)	  
				 /*when  month(@FDate)-month(@FEY) between 6 and 8 then dateadd(m,-3*(@SeqNum-1),(dateadd(m,3,@FHDate))) 
				 when  month(@FDate)-month(@FEY) between 9 and 11 then dateadd(m,-3*(@SeqNum-1),(dateadd(m,6,@FHDate)))
				 when   month(@FDate)-month(@FEY) =12 then dateadd(m,-3*(@SeqNum-1),(dateadd(m,9,@FHDate)))
				 ELSE dateadd(mm,-3*@SeqNum,
			     cast(year(@FDate) as Varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50)))*/
				END  END END  END
		When @Comparision=3 then  Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @FDate)  ELSE
				 case when @SeqNum=0 then @FDate ELSE DATEADD(MONTH, DATEDIFF(MONTH, 0, @FDate)-@SeqNum, 0)  
				 END END END as 'FromDate' ,
		Case When @Comparision=0 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date) ELSE Case When @SeqNum=0 then cast(@Date as Date)  ELSE 
				 --DATEADD(YEAR,-@SeqNum, @Fdate)
				 case when right(cast(@FEY as Date),5)='12-31' then  dateadd(YEAR, datediff(YEAR, -1, @FDate) - @SeqNum, -1) 
				 ELSE case when (DATEADD(d, 1, EOMONTH(@FDate)))>=@Date then
				  dateadd(day,datediff(day,1,cast(year(@FDate)-@SeqNum as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50))),0)
				 else  dateadd(day,datediff(day,1,cast(year(@FDate)-@SeqNum+1 as varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50))),0) END END END END
			When @Comparision=1 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)  ELSE Case When @SeqNum = 0 then @Date 
				 ELSE case when right(cast(@FEY as Date),5)='12-31' then
				      DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0, (DATEADD(MONTH,-@SeqNum * 6,CAST(CAST(((((MONTH(@FDate) - 1) / 6) * 6) + 6) AS VARCHAR) + '-1-' + 
					  CAST(YEAR(@FDate) AS VARCHAR) AS DATETIME))))+1,0)) 
				   ELSE case when month(@FHY)-month(@FDate) between 1 and 6 OR month(@FHY)-month(@FDate) IN (-6,-8,-7,-9,-10,-11)
				  then  dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6*(@SeqNum+1)+6,@FHY)), 0))
				 when month(@FHY)-month(@FDate) in (7,8,9,0,10,11,12) OR month(@FHY)-month(@FDate) IN (-3,-4,-5,-1,-2,-12)
				 then  dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -6*(@SeqNum+2)+6,@FHY)), 0)) 
				 END End END END 
		   When @Comparision=2 Then  Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date) ELSE Case When @SeqNum=0 then @Date
				 ELSE case when right(cast(@FEY as Date),5)='12-31' then dateadd(quarter, datediff(quarter, -1, @FDate) - @SeqNum, -1) Else 
				 case when month(@FHY)-month(@FDate) between 1 and 3 OR month(@FHY)-month(@FDate) IN (-9,-10,-11)
				 --between -3 and -1 
				 then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+1)+3,@FHY)), 0))
				  when (month(@FHY)-month(@FDate) between 4 and 6) OR (month(@FHY)-month(@FDate) IN (-6,-8,-7)
				  --between -6 and -4
				  ) 
				     then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+2)+3,@FHY)), 0))
			      when month(@FHY)-month(@FDate) between 7 and 9 OR (month(@FHY)-month(@FDate) IN (-3,-4,-5)
				  --between -9 and -7
				  )    then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+3)+3,@FHY)), 0))
				  when month(@FHY)-month(@FDate) in (0,10,11,12) Or month(@FHY)-month(@FDate) in (-1,-2,-12)  then dateadd(day,-1,Dateadd(Month, Datediff(Month, 0, DATEADD(m, -3*(@SeqNum+4)+3,@FHY)), 0))
					/*case when month(@FDate)-month(@FEY) < 0 then dateadd(day,-1,dateadd(m,3,DATEADD(m, -3*(@SeqNum),dateadd(m,-3,@FHDate))))
				 --DATEADD(m, -3*(@SeqNum-1), @FHDate)when
				 month(@FDate)-month(@FEY) between 3 and 5 then dateadd(day,-1,dateadd(m,3,DATEADD(m, -3*(@SeqNum-1), @FHDate)))
				 when  month(@FDate)-month(@FEY) between 6 and 8 then dateadd(day,-1,dateadd(m,3,dateadd(m,-3*(@SeqNum-1),(dateadd(m,3,@FHDate))) ))
				 when  month(@FDate)-month(@FEY) between 9 and 11 then dateadd(day,-1,dateadd(m,3,dateadd(m,-3*(@SeqNum-1),(dateadd(m,6,@FHDate)))))
				 when   month(@FDate)-month(@FEY) =12 then dateadd(day,-1,dateadd(m,3,dateadd(m,-3*(@SeqNum-1),(dateadd(m,9,@FHDate)))))
				 ELSE DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,dateadd(mm,-3*@SeqNum+3,
					cast(year(@FDate) as Varchar(50)) ++ cast(right(cast(@FEY as Date),6)as Varchar(50)))) ,0)) */
					END END END END 
			When @Comparision=3 then  Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)
	 				 Else Case When @SeqNum=0 then @Date ELSE  DATEADD(MONTH, DATEDIFF(MONTH, -1, @FDate)-@SeqNum, -1) END END	
				 END as 'ToDate'
	 FROM 
		 (
          Select Case When @Comparision=0 Then FromDate 
                      When @Comparision=1 Then CASE  WHEN @Date  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN FromDate 
                                          WHEN @Date  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,6,FromDate)  END
                      When @Comparision=2 then CASE  WHEN @Date  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,3,FromDate)) THEN FromDate 
										  WHEN @Date  BETWEEN DATEADD(M,3,FromDate) AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN DATEADD(M,3,FromDate) 
										  WHEN @Date  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,9,FromDate)) THEN DATEADD(M,6,FromDate) 
                                          WHEN @Date  BETWEEN DATEADD(M,9,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,9,FromDate) END
                      When @Comparision=3 Then CASE WHEN DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) > @Date THEN DATEADD(M,-1,DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate))) 
											   ELSE DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) END END as 'FromDate',P.FromDate AS FD
           From 
				(
				  SELECT Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date 
				  		 then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))else
				  		 dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) end as FromDate 
				  FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId
				) AS P
		 ) AS PP
    SET @SeqNum = @SeqNum + 1;
END



	
	--Select  * From @TABLE_TEST
	
	
	--Select  * From @TABLE_TEST
	
	Set @Row=1
		While @Row <= @Frequency+1 and @Frequency <=11
		Begin
		select @FromDate=FromDate,@ToDate=ToDate 
			 from 
				 (
		 		    Select ROW_NUMBER()Over(Order By FromDate DESC) as 'Row_No',* from @TABLE_TEST
				  ) AS P
		     Where Row_No=@Row
			-- Select  * From @TABLE_TEST
	
	------ RetarnedEarnings-------------	
	If @ExcludeInterco=0
	Begin
	INSERT INTO @COAName_New
		Select  DENSE_RANK() over(order by [COA Name],@FromDate) , *,@FromDate,@ToDate from 
			(
		
				SELECT [COA Name], [COA COde],Class,classOrder,Recorder,Case when BaseTotal >= 0 then BaseTotal end as Debit,
		            case when BaseTotal < 0 then -BaseTotal end as Credit,DocDate
		     FROM 
		        (
				--Income Statement
				SELECT [COA Name],[COA COde],Class,sum(isnull(BaseDebit,0)) BaseDebit,sum(Isnull(BaseCredit,0)) BaseCredit,
				 	    sum(isnull(BaseDebit,0))-sum(Isnull(BaseCredit,0)) as BaseTotal,classOrder,Recorder,DocDate
				 FROM
					 (
					  SELECT COA.Name [COA Name],COA.Code AS [COA COde],COA.Class,'3' AS classOrder,AT.Recorder,convert(date,JD.PostingDate) as DocDate,
						     /*case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end*/ JD.BaseDebit BaseDebit,
						     /*Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end*/ JD.BaseCredit BaseCredit
					  FROM   Bean.JournalDetail(NoLock) as JD
						     Inner join  Bean.Journal(NoLock) as J on J.Id=JD.journalId
						     Inner join  Bean.chartOfAccount(NoLock) as COA on COA.Id=JD.COAID
						     Left  Join  Bean.AccountType(NoLock) As AT On AT.Id=COA.AccountTypeId And AT.CompanyId=COA.CompanyId
						     Inner join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
							 Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
					  WHERE  COA.companyId=@CompanyId and COA.ModuleType='Bean'  --And J.DocSubType<>'Interco'
					  --and
						   --SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,',')) 
						   and
						     J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')  ---->> Deleted state Added on '25-04-2023'
							 AND COA.Class IN ('Income','Expenses') --and
						     --convert(date,JD.PostingDate) <=  @Date-- And @ToDate/*getdate()*/
							  and   
							  convert(date,JD.PostingDate) --<=  @Date
							  Between @FromDate --DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(Varchar(Max),year( @FromDate)-1)))--@FromDate
		  
		  --CONVERT(CHAR(11), CONVERT(SMALLDATETIME, @BusinessYearEnd+'-'+convert(Varchar(Max),year( @FromDate)), 13), 103) 
		  And @Todate--@ToDate
					  ) IE1
		       GROUP BY [COA Name],[COA COde],classOrder,Class,Recorder,DocDate
		) IE2
		--where DocDate between @FromDate and @ToDate 
		) AS PP
		--where [COA Name]='Trade receivables'
		Order By RecOrder,[COA COde]/**/
	End
	Else
	Begin
		INSERT INTO @COAName_New
		Select  DENSE_RANK() over(order by [COA Name],@FromDate) , *,@FromDate,@ToDate from 
			(
		
				SELECT [COA Name], [COA COde],Class,classOrder,Recorder,Case when BaseTotal >= 0 then BaseTotal end as Debit,
		            case when BaseTotal < 0 then -BaseTotal end as Credit,DocDate
		     FROM 
		        (
				--Income Statement
				SELECT [COA Name],[COA COde],Class,sum(isnull(BaseDebit,0)) BaseDebit,sum(Isnull(BaseCredit,0)) BaseCredit,
				 	    sum(isnull(BaseDebit,0))-sum(Isnull(BaseCredit,0)) as BaseTotal,classOrder,Recorder,DocDate
				 FROM
					 (
					  SELECT COA.Name [COA Name],COA.Code AS [COA COde],COA.Class,'3' AS classOrder,AT.Recorder,convert(date,JD.PostingDate) as DocDate,
						     /*case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end*/ JD.BaseDebit BaseDebit,
						     /*Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end*/ JD.BaseCredit BaseCredit
					  FROM   Bean.JournalDetail(NoLock) as JD
						     Inner join  Bean.Journal(NoLock) as J on J.Id=JD.journalId
						     Inner join  Bean.chartOfAccount(NoLock) as COA on COA.Id=JD.COAID
						     Left  Join  Bean.AccountType(NoLock) As AT On AT.Id=COA.AccountTypeId And AT.CompanyId=COA.CompanyId
						     Inner join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
							 Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
					  WHERE  COA.companyId=@CompanyId and COA.ModuleType='Bean'  And J.DocSubType<>'Interco'
					  --and
						   --SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,',')) 
						   and
						     J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')  ---->> Deleted state Added on '25-04-2023'
							 AND COA.Class IN ('Income','Expenses') --and
						     --convert(date,JD.PostingDate) <=  @Date-- And @ToDate/*getdate()*/
							  and   
							  convert(date,JD.PostingDate) --<=  @Date
							  Between @FromDate --DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(Varchar(Max),year( @FromDate)-1)))--@FromDate
		  
		  --CONVERT(CHAR(11), CONVERT(SMALLDATETIME, @BusinessYearEnd+'-'+convert(Varchar(Max),year( @FromDate)), 13), 103) 
		  And @Todate--@ToDate
					  ) IE1
		       GROUP BY [COA Name],[COA COde],classOrder,Class,Recorder,DocDate
		) IE2
		--where DocDate between @FromDate and @ToDate 
		) AS PP
		--where [COA Name]='Trade receivables'
		Order By RecOrder,[COA COde]/**/
	End
	
	SET @Row = @Row + 1;
	
	END
	-- END Retarned Earnings ---------------------
	
	INSERT INTO @COAName
	 select Dense_Rank()Over( Order by [COA Name]) as 'Row' ,Dense_Rank()over(Partition by [COA Name] Order by FromDate  DESC) as 'Row_Id',
	[COA Name],[COA Code],[Class],[Class Order],Recorder,SUM(Debit)Debit,SUM(Credit)Credit,FromDate,ToDate from 
	(
	select Row_Id,[COA Name],[COA Code],[Class],[Class Order],Recorder,isnull(Debit,0)Debit,Isnull(Credit,0)Credit 
	,FromDate,ToDate from  @COAName_New 
	) AS P
	Group BY [COA Name],[COA Code],[Class],[Class Order],Recorder,FromDate,ToDate
	/**/Order By Recorder,[COA COde]
	  While  @Row_Id<=(Select count(distinct [COA Name]) From @COAName)
	  Begin
	        SET @RowNum  = 1
		While @RowNum <= @Frequency+1 and @Frequency <=11
		Begin
		     (Select @COA= [COA Name] From @COAName where Row_=@Row_Id)
			 select @FromDate=FromDate,@ToDate=ToDate 
			 from 
				 (
		 		    Select * from @TABLE_TEST
				  ) AS P
		     Where Id=@RowNum
	
	        IF ( Select count(distinct Row_Id) From @COAName 
		     	where FromDate = @FromDate and ToDate= @ToDate AND [COA Name] in (@COA)) =0
	          begin
	          
	              Insert into @TBL
		       	  select @RowNum,Name,Code,Class,Null,Null,0,0,@FromDate ,@ToDate  from Bean.chartofaccount as C (NoLock)
		       	  WHere C.Name in (@COA) and CompanyId=@CompanyId
	           end
		   ELSE
	       begin
	           INSERT INTO @TBL
			   Select @RowNum,[COA Name],[COA COde],Class,[class Order],Recorder,Sum(Debit)Debit,Sum(Credit)Credit,@FromDate,@ToDate 
			   from  @COAName
			   Where FromDate= @FromDate and ToDate=@ToDate and [COA Name] in (@COA)
			   Group BY [COA Name],[COA COde],Class,[class Order],Recorder
		 end
	
	 IF @RowNum <>1 
		BEGIN
		    INSERT INTO @TBLN
		    SELECT [CoA Name],[COA Code],Class,
			DBO.SmDateFormats(FromDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, FromDate, 103 )
			+' To '+
			DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 )
			,Debit,Credit,0 as 'Percentage' FROM @TBL
		    where Row_No=@RowNum AND [COA Name] in (@COA)
		
		IF @RowNum >= 2
		  Begin
		  SET @JN =@RowNum -1 ;
		  SET @KN = @RowNum ;
	
			INSERT INTO @TBLN
			SELECT( SELECT DISTINCT [CoA Name] FROM @TBL  WHERE Row_No=@JN and [CoA Name] in ( (@COA))),
				  ( SELECT DISTINCT [COA Code] FROM @TBL  WHERE Row_No=@JN and [COA Name] in (@COA)),
				  ( SELECT DISTINCT [Class] FROM @TBL  WHERE Row_No=@JN and [COA Name] in (@COA)),
				 convert(Varchar(Max),(select DISTINCT --CONVERT( VARCHAR, FromDate, 103 )
				 DBO.SmDateFormats(FromDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) +' To '+
			DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 ) 
			from @TBL Where Row_No=@JN and [COA Name] in (@COA)))+' Vs '+
				 convert(Varchar(Max),(select  DISTINCT DBO.SmDateFormats(FromDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, FromDate, 103 )
				 +' To '+
			DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 ) 
			from @TBL Where Row_No=@KN and [COA Name] in (@COA))),0,0,
	
	
		/*
			Case When 
			((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))=0 AND
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) =0)
				
				then NULL 
	
				When 
			(((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))>0 AND
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) <= 0))
				Or
				(((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))<=0 AND
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) >0))
				then NULL 
			else
			 Case
				 when
				 	((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA)) -
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)))=0
				  then '0'
				  Else
	
				 Cast( Cast(NULLIF (((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No = @JN and [COA Name] in (@COA)) -
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA))),0)/
				 NULLIF((SELECT DISTINCT ABS(isnull(Debit,0)-Isnull(Credit,0))  FROM @TBL WHERE Row_No = @KN and [COA Name] in (@COA)),0)*100 as Decimal(17,2))as  Varchar(Max))
				 end
				 end */

				 Case When 
			((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))=0 AND
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) =0)
				
				then NULL 
	
				When 
			(((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))>0 AND
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) <= 0))
				Or
				(((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))<0 AND
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) >0))
				then NULL 
			else
			 Case
				 when
				 	((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA)) -
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)))=0
				  then '0'
				  Else
	
	             Case When ((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA)) <0 AND
				 (SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) <0)
				 THEN

				 Cast( Cast(NULLIF (((SELECT DISTINCT Case When Class='Income' Then ABS((isnull(Debit,0)-Isnull(Credit,0))*-1) Else ABS(isnull(Debit,0)-Isnull(Credit,0)) END  FROM @TBL WHERE Row_No = @JN and [COA Name] in (@COA)) -
				(SELECT DISTINCT Case When Class='Income' Then ABS((isnull(Debit,0)-Isnull(Credit,0))*-1) Else ABS(isnull(Debit,0)-Isnull(Credit,0)) END  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA))),0)/
				 NULLIF((SELECT DISTINCT ABS(isnull(Debit,0)-Isnull(Credit,0))  FROM @TBL WHERE Row_No = @KN and [COA Name] in (@COA)),0)*100 as Decimal(17,2))as  Varchar(Max))

				 ELSE 

				 Cast( Cast(NULLIF (((SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No = @JN and [COA Name] in (@COA)) -
				(SELECT DISTINCT Case When Class='Income' Then (isnull(Debit,0)-Isnull(Credit,0))*-1 Else isnull(Debit,0)-Isnull(Credit,0) ENd  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA))),0)/
				 NULLIF((SELECT DISTINCT ABS(isnull(Debit,0)-Isnull(Credit,0))  FROM @TBL WHERE Row_No = @KN and [COA Name] in (@COA)),0)*100 as Decimal(17,2))as  Varchar(Max))
				 end
				 end 
				 END
	
	    END
	  END
	  ELSE If @RowNum =1 
	  Begin
		 
		 INSERT INTO @TBLN
		 SELECT [CoA Name],[COA Code],Class,DBO.SmDateFormats(FromDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, FromDate, 103 )
		 +' To '+
			DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 )
			,Debit,Credit,0 as 'Percentage' FROM @TBL
		 where Row_No=@RowNum and [CoA Name] in (@COA)
	  END
		SET @RowNum = @RowNum + 1;
	 END
	   SET @Row_Id = @Row_Id + 1;
	END
	
	Select id RId,[COA Name],[COA Code],Class,Period,Case When Class IN ('Income') then Balance*(-1) Else Balance END As 
			Balance,
			Comparision,COAID,Companyid
			,CategoryId,SubCategoryId,FRCoaId,FRPATId,FRRecOrder From
			(
	select P.id,[COA Name],[COA Code],P.Class,Period,Isnull(Debit,0)-Isnull(Credit,0) as 'Balance',Comparision,C.id As COAId,p.Companyid
	,C.CategoryId,C.SubCategoryId,C.FRCoaId,C.FRPATId,C.FRRecOrder
	 from 
	(
	
	SELECT   id,@CompanyId CompanyId,[COA Name],[COA COde],Class,Period,Case when isnull(Debit,0)-isnull(Credit,0) >= 0 then isnull(Debit,0)-isnull(Credit,0) end as Debit,
	        case when isnull(Debit,0)-isnull(Credit,0) < 0 then -(isnull(Debit,0)-isnull(Credit,0)) end as Credit,Comparision
	FROM  @TBLN
	)as P
	INNER JOIN Bean.ChartOfAccount(NoLock) as C ON C.CompanyId=p.Companyid and p.[COA Name]=Name
	) KKK
	Order BY 	[COA Code]--[COA Name]	

END
GO
