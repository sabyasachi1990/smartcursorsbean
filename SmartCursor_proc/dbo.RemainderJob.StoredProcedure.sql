USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[RemainderJob]    Script Date: 16-12-2024 9.20.11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
--Alter Table WorkFlow.CASEGroup Add QualityInchargeEmployeeName Nvarchar(250)
--Alter Table WorkFlow.ScheduleDetailNew Add  IsQIIncharge Bit
--exec [dbo].[RemainderJob]
--select * from ClientCursor.Account where Id='8f46a390-8deb-4955-8623-771846028b62'
--select * from ClientCursor.ReminderMaster where ReminderType='AGM' and companyId=1077
--select * from ClientCursor.ReminderDetail where ReminderMasterId='215DB434-C2EF-4F65-B92A-425D52DF429B'
--select * from common.ContactDetails where entityId='8f46a390-8deb-4955-8623-771846028b62'
--[{"key":"Email","value":"Latham@yopmail.com"},{"key":"Mobile","value":"548-555-0129"}]

CREATE procedure [dbo].[RemainderJob]


as 
Begin--1

Declare @AccountCount int
declare @RecCount int 
Declare @Reminders nvarchar(250)
Declare @Reminder1 nvarchar(250)
Declare @ReminderDetailCount int
Declare @RecCount1 int
Declare @ReminderType nvarchar(250)
Declare @Id uniqueIdentifier
Declare @ReminderDate DateTime2(7)
Declare @DetailName nvarchar(250)
Declare @RecurrenceType nvarchar(200)
Declare @Period nvarchar(250)
Declare @OperationSymbol nvarchar(50)
Declare @PeriodValue int
Declare @Date DateTime2(7)
Declare @CompanyId bigint
Declare @AccountId uniqueIdentifier
Declare @Description nvarchar(500)
declare @TemplateId uniqueIdentifier
declare @FinancialYearEnd Datetime2(7)
Declare @IsReminderReceipent bit
Declare @Communication nvarchar(500)
Declare @ReminderReceipient nvarchar(250)
Declare @ContactCommunication nvarchar(500)
Declare @isFromEntityDetails bit
Declare @ReminderDate1 nvarchar(250)
Declare @FinancialYearEnd1 nvarchar(250)
declare @PeriodValue1 nvarchar(250)
Declare @PresentDate1 nvarchar(250)
Declare @FinancialYearEnd2 nvarchar(250)
declare @ContactDetailCount int
declare @ContactDetailRecCount int
BEGIN TRANSACTION--s2
	BEGIN TRY--s3


Create table  #AllAccount_Tbl  (S_No INT Identity(1, 1), Reminders NVARCHAR(200),companyId bigInt,AccountId uniqueIdentifier,FinancialYearEnd DateTime2(7))
Create table  #Reminder_Tbl  (S_No INT Identity(1, 1),name NVARCHAR(200),Id NVARCHAR(200))
Create table  #Contact_Tbl  (S_No INT Identity(1, 1),name NVARCHAR(200),Id NVARCHAR(200))
Create table  #ContactDetail_Tbl  (S_No INT Identity(1, 1),name NVARCHAR(200),Id NVARCHAR(200))
Create table  #ContactDetails_Tbl1  (S_No INT Identity(1, 1),IsRemiderReceipient bit,Communication NVARCHAR(500),ContactCommunication NVARCHAR(500))
create table #ReminderDetail_tbl (S_No INT Identity(1, 1),ReminderType nvarchar(200),Id uniqueIdentifier,ReminderDate DateTime2(7),DetailName nvarchar(250),RecurrenceType nvarchar(200),
Period1 nvarchar(250),OperationSymbol nvarchar(50),PeriodValue int,TemplateId uniqueIdentifier)

INSERT INTO #AllAccount_Tbl
SELECT a.Reminders,a.CompanyId,a.Id,a.FinancialYearEnd
FROM ClientCursor.Account as a (NOLOCK)
where Reminders is not null 
SET @AccountCount = (
		SELECT Count(*)
		FROM #AllAccount_Tbl
		)
SET @RecCount = 1


WHILE @AccountCount >= @RecCount
	BEGIN --2
		SELECT @Reminders=Reminders,@CompanyId=companyId,@AccountId=AccountId,@FinancialYearEnd=FinancialYearEnd
		FROM #AllAccount_Tbl
		WHERE S_No = @RecCount
	
	
	insert into #ContactDetails_Tbl1
	select IsReminderReceipient,cd.Communication,c.Communication from common.ContactDetails as cd (NOLOCK) join common.Contact as c (NOLOCK) on cd.ContactId=c.Id where cd.EntityId in (select AccountId from #AllAccount_Tbl
		WHERE S_No = @RecCount )  and IsReminderReceipient=1

		SET @ContactDetailCount = (
		SELECT Count(*)
		FROM #ContactDetails_Tbl1
		)
SET @ContactDetailRecCount = 1
--set @ReminderReceipient=''

WHILE @ContactDetailCount >= @ContactDetailRecCount
begin--m1
SELECT @IsReminderReceipent=IsRemiderReceipient,@Communication=Communication,@ContactCommunication=ContactCommunication
		FROM #ContactDetails_Tbl1
		WHERE S_No = @ContactDetailRecCount
	--set @IsReminderReceipent =(select @IsReminderReceipent from #ContactDetails_Tbl1
		--WHERE S_No = @ContactDetailRecCount )
		--set @Communication =(select Communication from #ContactDetails_Tbl1
		--WHERE S_No = @ContactDetailRecCount )
		--select @IsReminderReceipent
		--select @Communication
		--select @ContactCommunication

		
		set @isFromEntityDetails =0
		if(@IsReminderReceipent=1 and @Communication is not null)
		begin
		INSERT INTO #Contact_Tbl
		 SELECT *
FROM OPENJSON(@Communication,N'$')
  WITH (
    name NVARCHAR(50) N'$.key',
    Id NVARCHAR(50) N'$.value'    
  );
  set @ReminderReceipient = (select Top 1 Id from #Contact_Tbl where name='Email')
  --select @ReminderReceipient
  if(@ReminderReceipient is not null)
  begin
  set @isFromEntityDetails=1
  end

		end
		if(@isFromEntityDetails=0)
		begin--m2
		--set @ContactCommunication = (select ContactCommunication from #ContactDetails_Tbl1
		--WHERE S_No = @ContactDetailRecCount)
		if(@IsReminderReceipent=1 and @ContactCommunication is not null)
		begin--m3
		--print @ContactCommunication
		print @AccountId
		INSERT INTO #ContactDetail_Tbl
		 SELECT *
FROM OPENJSON(@ContactCommunication,N'$')
  WITH (
    name NVARCHAR(50) N'$.key',
    Id NVARCHAR(50) N'$.value'    
  );
  set @ReminderReceipient = (select Top 1 Id from #ContactDetail_Tbl where name='Email')
  --select @ReminderReceipient
  
		end
		end
		set @ContactDetailRecCount = @ContactDetailRecCount+1
		end
		
		 set @Reminder1 = (select Reminders from #AllAccount_Tbl where S_No=@RecCount)

		 INSERT INTO #Reminder_Tbl
		 SELECT *
FROM OPENJSON(@Reminder1,N'$')
  WITH (
    name NVARCHAR(50) N'$.key',
    Id NVARCHAR(50) N'$.value'    
  );

  insert into #ReminderDetail_tbl 
  select rm.ReminderType,rmd.Id,rmd.RemainderDate,rmd.Name,rmd.RecurranceType,rmd.Period,rmd.OperatorSymbol,rmd.PeriodValue,rmt.TemplateId from ClientCursor.ReminderMaster as rm (NOLOCK)
  join ClientCursor.ReminderDetail as rmd (NOLOCK) on rm.Id = rmd.ReminderMasterId  join ClientCursor.ReminderDetailTemplate as rmt (NOLOCK) on rmd.Id=rmt.ReminderDetailId  
  where rm.ReminderType in (select name from 
  #Reminder_Tbl where Id='true') and CompanyId=@CompanyId and rm.Status=1 
  

  SET @ReminderDetailCount = (
		SELECT Count(*)
		FROM #ReminderDetail_tbl
		)
		--select @ReminderDetailCount
		
		
SET @RecCount1 = 1

WHILE @ReminderDetailCount >= @RecCount1
	BEGIN --3
		SELECT @ReminderType=ReminderType,@Id=Id,@ReminderDate=ReminderDate,@DetailName=DetailName,@RecurrenceType=RecurrenceType,@Period=Period1,@OperationSymbol=OperationSymbol,
		@PeriodValue=PeriodValue,@TemplateId=TemplateId
		FROM #ReminderDetail_tbl
		WHERE S_No = @RecCount1

		Declare @PresentDate Datetime2(7)
		set @PresentDate=CONVERT(VARCHAR(10), getdate(), 111);
		
		if(@RecurrenceType='Calendar')
		Begin--4
		if(@Period='No of Days')
		begin--5
		if(@OperationSymbol='+')
		begin--6
		set @Date=(DATEADD(DAY, @PeriodValue, @ReminderDate))
		end--6
		else

		begin--7
		set @Date=(DATEADD(DAY, (-@PeriodValue), @ReminderDate))
		end--7
		end--5
		else
		begin--8
		if(@OperationSymbol='+')
		begin--9
		set @Date=(DATEADD(MONTH, @PeriodValue, @ReminderDate))
		end--9
		else

		begin--10
		set @Date=(DATEADD(MONTH, (-@PeriodValue), @ReminderDate))
		end--10
		end--8

		

		if(DAY(@Date)=Day(@PresentDate) and Month(@Date)=Month(@PresentDate) and Year(@Date)=Year(@PresentDate))
		Begin--5

		if(@Period='No of Days')
		begin
		if(@RecurrenceType='Calendar')
		begin
		if(@ReminderDate is not null)
		begin
		set @ReminderDate1=(select CONVERT(VARCHAR(250), @ReminderDate, 103));
		set @PeriodValue1 = (Select CONVERT(VARCHAR(250), @PeriodValue))
		set @Description=(''+@RecurrenceType+'('+@ReminderDate1+''+@OperationSymbol+''+@PeriodValue1+' Days)')
		end
		end
		--else
		--begin
		--if(@FinancialYearEnd is not null)
		--begin
		--set @FinancialYearEnd = DAY('+@FinancialYearEnd+')+'/'+MONTH(@FinancialYearEnd)+'/'+Year(@PresentDate)
		--set @Description=(''+@RecurrenceType+'('+@FinancialYearEnd+''+@OperationSymbol+''+@PeriodValue+' Days)')
		--end
		end
	
		
		else
		
		if(@RecurrenceType='Calendar')
		begin
		if(@ReminderDate is not null)
		begin
		set @ReminderDate1=(select CONVERT(VARCHAR(250), @ReminderDate, 103));
		set @PeriodValue1 = (Select CONVERT(VARCHAR(250), @PeriodValue))
		set @Description=(''+@RecurrenceType+'('+@ReminderDate1+''+@OperationSymbol+''+@PeriodValue1+' Months)')
		end
		end
		--else
		--begin
		--if(@FinancialYearEnd is not null)
		--begin
		--set @FinancialYearEnd = DAY('+@FinancialYearEnd+')+'/'+MONTH(@FinancialYearEnd)+'/'+Year(@PresentDate)
		--set @Description=(''+@RecurrenceType+'('+@FinancialYearEnd+''+@OperationSymbol+''+@PeriodValue+' Months)')
		--end
		--end
	
		if Not Exists(select * from Common.ReminderBatchList (NOLOCK) where CompanyId=@CompanyId and AccountId=@AccountId and ReminderType=@ReminderType and Description=@Description and Name=@DetailName)
		Begin
		insert into Common.ReminderBatchList values(NewId(),@CompanyId,@AccountId,@ReminderType,@ReminderReceipient,GETDATE(),@TemplateId,@Description,null,'System',GETDATE(),null,null,1,null,@DetailName)
		end
		end
		end--4
	

	   else if(@RecurrenceType='FYE')
		begin
		if(@FinancialYearEnd is not null)
		Begin--4
		
		if(@Period='No of Days')
		begin--5

		if(@OperationSymbol='+')
		begin--6
		set @Date=(DATEADD(DAY, @PeriodValue, @FinancialYearEnd))
		end--6
		else

		begin--7
		set @Date=(DATEADD(DAY, (-@PeriodValue), @FinancialYearEnd))
		end--7
		end--5
		else
		begin--8
		if(@OperationSymbol='+')
		begin--9
		set @Date=(DATEADD(MONTH, @PeriodValue, @FinancialYearEnd))
		end--9
		else

		begin--10
		set @Date=(DATEADD(MONTH, (-@PeriodValue), @FinancialYearEnd))
		end--10
		end--8

		

		if(DAY(@Date)=Day(@PresentDate) and Month(@Date)=Month(@PresentDate))
		Begin--5

		if(@Period='No of Days')
		
		
		begin
		if(@FinancialYearEnd is not null)
		begin
		set @FinancialYearEnd2 =(select CONVERT (nvarchar(250), @FinancialYearEnd, 103))
		--select @FinancialYearEnd
		
		set @PresentDate1 = (select CONVERT (NVARCHAR(250), @PresentDate1, 103))
		--select @PresentDate1

		--Declare @day nvarchar(250)
		--Declare @month nvarchar(250)
		--Declare @Year nvarchar(250)
		--set @day=DAY(@FinancialYearEnd2)
		--set @month = MONTH(@FinancialYearEnd2)
		--set @Year = Year(@FinancialYearEnd2)
		----set @FinancialYearEnd1 = (''+DAY(@FinancialYearEnd2)+'/'+MONTH(@FinancialYearEnd2)+'/'+Year(@PresentDate1)+'')
		--set @FinancialYearEnd1 = (''+@day+'/'+@month+'/'+@Year+'')
		set @PeriodValue1 = (Select CONVERT(VARCHAR(250), @PeriodValue))
		set @Description=(''+@RecurrenceType+'('+@FinancialYearEnd2+''+@OperationSymbol+''+@PeriodValue1+' Days)')
		
		end
	end
		
		
		
		else
	
		if(@FinancialYearEnd is not null)
		begin
		set @FinancialYearEnd2 = (select CONVERT (NVARCHAR(250), @FinancialYearEnd, 103))
		set @PresentDate1 = (select CONVERT (NVARCHAR(250), @PresentDate, 103))
		--set @day=DAY(@FinancialYearEnd2)
		--set @month = MONTH(@FinancialYearEnd2)
		--set @Year = Year(@FinancialYearEnd2)
		----set @FinancialYearEnd1 = (''+DAY(@FinancialYearEnd2)+'/'+MONTH(@FinancialYearEnd2)+'/'+Year(@PresentDate1)+'')
		--set @FinancialYearEnd1 = (''+@day+'/'+@month+'/'+@Year+'')
		
		
		set @PeriodValue1 = (Select CONVERT(VARCHAR(250), @PeriodValue))
		set @Description=(''+@RecurrenceType+'('+@FinancialYearEnd2+''+@OperationSymbol+''+@PeriodValue1+' Months)')
		--select @Description
		end
		if Not Exists(select * from Common.ReminderBatchList (NOLOCK) where CompanyId=@CompanyId and AccountId=@AccountId and ReminderType=@ReminderType and Description=@Description and Name=@DetailName)
		Begin
		insert into Common.ReminderBatchList values(NewId(),@CompanyId,@AccountId,@ReminderType,@ReminderReceipient,GETDATE(),@TemplateId,@Description,null,'System',GETDATE(),null,null,1,null,@DetailName)
		end
		end
		end--4
		end
		SET @RecCount1 = @RecCount1 + 1
		end--3
		set @RecCount=@RecCount+1
		truncate table #ReminderDetail_tbl
		truncate table #Reminder_Tbl
		truncate table #Contact_Tbl
		truncate table #ContactDetail_Tbl
		truncate table #ContactDetails_Tbl1

		end--2

		IF OBJECT_ID(N'tempdb..#AllAccount_Tbl') IS NOT NULL
BEGIN
DROP TABLE #AllAccount_Tbl
END

Commit Transaction--s2
	End try --s3
	Begin Catch
	ROLLBACK TRANSACTION
		DECLARE
				@ErrorMessage NVARCHAR(4000),
				@ErrorSeverity INT,
				@ErrorState INT;
		SELECT
				@ErrorMessage = ERROR_MESSAGE(),
				@ErrorSeverity = ERROR_SEVERITY(),
				@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
	End Catch
	end--1





		


		

		





  
GO
