USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_AGM_Remider_Due]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[BR_AGM_Remider_Due] --- exec  [dbo].[BR_AGM_Remider_Due]
AS
Begin
 IF Exists (Select Id from Boardroom.BRAGM where EntityId in (Select Id from Common.EntityDetail where State='Active') and AGMDate is not null)
 Begin
   declare  @companyId bigint,@entityId uniqueidentifier,@duration nvarchar(25),@calculationbasedon nvarchar(100),@period bigint,@agmId uniqueidentifier,@reminderId  uniqueidentifier,
   @reminderDate smallDateTime,@genericTemplateId uniqueidentifier
   Declare reminderDue cursor for 
     Select AGMAndAR.CompanyId,Ed.Id as EntityId,AGMAndAR.Duration,AGMAndAR.CalculationBasedOn,Convert(bigint,Concat(AGMAndAR.Operator,AGMAndAR.Period)) as AgmAndArCalculation,
     agm.Id as AGMId,AGMAndAR.Id,AGMAndAR.TemplateId from Common.EntityDetail as ED join
     Boardroom.AGMAndARReminders as AGMAndAR on Ed.CompanyId=AGMAndAR.CompanyId join Boardroom.BRAGM as agm on Ed.Id=agm.EntityId where Ed.State='Active' and agm.AGMDate is null and  AGMAndAR.Status=1 and AGMAndAR.TemplateId is not null 
     OPEN reminderDue 
     FETCH NEXT FROM reminderDue into @companyId,@entityId,@duration,@calculationbasedon,@period,@agmId,@reminderId,@genericTemplateId
     WHILE @@FETCH_STATUS = 0
      BEGIN
	 
	       IF Exists(select Id from Boardroom.BRAGM where Id=@agmId)
	        Begin
	      IF(@calculationbasedon='AGM Due Date')
	        Begin
	 	      IF(@duration='Days')
	 	         Begin
	              SET @reminderDate=(select DATEADD(Day,@period,(select Section175 from Boardroom.BRAGM where Id=@agmId)))
	 	         End
	 	      IF(@duration='Months')
	 	        Begin
	 	           SET @reminderDate=(select DATEADD(MONTH,@period,(select Section175 from Boardroom.BRAGM where Id=@agmId)))
	 	        End
	 	      IF(@duration='Years')
	 	        Begin
	  	         SET @reminderDate=(select DATEADD(YEAR,@period,(select Section175 from Boardroom.BRAGM where Id=@agmId)))
	  	        End
		    End	
			ELSE IF(@calculationbasedon='AR Due Date')
	           Begin
	 	         IF(@duration='Days')
	 	            Begin
	                 SET @reminderDate=(select DATEADD(Day,@period,(select Section197 from Boardroom.BRAGM where Id=@agmId)))
	 	            End
	 	         IF(@duration='Months')
	 	           Begin
	 	              SET @reminderDate=(select DATEADD(MONTH,@period,(select Section197 from Boardroom.BRAGM where Id=@agmId)))
	 	           End
	 	         IF(@duration='Years')
	 	           Begin
	  	            SET @reminderDate=(select DATEADD(YEAR,@period,(select Section197 from Boardroom.BRAGM where Id=@agmId)))
	  	           End
		       End
			 ELSE IF(@calculationbasedon='FYE Date')
			   BEGIN
			     IF(@duration='Days')
	 	            Begin
	                 SET @reminderDate=(select DATEADD(Day,@period,(select FYE from Boardroom.BRAGM where Id=@agmId)))
	 	            End
	 	         IF(@duration='Months')
	 	           Begin
	 	              SET @reminderDate=(select DATEADD(MONTH,@period,(select FYE from Boardroom.BRAGM where Id=@agmId)))
	 	           End
	 	         IF(@duration='Years')
	 	           Begin
	  	            SET @reminderDate=(select DATEADD(YEAR,@period,(select FYE from Boardroom.BRAGM where Id=@agmId)))
	  	           End


			   END


		  IF(Convert(date,@reminderDate)=Convert(date,GETDATE()))
		    Begin
			    If Not Exists ( select id from Boardroom.Remindersent where EntityId=@entityId and  AGMId=@agmId and ReminderId=@reminderId and CompanyId=@companyId and    ReminderDate=@reminderDate )
			    begin 
			       Insert Boardroom.Remindersent (Id,CompanyId,EntityId,AGMId,ReminderDate,ReminderId,ReminderType,AGMDueDate,ARDueDate,FYEDate,GenericTemplateId) 
			       values(NEWID(),@companyId,@entityId,@agmId,@reminderDate,@reminderId,'Due',(Select Section175 from Boardroom.BRAGM where Id=@agmId),
				   (Select Section197 from Boardroom.BRAGM where Id=@agmId),(Select FYE from Boardroom.BRAGM where Id=@agmId),@genericTemplateId)
			    end 
		    End

	   END
	   
	   FETCH NEXT FROM reminderDue into @companyId,@entityId,@duration,@calculationbasedon,@period,@agmId,@reminderId,@genericTemplateId
	   End
	   END
	   End

GO
