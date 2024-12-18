USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Audit_Blade1]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Audit_Blade1] (@engagementId uniqueidentifier,@accountName Nvarchar(256))
AS BEGIN

declare @amount  decimal(17,2);
declare @gldate  Nvarchar(50);
declare @cyamount decimal(17,2);
declare @pyamount decimal(17,2);
declare @addcyamount decimal(17,2)=0;
declare @addpyamount decimal(17,2)=0;
declare @monthNumber int;
declare @gldates table (monthno int,gldate Nvarchar(100));
declare @optable table (AccountName nvarchar(256),Cybalance decimal(17,2),PyBalance decimal(17,2),GLDate nvarchar(50));
           

 INSERT into @gldates
 select distinct MONTH(GLD.GLDate) , datename(month,GLD.GLDate)  AS GlDates
  -- Left(datename(MONTH, gld.GLDate),3)+'-'+Right(Year(gld.GLDate),2) as MonthYear,Year( gld.GLDate) as 'Year' ,Month( gld.GLDate) as 'Month'
  from Audit.GeneralLedgerImport GL 
 join  Audit.GeneralLedgerDetail GLD  on GL.Id= GLD.GeneralLedgerId
 where GL.EngagementId =@engagementId and GL.AccountName=@accountName order by MONTH(GLD.GLDate)
   --outer cursor for loop users
   DECLARE  SaveUserAdmin CURSOR FOR SELECT * FROM @gldates
   OPEN SaveUserAdmin
   FETCH NEXT FROM SaveUserAdmin INTO @monthNumber,@gldate
   WHILE @@FETCH_STATUS >= 0
   BEGIN
    set @cyamount  =@addcyamount+ (select  ISNULL(sum(GLD.Debit-GLD.Credit), 0) from Audit.GeneralLedgerImport GL 
    join  Audit.GeneralLedgerDetail GLD  on GL.Id= GLD.GeneralLedgerId
    where GL.GLType='CY' and    GL.EngagementId = @engagementId and GL.AccountName=@accountName   and MONTH(GLD.GLDate) =@monthNumber);
    set @addcyamount=@cyamount;

    set @pyamount  = @addpyamount+(select  ISNULL(sum(GLD.Debit-GLD.Credit), 0) from Audit.GeneralLedgerImport GL 
    join  Audit.GeneralLedgerDetail GLD  on GL.Id= GLD.GeneralLedgerId
    where GL.GLType='PY' and    GL.EngagementId = @engagementId and GL.AccountName=@accountName   and MONTH(GLD.GLDate) =@monthNumber);
    set @addpyamount=@pyamount;

    insert into  @optable values 
    (@accountName,@cyamount,@pyamount,@gldate)
    FETCH NEXT FROM SaveUserAdmin INTO  @monthNumber,@gldate
   END
   CLOSE SaveUserAdmin
   DEALLOCATE SaveUserAdmin
  

--SELECT * FROM @optable  

--SELECT Name,Value,Left(datename(MONTH,GLDate),3)+'-'+Right(Year(GLDate),2) as MonthYear
--SELECT Name,Value,substring(datename(MONTH,GLDate),3) as MonthYear
--SELECT Name,Value,substring (GLDate,0,3) as MonthYear
SELECT Name,Value,GLDate as MonthYear
 FROM @optable  

Unpivot
(
  Value for Name in (Cybalance,PyBalance)
  )as Piv  
END
GO
