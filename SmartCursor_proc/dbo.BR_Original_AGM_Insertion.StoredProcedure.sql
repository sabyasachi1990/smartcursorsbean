USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_Original_AGM_Insertion]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE Proc [dbo].[BR_Original_AGM_Insertion] @companyId bigint,@entityId uniqueidentifier,@fillingAGMId uniqueidentifier,@agmId uniqueidentifier, @userName nvarchar(Max),@isagmupdate bit
as
 
  If Exists (select Id from Boardroom.AGMFillingChanges where Id=@fillingAGMId)
    Begin
	   Declare @type nvarchar(20),@agmdueDateorsec175 Datetime2(7),@ardueDateorsec197 Datetime2(7),@agmDate DateTime2(7),@arDate DateTime2(7),@fyeDate DateTime2(7),@incorporationDate Datetime2(7),
	   @Existingentity nvarchar(100),@day nvarchar(20),@month nvarchar(30),@year nvarchar(30)
	   declare @FyeDateNew Datetime2(7)=(Select FyeDate from Boardroom.AGMFillingChanges where  Id=@fillingAGMId)
	  Begin
		
	   if( @agmId = (SELECT CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)) ) --FirstAGM Calculation
		   Begin
		    Declare @agmfillingChangestemp table (AGMDate DateTime2(7),ARDate DateTime2(7),AGMDueDateorSec175 DateTime2(7),ARDueDateorSec197 Nvarchar(30))
		    Insert into @agmfillingChangestemp(AGMDate,ARDate,AGMDueDateorSec175,ARDueDateorSec197) 
		    Select ProposedDateofAGM,ProposedDateofAR,CurrentAGMDueDate,CurrentARDueDate from Boardroom.AGMFillingChanges where  Id=@fillingAGMId
		    Set @agmDate=(select AGMDate from @agmfillingChangestemp)
		    Set @arDate=(select ARDate from @agmfillingChangestemp)
		    Set @incorporationDate=(select IncorporationDate from Common.EntityDetail where Id=@entityId)
		    Set @fyeDate=(select FyeDate from Boardroom.AGMFillingChanges where id=@fillingAGMId)
			
			Set @agmdueDateorsec175=(Select AGMDueDateorSec175 from @agmfillingChangestemp)
		    Set @ardueDateorsec197=(Select ARDueDateorSec197 from @agmfillingChangestemp)
			set @Existingentity=(select ExistingCompany from Common.EntityDetail where Id=@entityId)
			Set @agmId  = NewId()
			set @day=(Right('0'+Cast(Day(Cast(@fyeDate As date)) As varchar),2))
			set @month=(Left(DateName(month,@fyeDate),3))
			set @year=(SELECT CAST(Year(@fyeDate)as nvarchar(30)))
			Update Boardroom.AGMFillingChanges set AGMId=@agmId where (Id=@fillingAGMId OR FyeDate=@FyeDateNew)
		    
			Insert Boardroom.BRAGM ([Id],[CompanyId],[EntityId],[FirstAGM],[IsFirst],[Section175],[Section197],[FYE],[IsDisable],[AGMDate],[ARDate],[IncorporationDate],[UserCreated],[CreatedDate],[Day],[Month],[Year],[Status])
		    Values(@agmId,@companyId,@entityId,'Yes',1,@agmdueDateorsec175,@ardueDateorsec197,@fyeDate,1,@agmDate,@arDate,@incorporationDate,@userName,GETUTCDATE(),@day,@month,@year,1)
		     
			set @year=(SELECT CAST(Year(@fyeDate) as nvarchar(30)))
			Update  Common.EntityDetail set  FYEYear =@year where Id=@entityId
		   IF Exists(select Id from Boardroom.BRAGM where Id=@agmId and AGMDate Is not Null)
			 Begin 
			  Exec [dbo].[BR_SecondAGM_Calculation] @agmId,@entityId,@agmDate,@arDate,@userName,0   
			End
		   End
		
		 Else
		  Begin
		  
		   Set @agmDate=(select ProposedDateofAGM from Boardroom.AGMFillingChanges where AGMId=@agmId and Id=@fillingAGMId)
		   Set @arDate=(select ProposedDateofAR from Boardroom.AGMFillingChanges where AGMId=@agmId  and Id=@fillingAGMId)
		   
		   Exec [dbo].[BR_SecondAGM_Calculation] @agmId,@entityId,@agmDate,@arDate,@userName,@isagmupdate	 
		  End
		 

	End
End

      
GO
