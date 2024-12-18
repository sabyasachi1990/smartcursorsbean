USE [SmartCursorSTG]
GO
/****** Object:  StoredProcedure [dbo].[Common_WorkFlow_AutoNumber_Gen]    Script Date: 16-12-2024 9.20.10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[Common_WorkFlow_AutoNumber_Gen]
(
@CompanyId BigInt,
@EntityType NVARCHAR(100),
@CursorName NVARCHAR(80), 
@ServiceGroup NVARCHAR(100), 
@Service NVARCHAR(100), 
@CC_Auto_No_Gen  Nvarchar(400) output
)

AS
BEGIN
         Declare @AutoTemp Table(Id UniqueIdentifier,CompanyId BigInt,ModuleMasterId BigInt,EntityType Nvarchar(100),Format Nvarchar(100),GeneratedNumber Nvarchar(100),CLength Int,StartNumber bigint,Reset Nvarchar(40),Preview NvarChar(100))
         Declare @modulemasterId BigInt,  
         @generatedNumber Nvarchar(50),  
         @format Nvarchar(100),  
         @LastAutoNo Nvarchar(50),  
         @AutoNumberType NvarChar(80)
BEGIN TRY  
         Select @modulemasterId=m.Id from Common.ModuleMaster as m where Name=@CursorName and CompanyId=0  
         IF EXISTS(Select top(1) Id from Common.AutoNumber where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType)
         BEGIN--If AutoNumber is Exist  
         Insert Into @AutoTemp Select Id,CompanyId,ModuleMasterId,EntityType,Format,GeneratedNumber,CounterLength,StartNumber,Reset,Preview from Common.AutoNumber where CompanyId=@CompanyId and ModuleMasterId=@modulemasterId and EntityType=@EntityType
         Set @AutoNumberType=@EntityType;  
        If(@CursorName='Workflow Cursor')
             Begin
             Set @LastAutoNo=(select [dbo].[Common_GetLastAutoNo](@CompanyId,@CursorName,@EntityType,@modulemasterId))  
        If(@EntityType='Workflow Invoice' OR @EntityType='Workflow Client')
           Begin
           Select @format=a.Format from @AutoTemp as a  
           IF(@format Like '%{MM/YYYY}%')  
		   Begin--If contains the Month with Year Format  
             Update Common.AutoNumber SET GeneratedNumber=(@LastAutoNo+1) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  		    
		   select @CC_Auto_No_Gen=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As  varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(@LastAutoNo+1)) + cast (@LastAutoNo+1 as varchar) from  @AutoTemp as t  
	       END--End of Month format  
           ELSE IF(@format Like '%{YYYY}%')         --if year contains  
           BEGIN  
	   	    Update Common.AutoNumber SET GeneratedNumber=(@LastAutoNo+1) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
            select @CC_Auto_No_Gen=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(@LastAutoNo+1)) + cast (@LastAutoNo+1 as varchar) from @AutoTemp as t  
           End --YYY format ends 
		Else
		   Begin
			Update Common.AutoNumber SET GeneratedNumber=(@LastAutoNo+1) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
		    select @CC_Auto_No_Gen=t.Format  + replicate('0', t.CLength - len(@LastAutoNo+1)) + cast (@LastAutoNo+1 as varchar) from @AutoTemp as t  
		   End
        End--workflow Invoice ends

        If(@EntityType='WorkFlow Case') 
		BEGIN
        Select @format=a.Format from @AutoTemp as a  
        IF(@format Like '%{MM/YYYY}%')  
        BEGIN--If contains the Month with Year Format  
  	     Update Common.AutoNumber SET GeneratedNumber=(@LastAutoNo+1) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  		    
         select @CC_Auto_No_Gen=REPLACE(t.Format,'{MM/YYYY}',Concat(RIGHT('0'+Cast(Month(GETUTCDATE()) As  varchar),2),'/',YEAR(GETUTCDATE()))) + replicate('0', t.CLength - len(@LastAutoNo+1)) + cast (@LastAutoNo+1 as varchar) from  @AutoTemp as t  
			    IF(@format Like '%{SERVICE}%')
				   BEGIN
	               select @CC_Auto_No_Gen=REPLACE(@CC_Auto_No_Gen,'{SERVICE}',@Service) from @AutoTemp as t  
				   End
			    If(@format Like '%{SERVICEGROUP}%')
				   BEGIN
				   select @CC_Auto_No_Gen=REPLACE(@CC_Auto_No_Gen,'{SERVICEGROUP}',@ServiceGroup) from @AutoTemp as t  
				   End
	      
        End--End of Month format  
        ELSE IF(@format Like '%{YYYY}%')     --if year contains  
        BEGIN  
	   	 Update Common.AutoNumber SET GeneratedNumber=(@LastAutoNo+1) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
		 select @CC_Auto_No_Gen=REPLACE(t.Format,'{YYYY}',YEAR(GETUTCDATE()))  + replicate('0', t.CLength - len(@LastAutoNo+1)) + cast (@LastAutoNo+1 as varchar) from @AutoTemp as t 
		        IF(@format Like '%{SERVICE}%')
				  BEGIN
				  select @CC_Auto_No_Gen=REPLACE(@CC_Auto_No_Gen,'{SERVICE}',@Service) from @AutoTemp as t  
				  End
		        If(@format Like '%{SERVICEGROUP}%')
				  BEGIN
				  select @CC_Auto_No_Gen=REPLACE(@CC_Auto_No_Gen,'{SERVICEGROUP}',@ServiceGroup) from @AutoTemp as t  
				  End
                  End --YYY format ends 
		  Else 
		  BEGIN
		  Update Common.AutoNumber SET GeneratedNumber=(@LastAutoNo+1) where CompanyId=@CompanyId and EntityType=@AutoNumberType and ModuleMasterId=@modulemasterId  
		  select @CC_Auto_No_Gen=t.Format + replicate('0', t.CLength - len(@LastAutoNo+1)) + cast (@LastAutoNo+1 as varchar) from @AutoTemp as t  
		  IF(@format Like '%{SERVICE}%')
				 BEGIN
				 select @CC_Auto_No_Gen=REPLACE(@CC_Auto_No_Gen,'{SERVICE}',@Service) from @AutoTemp as t  
				 End
		  If(@format Like '%{SERVICEGROUP}%')
				 BEGIN
				 select @CC_Auto_No_Gen=REPLACE(@CC_Auto_No_Gen,'{SERVICEGROUP}',@ServiceGroup) from @AutoTemp as t  
				 End
				 End
       End --workflow Case Ends
	   End
	   End
  END TRY  
  BEGIN CATCH  
  END CATCH  
  select @CC_Auto_No_Gen;
END
GO
