USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[AuditAmount]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AuditAmount] (@engagementId uniqueidentifier,@accountName Nvarchar(256))
AS BEGIN

declare @amount  decimal(17,2);
declare @gldate  date;
declare @cyamount decimal(17,2);
declare @pyamount decimal(17,2);
declare @addcyamount decimal(17,2)=0;
declare @addpyamount decimal(17,2)=0;
declare @gldates table (gldate Datetime);
declare @optable table (AccountName nvarchar(256),Cybalance decimal(17,2),PyBalance decimal(17,2),GLDate date);
           

 INSERT into @gldates
 select distinct DATEADD(MONTH, DATEDIFF(MONTH, 0, GLD.GLDate), 0) AS GlDates
  -- Left(datename(MONTH, gld.GLDate),3)+'-'+Right(Year(gld.GLDate),2) as MonthYear,Year( gld.GLDate) as 'Year' ,Month( gld.GLDate) as 'Month'
  from Audit.GeneralLedgerImport GL 
 join  Audit.GeneralLedgerDetail GLD  on GL.Id= GLD.GeneralLedgerId
 where GL.EngagementId = @engagementId and GL.AccountName=@accountName 
   --outer cursor for loop users
   DECLARE  SaveUserAdmin CURSOR FOR SELECT * FROM @gldates
   OPEN SaveUserAdmin
   FETCH NEXT FROM SaveUserAdmin INTO @gldate
   WHILE @@FETCH_STATUS >= 0
   BEGIN
    set @cyamount  =@addcyamount+ (select  ISNULL(sum(GLD.Debit-GLD.Credit), 0) from Audit.GeneralLedgerImport GL 
    join  Audit.GeneralLedgerDetail GLD  on GL.Id= GLD.GeneralLedgerId
    where GL.GLType='CY' and    GL.EngagementId = @engagementId and GL.AccountName=@accountName   and DATEADD(MONTH, DATEDIFF(MONTH, 0, GLD.GLDate), 0) =DATEADD(MONTH, DATEDIFF(MONTH, 0, @gldate), 0))
    set @addcyamount=@cyamount;
    set @pyamount  = @addpyamount+(select  ISNULL(sum(GLD.Debit-GLD.Credit), 0) from Audit.GeneralLedgerImport GL 
    join  Audit.GeneralLedgerDetail GLD  on GL.Id= GLD.GeneralLedgerId
    where GL.GLType='PY' and    GL.EngagementId = @engagementId and GL.AccountName=@accountName   and DATEADD(MONTH, DATEDIFF(MONTH, 0, GLD.GLDate), 0) =DATEADD(MONTH, DATEDIFF(MONTH, 0, @gldate), 0))
    set @addpyamount=@pyamount;
    insert into  @optable values 
    (@accountName,@cyamount,@pyamount,@gldate)
    FETCH NEXT FROM SaveUserAdmin INTO @gldate
   END
   CLOSE SaveUserAdmin
   DEALLOCATE SaveUserAdmin
  

--SELECT * FROM @optable  

SELECT Name,Value,Left(datename(MONTH,GLDate),3)+'-'+Right(Year(GLDate),2) as MonthYear
 FROM @optable  

Unpivot
(
  Value for Name in (Cybalance,PyBalance)
  )as Piv
END
GO
