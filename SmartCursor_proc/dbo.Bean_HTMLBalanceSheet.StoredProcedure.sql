USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Bean_HTMLBalanceSheet]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- Exec [dbo].[Bean_HTMLBalanceSheet] 2151,2152,'2023-03-27',1,0,0


-- Select * from Common.Company Order by Name



CREATE pROCEDURE [dbo].[Bean_HTMLBalanceSheet]

@CompanyId INT,
@ServiceCompany varchar(max),
@Date  Datetime,
@Frequency int,
@Comparision int,
@SamePeriod int
as


Begin
--Declare 
--@CompanyId INT=404,
--@ServiceCompany varchar(max)='405',
--@Date  Datetime='2020-02-29',
--@Frequency int=11,
--@Comparision int=0,
--@SamePeriod int=0
/*Declare  @ServEnt_TBL Table (ServEntity NVarchar(200))
Insert INTO @ServEnt_TBL 
select Distinct items from dbo.SplitToTable(@ServiceCompany,',')

Declare  @TABLE_TEST  TABLE (id int identity(1,1),FromDate date,ToDate Date)
--Declare  @COAName  TABLE (Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),DocDate Date)
Declare  @COAName  TABLE (Row_ int,Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
Declare  @COAName_New  TABLE (Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),DocDate Date,FromDate date,ToDate Date)
Declare  @TBL  TABLE (Row_No Int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
DECLARE @SeqNum INT=0,@RowNum int,--@Frequency int=1,@Comparision int=0,@SamePeriod int=0,
@Row_Id int=1,@JN INT=1,@KN INT=2,@COA Varchar(Max),@BusinessYearEnd Varchar(Max)
Declare @FromDate Datetime , @ToDate Datetime, @Row int,@FY varchar(50)
 
Declare @FEY DateTime,@EOF DateTime,@FyFlag bit


 select @FY=BusinessYearEnd FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId set @FEY  = ( 
SELECT  case when @FY='31-Dec' then
								DATEADD(day,1,Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date
                          											then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))
													Else dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) 
												End)
			 When @FY='28-Feb' Then Case when dateadd(YEAR, 0, dateadd(day, 1, EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))) < @Date 
                          						then dateadd(YEAR, 0, dateadd(day, 1,EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date))))
										 Else
                          					DateAdd(Day,1,EOMONTH(dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))))
									End
             Else 

DATEADD(day,1,Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date
                          											then dateadd(YEAR, 0, dateadd(day, 0,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))
													Else dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, GetDate()) as char(4)) as date))) 
												End)

         END as FromDate 
                  
                  FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId)
 

set @FYFlag =(case when @FEY = EOMONTH(@FEY) THEN 1 ELSE 0 END)
 
--select @FEY


------------------------------------------------------------------------------------------------------------------
-----Verification 
 				--SELECT Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) <= @Date 
				 --               /*then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))*/
					--		Then 
					--			 Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
					--							dateadd(YEAR,0, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--				  Else dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--			 End
					--		Else
     --           				/*dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) end*/
					--			Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
					--					dateadd(YEAR, -1, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--				 Else dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--  End
					--End	as FromDate 
     --             FROM [Common].[Localization] Where CompanyId=@CompanyId


------------------------------------------------------------------------------------------------------------------
 

Set @BusinessYearEnd =(Select BusinessYearEnd from Common.Localization where CompanyId=@CompanyId)

 
DECLARE @TBLN TABLE(id int identity(1,1),[COA Name] Varchar(MAX),[COA COde] Varchar(MAX),[Class] Varchar(MAX),Period varchar(MAX)
,Debit Decimal(17,2),Credit Decimal(17,2),Comparision varchar(MAX))
 Declare @StartDate date=(select Top 1 JD.PostingDate from Bean.JournalDetail(NoLock) as JD
                                 join  Bean.Journal(NoLock) as J on J.Id=JD.journalId Where j.CompanyId=@CompanyId and JD.PostingDate is not null
                          Order by JD.PostingDate )
     --Declare @StartDate date='1990-01-01'
 
 
----FYE-04/14
--0-- Year
--1-- Semi-Anually
--2-- Quaterly
--3-- Month
  --Select BusinessYearEnd from Common.Localization where CompanyId=@CompanyId

WHILE @SeqNum <= @Frequency and @Frequency <=11
BEGIN
    Insert Into @TABLE_TEST
     SELECT   Case 
     When @Comparision=0 Then Case When @SamePeriod =1 Then case when @FEY>=@Date then DATEADD(year,-@SeqNum,FromDate) ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END ELSE
       DATEADD(YEAR,-@SeqNum, @FEY)  END
              WHEN @Comparision=1 Then Case When @SamePeriod =1 Then case when @FEY>@Date then DATEADD(year,-@SeqNum-1,@FEY)
              When @FEY<=@Date then DATEADD(year,-@SeqNum,@FEY)
              ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END  ELSE DATEADD(MONTH,-@SeqNum * 6, FromDate) End
              When @Comparision=2 Then Case When @SamePeriod =1 Then case when @FEY>@Date then DATEADD(year,-@SeqNum-1,@FEY)
             when @FEY<=@Date then DATEADD(year,-@SeqNum,@FEY)
              ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END  ELSE DATEADD(Q,-@SeqNum, FromDate) End
              WHen @Comparision=3 then Case when @SamePeriod =1 Then case when @FEY>@Date then DATEADD(year,-@SeqNum-1,@FEY)
             when @FEY<=@Date then DATEADD(year,-@SeqNum,@FEY)  ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END 
                                       ELSE 
                                      DATEADD(MONTH,-@SeqNum, FromDate) END END as 'FromDate' , 



      Case When @Comparision=0 Then Case When @SamePeriod =1 Then /*DATEADD(YEAR, -@SeqNum,@Date)*/
													Case When MONTH(@Date)=2 And (DAY(@Date)=28 Or DAY(@Date)=29) Then EOMONTH(DATEADD(YEAR, -@SeqNum,Dateadd(DAY,-1,@Date)))
														 Else DATEADD(YEAR, -@SeqNum,@Date) End
          								 ELSE Case When @SeqNum=0 then cast(@Date as Date) 
          	     									ELSE /*DATEADD(YEAR,-@SeqNum,DATEADD(D,-1,DATEADD(YEAR,1, FromDate))) */
														DATEADD(D,-1,DATEADD(YEAR,-@SeqNum,DATEADD(YEAR,1, @FEY))) 
												END 
									END
              
           When @Comparision=1 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)  
										 ELSE Case when @SeqNum = 0 then @Date   
													ELSE  EOMonth( DATEADD(MONTH,-@SeqNum * 6,DATEADD(D,-1,DATEADD(M,6,FromDate)))) 
							                  END
									END   --end
    		When @Comparision=2 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)
                                       		ELSE Case When @SeqNum = 0 then @Date 
                                      					ELSE Case When @FYFlag=1 then EOMonth(Dateadd(d,-1,DATEADD(Q,-@SeqNum,DATEADD(M,3,FD)))) 
																	ELSE 
                                                        			--DATEADD(Q,-@SeqNum,DATEADD(D,-1,DATEADD(M,3,FD)))
                                                        			-- DATEADD(D,-1,DATEADD(M,3,FD))
                                                        				Dateadd(d,-1,DATEADD(Q,-@SeqNum,DATEADD(M,3,FromDate)))
                                                         
                                                          	 END
												 END 
									 END
 
            When @Comparision=3 then Case when @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)
                                          Else CASE When @SeqNum = 0 then @Date  WHEN day(FD) = 1 THEN EOMONTH(DATEADD(MONTH,-@SeqNum,DATEADD(D,-1, DATEADD(MONTH,1, FromDate)))) 
                                           			ELSE DATEADD(MONTH,-@SeqNum,DATEADD(D,-1, DATEADD(MONTH,1, FromDate))) 
												END 
									 END 
			END as 'ToDate'
     FROM 
         (
          Select Case When @Comparision=0 Then FromDate 
                 When @Comparision=1 Then Case when cast(@Date as Date)  BETWEEN DATEADD(M,-6,FromDate) and dateadd(d,-1,FromDate) then DATEADD(M,-6,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-12,FromDate) and DATEADD(D,-1,DATEADD(M,-6,FromDate)) then dateadd(M,-12,FromDate)
  				 WHEN cast(@Date as Date)  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN FromDate 
 				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,6,FromDate)  END
                 When @Comparision=2 then CASE  WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-3,FromDate) and dateadd(d,-1,FromDate) then DATEADD(M,-3,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-6,FromDate) and dateadd(d,-1,DATEADD(M,-3,FromDate)) then DATEADD(M,-6,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-9,FromDate) and dateadd(d,-1,DATEADD(M,-6,FromDate)) then DATEADD(M,-9,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-12,FromDate) and dateadd(d,-1,DATEADD(M,-9,FromDate)) then DATEADD(M,-12,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,3,FromDate)) THEN FromDate 
                 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,3,FromDate) AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN DATEADD(M,3,FromDate) 
                 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,9,FromDate)) THEN DATEADD(M,6,FromDate) 
                 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,9,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,9,FromDate) END
                 When @Comparision=3 Then CASE WHEN DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) > @Date THEN DATEADD(M,-1,DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate))) 
                 ELSE DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) END END as 'FromDate',P.FromDate AS FD
           From 
                (
				SELECT Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) <= @Date 
				                /*then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))*/
							Then 
								 Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
												dateadd(YEAR,0, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
									  Else dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
								 End
							Else
                				/*dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) end*/
								Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
										dateadd(YEAR, -1, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
									 Else dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					  End
					End	as FromDate 
                  FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId
                ) AS P
         ) AS PP
    SET @SeqNum = @SeqNum + 1;
--END
END*/

Declare  @ServEnt_TBL Table (ServEntity NVarchar(200))
Insert INTO @ServEnt_TBL 
select Distinct items from dbo.SplitToTable(@ServiceCompany,',')

Declare  @TABLE_TEST  TABLE (id int identity(1,1),FromDate date,ToDate Date)
--Declare  @COAName  TABLE (Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),DocDate Date)
Declare  @COAName  TABLE (Row_ int,Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
Declare  @COAName_New  TABLE (Row_Id int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),DocDate Date,FromDate date,ToDate Date)
Declare  @TBL  TABLE (Row_No Int,[COA Name] Varchar(Max),[COA Code] Varchar(Max),[Class] Varchar(Max),[Class Order] int,[Recorder] int,Debit Decimal(17,2),Credit Decimal(17,2),FromDate date,ToDate Date)
DECLARE @SeqNum INT=0,@RowNum int,--@Frequency int=1,@Comparision int=0,@SamePeriod int=0,
@Row_Id int=1,@JN INT=1,@KN INT=2,@COA Varchar(Max),@BusinessYearEnd Varchar(Max)
Declare @FromDate Datetime , @ToDate Datetime, @Row int,@FY varchar(50)
 
Declare @FEY DateTime,@EOF DateTime,@FyFlag bit


 select @FY=BusinessYearEnd FROM [Common].[Localization] (NoLock) Where CompanyId=@CompanyId set @FEY  = ( 
SELECT  case when @FY='31-Dec' then
								DATEADD(day,1,Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date
                          											then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))
													Else dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) 
												End)
			 When @FY='28-Feb' Then Case when dateadd(YEAR, 0, dateadd(day, 1, EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))) < @Date 
                          						then dateadd(YEAR, 0, dateadd(day, 1,EOMONTH(cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date))))
										 Else
                          					DateAdd(Day,1,EOMONTH(dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))))
									End
             Else 

				DATEADD(day,1,
							Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) < @Date
                          		then dateadd(YEAR, 0, dateadd(day, 0,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))
							Else dateadd(YEAR, -1, dateadd(day, 0, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) 
							End)

         END as FromDate 
                  
                  FROM [Common].[Localization] (NoLock) Where CompanyId=@CompanyId)
 

set @FYFlag =(case when @FEY = EOMONTH(@FEY) THEN 1 ELSE 0 END)
 
--select @FEY


------------------------------------------------------------------------------------------------------------------
-----Verification 
 				--SELECT Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) <= @Date 
				 --               /*then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))*/
					--		Then 
					--			 Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
					--							dateadd(YEAR,0, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--				  Else dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--			 End
					--		Else
     --           				/*dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) end*/
					--			Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
					--					dateadd(YEAR, -1, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--				 Else dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					--  End
					--End	as FromDate 
     --             FROM [Common].[Localization] Where CompanyId=@CompanyId


------------------------------------------------------------------------------------------------------------------
 

Set @BusinessYearEnd =(Select BusinessYearEnd from Common.Localization (NoLock) where CompanyId=@CompanyId)

 
DECLARE @TBLN TABLE(id int identity(1,1),[COA Name] Varchar(MAX),[COA COde] Varchar(MAX),[Class] Varchar(MAX),Period varchar(MAX)
,Debit Decimal(17,2),Credit Decimal(17,2),Comparision varchar(MAX))
 Declare @StartDate date=(select Top 1 JD.PostingDate from Bean.JournalDetail(NoLock) as JD
                                 join  Bean.Journal(NoLock) as J on J.Id=JD.journalId Where j.CompanyId=@CompanyId and JD.PostingDate is not null
                          Order by JD.PostingDate )
     --Declare @StartDate date='1990-01-01'
 
 
----FYE-04/14
--0-- Year
--1-- Semi-Anually
--2-- Quaterly
--3-- Month
  --Select BusinessYearEnd from Common.Localization where CompanyId=@CompanyId

WHILE @SeqNum <= @Frequency and @Frequency <=11
BEGIN
    Insert Into @TABLE_TEST
     SELECT   Case 
     When @Comparision=0 Then Case When @SamePeriod =1 Then case when @FEY>=@Date then DATEADD(year,-@SeqNum,FromDate) ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END ELSE
       DATEADD(YEAR,-@SeqNum, @FEY)  END
              WHEN @Comparision=1 Then Case When @SamePeriod =1 Then case when @FEY>@Date then DATEADD(year,-@SeqNum-1,@FEY)
              When @FEY<=@Date then DATEADD(year,-@SeqNum,@FEY)
              ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END  ELSE DATEADD(MONTH,-@SeqNum * 6, FromDate) End
              When @Comparision=2 Then Case When @SamePeriod =1 Then case when @FEY>@Date then DATEADD(year,-@SeqNum-1,@FEY)
             when @FEY<=@Date then DATEADD(year,-@SeqNum,@FEY)
              ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END  ELSE DATEADD(Q,-@SeqNum, FromDate) End
              WHen @Comparision=3 then Case when @SamePeriod =1 Then case when @FEY>@Date then DATEADD(year,-@SeqNum-1,@FEY)
             when @FEY<=@Date then DATEADD(year,-@SeqNum,@FEY)  ELSE
      DATEADD(YEAR, -@SeqNum, @FEY) END 
                                       ELSE 
                                      DATEADD(MONTH,-@SeqNum, FromDate) END END as 'FromDate' , 



      Case When @Comparision=0 Then Case When @SamePeriod =1 Then /*DATEADD(YEAR, -@SeqNum,@Date)*/
													Case When MONTH(@Date)=2 And (DAY(@Date)=28 Or DAY(@Date)=29) Then EOMONTH(DATEADD(YEAR, -@SeqNum,Dateadd(DAY,-1,@Date)))
														 Else DATEADD(YEAR, -@SeqNum,@Date) End
          								 ELSE Case When @SeqNum=0 then cast(@Date as Date) 
          	     									ELSE /*DATEADD(YEAR,-@SeqNum,DATEADD(D,-1,DATEADD(YEAR,1, FromDate))) */
														DATEADD(D,-1,DATEADD(YEAR,-@SeqNum,DATEADD(YEAR,1, @FEY))) 
												END 
									END
              
           When @Comparision=1 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)  
										 ELSE Case when @SeqNum = 0 then @Date   
													ELSE  EOMonth( DATEADD(MONTH,-@SeqNum * 6,DATEADD(D,-1,DATEADD(M,6,FromDate)))) 
							                  END
									END   --end
    		When @Comparision=2 Then Case When @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)
                                       		ELSE Case When @SeqNum = 0 then @Date 
                                      					ELSE Case When @FYFlag=1 then EOMonth(Dateadd(d,-1,DATEADD(Q,-@SeqNum,DATEADD(M,3,FD)))) 
																	ELSE 
                                                        			--DATEADD(Q,-@SeqNum,DATEADD(D,-1,DATEADD(M,3,FD)))
                                                        			-- DATEADD(D,-1,DATEADD(M,3,FD))
                                                        				Dateadd(d,-1,DATEADD(Q,-@SeqNum,DATEADD(M,3,FromDate)))
                                                         
                                                          	 END
												 END 
									 END
 
            When @Comparision=3 then Case when @SamePeriod =1 Then DATEADD(YEAR, -@SeqNum, @Date)
                                          Else CASE When @SeqNum = 0 then @Date  WHEN day(FD) = 1 THEN EOMONTH(DATEADD(MONTH,-@SeqNum,DATEADD(D,-1, DATEADD(MONTH,1, FromDate)))) 
                                           			ELSE DATEADD(MONTH,-@SeqNum,DATEADD(D,-1, DATEADD(MONTH,1, FromDate))) 
												END 
									 END 
			END as 'ToDate'
     FROM 
         (
          Select Case When @Comparision=0 Then FromDate 
                 When @Comparision=1 Then Case when cast(@Date as Date)  BETWEEN DATEADD(M,-6,FromDate) and dateadd(d,-1,FromDate) then DATEADD(M,-6,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-12,FromDate) and DATEADD(D,-1,DATEADD(M,-6,FromDate)) then dateadd(M,-12,FromDate)
  				 WHEN cast(@Date as Date)  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN FromDate 
 				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,6,FromDate)  END
                 When @Comparision=2 then CASE  WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-3,FromDate) and dateadd(d,-1,FromDate) then DATEADD(M,-3,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-6,FromDate) and dateadd(d,-1,DATEADD(M,-3,FromDate)) then DATEADD(M,-6,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-9,FromDate) and dateadd(d,-1,DATEADD(M,-6,FromDate)) then DATEADD(M,-9,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,-12,FromDate) and dateadd(d,-1,DATEADD(M,-9,FromDate)) then DATEADD(M,-12,FromDate)
				 WHEN cast(@Date as Date)  BETWEEN FromDate AND DATEADD(D,-1,DATEADD(M,3,FromDate)) THEN FromDate 
                 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,3,FromDate) AND DATEADD(D,-1,DATEADD(M,6,FromDate)) THEN DATEADD(M,3,FromDate) 
                 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,6,FromDate) AND DATEADD(D,-1,DATEADD(M,9,FromDate)) THEN DATEADD(M,6,FromDate) 
                 WHEN cast(@Date as Date)  BETWEEN DATEADD(M,9,FromDate) AND DATEADD(D,-1,DATEADD(M,12,FromDate)) THEN DATEADD(M,9,FromDate) END
                 When @Comparision=3 Then CASE WHEN DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) > @Date THEN DATEADD(M,-1,DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate))) 
                 ELSE DATEFROMPARTS(YEAR(@Date), MONTH(@Date), day(FromDate)) END END as 'FromDate',P.FromDate AS FD
           From 
                (
				SELECT Case when dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) <= @Date 
				                /*then dateadd(YEAR, 0, dateadd(day, 1,cast(REPLACE(BusinessYearEnd, '-', ' ') + cast(datepart(year, @Date) as char(4)) as date)))*/
							Then 
								 Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
												dateadd(YEAR,0, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
									  Else dateadd(YEAR, 0, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
								 End
							Else
                				/*dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date))) end*/
								Case When @FY='28-Feb' And ISDATE(CONCAT(YEAR(@Date),'0229'))=1 Then
										dateadd(YEAR, -1, dateadd(day, 2, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
									 Else dateadd(YEAR, -1, dateadd(day, 1, cast(REPLACE(BusinessYearEnd, '-', ' ') +cast(datepart(year, @Date) as char(4)) as date)))
					  End
					End	as FromDate 
                  FROM [Common].[Localization](NoLock) Where CompanyId=@CompanyId
                ) AS P
         ) AS PP
    SET @SeqNum = @SeqNum + 1;
--END
END

    
--SELECT * from @TABLE_TEST
 



Set @Row=1
	While @Row <= @Frequency+1 and @Frequency <=11
	Begin
	select @FromDate=FromDate,@ToDate=ToDate 
		 from 
			 (
	 		    Select ROW_NUMBER()Over(Order By FromDate DESC) as 'Row_No',* from @TABLE_TEST
			  ) AS P
	     Where Row_No=@Row
		-- SET @Row = @Row + 1;

--END

------ RetarnedEarnings-------------		 
INSERT INTO @COAName_New
Select  DENSE_RANK() over(order by [COA Name],@FromDate) , *,@FromDate,@ToDate from 
	(
SELECT  [COA Name],[COA COde],Class,classOrder,Recorder,Case when BaseTotal >= 0 then BaseTotal end as Debit,
            case when BaseTotal < 0 then -BaseTotal end as Credit,DocDate
     FROM 
        (
Select [COA Name],[COA COde],Class,sum(isnull(BaseDebit,0)) BaseDebit,sum(Isnull(BaseCredit,0)) BaseCredit,
	   sum(isnull(BaseDebit,0))-sum(Isnull(BaseCredit,0)) as BaseTotal,classOrder,Recorder,DocDate 
from 
(
Select convert(date,JD.PostingDate) as DocDate,
       COA.Name AS [COA Name],COA.Code AS [COA COde],Coa.Class,'2' AS classOrder,'' AS RecOrder,
       /*case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end*/ JD.BaseDebit BaseDebit,
       /*Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end*/ JD.BaseCredit BaseCredit--,
from Bean.JournalDetail(NoLock) as JD
    join  Bean.Journal(NoLock) as J on J.Id=JD.journalId
    join  Bean.chartOfAccount(NoLock) as COA on COA.Id=JD.COAID
    join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
	Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
 Where COA.CompanyId=@CompanyId  AND COA.Name IN ('Retained earnings') 
 AND J.DocumentState NOT IN ('Void','Recurring') ---->> Added by Ali on 06 May 24 
 --AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
  and   convert(date,JD.PostingDate) Between @StartDate And 
  --convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))
  /*Case When @BusinessYearEnd ='31-Dec' Then convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))  
            When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Else convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))END END*/
			Case When @BusinessYearEnd ='31-Dec' Then convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))  
			When @BusinessYearEnd='28-Feb' Then cast((@FromDate-1) as Date)
            When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) 
			Else convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))END END

  
UNION ALL
Select convert(date,JD.PostingDate) as DocDate,COA.Name AS [COA Name],COA.Code AS [COA COde],Class,'2' AS classOrder,'' AS RecOrder,
       /*case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end*/ JD.BaseDebit BaseDebit,
       /*Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end*/  JD.BaseCredit BaseCredit--,
from Bean.JournalDetail(NoLock) as JD
    join  Bean.Journal(NoLock) as J on J.Id=JD.journalId
    join  Bean.chartOfAccount(NoLock) as COA on COA.Id=JD.COAID
	join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
	Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
Where COA.CompanyId=@CompanyId  AND COA.Name IN ('Retained earnings')
AND J.DocumentState NOT IN ('Void','Recurring') ---->> Added by Ali on 06 May 24
--AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
  and   convert(date,JD.PostingDate) Between  
 -- DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1)))--@FromDate
  /* Case When @BusinessYearEnd ='31-Dec' Then DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) 
            When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)))) Else DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) END END*/
			Case When @BusinessYearEnd ='31-Dec' Then DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) 
            When @BusinessYearEnd='28-Feb' Then cast((@FromDate) as Date)
			When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)))) Else DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) END END

  And @Todate--@ToDate
 UNION ALL

select convert(date,JD.PostingDate) as DocDate,'Retained earnings' AS [COA Name],
	  (Select Distinct COA.Code From 
	             --   Bean.JournalDetail as JD
              --join  Bean.Journal as J on J.Id=JD.journalId
			   Bean.chartOfAccount(NoLock) COA 
			  --ON COA.Id=JD.COAId
			  join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
			  Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
       Where COA.CompanyId=@CompanyId 
	   --AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,',')) 
	   AND COA.Name IN ('Retained earnings') 
      ) AS [COA COde],'Equity' AS Class,'2' AS classOrder,'' AS RecOrder,
        /*case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end*/ JD.BaseDebit BaseDebit,
        /*Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end*/ JD.BaseCredit BaseCredit--,
    from  Bean.JournalDetail(NoLock) as JD
    join  Bean.Journal(NoLock) as J on J.Id=JD.journalId
    join  Bean.chartOfAccount(NoLock) as COA on COA.Id=JD.COAID
    join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
	Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
    where COA.companyId=@CompanyId and COA.ModuleType='Bean' 
	and J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')  ---->> Deleted state Added on '25-04-2023'
    AND COA.Class IN ('Income','Expenses')
	--AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
    and   convert(date,JD.PostingDate) Between  @StartDate And 
	 --convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))
	 /*Case When @BusinessYearEnd ='31-Dec' Then convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))  
            When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Else convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))END END*/
			Case When @BusinessYearEnd ='31-Dec' Then convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))  
			When @BusinessYearEnd='28-Feb' Then cast((@FromDate-1) as Date)
            When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) 
			Else convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))END END

	 UNION ALL

select convert(date,JD.PostingDate) as DocDate,'Profit/Loss' AS [COA Name],
	  --(Select Distinct COA.Code From 
	  --           --   Bean.JournalDetail as JD
   --           --join  Bean.Journal as J on J.Id=JD.journalId
			--   Bean.chartOfAccount COA 
			--  --ON COA.Id=JD.COAId
			--  join  Common.Company As SC on SC.Id=J.ServiceCompanyId
   --    Where COA.CompanyId=@CompanyId 
	  -- AND SC.Name in (select items from dbo.SplitToTable(@ServiceCompany,',')) AND COA.Name IN ('Retained earnings') 
   --   ) AS 
	 '' AS  [COA COde],'Equity' AS Class,'2' AS classOrder,'' AS RecOrder,
        /*case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end*/ JD.BaseDebit BaseDebit,
        /*Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end*/ JD.BaseCredit BaseCredit--,
    from  Bean.JournalDetail(NoLock) as JD
    join  Bean.Journal(NoLock) as J on J.Id=JD.journalId
    join  Bean.chartOfAccount(NoLock) as COA on COA.Id=JD.COAID
    join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
	Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
    where COA.companyId=@CompanyId and COA.ModuleType='Bean' 
	and J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')  ---->> Deleted state Added on '25-04-2023'
    AND COA.Class IN ('Income','Expenses')
	--AND SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
    and   convert(date,JD.PostingDate) Between  
	--DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1)))
	/*Case When @BusinessYearEnd ='31-Dec' Then DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) 
            When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)))) Else DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) END END*/
			Case When @BusinessYearEnd ='31-Dec' Then DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) 
            When @BusinessYearEnd='28-Feb' Then cast((@FromDate) as Date)
			When @BusinessYearEnd <>'31-Dec' Then Case When Cast(@FromDate AS Date)> convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate))) Then 
            DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)))) Else DateAdd(Day,1,convert(date,@BusinessYearEnd+'-'+convert(varchar(50),year( @FromDate)-1))) END END 
	And @ToDate
	 


) AS P
Group BY [COA Name],[COA COde],classOrder,Class,Recorder,DocDate
) IE2

UNION ALL
--Balance Sheet --
	 SELECT [COA Name],[COA COde],Class,classOrder,Recorder,Case when BaseTotal >= 0 then BaseTotal end as Debit,
            case when BaseTotal < 0 then -BaseTotal end as Credit,DocDate
     FROM 
        (
	Select [COA Name],[COA COde],Class,sum(isnull(BaseDebit,0)) BaseDebit,sum(Isnull(BaseCredit,0)) BaseCredit,
		 	    sum(isnull(BaseDebit,0))-sum(Isnull(BaseCredit,0)) as BaseTotal,classOrder,Recorder,DocDate
	From
		(
		 select COa.Name [COA Name],JD.PostingDate As DocDate,COA.Code AS [COA COde],COA.Class,'1' AS classOrder,AT.RecOrder,
				/*case when JD.BaseCurrency=JD.DocCurrency and JD.BaseDebit is null then JD.DocDebit else JD.BaseDebit end*/ JD.BaseDebit BaseDebit,
				/*Case when JD.BaseCurrency=JD.DocCurrency and JD.BaseCredit is null then JD.DocCredit else JD.BaseCredit end*/ JD.BaseCredit BaseCredit
		 from   Bean.JournalDetail(NoLock) as JD
				join  Bean.Journal(NoLock) as J on J.Id=JD.journalId
				join  Bean.chartOfAccount(NoLock) as COA on COA.Id=JD.COAID
				Left Join Bean.AccountType(NoLock) As AT On AT.Id=COA.AccountTypeId And AT.CompanyId=COA.CompanyId
				join  Common.Company(NoLock) As SC on SC.Id=J.ServiceCompanyId
				Join @ServEnt_TBL As Ser On Ser.ServEntity=SC.Id
		 WHERE COA.companyId=@CompanyId and COA.ModuleType='Bean' 
			  -- and SC.Id in (select items from dbo.SplitToTable(@ServiceCompany,','))
			  and J.DocumentState NOT IN ('Void','Cancelled','Parked','Reset','Recurring','Deleted')  ---->> Deleted state Added on '25-04-2023'
			  AND COA.Category='Balance Sheet' AND COA.Name NOT IN ('Retained earnings')--COA.Class IN ('Income','Expenses')
			  and   convert(date,JD.PostingDate) Between  @StartDate And @Todate--@ToDate/*getdate()*/
		 ) BS1
		  GROUP BY [COA Name],[COA COde],classOrder,Recorder,Class,DocDate
		) AS P


--where DocDate between @FromDate and @ToDate 
) AS PP
--where [COA Name]='Trade receivables'
Order By RecOrder

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

			  select * from 
			  (
	       	  select @RowNum as RowNum ,Name,Code,Class,Null [class Order],Null Recorder,0 Debit,0 Credit,@FromDate FromDate,@ToDate ToDate from Bean.chartofaccount(NoLock) as C
	       	  WHere C.Name in (@COA) and CompanyId=@CompanyId
			   Union ALL

			  select * from 
			  (
			   select  @RowNum as RowNum ,'Profit/Loss' Name,'' Code, 'Equity' Class,Null [class Order],Null Recorder,0 Debit,0 Credit,
			   @FromDate FromDate ,@ToDate  ToDate 
			  ) AS KK
			    where Name='Profit/Loss'
				) AS PP
				 WHere Name in (@COA) 

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
	    SELECT [CoA Name],[COA Code],Class,DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 )
		,Debit,Credit,0 as 'Percentage' FROM @TBL
	    where Row_No=@RowNum AND [COA Name] in (@COA)
	
	IF @RowNum >= 2
	  Begin
	  SET @JN =@RowNum -1 ;
	  SET @KN = @RowNum ;
	  --select * from @TBL
		INSERT INTO @TBLN
		SELECT( SELECT DISTINCT [CoA Name] FROM @TBL  WHERE Row_No=@JN and [CoA Name] in ( (@COA))),
			  ( SELECT DISTINCT [COA Code] FROM @TBL  WHERE Row_No=@JN and [COA Name] in (@COA)),
			  ( SELECT DISTINCT [Class] FROM @TBL  WHERE Row_No=@JN and [COA Name] in (@COA)),
			 convert(varchar(50),(select DISTINCT DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 ) 
			 from @TBL Where Row_No=@JN and [COA Name] in (@COA)))+' Vs '+
			 convert(varchar(50),(select  DISTINCT DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 ) 
			 from @TBL Where Row_No=@KN and [COA Name] in (@COA))),0,0,



			 		 		Case When 
		((SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))=0 AND
			(SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) =0)
			
			then NULL 
			When 
		(((SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))>0 AND
			(SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) <= 0))
			Or
			(((SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))<0 AND
			(SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) >0))
			then NULL 

		else
		 Case
			 when
			 	((SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA)) -
			(SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)))=0
			  then '0'
			  Else
			  Case When (((SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@JN  and [COA Name] in (@COA))<0 AND
			(SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA)) <0))
			Then 
			 Cast( Cast(NULLIF (((SELECT DISTINCT ABS(isnull(Debit,0)-Isnull(Credit,0))  FROM @TBL WHERE Row_No = @JN and [COA Name] in (@COA)) -
			(SELECT DISTINCT ABS(isnull(Debit,0)-Isnull(Credit,0))  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA))),0)/
			 NULLIF((SELECT DISTINCT ABS(isnull(Debit,0)-Isnull(Credit,0))  FROM @TBL WHERE Row_No = @KN and [COA Name] in (@COA)),0)*100 as Decimal(17,2))as  Varchar(Max))

			 Else

			 Cast( Cast(NULLIF (((SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No = @JN and [COA Name] in (@COA)) -
			(SELECT DISTINCT isnull(Debit,0)-Isnull(Credit,0)  FROM @TBL WHERE Row_No =@KN  and [COA Name] in (@COA))),0)/
			 NULLIF((SELECT DISTINCT ABS(isnull(Debit,0)-Isnull(Credit,0))  FROM @TBL WHERE Row_No = @KN and [COA Name] in (@COA)),0)*100 as Decimal(17,2))as  Varchar(Max))
			 END
			 end
			 end 

    END
  END
  ELSE If @RowNum =1 
  Begin
	 
	 INSERT INTO @TBLN
	 SELECT [CoA Name],[COA Code],Class,DBO.SmDateFormats(ToDate,(SELECT ShortDateFormat FROM Common.Localization(NoLock) WHERE CompanyId=@CompanyId)) --CONVERT( VARCHAR, ToDate, 103 )
	 ,Debit,Credit,0 as 'Percentage' FROM @TBL
	 where Row_No=@RowNum and [CoA Name] in (@COA)
  END
	SET @RowNum = @RowNum + 1;
 END
   SET @Row_Id = @Row_Id + 1;
END



Declare @NEWFRCoaId uniqueidentifier=  Newid() 
Declare @NEWCOAId bigint = (Select Max(Id)+1  From Bean.ChartOfAccount(NoLock) Where CompanyId=@CompanyId)
Declare @NewFRPATId uniqueidentifier = (Select FRPATId From Bean.ChartOfAccount(NoLock) Where CompanyId=@CompanyId AND Name IN ('Retained earnings') )
-----------////////////////////////------------------
Declare @Temp Table (Rid Int,[COA Name] Nvarchar(500),[COA Code] Nvarchar(500),Class Nvarchar(500),Period Nvarchar(500),Balance Money,Comparision Money,COAID BigInt,Companyid BigInt,CategoryId Nvarchar(500),SubCategoryId Nvarchar(500),FRCoaId Uniqueidentifier,
FRPATId Uniqueidentifier,FRRecOrder Nvarchar(500))

Insert Into @Temp(Rid,[COA Name],[COA Code] ,Class,Period,Balance,Comparision,COAID,Companyid,CategoryId,SubCategoryId ,FRCoaId,
FRPATId,FRRecOrder)
select RId,[COA Name],[COA Code],Class,Period,Balance,Comparision,COAID,Companyid,CategoryId,SubCategoryId,FRCoaId,FRPATId,FRRecOrder

--min(RId)RId,[COA Name],[COA Code],Class,Period,sum(Balance)Balance,Comparision,COAID,Companyid
--,CategoryId,SubCategoryId,FRCoaId,FRPATId,FRRecOrder ,
from 
(

	Select id RId,[COA Name],[COA Code],Class,Period,Case When Class IN ('Liabilities','Equity') then Balance*(-1) 
	Else Balance END As 
		Balance,
		Comparision,COAID,Companyid
		,CategoryId,SubCategoryId,FRCoaId,FRPATId,FRRecOrder
		From
		(
Select P.id,[COA Name],[COA Code],P.Class,Period,Isnull(Debit,0)-Isnull(Credit,0) as 'Balance',Comparision,
		Case when [COA Name] = 'Profit/Loss' AND C.Id is null then @NEWCOAId else C.Id END COAID,p.Companyid,
		C.CategoryId,C.SubCategoryId,case when [COA Name] = 'Profit/Loss' AND C.FRCoaId is null then @NEWFRCoaId else C.FRCoaId END FRCoaId,
		Case when [COA Name] = 'Profit/Loss' AND C.FRPATId is null then @NewFRPATId else C.FRPATId END FRPATId,C.FRRecOrder
		 From 
		(

		SELECT   id,@CompanyId CompanyId,[COA Name],[COA COde],Class,Period,Case when isnull(Debit,0)-isnull(Credit,0) >= 0 then isnull(Debit,0)-isnull(Credit,0) end as Debit,
				case when isnull(Debit,0)-isnull(Credit,0) < 0 then -(isnull(Debit,0)-isnull(Credit,0)) end as Credit,Comparision
		FROM  @TBLN
		)as P
		Left JOIN Bean.ChartOfAccount(NoLock) as C ON C.CompanyId=p.Companyid and p.[COA Name]=Name
		
		) AS KKK 
	
)J
--group by [COA Name],[COA Code],Class,Period,COAID,Companyid
--,CategoryId,SubCategoryId,FRCoaId,FRPATId,FRRecOrder 
Declare @PL Int,
		@RE Int
Select @PL=Min(Rid) From @Temp Where [COA Name]='Profit/Loss'
Select @RE=Min(Rid) From @Temp Where [COA Name]='Retained earnings'
Update @Temp Set Rid=Rid-(@RE-@PL) Where [COA Name]='Retained earnings'
Update @Temp Set Rid=Rid+(@RE-@PL) Where [COA Name]='Profit/Loss'
Select * From @Temp Order by [COA Code],Rid


end

GO
