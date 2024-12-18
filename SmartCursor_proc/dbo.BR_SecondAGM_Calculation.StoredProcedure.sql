USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[BR_SecondAGM_Calculation]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Proc [dbo].[BR_SecondAGM_Calculation] @agmId uniqueidentifier, @entityId uniqueidentifier,@agmDate Datetime2(7),@arDate Datetime2(7),@userName nvarchar(Max),@isagmupdate bit
as
 
  If Exists (Select Id from Boardroom.BRAGM where Id=@agmId)
    Begin
	   Declare @previusagmDate DateTime2(7)
	   Declare @agmDetailTemp table (Name Nvarchar(50),Duration Nvarchar(10),DaysOrMonths Nvarchar(20),Type Nvarchar(30))
	   Declare @fyeDate DateTime2(7) ,@type nvarchar(20),@section175 Datetime2(7),@section197 Datetime2(7),@duration nvarchar(10),@DaysOrMonths nvarchar(5)
	   Set @previusagmDate = (Select LastAGM from Boardroom.BRAGM where LastAGM=(Select AGMDate from Boardroom.BRAGM where Id=@agmId) and EntityId=@entityId)
	   If ( @isagmupdate=0 And @previusagmDate is null)
	       Begin
		   Print @agmDate
		      SET @fyeDate=  DateAdd(Year,1, (select Concat(CurrentFYE,' ',FyeYear) from Common.EntityDetail where Id=@entityId))
		        Insert into @agmDetailTemp(Name,Duration,DaysOrMonths,Type) 
			     Select Name,Duration,DaysOrMonths,Type from Boardroom.AGMDetail where  AGMId=(Select Id from Boardroom.AGM where CompanyType='Local Company')
				 Declare agm cursor for Select Type,Duration,DaysOrMonths from @agmDetailTemp 
				
                  Open agm
                         FETCH NEXT FROM agm into @type,@duration,@DaysOrMonths
						 
                      WHILE @@FETCH_STATUS = 0
					  BEgin
					       IF(@type='AGM')
					       Begin
							 If(@duration='Days')
							   SET @section175= DateAdd(DAY,Convert(int,@DaysOrMonths),@fyeDate)
							 If(@duration='Months')
							   SET @section175=DATEADD(MONTH,Convert(int,@DaysOrMonths),@fyeDate)
							 If(@duration='Years')
							   SET @section175=DATEADD(YEAR,Convert(int,@DaysOrMonths),@fyeDate)
						     End
						  else
						    Begin
							 If(@duration='Days')
							   SET @section197= DateAdd(DAY,Convert(int,@DaysOrMonths),@fyeDate)
							 If(@duration='Months')
							   SET @section197=DATEADD(MONTH,Convert(int,@DaysOrMonths),@fyeDate)
							 If(@duration='Years')
							   SET @section197=DATEADD(YEAR,Convert(int,@DaysOrMonths),@fyeDate)
						     End
				       FETCH NEXT FROM agm into @type,@duration,@DaysOrMonths
                    END
                 Close agm
                 DEALLOCATE  agm
				 Update Boardroom.BRAGM set AGMDate=@agmDate,ARDate=@arDate,IsDisable=1,ModifiedBy=@userName,ModifiedDate=GETUTCDATE() where Id=@agmId
				
				
				Insert Boardroom.BRAGM ([Id],[CompanyId],[EntityId],[FirstAGM],[IsFirst],[Section175],[Section197],[FYE],[IsDisable],[LastAGM],[IncorporationDate],[UserCreated],[CreatedDate],[Day],[Month],[Year],[Status])
				 Values(NEWID(),(select CompanyId from Boardroom.BRAGM where Id=@agmId),(select EntityId from Boardroom.BRAGM where Id=@agmId),'No',0,@section175,@section197,@fyeDate,0,(select AGMDate from Boardroom.BRAGM where Id=@agmId),(select IncorporationDate from Boardroom.BRAGM where Id=@agmId),'System',GETUTCDATE(),
				  (Right('0'+Cast(Day(Cast(@fyeDate As date)) As varchar),2)),(Left(DateName(month,@fyeDate),3)),(SELECT CAST(Year(@fyeDate)as nvarchar(30))),1)

		    
			Update  Common.EntityDetail set  FYEYear =Cast((Year(@fyeDate))as Nvarchar(20)) where Id=@entityId
		   End
		   
       Else
	   
	     Begin
		 
		  Declare @lastagmid uniqueidentifier
		  --Set @lastagmid=(Select Id from Boardroom.BRAGM where FYE =(Select DateAdd(Year,1,FYE) from Boardroom.BRAGM where Id in (@agmId)) and EntityId=@entityId)
		  Set @lastagmid=(Select Top 1  Id from Boardroom.BRAGM where Id not in (@agmId) and EntityId=@entityId and Year > (select Year from Boardroom.BRAGM where Id=@agmId)   Order by CreatedDate)
		  Update Boardroom.BRAGM set LastAGM= @agmDate where Id=@lastagmid
		  Update Boardroom.BRAGM set AGMDate=@agmDate,ARDate=@arDate where Id=@agmId
		  
		 End

		End
GO
